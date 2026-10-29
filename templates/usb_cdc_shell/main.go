// @NAME@: serial command shell (tinygo-box new usb_cdc_shell @NAME@). machine.Serial is USB-CDC on the Pico,
// nice!nano and ESP32-C3/S3 (USB-Serial/JTAG), UART elsewhere. Commands: led on|off, uptime, help.
package main

import (
	"machine"
	"strconv"
	"time"

	"@NAME@/shell"
)

func main() {
	start := time.Now()
	led := machine.LED
	led.Configure(machine.PinConfig{Mode: machine.PinOutput})
	sh := shell.New()
	sh.Register("led", func(a []string) string {
		if len(a) == 1 && (a[0] == "on" || a[0] == "off") {
			led.Set(a[0] == "on")
			return "ok"
		}
		return "usage: led on|off"
	})
	sh.Register("uptime", func([]string) string { return strconv.Itoa(int(time.Since(start).Milliseconds())) + " ms" })
	sh.Register("help", func([]string) string { return "led on|off, uptime, help" })
	for {
		if machine.Serial.Buffered() == 0 {
			time.Sleep(5 * time.Millisecond)
			continue
		}
		b, _ := machine.Serial.ReadByte()
		if reply, ok := sh.Feed(b); ok {
			machine.Serial.Write([]byte(reply + "\r\n> "))
		}
	}
}
