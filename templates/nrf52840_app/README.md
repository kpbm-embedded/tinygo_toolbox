# @NAME@

nRF52840 firmware (nice!nano, Pro Micro nRF52840) from `tinygo-box new nrf52840_app @NAME@` (32_23_tinygo).
The app is linked above the S140 v6 SoftDevice (0x26000) for the Adafruit UF2 bootloader.

    tinygo-box run bash check.sh                     # UF2 + ELF checks (TARGET=xiao-ble ... for other boards)
