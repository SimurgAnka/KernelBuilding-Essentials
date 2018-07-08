# Write device build instructions and data into ./resources/devices/<device>
# By Artx/Stayn <jesusgabriel.91@gmail.com>

# Here we go
# Create config file
touch $CDF/resources/devices/$DEVICE
# File path
FILE=$CDF/resources/devices/$DEVICE
# Write some info into the device file
echo "# Pre-configured file for $DEVICE" > $FILE
echo "# Auto-generated by 'auto' command" >> $FILE
echo "# Usage: auto $DEVICE" >> $FILE
echo " " >> $FILE
# Check source folder
if [ ! -d $CDF/source/* ]; then
echo " "
echo -e "$RED - No Kernel Source Found...$BLD (Kernel source goes into 'source' folder)$RATT"
rm $CDF/resources/devices/$DEVICE
CWK=n
echo " "
return 1
fi

# Prompt for data
echo " "
echo -e "$GREEN$BLD - Please, enter the necessary data for this session...$WHITE"
echo " "
read -p "   Kernel Name: " KERNELNAME; echo "export KERNELNAME=$KERNELNAME" >> $FILE
read -p "   Target Android OS: " TARGETANDROID; echo "export TARGETANDROID=$TARGETANDROID" >> $FILE
read -p "   Version: " VERSION; echo "export VERSION=$VERSION" >> $FILE

#read -p "   Number of Compiling Jobs: " NJOBS; export NJOBS

#until [ "$BLDTYPE" = A ] || [ "$BLDTYPE" = K ]; do
#  read -p "   Enter Build Type (A = AROMA; K = AnyKernel): " BLDTYPE
#  if [ $BLDTYPE != A ] && [ $BLDTYPE != K ]; then
#    echo " "
#    echo -e "$RED - Error, invalid option, try again..."
#    echo -e "$WHITE"
#  fi
#done
echo "export BLDTYPE=K" >> $FILE # Aroma is still not available
export BLDTYPE=K

# Get the ARCH Type
echo " "
echo -e "$GREEN$BLD - Choose ARCH Type ($WHITE 1 = 32Bits Devices; 2 =  64Bits Devices $GREEN$BLD) $WHITE"
until [ "$ARMT" = "1" ] || [ "$ARMT" = "2" ]; do
  read -p "   Your option [1/2]: " ARMT
  if [ "$ARMT" != "1" ] && [ "$ARMT" != "2" ]; then
    echo " "
    echo -e "$RED$BLD - Error, invalid option, try again..."
    echo -e "$WHITE"
  fi
done
if [ "$ARMT" = "1" ]; then
  echo "export ARCH=arm" >> $FILE; export ARCH=arm
  export CROSSCOMPILE=$CDF/resources/crosscompiler/arm/bin/arm-eabi-
elif [ "$ARMT" = "2" ]; then
  echo "export ARCH=arm64" >> $FILE; export ARCH=arm64
  export CROSSCOMPILE=$CDF/resources/crosscompiler/arm64/bin/aarch64-linux-android-
fi

echo "# This will export the correspondent CrossCompiler for the ARCH Type
if [ "$ARCH" = "arm" ]; then
  export CROSSCOMPILE=$CDF/resources/crosscompiler/arm/bin/arm-eabi- # arm CrossCompile
  # Check
  if [ ! -f "$CROSSCOMPILE"gcc ]; then
  git clone https://github.com/KB-E/gcc-$ARCH $CDF/resources/crosscompiler/$ARCH/ &> /dev/null
  fi
elif [ "$ARCH" = "arm64" ]; then
  export CROSSCOMPILE=$CDF/resources/crosscompiler/arm64/bin/aarch64-linux-android-
  # Check
  if [ ! -f "$CROSSCOMPILE"gcc ]; then
  git clone https://github.com/KB-E/gcc-$ARCH $CDF/resources/crosscompiler/$ARCH/ &> /dev/null
  fi
fi" >> $FILE

# AnyKernel Source Select
if [ "$BLDTYPE" = "K" ]; then
  BTYPE=AnyKernel
echo " "
echo -e "$GREEN$BLD - Choose an option for $BTYPE Installer: "
echo " "
echo -e "$WHITE   1) Use local $GREEN$BLD$BTYPE$WHITE Template"
echo -e "   2) Download a Template from your MEGA (If MEGA isn't configured"
echo -e "      this will initialize a 'megacheck' command)"
echo -e "   3) Let me manually set my template"
echo " "
until [ "$AKBO" = "1" ] || [ "$AKBO" = "2" ] || [ "$AKBO" = "3" ]; do
  read -p "   Your option [1/2/3]: " AKBO
  if [ "$AKBO" != "1" ] && [ "$AKBO" != "2" ] && [ "$AKBO" != "3" ]; then
    echo " "
    echo -e "$RED$BLD - Error, invalid option, try again..."
    echo -e "$WHITE"
  fi
done

if [ "$AKBO" = "1" ]; then
  # Tell the makeanykernel script to use the "./out/aktemplates folder for anykernel building"
  echo "export TF=$AKT" >> $FILE
  # If this file is missing we can assume that we need to restore this template
  echo "if [ ! -f $AKT/anykernel.sh ]; then
    checkfolders
    templatesconfig
  fi" >> $FILE
fi

if [ "$AKBO" = "2" ]; then
  # Tell the makeanykernel script to use the "./out/mega_aktemplates folder for anykernel building"
  echo "export TF=$MAKT" >> $FILE
  # If this file is missing we can assume that we need to restore this template
  if [ ! -f $MAKT/anykernel.sh ]; then
    megadlt
  fi
fi
fi

if [ "$AKBO" = "3" ]; then
  # Tell the makeanykernel script to use the "./out/aktemplates folder for anykernel building"
  echo "export TF=$AKT" >> $FILE
fi

echo " "
echo -e "$GREEN$BLD - Select a Kernel Source folder...$WHITE"
cd $CDF/source
select d in */; do test -n "$d" && break; echo " "; echo -e "$RED$BLD>>> Invalid Selection$WHITE"; echo " "; done
cd $CURF
echo -e "$WHITE"
echo "export P=$CDF/source/$d" >> $FILE; P=$CDF/source/$d
read -p "   Debug Kernel Building? [y/n]: " KDEBUG
if [ $KDEBUG = y ] || [ $KDEBUG = Y ]; then
  echo "export KDEBUG=1" >> $FILE
fi
echo " "

# Variant and Defconfig 
read -p "   Device Variant: " VARIANT; echo "export VARIANT=$VARIANT" >> $FILE
echo -e "   Select a Defconfig: " 
cd $P/arch/$ARCH/configs/
select DEF in *; do test -n "$DEF" && break; echo " "; echo -e "$RED$BLD>>> Invalid Selection$WHITE"; echo " "; done
cd $CURF
echo "export DEFCONFIG=$DEF" >> $FILE
echo " "

# Device Tree Image
if [ $ARCH = arm ]; then
  read -p "   Make dt.img? (Device Tree Image) [y/n]: " MKDTB
  if [ "$MKDTB" = "y" ] || [ "$MKDTB" = "Y" ]; then
    echo "export MAKEDTB=1" >> $FILE
  fi
fi

read -p "   Clear Source on every Build? [y/n]: " CLRS
if [ "$CLRS" = "y" ] || [ "$CLRS" = "Y" ]; then
  echo "export CLR=1" >> $FILE
fi

# Clear variables
unset ARCH; unset AKBO; unset KERNELNAME; unset VERSION; unset TARGETANDROID
unset BLDTYPE; unset ARMT; unset BTYPE; unset KDEBUG; unset CURF; unset VARIANT
unset P; unset MKDTB; unset CLRS; unset CROSSCOMPILE

echo -e "$GREEN$BLD - Device configuration file created successfully!"
