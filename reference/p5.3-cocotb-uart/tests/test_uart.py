"""cocotb tests for the P1.5 UART (uart_top), ported from tb/tb_uart.v.

  * test_loopback:   random bytes through TX FIFO -> TX -> RX -> RX FIFO, scoreboard in a Python deque
  * test_rx_frames:  a Python bit-banger drives rxd directly: good frames, bad parity, bad stop bit
  * test_glitch:     a short low pulse on rxd (shorter than half a bit) must not start a frame
"""
import random
from collections import deque

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, FallingEdge, RisingEdge

DIV = 2
BIT_CLKS = 16 * DIV


async def reset(dut, loopback):
    dut.rst_n.value = 0
    dut.loopback.value = loopback
    dut.tx_push.value = 0
    dut.tx_data.value = 0
    dut.rx_pop.value = 0
    dut.rxd.value = 1
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 5)


async def reader(dut, got, n):
    """Pop the RX FIFO whenever it is not empty; FWFT, so data is valid before the pop."""
    while len(got) < n:
        await FallingEdge(dut.clk)
        if not dut.rx_empty.value:
            got.append(int(dut.rx_data.value))
            dut.rx_pop.value = 1
            await FallingEdge(dut.clk)
            dut.rx_pop.value = 0


@cocotb.test()
async def test_loopback(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    await reset(dut, loopback=1)
    n = 500
    sent, got = deque(), []
    rd = cocotb.start_soon(reader(dut, got, n))
    for _ in range(n):
        await FallingEdge(dut.clk)
        while dut.tx_full.value:
            await FallingEdge(dut.clk)
        b = random.getrandbits(8)
        dut.tx_data.value = b
        dut.tx_push.value = 1
        sent.append(b)
        await FallingEdge(dut.clk)
        dut.tx_push.value = 0
    await rd
    assert got == list(sent), "loopback data mismatch"
    assert not dut.frame_err.value and not dut.parity_err.value
    dut._log.info("loopback: %d bytes, 0 errors", n)


async def send_frame(dut, byte, bad_parity=False, bad_stop=False):
    bits = [0] + [(byte >> k) & 1 for k in range(8)] + [(bin(byte).count("1") & 1) ^ bad_parity] + [0 if bad_stop else 1]
    for b in bits:
        dut.rxd.value = b
        await ClockCycles(dut.clk, BIT_CLKS)
    dut.rxd.value = 1
    await ClockCycles(dut.clk, 2 * BIT_CLKS)


@cocotb.test()
async def test_rx_frames(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    await reset(dut, loopback=0)
    perr = ferr = 0

    async def watch():
        nonlocal perr, ferr
        while True:
            await RisingEdge(dut.clk)
            perr |= int(dut.parity_err.value)
            ferr |= int(dut.frame_err.value)

    cocotb.start_soon(watch())
    data = [random.getrandbits(8) for _ in range(40)]
    got = []
    rd = cocotb.start_soon(reader(dut, got, len(data)))
    for b in data:
        await send_frame(dut, b)
    await rd
    assert got == data
    assert perr == 0 and ferr == 0
    await send_frame(dut, 0x5A, bad_parity=True)
    assert perr == 1, "bad parity not flagged"
    await send_frame(dut, 0x3C, bad_stop=True)
    await ClockCycles(dut.clk, 4 * BIT_CLKS)
    assert ferr == 1, "bad stop bit not flagged"
    dut._log.info("rx frames: 40 good, parity error and framing error flagged")


@cocotb.test()
async def test_glitch(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    await reset(dut, loopback=0)
    dut.rxd.value = 0
    await ClockCycles(dut.clk, BIT_CLKS // 4)
    dut.rxd.value = 1
    await ClockCycles(dut.clk, 12 * BIT_CLKS)
    assert dut.rx_empty.value == 1, "a glitch started a frame"
