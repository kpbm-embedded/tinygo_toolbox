# @NAME@

I2C sensor driver (TMP102 register layout) with a fake-bus unit test, and firmware that uses it on any board
(`tinygo-box new i2c_driver @NAME@`, 32_23_tinygo). The driver depends only on `sensor.Bus`, which `machine.I2C`
and `tinygo.org/x/drivers`' `drivers.I2C` both satisfy.

    tinygo-box run bash check.sh                                 # host tests + builds for pico, pico2, nicenano, esp32c3
    tinygo-box tinygo build -target pico -o build/@NAME@.uf2 .
