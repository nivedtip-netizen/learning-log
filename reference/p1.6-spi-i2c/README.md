# P1.6: SPI slave and I2C master

> **Reference implementation, built with AI help.** This folder was written with an AI assistant (Claude) as a worked reference for my RTL/DV study plan. I am rebuilding it myself, step by step, and my own version will replace this one. It is not my solo work yet.

An SPI slave register file (all four CPOL/CPHA modes, 8 registers, register 7 read-only 0xA5),
and an I2C master (START, address, write, repeated START, read, NACK abort, STOP) tested against a
behavioural EEPROM with open-drain lines and pull-ups.

## Run
```
make spi     # all 4 SPI modes
make i2c
make lint
```

## Results
- SPI: about 1,000 random writes and 1,000 reads per mode against a register model; read-only and unmapped addresses checked. PASS in all 4 modes.
- I2C: 125 writes, 126 random reads (90 of them to written cells) with repeated START, 49 wrong-address cases NACKed and aborted with STOP. PASS.

## Not run here, and what is left for me
- Rebuild this myself from a blank file; my version replaces this one.
- Step 5 (compare against a real part's datasheet timing) is mine to do.
