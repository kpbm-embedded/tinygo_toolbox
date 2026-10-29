// Package shell: a tiny line-oriented command interpreter for a serial console (USB-CDC or UART).
// No allocation per command; hardware-free, tested on the host.
package shell

import "strconv"

// Handler gets the arguments after the command name and returns the reply.
type Handler func(args []string) string

type Shell struct {
	cmds map[string]Handler
	line []byte
}

func New() *Shell { return &Shell{cmds: map[string]Handler{}, line: make([]byte, 0, 80)} }

func (s *Shell) Register(name string, h Handler) { s.cmds[name] = h }

// Feed takes one received byte; on '\r' or '\n' it runs the line and returns the reply (ok=true).
func (s *Shell) Feed(b byte) (reply string, ok bool) {
	switch {
	case b == '\r' || b == '\n':
		if len(s.line) == 0 {
			return "", false
		}
		reply = s.Run(string(s.line))
		s.line = s.line[:0]
		return reply, true
	case b == 0x7f || b == '\b':
		if len(s.line) > 0 {
			s.line = s.line[:len(s.line)-1]
		}
	case len(s.line) < cap(s.line):
		s.line = append(s.line, b)
	}
	return "", false
}

// Run executes one command line.
func (s *Shell) Run(line string) string {
	var f []string
	start := -1
	for i := 0; i <= len(line); i++ {
		if i == len(line) || line[i] == ' ' {
			if start >= 0 {
				f = append(f, line[start:i])
				start = -1
			}
		} else if start < 0 {
			start = i
		}
	}
	if len(f) == 0 {
		return ""
	}
	h, ok := s.cmds[f[0]]
	if !ok {
		return "error: unknown command " + f[0]
	}
	return h(f[1:])
}

// Atoi helper for handlers.
func Atoi(s string) (int, bool) { v, err := strconv.Atoi(s); return v, err == nil }
