# @NAME@

USB HID keyboard + mouse (`tinygo-box new usb_hid @NAME@`, 32_23_tinygo). TinyGo builds a CDC+HID composite
device; the descriptors come from `machine/usb/descriptor`. Not run without a board: `check.sh` builds for the
Pico and Pico 2 and checks the HID code and product string are in the image.

    tinygo-box run bash check.sh
    tinygo-box tinygo build -target pico -o build/@NAME@.uf2 .    # BOOTSEL + copy, then: lsusb, evtest
