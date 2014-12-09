Install jessie on beaglebone black
==================================

Step 1: Update the beaglebone builtin emmc bootloader
=====================================================

Download BBB-eMMC-flasher-debian-7.7-console-armhf-2014-10-22-2gb.img from http://elinux.org/Beagleboard:BeagleBoneBlack_Debian  
Burn the image to SD and from there to emmc. It's ok that it's a 7.7, not 8 (jessie) image.

Burn the image to SD-card (macosx)
----------------------------------

    fdkz@woueao:~/Downloads$ unxz BBB-eMMC-flasher-debian-7.7-console-armhf-2014-10-22-2gb.img.xz
    fdkz@woueao:~/Downloads$ diskutil list
    ...
    /dev/disk5
       #:                       TYPE NAME                    SIZE       IDENTIFIER
       0:     FDisk_partition_scheme                        *7.9 GB     disk5
       1:                 DOS_FAT_32 NO NAME                 7.9 GB     disk5s1
       
    fdkz@woueao:~/Downloads$ sudo diskutil unmountDisk /dev/disk5
    Unmount of all volumes on disk5 was successful
    
    fdkz@woueao:~/Downloads$ sudo dd bs=1m if=BBB-eMMC-flasher-debian-7.7-console-armhf-2014-10-22-2gb.img of=/dev/rdisk5


Burn the SD-card to BBB internal eMMC
-------------------------------------

Insert the card and power up the BBB. Watch the progress through debug-serial or wait until the leds finish their cylon-pattern and stay lit.


Step 2: Create a clean jessie SD-card
=====================================

Compile the mainline kernel using this doc:

http://eewiki.net/display/linuxonarm/BeagleBone+Black

But before starting, install 32-bit dependencies for the cross-compiler:

    sudo apt-get install lib32z1
    sudo apt-get install lib32stdc++6

and before ./build_kernel.sh make sure that git has your name/email or something in the buildin process won't work:

    git config --global user.email "you@example.com"
    git config --global user.name "Your Name"

To get the Huawei E3372 4G modem to work, DISABLE the "CDC MBIM support" module when configuring the kernel:

    │ Symbol: USB_NET_CDC_MBIM [=m]                                             │
    │ Type  : tristate                                                          │
    │ Prompt: CDC MBIM support                                                  │
    │   Location:                                                               │
    │     -> Device Drivers                                                     │
    │       -> Network device support (NETDEVICES [=y])                         │
    │         -> USB Network Adapters (USB_NET_DRIVERS [=y])                    │
    │ (3)       -> Multi-purpose USB Networking Framework (USB_USBNET [=m])     │
    │   Defined at drivers/net/usb/Kconfig:265                                  │
    │   Depends on: NETDEVICES [=y] && USB_NET_DRIVERS [=y] && USB_USBNET [=m]  │
    │   Selects: USB_WDM [=m] && USB_NET_CDC_NCM [=m]                           │


To create a 1GB partition instead of the full-disk partition, in section "Setup microSD/SD card":
    
    notes:

        fdkz@def 02:50:52 :~/bb-image-creation$ lsblk
            NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
            sda      8:0    0    20G  0 disk 
            ├─sda1   8:1    0    19G  0 part /
            ├─sda2   8:2    0     1K  0 part 
            └─sda5   8:5    0  1022M  0 part [SWAP]
            sdb      8:16   1   7,4G  0 disk 
            └─sdb1   8:17   1   7,4G  0 part /media/fdkz/6663-3666
            sr0     11:0    1  1024M  0 rom  
    
        export DISK=/dev/sdb
        umount /dev/sdb1

    section "Create Partition Layout":
        
        sudo sfdisk --in-order --Linux --unit M ${DISK} <<-__EOF__
        1,1024,0x83,*
        __EOF__

    ----

    fdkz@def 02:54:40 :~/bb-image-creation$ sudo sfdisk --in-order --Linux --unit M ${DISK} <<-__EOF__
    > 1,1024,0x83,*
    > __EOF__
    Checking that no-one is using this disk right now ...
    OK
    
    Disk /dev/sdb: 1021 cylinders, 245 heads, 62 sectors/track
    
    sfdisk: ERROR: sector 0 does not have an msdos signature
     /dev/sdb: unrecognized partition table type
    Old situation:
    No partitions found
    New situation:
    Warning: The partition table looks like it was made
      for C/H/S=*/49/4 (instead of 1021/245/62).
    For this listing I'll assume that geometry.
    Units = mebibytes of 1048576 bytes, blocks of 1024 bytes, counting from 0
    
       Device Boot Start   End    MiB    #blocks   Id  System
    /dev/sdb1   *     1   1024   1024    1048576   83  Linux
            start: (c,h,s) expected (10,22,1) found (0,33,3)
            end: (c,h,s) expected (1023,48,4) found (138,48,4)
    /dev/sdb2         0      -      0          0    0  Empty
    /dev/sdb3         0      -      0          0    0  Empty
    /dev/sdb4         0      -      0          0    0  Empty
    Successfully wrote the new partition table
    
    Re-reading the partition table ...
    
    If you created or changed a DOS partition, /dev/foo7, say, then use dd(1)
    to zero the first 512 bytes:  dd if=/dev/zero of=/dev/foo7 bs=512 count=1
    (See fdisk(8).)
    
    
