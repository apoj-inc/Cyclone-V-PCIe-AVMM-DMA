# Cyclone-V-PCIe-AVMM-DMA
A configurable PCIe 2.0 x4 FPGA DMA controller using AVMM interfaces and sending a receiving data to FPGA using FIFOs. Supports up to 16 channels, sends DMA interrupts using MSIX, supports one external interrupt source per DMA channel, allows for custom CSRs connected to AVMM interface.

## Repository structure

### Repository directory tree
```
| Tree                              | Description
/-----------------------------------/--------------------------------------------------------------------------------------------
├── build_system                    | Scripts for convenient EDA tool usage
│   ├── quartus                     | Scripts for Quartus, allowing for compilation and device programming from make
│   │   └── custom_assignments.tcl  | Custom Quartus assignments. Generally used for device-specific things like pin assignments
│   └── questa                      | Scripts for Questa HDL simulation. Allows for testbench execution
├── cctb                            | Scripts for usage of Cocotb framework, allowing for development of python testbenches
│   └── build                       | ...
│       └── user_requirements.txt   | List of external python libraries to be installed upon venv generation
├── fpga                            | Scripts and other tools for FPGA EDA-specific operations
│   └── quartus                     | 
│       ├── custom_ip               | Contains *_hw.tcl files describing custom IP-cores
│       └── qsys*                   | Contains a Platform Designer .qsys projects exported as Tcl scripts
├── rtl*                            | Synthesizable RTL-sources
├── sdc*                            | SDC-sources
├── sw                              | C-sources of driver and userspace example software
│   ├── dma_driver                  | Contains driver C-sources and a small Makefile to build it
│   └── example                     | Contains C-sources of userspace test/example software
└── tb*                             | Contains RTL-testbenches

* - HDL-buildable
```

### HDL-buildable directories
All of the directories, that are denoted with a `*`-sign are HDL-buildable. They are used for building HDL either for synthesis
or simulation and share similar structure.

- fpga/quartus/qsys, rtl, sdc
    ```
    ├── lists - contains lists of paths to particular files/names
    └── src   - sources
    ```
- tb
    ```
    ├── lists - contains lists of paths to particular files/names
    ├── tb_*
    ...
    └── tb_*  - testbenches containing either a SystemVerilog or both SystemVerilog and Python testbenches
    ```

### List files format
- `fpga/quartus/qsys/lists/names_qsys.lst` - contains paths to `.tcl`-exported Platform Designer projects WITHOUT `.tcl` extnesion;
- `rtl/lists/files_hex.lst` - contains paths to all `.hex` memory initialization files (none at the moment);
- `rtl/lists/files_rtl.lst` - contains paths to all synthesizable SystemVerilog sources;
- `rtl/lists/incdirs.lst` - contains paths to all `` `include``-directories (none at the moment);
- `sdc/lists/files_sdc.lst` - contains paths to all `.sdc` sources;
- `tb/lists/files_tb.lst` - contains paths to all SystemVerilog sources planned for usage in Questa simulation.

## Build and use
### System specs
This project was tested on following hardware:
- CPU: `Intel Core i9-9900KF`;
- OS: `Linux - Kubuntu 22.04`;
- FPGA: `Altera - Cyclone V 5CGTD9 FPGA 5CGTFD9D5F27C7N`;
- Devboard: `Terasic - Starter Platform for OpenVINO Toolkit`;

### Software prerequisites
- `Quartus Prime` (tested on Lite edition 25.1) - make sure `bin` path of `Quartus` is in `PATH` and `QSYS_ROOTDIR` variable is in
environment;
- `Questa*` (tested on Starter edition 24.1) - make sure `bin` path of `Questa*` is in `PATH`;
- `Python 3` (tested on 3.11).

### HDL-simulation in Questa

#### Running a testbench
Running a testbench and then launching Questa GUI for waveform inspection:
```
make -f build_system/questa/makefile TOPLEVEL=<SystemVerilog module name> run
make -f build_system/questa/makefile TOPLEVEL=<SystemVerilog module name> wave
```
Note: before running `make -f build_system/questa/makefile ... wave` command make sure that the testbench was executed beforehand.

#### Creating a custom testbench
- Write a testbench at `tb/tb_<test_name>/tb_<test_name>.sv` path (Note: make sure the module name is `tb_<test_name>`);
- Write `tb/tb_<test_name>/tb_<test_name>.sv` on a newline inside the `tb/lists/files_tb.lst` file;
- Run the testbench according to the instruction above.

### HDL-simulation in Questa using Cocotb

#### Running a testbench
Running a testbench and then launching Questa GUI for waveform inspection:
```
make -f cctb/build/makefile COCOTB_TOPLEVEL=<python file without .py> run
make -f cctb/build/makefile COCOTB_TOPLEVEL=<python file without .py> wave
```
Note: before running `make -f cctb/build/makefile ... wave` command make sure that the testbench was executed beforehand.

#### Creating a custom testbench
- Write a SystemVerilog source at `tb/tb_<test_name>/tb_<test_name>.sv` path (Note: make sure the module name is `tb_<test_name>`);
- Write a Python source at `tb/tb_<test_name>/tb_<test_name>.py`;
- Run the testbench according to the instruction above.

Note: if the SystemVerilog source is used in both Questa and Cocotb simulation, then write
```
`ifdef QUESTA
    $finish();
`endif
```
instead of 
```
$finish();
```
because using raw `$finish()` in a Cocotb context results in Cocotb reporting a test failure even when `$finish()` was planned

### Quartus synthesis
#### Synthesis and programming
4-step Quartus synthesis (Synthesis, Place and route, Programming file generation, Timing analysis):
```
make -f build_system/quartus/makefile TOPLEVEL=<SystemVerilog module name> compile
```
Device programming:
```
make -f build_system/quartus/makefile TOPLEVEL=<SystemVerilog module name> CABLE_NAME=<cable name> JTAG_CHAIN_DEVNUM=<number> program
```
If there was no synthesis before launching device programming, then the synthesis will be performed automatically.

#### Finding cable name and jtag device index
To determine JTAG cable name and device number, use `jtagconfig` command
```
$ jtagconfig
1) C5P [1-8]
  02B040DD   5CGTFD9(A5|C5|D5|E5)/..
