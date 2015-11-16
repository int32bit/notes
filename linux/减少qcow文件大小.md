# 减少qcow文件大小

当做虚拟机备份快照时，镜像的大小一般会大于实际数据大小，you'll need to zero out all free space of the partitions contained within the guest first.

参考维基百科:[https://pve.proxmox.com/wiki/Shrin\_Qcow2\_Disk\_Files](https://pve.proxmox.com/wiki/Shrink_Qcow2_Disk_Files)

针对linux镜像:

## 1. 删除无用文件

尽量删除一些无用文件

## 2. Zero out磁盘

```
dd if=/dev/zero of=/mytempfile
# that could take a some time
rm -f /mytempfile
```

## 3.减少磁盘大小

### 备份
mv image.qcow2 image.qcow2_backup

### #1: Shrink your disk without compression (better performance, larger disk size):
```sh
qemu-img convert -O qcow2 image.qcow2_backup image.qcow2
```
### #2: Shrink your disk with compression (smaller disk size, takes longer to shrink, performance impact on slower systems):
```sh
qemu-img convert -O qcow2 -c image.qcow2_backup image.qcow2
```
