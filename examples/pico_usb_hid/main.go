// pico_usb_hid: the Pico as a USB HID keyboard (TinyGo's machine/usb/hid/keyboard): a button on GP15
// (to GND, pull-up) types a line. TinyGo's USB stack replaces the CDC console with a CDC+HID composite device.
package main

import (
	"machine"
	"machine/usb"
	"machine/usb/hid/keyboard"
	"time"
)

func main() {
	usb.Product = "tinygo-box HID demo"
	btn := machine.GP15
	btn.Configure(machine.PinConfig{Mode: machine.PinInputPullup})
	kb := keyboard.Port()
	for {
		if !btn.Get() {
			kb.Write([]byte("hello from tinygo\n"))
			for !btn.Get() {
				time.Sleep(10 * time.Millisecond)
			}
		}
		time.Sleep(10 * time.Millisecond)
	}
}