```
In this case, cable name is `C5P` and device number is 1 because there is only one device on this chain. If there are multiple, then
all of them will be displayed on the console and you will have to determine, which one is the necessary FPGA.
Command for programming the device:
```
make -f build_system/quartus/makefile TOPLEVEL=<SystemVerilog module name> CABLE_NAME=C5P JTAG_CHAIN_DEVNUM=1 program
```

To compile and program the example project provided in this repository (DMA echodevice):
```
make -f build_system/quartus/makefile TOPLEVEL=toplevel CABLE_NAME=C5P JTAG_CHAIN_DEVNUM=1 program
```

### Adding new HDL sources

#### Adding RTL and RTL-adjacent sources
- If any new synthesizable SystemVerilog source is added, make sure to add its path on a newline into `rtl/lists/files_rtl.lst`;
- If any new `.hex` memory initialization file is added, make sure to add its path on a newline into `rtl/lists/files_hex.lst`;
- If any directory contains `.vh` or `.svh` headers, that are `` `include``-ed in any synthesizable SystemVerilog source,
make sure to add its path on a newline into `rtl/lists/incdirs.lst`.

#### Adding SDC sources
- If a new SDC source, that is to be read directly by the EDA (for example, Quartus), is added, make sure to add its path
on a newline into `sdc/lists/files_sdc.lst`;
- If a new SDC source, that is NOT to be read directly by the EDA (for example, Quartus), is added (for example, to be sourced by 
another SDC file), then DO NOT add its path into `sdc/lists/files_sdc.lst`.

#### Adding new custom Quartus IPs
- To add a new custom IP, place the `*_hw.tcl` file to the `fpga/quartus/custom_ip` path without any subdirectories;
- If any SystemVerilog sources are used in this IP-core, make sure that relative paths to them in the `*_hw.tcl` are relative to 
`fpga/quartus/custom_ip`.

#### Adding new Quartus Platform Designer projects
- Export Platform Designer project as a `.tcl` source in the menu bar: `File -> Export System as Platform Designer script (.tcl)`;
- Move the `.tcl` source to `fpga/quartus/qsys/src`;
- Add its path on a newline into `fpga/quartus/qsys/lists/names_qsys.lst` WITHOUT `.tcl` extension (example: file
`fpga/quartus/qsys/src/my_pcie.tcl`, `fpga/quartus/qsys/src/my_pcie` written to `fpga/quartus/qsys/lists/names_qsys.lst`).

### Building and using the driver
#### Resetting the PCIe device
***
WARNING! For avoiding kernel lockup, remove the PCIe device, program the FPGA and insert the PCIe device!
***

How to do it programmatically:
```
$ sudo lspci -vv
...
06:00.0 Unassigned class [ff00]: Altera Corporation Device d800 (rev 05)
        Subsystem: Altera Corporation Device 0001
        Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Interrupt: pin A routed to IRQ 0
...
```
The PCIe device ID is `06:00.0`, which depends in which PCIe interface it is plugged into. Find it in the `/sys/devices` tree.

