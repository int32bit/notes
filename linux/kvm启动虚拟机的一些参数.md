# kvm启动虚拟机的一些参数

kvm（qemu)启动虚拟机时，参数比较多，也很灵活，相对图形界面Virtalbox & virt-manager操作要复杂，但更灵活，功能更强大.

* -smp 指定虚拟个数
* -m 指定分配的内存大小
* -cpu 指定cpu model, 使用-cpu ?查看可用的model
* -name 指定虚拟机名称
* -vga 指定显卡类型，默认为cirrus,一般指定std。
* -usb 开启usb设备，在图形界面，为了鼠标指针精确定位，一般还有加上usb设备tablet
* -usbdevice增加usb设备
* -hda 第一块IDE硬盘
* -rtc 设置实时时钟，一般设置utc，但windows需要设置为localtime
* -soundhw 增加声卡设备，使用all，加载所有可用声卡类型
* -net nic 增加网卡
* -net tap 使用tap作为网络连接方式，即网桥。
* -drive 增加IDE，cdrom等设备
* -balloon使用balloon内存管理
* -full-screen 全屏模式

## DEMO

启动windows7
```bash
sudo kvm -m $RAM -smp $VCPUS -cpu $CPUS_MODEL -name $NAME -soundhw all -rtc base=localtime -balloon virtio -net nic,model=virtio -net tap,vnet_hdr=on,vhost=on -usb -usbdevice tablet -vga std  -drive file=$SECOND_DISK,if=virtio,index=2 -hda $ROOT_DISK 
```

启动ubuntu-server
```bash
sudo kvm -smp 2  -m 1024 -balloon virtio -net nic,model=virtio -net tap,vnet_hdr=on,vhost=on -drive file=vdb.disk,if=virtio -usb -name ubuntu14.04 ubuntu.qcow2
```
