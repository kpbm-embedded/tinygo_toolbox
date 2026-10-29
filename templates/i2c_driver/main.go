// @NAME@: I2C sensor driver + firmware (tinygo-box new i2c_driver @NAME@). machine.I2C0 is passed as sensor.Bus.
package main

import (
	"machine"
	"time"

	"@NAME@/sensor"
)

func main() {
	i2c := machine.I2C0
	if err := i2c.Configure(machine.I2CConfig{Frequency: 400 * machine.KHz}); err != nil {
		println("@NAME@: i2c", err.Error())
	}
	dev := sensor.New(i2c)
	if err := dev.Configure(); err != nil {
		println("@NAME@:", err.Error())
	}
	for {
		mc, err := dev.ReadMilliCelsius()
		if err == nil {
			println("@NAME@: mC", mc)
		}
		time.Sleep(time.Second)
	}
}
