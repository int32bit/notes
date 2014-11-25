# How to install the latest Nvidia drivers on ubuntu

## Step1 Find out your graphics card model

使用lspci命名查看显卡系列
```bash
lspci -vnn | grep -i VGA 12
```
输出
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
可以看到显卡系列是GeForce GT 630 OEM

## Step2 Find out the right driver version for your graphics card

访问[Nvidia官方网址](http://www.nvidia.com/Download/index.aspx),输入显卡类型，点击search按钮,则会显示需要安装的驱动版本。
```
Version: 	340.58
Release Date: 	2014.11.5
Operating System: 	Linux 64-bit
Language: 	English (US)
File Size: 	69.00 MB
```

## Step3 Setup the xorg-edgers ppa

运行以下命令更新源：
```bash
sudo add-apt-repository ppa:xorg-edgers/ppa -y
sudo apt-get update
```

## Step4 Install the driver

运行以下命令安装驱动：
```bash
 sudo apt-get install nvidia-340
 ```
## Step5 Verify the installation
 
运行以下命令：
```bash
lspci -vnn | grep -i VGA 12
```
输出
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
	Kernel driver in use: nvidia
```
可见Kernel driver in user显示使用的内核驱动为nvidia

## Step6 Nvidia settings tool

使用nvidia-settings命令配置驱动。

# Removing the drivers

如果安装驱动导致系统无法启动，需要卸载驱动，运行以下命令:
```bash
sudo apt-get purge nvidia*
```
# Additional Notes

很多教程说安装了nvidia驱动后需要把nouveau放入黑名单，其实并不需要，因为nvidia驱动会自动把它放入黑名单。
运行以下命令：
```bash
grep 'nouveau' /etc/modprobe.d/* | grep nvidia
```
输出:
```
/etc/modprobe.d/nvidia-340_hybrid.conf:blacklist nouveau
/etc/modprobe.d/nvidia-340_hybrid.conf:blacklist lbm-nouveau
/etc/modprobe.d/nvidia-340_hybrid.conf:alias nouveau off
/etc/modprobe.d/nvidia-340_hybrid.conf:alias lbm-nouveau off
/etc/modprobe.d/nvidia-graphics-drivers.conf:blacklist nouveau
/etc/modprobe.d/nvidia-graphics-drivers.conf:blacklist lbm-nouveau
/etc/modprobe.d/nvidia-graphics-drivers.conf:alias nouveau off
/etc/modprobe.d/nvidia-graphics-drivers.conf:alias lbm-nouveau off
```
说明已经把它放到黑名单了，即系统启动时不会自动加载这些模块。

# References

参照[英文博客](www.binarytides.com/install-nvidia-drivers-ubuntu-14-04/)
