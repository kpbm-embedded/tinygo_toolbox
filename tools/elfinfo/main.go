// elfinfo: artifact checks for the tinygo-box examples and templates (no board needed).
//
//	elfinfo elf FILE [-machine arm|riscv|xtensa] [-region ORIGIN:LEN ...] [-sym NAME ...]
//	elfinfo uf2 FILE -family 0xHEX
//	elfinfo esp FILE [-chip esp32|esp32c3|esp32s3]
//	elfinfo wasm FILE [-export NAME ...] [-import MODULE ...]
//
// Prints what it found and exits 1 on the first failed check (2 on usage errors).
package main

import (
	"bytes"
	"debug/elf"
	"encoding/binary"
	"flag"
	"fmt"
	"os"
	"strconv"
	"strings"
)

type list []string

func (l *list) String() string     { return strings.Join(*l, ",") }
func (l *list) Set(v string) error { *l = append(*l, v); return nil }

func fail(f string, a ...any) { fmt.Printf("FAIL: "+f+"\n", a...); os.Exit(1) }

func num(s string) uint64 {
	m := uint64(1)
	switch {
	case strings.HasSuffix(s, "K"):
		m, s = 1024, strings.TrimSuffix(s, "K")
	case strings.HasSuffix(s, "M"):
		m, s = 1024*1024, strings.TrimSuffix(s, "M")
	}
	v, err := strconv.ParseUint(s, 0, 64)
	if err != nil {
		fmt.Println("usage: bad number", s)
		os.Exit(2)
	}
	return v * m
}

func main() {
	if len(os.Args) < 3 {
		fmt.Println("usage: elfinfo elf|uf2|esp|wasm FILE [options]")
		os.Exit(2)
	}
	mode, file := os.Args[1], os.Args[2]
	fs := flag.NewFlagSet(mode, flag.ExitOnError)
	var regions, syms, exports, imports list
	machine := fs.String("machine", "", "expected ELF machine: arm, riscv, xtensa")
	family := fs.String("family", "", "expected UF2 family id")
	chip := fs.String("chip", "", "expected ESP chip")
	fs.Var(&regions, "region", "ORIGIN:LEN memory region (repeatable)")
	fs.Var(&syms, "sym", "symbol that must exist (repeatable)")
	fs.Var(&exports, "export", "wasm export that must exist (repeatable)")
	fs.Var(&imports, "import", "wasm import module that must exist (repeatable)")
	_ = fs.Parse(os.Args[3:])
	data, err := os.ReadFile(file)
	if err != nil {
		fail("%v", err)
	}
	switch mode {
	case "elf":
		checkELF(file, *machine, regions, syms)
	case "uf2":
		checkUF2(data, num(*family))
	case "esp":
		checkESP(data, *chip)
	case "wasm":
		checkWasm(data, exports, imports)
	default:
		fmt.Println("usage: unknown mode", mode)
		os.Exit(2)
	}
	fmt.Println("ok", mode, file)
}

func checkELF(file, machine string, regions, syms []string) {
	f, err := elf.Open(file)
	if err != nil {
		fail("%v", err)
	}
	want := map[string]elf.Machine{"arm": elf.EM_ARM, "riscv": elf.EM_RISCV, "xtensa": elf.Machine(94)}
	fmt.Printf("machine %v, entry 0x%x\n", f.Machine, f.Entry)
	if machine != "" && f.Machine != want[machine] {
		fail("machine %v, want %s", f.Machine, machine)
	}
	in := func(a, n uint64) bool {
		for _, r := range regions {
			o, l, _ := strings.Cut(r, ":")
			if a >= num(o) && a+n <= num(o)+num(l) {
				return true
			}
		}
		return len(regions) == 0
	}
	for _, sec := range f.Sections { // every allocated section must sit inside one of the regions
		if sec.Flags&elf.SHF_ALLOC == 0 || sec.Size == 0 {
			continue
		}
		fmt.Printf("section %-20s 0x%08x %7d\n", sec.Name, sec.Addr, sec.Size)
		if !in(sec.Addr, sec.Size) {
			fail("section %s at 0x%x (+%d) is outside the regions %v", sec.Name, sec.Addr, sec.Size, regions)
		}
	}
	if len(syms) > 0 {
		all, err := f.Symbols()
		if err != nil {
			fail("no symbols: %v", err)
		}
		have := map[string]bool{}
		for _, s := range all {
			have[s.Name] = true
		}
		for _, s := range syms {
			if !have[s] {
				fail("symbol %s missing", s)
			}
			fmt.Println("symbol", s)
		}
	}
}