Skip the "Dealing with old Bootloader in eMMC" section.
    
Skip the "/etc/udev/rules.d/70-persistent-net.rules" section. Don't need it and besides it screws with our huawei modem that wants to create an eth interface also.
    
Skip the "usb gadget" section and everything that follows it. We're done.


After first boot from the new SD-card:

    debian@arm:~$ df -h
    Filesystem      Size  Used Avail Use% Mounted on
    /dev/root       976M  430M  480M  48% /
    devtmpfs        239M     0  239M   0% /dev
    tmpfs           248M     0  248M   0% /dev/shm
    tmpfs           248M  8.3M  239M   4% /run
    tmpfs           5.0M     0  5.0M   0% /run/lock
    tmpfs           248M     0  248M   0% /sys/fs/cgroup


Step 3: Copy the new image
==========================

    fdkz@def 03:32:38 :~/bb-image-creation$ umount /dev/sdb1
    fdkz@def 03:32:40 :~/bb-image-creation$ sudo dd bs=1M count=1025 if=/dev/sdb of=bbb-clean-jessie-3.18-430MB-1025MB-20141205.img
    1025+0 records in
    1025+0 records out
    1074790400 bytes (1,1 GB) copied, 35,3751 s, 30,4 MB/s

    fdkz@def 03:37:03 :~/bb-image-creation$ umount /dev/sdb1
    fdkz@def 03:37:10 :~/bb-image-creation$ umount /dev/sdb2
    fdkz@def 03:37:11 :~/bb-image-creation$ sudo dd bs=1M count=1025 if=bbb-clean-jessie-3.18-430MB-1025MB-20141205.img of=/dev/sdb
    1025+0 records in
    1025+0 records out
    1074790400 bytes (1,1 GB) copied, 89,317 s, 12,0 MB/s


Step 4: Prepare the image for general purposes
==============================================

Boot the BBB with the newly created SD-card. Logins as root/root if from serial console.

If using USB for power, then CPU is limited to 300 MHz. (On some systems.) Set max speed temporarily:

    root@arm:~# cpufreq-info
    root@arm:~# cpufreq-set --governor performance


Uninstall unnecessary programs
------------------------------

    root@arm:~# apt-get purge --auto-remove apache2*
    root@arm:~# rm -rf /var/www/html/


Install new programs
--------------------

    root@arm:~# apt-get update
    root@arm:~# apt-get dist-upgrade
    root@arm:~# apt-get install vim ntp htop tree pkg-config zip unzip git lsof autossh gcc make autoconf automake udisks2 device-tree-compiler python-pip python-serial python-twisted screen tmux

udisks2 - needed by some 3G-modems.


Get networking to work
----------------------

Idea is to remove all dhcp clients and the archaic ifupdown system. Let systemd handle networking.
TODO: test yanking modems and network cables and booting.


Remove old legacy

    root@arm:~# apt-get purge --auto-remove ifupdown isc-dhcp-common isc-dhcp-client

Create a systemd-networkd config file and start the systemd-networkd.service

    root@arm:~# vim /etc/systemd/network/ether.network
        [Match]
        Name=eth*
        [Network]
        DHCP=yes

    root@arm:~# vim /etc/systemd/network/modem.network
        [Match]
        Name=wwan*
        [Network]
        DHCP=yes

    root@arm:~# systemctl enable systemd-networkd
    root@arm:~# systemctl start systemd-networkd