Example:
```
$ tree /sys/devices/ | grep 06\:00\.0
│   │   │   │   │   ├── physical_node -> ../../../../../pci0000:00/0000:00:1c.0/0000:06:00.0
│   │   ├── 0000:06:00.0
│   │   │           ├── device -> ../../../0000:06:00.0
    │       │   ├── 0000:06:00.0 -> ../../../../pci0000:00/0000:00:1c.0/0000:06:00.0
```
Path is `/sys/devices/pci0000:00/0000:00:1c.0/0000:06:00.0`
```
$ cd /sys/devices/pci0000:00/0000:00:1c.0
$ echo 1 | sudo tee 0000\:06\:00.0/remove
```
... Programming the FPGA ...
```
$ echo 1 | sudo tee /sys/bus/pci/rescan
```
This way the driver will not try to access the PCIe device while it's in an undefined state after programming
the FPGA.

#### Using the driver

Initial directory - base directory of the repository.

Insert the driver
```
$ cd ./sw/dma_driver
$ make
$ sudo insmod hdlnocgen_c5p_driver.ko
```
Remove the driver
```
$ sudo rmmod hdlnocgen_c5p_driver.ko
```

Features:

- DMA timeout if FPGA doesn't send DMA IRQ within 1000000 checks. Checking granularity - 1 us;
- `#define DMA_BUFFER_SIZE 4194304` sets the size of a DMA buffer for each channel in bytes. You can change it,
but 4 Mbytes set by default is a practical maximum a stock Linux system can allocate using `dma_alloc_coherent()`.

#### Using existing software test
The current DMA controller example implements a DMA echodevice, where internal DMA read queue is looped over to the DMA write queue, which means, that data
read from PC to DMA is going to be written from DMA to PC on a subsequent request. There are two userspace software examples, which test and demonstrate this
project in action:

* `echodevice_interactive.c` - requests user to input data, then writes this data to DMA and reads it back from the DMA;
* `echodevice_test.c` - tests all DMA channel echodevices over multiple iterations and all external IRQs through the external CSR example.

All macros are configurable.

Both are built in the same way (root directory of this repository is the starting point):
```
cd ./sw/dma_driver
gcc -o echodevice_<interactive/test> echodevice_<interactive/test>.c
```

Execution:
```
./echodevice_test
./echodevice_interactive <DMA channel number>
```

#### Writing software in userspace
Example: 16-channel DMA

Upon inserting the driver module, multiple chrdevs in `/dev` directory are created:
```
$ ls -l /dev
crw-rw-rw-  1 root root    239,   0 May 18 04:17 hdlnocgen_c5p0         \
crw-rw-rw-  1 root root    239,   1 May 18 04:17 hdlnocgen_c5p1          |
crw-rw-rw-  1 root root    239,  10 May 18 04:17 hdlnocgen_c5p10         |
crw-rw-rw-  1 root root    239,  11 May 18 04:17 hdlnocgen_c5p11         |
crw-rw-rw-  1 root root    239,  12 May 18 04:17 hdlnocgen_c5p12         |
crw-rw-rw-  1 root root    239,  13 May 18 04:17 hdlnocgen_c5p13         |
crw-rw-rw-  1 root root    239,  14 May 18 04:17 hdlnocgen_c5p14         |
crw-rw-rw-  1 root root    239,  15 May 18 04:17 hdlnocgen_c5p15         |
crw-rw-rw-  1 root root    239,   2 May 18 04:17 hdlnocgen_c5p2          | -> DMA chdevs
crw-rw-rw-  1 root root    239,   3 May 18 04:17 hdlnocgen_c5p3          |
crw-rw-rw-  1 root root    239,   4 May 18 04:17 hdlnocgen_c5p4          |
crw-rw-rw-  1 root root    239,   5 May 18 04:17 hdlnocgen_c5p5          |
crw-rw-rw-  1 root root    239,   6 May 18 04:17 hdlnocgen_c5p6          |
crw-rw-rw-  1 root root    239,   7 May 18 04:17 hdlnocgen_c5p7          |
crw-rw-rw-  1 root root    239,   8 May 18 04:17 hdlnocgen_c5p8          |
crw-rw-rw-  1 root root    239,   9 May 18 04:17 hdlnocgen_c5p9         /
crw-rw-rw-  1 root root    239,  17 May 18 04:17 hdlnocgen_c5p_env_csr     -> External CSR chdev
crw-rw-rw-  1 root root    239,  16 May 18 04:17 hdlnocgen_c5p_user_irq    -> External IRQ chdev
```

##### DMA read/write (example - channel 6):
```c
#define _GNU_SOURCE

#include <stdio.h>
#include <fcntl.h>

int main () {
    int fd_dma = open("/dev/hdlnocgen_c5p6", O_RDWR);

    uint64_t data_src[1024];
    uint64_t data_dst[1024];

    write(fd_dma, data_src, sizeof(data_src)); // DMA write to PCIe
    read(fd_dma, data_dst, sizeof(data_dst)); // DMA read from PCIe

    int fail = 0;
    for (int i = 0; i < 1024; i++) {
        if (data_src[i] != data_dst[i]) {
            fail++;
        }
    }
    printf("Fail count: %d\n", fail); // Should say "Fail count: 0"
}
```
If `data_src`/`data_dst` size is bigger than DMA buffer size, then DMA write/read will not be started
eand `write`/`read` functions will return `-ENOMEM`.