func checkUF2(d []byte, family uint64) {
	if len(d) == 0 || len(d)%512 != 0 {
		fail("size %d is not a multiple of 512", len(d))
	}
	le := binary.LittleEndian
	for i := 0; i < len(d); i += 512 {
		b := d[i : i+512]
		if le.Uint32(b[0:]) != 0x0A324655 || le.Uint32(b[4:]) != 0x9E5D5157 || le.Uint32(b[508:]) != 0x0AB16F30 {
			fail("block %d: bad UF2 magic", i/512)
		}
		if le.Uint32(b[8:])&0x2000 == 0 || uint64(le.Uint32(b[28:])) != family {
			fail("block %d: family 0x%x, want 0x%x", i/512, le.Uint32(b[28:]), family)
		}
	}
	fmt.Printf("uf2 %d blocks, family 0x%x, first address 0x%x\n", len(d)/512, family, le.Uint32(d[12:]))
}

func checkESP(d []byte, chip string) {
	ids := map[string]uint16{"esp32": 0, "esp32s2": 2, "esp32c3": 5, "esp32s3": 9, "esp32c6": 13}
	if len(d) < 24 || d[0] != 0xE9 {
		fail("no ESP image magic 0xE9")
	}
	id := binary.LittleEndian.Uint16(d[12:])
	fmt.Printf("esp image: %d segments, entry 0x%x, chip id %d\n", d[1], binary.LittleEndian.Uint32(d[4:]), id)
	if chip != "" && id != ids[chip] {
		fail("chip id %d, want %d (%s)", id, ids[chip], chip)
	}
}

// checkWasm walks the sections of a wasm module and checks exports and import modules.
func checkWasm(d []byte, exports, imports []string) {
	if !bytes.HasPrefix(d, []byte("\x00asm\x01\x00\x00\x00")) {
		fail("no wasm magic/version 1")
	}
	r := &reader{d: d, p: 8}
	ex, im := map[string]bool{}, map[string]bool{}
	for r.p < len(d) {
		id := d[r.p]
		r.p++
		n := int(r.u())
		end := r.p + n
		switch id {
		case 2: // imports: module, name, kind + desc
			for c := r.u(); c > 0; c-- {
				mod, _ := r.s(), r.s()
				im[mod] = true
				k := d[r.p]
				r.p++
				switch k {
				case 0:
					r.u()
				case 1:
					r.p++
					r.limits()
				case 2:
					r.limits()
				case 3:
					r.p += 2
				}
			}
		case 7: // exports: name, kind, index
			for c := r.u(); c > 0; c-- {
				ex[r.s()] = true
				r.p++
				r.u()
			}
		}
		r.p = end
	}
	fmt.Printf("wasm %d bytes, %d exports, import modules %v\n", len(d), len(ex), keys(im))
	for _, e := range exports {
		if !ex[e] {
			fail("export %s missing", e)
		}
	}
	for _, m := range imports {
		if !im[m] {
			fail("import module %s missing", m)
		}
	}
}

func keys(m map[string]bool) (k []string) {
	for s := range m {
		k = append(k, s)
	}
	return
}

type reader struct {
	d []byte
	p int
}

func (r *reader) u() (v uint64) {
	for s := 0; ; s += 7 {
		b := r.d[r.p]
		r.p++
		v |= uint64(b&0x7f) << s
		if b < 0x80 {
			return
		}
	}
}
func (r *reader) s() string { n := int(r.u()); r.p += n; return string(r.d[r.p-n : r.p]) }
func (r *reader) limits() {
	f := r.d[r.p]
	r.p++
	r.u()
	if f&1 != 0 {
		r.u()
	}
}
