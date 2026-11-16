> **Reference implementation, built with AI help.** This folder was written with an AI assistant (Claude) as a worked reference for my RTL/DV study plan. I am rebuilding it myself, step by step, and my own version will replace this one. It is not my solo work yet.

# How I would verify the digital control of an RF beamformer

*One page. Generic phased-array beamformer IC; no product or company details.*

## What the digital block does

A beamformer IC has N RF channels. Each channel has a variable-gain amplifier and a phase shifter set by a digital code (for example 6-bit phase, 5-bit gain). The digital control block is:

- an **SPI slave** and a **register map** (chip ID, mode, channel enables, TX/RX select, beam index, status);
- **beam tables**: RAM holding gain and phase codes for each channel and each beam (say 64 beams x N channels);
- a **load/latch path**: codes are written into a shadow copy and moved to the live DACs on a *load* strobe (a register bit or a pin), so all channels switch together;
- optional **temperature compensation** that adds an offset to the codes.

The risk is not the RF. It is the wrong code reaching the wrong channel at the wrong time.

## Verification plan

| Feature | How it is checked | Pass criterion |
|---|---|---|
| Reset values | read every register after reset | all match the spec table |
| Register access | write/read walking 1s and 0s, random values, RO/W1C/reserved bits | read-back follows the access type of every field |
| SPI protocol | all 4 SPI modes if supported, back-to-back frames, short and long frames, CS dropped mid-frame | no corruption; a broken frame is ignored |
| Beam table load | write all beams with random codes, read them back; then the extremes (all 0, all max) | RAM contents match the model |
| Shadow/live behaviour | write the table, check live DAC codes do **not** change; pulse load, check every channel changes on the **same** cycle | no channel updates early or alone |
| Beam switching | step through beam indices fast, as a radar scan would | live codes = table[beam] for each channel, every step |
| Channel mapping | one channel at a time gets a unique code | code lands on that channel's DAC outputs only (catches swapped bits or channels) |
| Temp compensation | sweep offset and codes, including saturation at max/min | output = clamp(code + offset), never wraps |
| Error cases | address out of range, write to RO, load during a table write | defined behaviour, status/error bit set |

**Testbench:** an SPI agent (driver + monitor), a register model (RAL) for the map, a reference model of the beam tables in the scoreboard, and a monitor on the per-channel DAC code outputs. The scoreboard predicts the live codes from every SPI write and every load strobe, and compares them on every cycle. Coverage: every register field x access type, every beam index, every channel, codes at 0/max/mid, load during idle vs. during a write, all SPI modes.

**Assertions:** live codes are stable unless a load happened; a load updates all channels in the same cycle; SPI MISO is driven only while CS is low.

## What carries over from ATE

On the tester, I already did the same thing from the outside: program registers over SPI, set a beam, measure gain and phase, compare against limits, and sweep over codes and temperature. In DV the measurement is replaced by a monitor on the DAC code bus and the limits by a reference model, but the test list (register test, code sweep, beam switching, temperature sweep) is the same. Post-silicon test also tells me which bugs are expensive: a channel-mapping or load-timing bug found on the tester costs a respin, so those are the first things I would cover in pre-silicon DV.