##### External CSR read/write:

***
WARNING! Behaviour of external CSR reads/writes are entirely dependent on the RTL-logic of that CSR.
External CSR is connected to BAR[2] with offset 0x2000 (address 0x0 of external CSR is address 0x2000
on BAR[2]).

If any of the following things are valid:

- There are addresses, which are permitted by BAR[2]'s range, where read/write requests result in AVMM's
`waitrequest` signal never being set to 0;
- There are addresses, where read requests will never result in AVMM's `readdatavalid` signal being set to 1.

then be extra careful when operating with `/dev/hdlnocgen_c5p_env_csr` chdev. Any wrong move will result in a
kernel lockup, which will require a hard reset, resulting in possible corruptions or loss of data, even if the
driver is operating over a virtual machine.

If there's no external CSR or AVMM plug connected to the DMA, then NEVER!!! read/write to `/dev/hdlnocgen_c5p_env_csr`.

Rule of thumb: if AXI/AVMM/any other bus is not verified properly and a host PC with an operating OS is critical,
don't let the bus anywhere near an FPGA which is connected to the host PC through the kernel.
***
```c
#define _GNU_SOURCE

#include <stdio.h>
#include <fcntl.h>

int main () {
    int fd_csr = open("/dev/hdlnocgen_c5p_env_csr", O_RDWR);

    uint32_t wrdata = /*init_value*/;
    uint64_t rddata;

    pwrite(fd_csr, &wrdata, 4, (off_t)0x0); // Write 32-bit data to address 0x0 of the CSR
    pwrite(fd_csr, &wrdata, 4, (off_t)0x4); // Write 32-bit data to address 0x4 of the CSR
    pread(fd_csr, &rddata, 8, (off_t)0x10); // Read 64-bit data from address 0x10 of the CSR
}
```

##### Checking external IRQ status:
```c
#define _GNU_SOURCE

#include <stdio.h>
#include <fcntl.h>

int main () {
    int fd_irq = open("/dev/hdlnocgen_c5p_user_irq", O_RDWR);

    uint8_t irq_status;
    uint8_t deassert_irq = 0;

    pread(fd_irq, &irq_status, sizeof(irq_status), (off_t)0x0);      // Read external IRQ 0 status (0 or 1)
    pwrite(fd_irq, &deassert_irq, sizeof(deassert_irq), (off_t)0x0); // Deassert external IRQ 0 (status will turn to 0)
    pread(fd_irq, &irq_status, sizeof(irq_status), (off_t)0x0);      // Read external IRQ 0 status (0 if not asserted again)
    

    pread(fd_irq, &irq_status, sizeof(irq_status), (off_t)0x9);      // Read external IRQ 9 status (0 or 1)
    pwrite(fd_irq, &deassert_irq, sizeof(deassert_irq), (off_t)0x9); // Deassert external IRQ 9 (status will turn to 0)
    pread(fd_irq, &irq_status, sizeof(irq_status), (off_t)0x9);      // Read external IRQ 9 status (0 if not asserted again)
}
```

#### Using a VM
To use this project through a VM, make surem that following things are true:
- VT-d and VT-x (Intel) or AMD-V and AMD-Vi (AMD) are both enabled in BIOS;
- IOMMU is enabled in GRUB: file `/etc/default/grub`, variable `GRUB_CMDLINE_LINUX_DEFAULT` includes
`amd_iommu=on` (AMD) or `intel_iommu=on` (Intel).

Then you can use `vfio` and perform PCIe device passthrough to a VM of your liking.

Guide: https://askubuntu.com/questions/1406888/ubuntu-22-04-gpu-passthrough-qemu

Archived: https://web.archive.org/web/20260309112117/https://askubuntu.com/questions/1406888/ubuntu-22-04-gpu-passthrough-qemu

## Acknowledgement

Thanks to MIEM HSE (HSE Tikhonov Moscow Institute of Electronics and Mathematics) for providing all necessary
hardware for me to be able to create this highly educational and functional project.

Thanks to E. V. Lezhnev, M. Yu. Romashikhin, V. V. Zunin, A. A. Amerikanov, L. G. Evtushenko, A. Yu. Romanov and the rest of
CAD laboratory for the support throughought the development.

Thanks to [Elgrush](https://github.com/Elgrush), [MichShch](https://github.com/MichShch), [Timur123](https://github.com/Timur132) and Don_Dimon
for working with me on this and adjacent projects and celebrating all of it.

Head of the snake: [AXI-NoC-with-built-in-PMUs](https://github.com/apoj-inc/AXI-NoC-with-built-in-PMUs)