Test if systemd-networkd is working:

    [root@koerkana-origin-20141104 ~]# systemctl status systemd-networkd
    ● systemd-networkd.service - Network Service
       Loaded: loaded (/lib/systemd/system/systemd-networkd.service; enabled)
       Active: active (running) since Tue 2014-11-11 02:00:07 UTC; 2 days ago
         Docs: man:systemd-networkd.service(8)
    ...
    [root@koerkana-origin-20141104 ~]# systemctl status networking
    ● networking.service
       Loaded: not-found (Reason: No such file or directory)
       Active: inactive (dead)

Edit /etc/network/interfaces as is. I think it's not used anymore?:

    source-directory /etc/network/interfaces.d
    auto lo
    iface lo inet loopback

/etc/resolv.conf

    # OpenDNS servers.
    nameserver 208.67.222.222
    nameserver 208.67.220.220

Reboot.


Finish setup with ansible
-------------------------

This will change the root prompt, setup vim, add fstrim and fake-hwclock to crontab. But before you can start using ansible, you'll have to:

  * change hosts.ini as needed
  * ssh-keygen on the beaglebone root to generate the .ssh directory with correct permissions
  * copy your ssh public key to /root/.ssh/authorized_keys


    user@machine:/repositories/iotee/beaglebone-usbasp-cape/debian-install$ ansible-playbook -i hosts.ini general-setup.yml


Troubleshooting:
----------------

You can get an internet connection up like this:

    root@arm:~# ip addr add 192.168.1.230/24 dev eth0
    root@arm:~# ip route add default via 192.168.1.1
    root@arm:~# vi /etc/resolv.conf
        add line: nameserver 8.8.8.8
    root@arm:~# ip link set eth0 up


Step 5: Prepare the image for koerkana purposes
===============================================

First, init some koerkana specific soft/settings with ansible. This will set the root and debian password, copy koerkana scripts and ssh keys.

Run on you computer:

    user@machine:/repositories/iotee/beaglebone-usbasp-cape/debian-install$ ansible-playbook -i hosts.ini koerkana-addons.yml

If ansible finished, then continue here.

    root@arm:~# kana-change-id.sh 0
    root@arm:~# apt-get install flex bison libelf-dev libusb-dev libftdi-dev libusbhid-common

Install avrdude with spidev support
-----------------------------------

This was a reference at some point: 
http://kevincuzner.com/2013/05/27/raspberry-pi-as-an-avr-programmer/

    root@arm:~# apt-get install flex bison libelf-dev libusb-dev libftdi-dev libusbhid-common


    root@arm:~# git clone https://github.com/kcuzner/avrdude.git avrdude-spi

    root@arm:~# cd avrdude-spi/avrdude/
    root@arm:~/avrdude-spi/avrdude# ./bootstrap
    root@arm:~/avrdude-spi/avrdude# ./configure --enable-linuxgpio CPPFLAGS="-DHAVE_LINUX_GPIO=1"
    root@arm:~/avrdude-spi/avrdude# make install
        
    Configuration summary:
    ----------------------
    DO HAVE    libelf
    DO HAVE    libusb
    DON'T HAVE libusb_1_0
    DON'T HAVE libftdi1
    DO HAVE    libftdi
    DON'T HAVE libhid
    DO HAVE    pthread
    DISABLED   doc
    DISABLED   parport
    ENABLED    linuxgpio
    ENABLED    linuxspi


=== Configure avrdude. Select reset pin for avrdude.

Note: to find out the linux gpio to use for a beaglebone pin: http://datko.net/2013/11/11/bbb_atmega328p/

        linuxgpio = numchip * 32 + numpin
        chip one, pin 23 (GPIO1-17): linuxgpio = 1 * 32 + 17 = 49

Edit the file /usr/local/etc/avrdude.conf. change this:

    programmer
      id = "linuxspi";
      desc = "Use Linux SPI device in /dev/spidev*";
      type = "linuxspi";
      reset = 25;
      baudrate=400000;
    ;

