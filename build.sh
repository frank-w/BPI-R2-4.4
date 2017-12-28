#!/bin/bash
# (c) 2015, 2016, Leo Xu <otakunekop@banana-pi.org.cn>
# Build script for BPI-M2U-BSP 2016.09.10

TARGET_PRODUCT="bpi-r2"
BOARD=BPI-R2-720P
board="bpi-r2"
kernver=$(cd linux-mt;make kernelversion)
#kernel="4.4.108-BPI-R2-Kernel"
kernel=${kernver}"-BPI-R2-Kernel"
MODE=$1
BPILINUX=linux-mt
BPIPACK=mt-pack
BPISOC=mtk
RET=0

cp_download_files()
{
T="$TOPDIR"
SD="$T/SD"
U="${SD}/100MB"
B="${SD}/BPI-BOOT"
R="${SD}/BPI-ROOT"
	#
	## clean SD dir.
	#
	rm -rf $SD
	#
	## create SD dirs (100MB, BPI-BOOT, BPI-ROOT) 
	#
	mkdir -p $SD
	mkdir -p $U
	mkdir -p $B
	mkdir -p $R
	#
	## copy files to 100MB
	#
	cp -a $T/out/${TARGET_PRODUCT}/100MB/* $U
	#
	## copy files to BPI-BOOT
	#
	mkdir -p $B/bananapi/${board}
	cp -a $T/${BPIPACK}/${BPISOC}/${TARGET_PRODUCT}/configs/default/linux $B/bananapi/${board}/
	cp -a $T/${BPILINUX}/arch/arm/boot/uImage $B/bananapi/${board}/linux/uImage

	#
	## copy files to BPI-ROOT
	#
	mkdir -p $R/usr/lib/u-boot/bananapi/${board}
	cp -a $U/*.gz $R/usr/lib/u-boot/bananapi/${board}/
	rm -rf $R/lib/modules
	mkdir -p $R/lib/modules
	cp -a $T/${BPILINUX}/output/lib/modules/${kernel} $R/lib/modules
	#
	## create files for bpi-tools & bpi-migrate
	#
	(cd $B ; tar czvf $SD/${kernel}-BPI-BOOT-${board}.tgz .)
	(cd $R ; tar czvf $SD/${kernel}-net.tgz lib/modules/${kernel}/kernel/net)
	(cd $R ; mv lib/modules/${kernel}/kernel/net $R/net)
	(cd $R ; tar czvf $SD/${kernel}.tgz lib/modules)
	(cd $R ; mv $R/net lib/modules/${kernel}/kernel/net)
	(cd $R ; tar czvf $SD/BOOTLOADER-${board}.tgz usr/lib/u-boot/bananapi)
	(cd $SD ; md5sum ${kernel}-BPI-BOOT-${board}.tgz ${kernel}.tgz > ${kernel}.md5)
	return #SKIP
}

list_boards() {
	cat <<-EOT
	NOTICE:
	new build.sh default select $BOARD and pack all boards
	supported boards:
	EOT
        (cd ${BPIPACK}/${BPISOC}/${TARGET_PRODUCT}/configs ; ls -1d BPI* )
	echo
}

list_boards

./configure $BOARD

if [ -f env.sh ] ; then
	. env.sh
fi

if [[ -z "$(which arm-linux-gnueabihf-gcc)" ]];then echo "please install first gcc-arm-linux-gnueabihf";exit 1;fi
if [[ -z "$(which mkimage)" ]];then echo "please install first u-boot-tools";exit 1;fi

echo "This tool support following building mode(s):"
echo "--------------------------------------------------------------------------------"
echo "	1. Build all, uboot and kernel and pack to download images."
echo "	2. Build uboot only."
echo "	3. Build kernel only."
echo "	4. kernel configure."
echo "	5. Pack the builds to target download image, this step must execute after u-boot,"
echo "	   kernel and rootfs build out"
echo "	6. update files for SD"
echo "	7. Clean all build."
echo "--------------------------------------------------------------------------------"

if [ -z "$MODE" ]; then
	read -p "Please choose a mode(1-7): " mode
	echo
else
	mode=1
fi

if [ -z "$mode" ]; then
        echo -e "\033[31m No build mode choose, using Build all default   \033[0m"
        mode=1
fi

echo -e "\033[33m Now building...\033[0m"
echo
ret=1

logfile="$(dirname $0)/build.log"
exec 3> >(tee $logfile)

case $mode in
	1) make 2>&3 &&
	   make pack 2>&3 &&
	   cp_download_files &&
       ret=0
           ;;
	2) make u-boot 2>&3 &&ret=0;;
	3) make kernel 2>&3 &&ret=0;;
	4) make kernel-config && ret=0;;
	5) make pack 2>&3 && ret=0;;
	6) cp_download_files && ret=0;;
	7) make clean && ret=0;;
esac

exec 3>&-

echo

if [ "$ret" -eq "0" ];
then
  echo -e "\033[32m Build success!\033[0m"
else
  echo -e "\033[31m Build failed!\033[0m"
fi
echo
