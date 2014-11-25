## How to install the latest Nvidia drivers on ubuntu

1. Find out your graphics card model

使用lspci命名查看显卡系列
```bash
lspci -vnn | grep -i VGA 12
```
```
01:00.0 VGA compatible controller [0300]: NVIDIA Corporation GK107 [GeForce GT 630 OEM] [10de:0fc2] (rev a1) (prog-if 00 [VGA controller])
	Subsystem: Micro-Star International Co., Ltd. [MSI] Device [1462:275c]
	Flags: bus master, fast devsel, latency 0, IRQ 46
	Memory at f6000000 (32-bit, non-prefetchable) [size=16M]
	Memory at e0000000 (64-bit, prefetchable) [size=256M]
	Memory at f0000000 (64-bit, prefetchable) [size=32M]
	I/O ports at e000 [size=128]
	Expansion ROM at f7000000 [disabled] [size=512K]
	Capabilities: <access denied>
	Kernel driver in use: nouveau
```
