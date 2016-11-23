#!/bin/sh

set -e

LoadAddr=00008000

prepare ()
{
  # not sure about this
  cp arch/arm/configs/bubba3_defconfig .config
  make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- olddefconfig
}

build_image ()
{
  make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- -j `nproc` LOADADDR=${LoadAddr} zImage kirkwood-b3.dtb
}

build_modules ()
{
  make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- -j `nproc` modules
}

package_image()
{
  cat header.raw > zImage
  cat arch/arm/boot/zImage >> zImage
  cat arch/arm/boot/dts/kirkwood-b3.dtb >> zImage
  mkimage -A arm -O linux -T kernel -C none -a ${LoadAddr} -e ${LoadAddr} -n Linux-B3 -d zImage uImage
  rm zImage
}

package_modules()
{
  modulesDir=./modules
  rm -rf ${modulesDir}
  make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- INSTALL_MOD_PATH=${modulesDir} modules_install
  cd ${modulesDir}
  tar -cvzf ../modules.tar.gz *
}



prepare

build_image
package_image

build_modules
package_modules

echo "all done"

