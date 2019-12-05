# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=Matrix-Kernel by abhijiths362 @ xda-developers
do.devicecheck=1
do.modules=0
do.cleanup=1
do.cleanuponabort=0
device.name1=beryllium
device.name2=PocoF1
device.name3=
device.name4=
device.name5=
supported.versions=
supported.patchlevels=
'; } # end properties

# shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=0;
ramdisk_compression=auto;


## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. tools/ak3-core.sh;


## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
set_perm_recursive 0 0 755 644 $ramdisk/*;
set_perm_recursive 0 0 750 750 $ramdisk/init.qcom.rc $ramdisk/sbin;


## AnyKernel install
dump_boot;

# migrate from /overlay to /overlay.d to enable SAR Magisk
if [ -d $ramdisk/overlay ]; then
  rm -rf $ramdisk/overlay;
fi;

# use custom kernel compression
kernel_compression=gzip;
kernel_comp_ext=gz;


# combine kernel image and dtbs if separated in the zip
decompressed_image=$home/kernel/Image;
compressed_image=$decompressed_image.$kernel_comp_ext;
combined_image=$home/Image.$kernel_comp_ext-dtb;
if [ -f $compressed_image ]; then
  # hexpatch the kernel if Magisk is installed ('skip_initramfs' -> 'want_initramfs')
  if ! $bin/magiskboot cpio $split_img/ramdisk.cpio test; then
    ui_print " " "Magisk detected! Patching kernel so reflashing Magisk is not necessary...";
    $bin/magiskboot --decompress $compressed_image $decompressed_image;
    $bin/magiskboot --hexpatch $decompressed_image 736B69705F696E697472616D667300 77616E745F696E697472616D667300;
    $bin/magiskboot --compress=$kernel_compression $decompressed_image $compressed_image;
  fi;
  if [ -d $home/dtbs ]; then
    cat $compressed_image $home/dtbs/*.dtb > $combined_image;
  else
    mv -f $compressed_image $home;
  fi;
fi;

write_boot;
## end install

