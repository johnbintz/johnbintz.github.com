---
title: SheevaPlug bootenv, pre- and post-SD card as root
layout: post
---

So I remember. Be sure to get the uImage for the kernel at [sheeva.with-linux.com](http://sheeva.with-linux.com/sheeva/kernel/2/2.6/2.6.37/2.6.37/).
I followed the instructions [here](http://www.randomexploits.com/projects/sheevaplug/sd-boot.htm) to get the OS off the NAND and onto an SD card.

{% highlight bash %}
# pre-SD card
bootargs=console=ttyS0,115200 ubi.mtd=2 root=ubi0:rootfs rootfstype=ubifs rootdelay=15
bootcmd=nand read.e 0x800000 0x100000 0x400000; bootm 0x800000

# post-SD card
setenv bootargs_console 'console=ttyS0,115200 rootdelay=15'
setenv bootargs_root_nand 'ubi.mtd=2 root=ubi0:rootfs rootfstype=ubifs'
setenv bootcmd_nand 'setenv bootargs $(bootargs_console) $(bootargs_root_nand); nand read.e 0x800000 0x100000 0x400000; bootm 0x800000'
setenv bootargs_root_mmc 'root=/dev/mmcblk0p1'
setenv bootcmd_mmc 'setenv bootargs $(bootargs_console) $(bootargs_root_mmc); mmcinit; ext2load mmc 0 0x800000 /boot/uImage; bootm 0x800000'
setenv bootcmd 'run bootcmd_mmc; run bootcmd_nand;'

# if the SD card was uncleanly mounted, you'll end up booting from NAND. Fix it:

# boot to NAND and...
sudo e2fsck /dev/mmcblk0p1
sudo shutdown -r now
# this can probably be automated in some way.

# ...after the move:
Filesystem           1K-blocks      Used Available Use% Mounted on
rootfs                 3811344    696732   2921000  20% /
/dev/root              3811344    696732   2921000  20% /
{% endhighlight %}

BAM.