to this:

    programmer
      id = "linuxspi1";
      desc = "Use Linux SPI device in /dev/spidev1.0";
      type = "linuxspi";
      reset = 60;
      baudrate=4000000;
    ;

    programmer
      id = "linuxspi2";
      desc = "Use Linux SPI device in /dev/spidev1.0";
      type = "linuxspi";
      reset = 66;
      baudrate=4000000;
    ;        


=== Enable SPI1, switch SPI1 MISO/MOSI pins and enable only serial ports O1 and O4

Turn on/off some serial ports AND swap SPI1 MISO/MOSI (because the board has an error). Make these changes to devicetree files in you kernel tree:

    fdkz@def 15:36:17 :~/bb-image-creation/bb-kernel/KERNEL$ git status
    On branch v3.18-rc7-bone1
    Changes not staged for commit:
      (use "git add <file>..." to update what will be committed)
      (use "git checkout -- <file>..." to discard changes in working directory)

    	modified:   arch/arm/boot/dts/am335x-bone-common-pinmux.dtsi
    	modified:   arch/arm/boot/dts/am335x-bone-spi1-spidev.dtsi
    	modified:   arch/arm/boot/dts/am335x-boneblack.dts


    fdkz@def 15:36:17 :~/bb-image-creation/bb-kernel/KERNEL$ git diff
    diff --git a/arch/arm/boot/dts/am335x-bone-common-pinmux.dtsi b/arch/arm/boot/dts/am335x-bone-common-pinmux.dtsi
    index 3e58be3..4cf3c4e 100644
    --- a/arch/arm/boot/dts/am335x-bone-common-pinmux.dtsi
    +++ b/arch/arm/boot/dts/am335x-bone-common-pinmux.dtsi
    @@ -98,8 +98,8 @@
            spi1_pins: pinmux_spi1_pins {
                    pinctrl-single,pins = <
                            0x190 0x33      /* mcasp0_aclkx.spi1_sclk, INPUT_PULLUP | MODE3 */
    -                       0x194 0x33      /* mcasp0_fsx.spi1_d0, INPUT_PULLUP | MODE3 */
    -                       0x198 0x13      /* mcasp0_axr0.spi1_d1, OUTPUT_PULLUP | MODE3 */
    +                       0x194 0x13      /* mcasp0_fsx.spi1_d0, INPUT_PULLUP | MODE3 */
    +                       0x198 0x33      /* mcasp0_axr0.spi1_d1, OUTPUT_PULLUP | MODE3 */
                            0x19c 0x13      /* mcasp0_ahclkr.spi1_cs0, OUTPUT_PULLUP | MODE3 */
                            // 0x164 0x12   /* eCAP0_in_PWM0_out.spi1_cs1 OUTPUT_PULLUP | MODE2 */
                    >;
    diff --git a/arch/arm/boot/dts/am335x-bone-spi1-spidev.dtsi b/arch/arm/boot/dts/am335x-bone-spi1-spidev.dtsi
    index c116d60..0437c31 100644
    --- a/arch/arm/boot/dts/am335x-bone-spi1-spidev.dtsi
    +++ b/arch/arm/boot/dts/am335x-bone-spi1-spidev.dtsi
    @@ -24,6 +24,7 @@
     &spi1 {
            pinctrl-names = "default";
            pinctrl-0 = <&spi1_pins>;
    +       ti,pindir-d0-out-d1-in = <1>;
            status = "okay";
     
            spidev2: spi@0 {
    diff --git a/arch/arm/boot/dts/am335x-boneblack.dts b/arch/arm/boot/dts/am335x-boneblack.dts
    index 4046455..d061424 100644
    --- a/arch/arm/boot/dts/am335x-boneblack.dts
    +++ b/arch/arm/boot/dts/am335x-boneblack.dts
    @@ -48,7 +48,7 @@
     /* Capes */
     #include "am335x-boneblack-emmc.dtsi"
     /* HDMI: without audio */
    -#include "am335x-boneblack-nxp-hdmi-no-audio.dtsi"
    +//#include "am335x-boneblack-nxp-hdmi-no-audio.dtsi"
     
     /* Max Core Speed */
     #include "am335x-boneblack-1ghz.dtsi"
    @@ -66,7 +66,7 @@
     /* P9.29 spi1_d0 */
     /* P9.30 spi1_d1 */
     /* P9.28 spi1_cs0 */
    -/* #include "am335x-bone-spi1-spidev.dtsi" */
    +#include "am335x-bone-spi1-spidev.dtsi"
     
     /* spi1a: */
     /* P9.42 spi1_sclk */
    @@ -79,13 +79,13 @@
     #include "am335x-ttyO1.dtsi"
     /* #include "am335x-bone-ttyO1.dtsi" */
     /* uart2: P9.21, P9.22 */
    -#include "am335x-ttyO2.dtsi"
    +//#include "am335x-ttyO2.dtsi"
     /* #include "am335x-bone-ttyO2.dtsi" */
     /* uart4: P9.11, P9.13 */
     #include "am335x-ttyO4.dtsi"
     /* #include "am335x-bone-ttyO4.dtsi" */
     /* uart5: P8.37, P8.38 boneblack: hdmi has to be disabled for ttyO5 */
    -#include "am335x-ttyO5.dtsi"
    +//#include "am335x-ttyO5.dtsi"
     /* #include "am335x-bone-ttyO5.dtsi" */
     
     /* Capes */

    ----

    fdkz@def 20:12:24 :~/bb-image-creation/bb-kernel$ vim ./KERNEL/arch/arm/boot/dts/am335x-boneblack.dts
    fdkz@def 20:08:38 :~/bb-image-creation/bb-kernel$ vim ./KERNEL/arch/arm/boot/dts/am335x-bone-common-pinmux.dtsi
    fdkz@def 20:10:03 :~/bb-image-creation/bb-kernel$ vim ./KERNEL/arch/arm/boot/dts/am335x-bone-spi1-spidev.dtsi

Build the kernel (only the changed files will be rebuilt). On the kernel menuconfig just press exit:

    fdkz@def 22:25:55 :~/bb-image-creation/bb-kernel$ ./tools/rebuild.sh
    ...    
    Building dtbs archive...
    Compressing 3.18.0-rc7-bone1-dtbs.tar.gz...
    -rw-rw-r-- 1 fdkz fdkz 952K dets   8 22:25 /home/fdkz/bb-image-creation/bb-kernel/deploy/3.18.0-rc7-bone1-dtbs.tar.gz
    ...
    

And notes on how to get the new devicetree files to the bone SD (has to be mounted):
    
    root@def:/media/fdkz/rootfs/boot/dtbs# mkdir 3.18.0-rc7-bone1
    root@def:/media/fdkz/rootfs/boot/dtbs# tar -zxvf /home/fdkz/bb-image-creation/bb-kernel/deploy/3.18.0-rc7-bone1-dtbs.tar.gz -C /media/fdkz/rootfs/boot/dtbs/3.18.0-rc7-bone1/
    root@def:/media/fdkz# sync
    root@def:/media/fdkz# umount /dev/sdb1


=== Using avrdude

    root@koerkana0 13:43:25 :~# kana-select-port-1.sh; /usr/local/bin/avrdude -clinuxspi1 -P/dev/spidev1.0 -U hfuse:w:0xd8:m -pm128rfa1 -U efuse:w:0xf0:m -U flash:w:/tmp/main.srec:a
    root@koerkana0 13:43:25 :~# kana-select-port-2.sh; /usr/local/bin/avrdude -clinuxspi2 -P/dev/spidev1.0 -U hfuse:w:0xd8:m -pm128rfa1 -U efuse:w:0xf0:m -U flash:w:/tmp/main.srec:a

    scp -P 15000 main.srec root@test2.arupuru.com:/tmp/ ; ssh root@test2.arupuru.com -p 15000 "kana-select-port-1.sh; /usr/local/bin/avrdude -clinuxspi1 -P/dev/spidev1.0 -U hfuse:w:0xd8:m -pm128rfa1 -U efuse:w:0xf0:m -U flash:w:/tmp/main.srec:a"
    
    avrdude -clinuxspi1 -b 5000000 -P/dev/spidev1.0 -U hfuse:w:0xd8:m -pm128rfa1 -U efuse:w:0xf0:m -U flash:w:main.srec:a


FINALLY
=======

Make a copy of the koerkana image and start using it.

  * update bbb emmc bootloader. step 1?
  * insert a new copy of koerkana SD-card, boot.
  * ssh-keygen for a fresh key
  * copy the ssh key to your testserver authorized_keys
  * change bbb id/hostname/autosssh port with: kana-change-id.sh kana_num
  * /opt/scripts/tools/grow_partition.sh
