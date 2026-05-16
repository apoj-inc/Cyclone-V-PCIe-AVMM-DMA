import cocotb
from cocotb.triggers import RisingEdge, Timer, First

@cocotb.test
async def test(dut):
    await RisingEdge(dut.clk)

    task_awaiter = RisingEdge(dut.test_done)
    timeout = Timer(300_000, unit='ns')

    result = await First(
        timeout,
        task_awaiter
    )

    assert result is not timeout, "The design has hung!"