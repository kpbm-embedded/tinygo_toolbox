// @NAME@: USB HID device (tinygo-box new usb_hid @NAME@): keyboard + mouse on one port (TinyGo's CDC+HID
// composite). Button on GP15 (to GND) types a word, GP14 nudges the mouse. RP2040/RP2350, nRF52840, SAMD.
package main

import (
	"machine"
	"machine/usb"
	"machine/usb/hid/keyboard"
	"machine/usb/hid/mouse"
	"time"
)

func main() {
	usb.Manufacturer = "tinygo-box"
	usb.Product = "@NAME@"
	typeBtn, moveBtn := machine.GP15, machine.GP14
	typeBtn.Configure(machine.PinConfig{Mode: machine.PinInputPullup})
	moveBtn.Configure(machine.PinConfig{Mode: machine.PinInputPullup})
	kb, ms := keyboard.Port(), mouse.Port()
	for {
		if !typeBtn.Get() {
			kb.Write([]byte("@NAME@\n"))
			time.Sleep(300 * time.Millisecond)
		}
		if !moveBtn.Get() {
			ms.Move(5, 0)
		}
		time.Sleep(10 * time.Millisecond)
	}
}
