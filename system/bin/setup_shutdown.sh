#!/system/bin/sh
#
# Copyright (c) 2016, Motorola LLC  All rights reserved.
#
# Shutdown phone if setup screen is active while phone appears to be in a box.
#

# Bail-out conditions:  Setup-check has already run once and saw the device
# wasn't running setup, or the boot mode isn't normal.

if [ -e /data/.nosetupcheck ]; then
   exit
fi

BOOTMODE=`getprop ro.bootmode`

if [ $BOOTMODE != "normal" ]; then
   exit
fi

# Wait 60 minutes.  Can't do a simple sleep, since it does not progress in suspend.

while true; do
   echo wait for 60 minutes of uptime.
   UPTIME=($(</proc/uptime))
   UPTIME=${UPTIME%%.*}
   if [ $UPTIME -gt 3600 ]; then
      echo done
      break
   fi
   sleep 1
done

ACTIVITY=`dumpsys activity provider com.android.providers.settings/.SettingsProvider | grep user_setup_complete`

WIZARD_UP=`echo $ACTIVITY | grep -c value:0`

SCREEN_OFF=`dumpsys power | grep -c "Display Power: state=OFF"`

if [ $WIZARD_UP -gt 0 ] && [ $SCREEN_OFF -gt 0 ]; then
    echo Wizard is up and the screen is off- shutdown
    setprop sys.powerctl shutdown
fi


if [ $WIZARD_UP -eq 0 ]; then
    echo Disable this setup check for future boots.
    echo 1 > /data/.nosetupcheck
fi
