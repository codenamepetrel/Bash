#!/bin/bash

EXE="/Library/FireEye/xagt/xagt.app/Contents/MacOS/bin/xagt"
PLIST="/Library/LaunchDaemons/com.fireeye.xagt.plist"
NOTIF_PLIST="/Library/LaunchAgents/com.fireeye.xagtnotif.plist"
BINDIR="/Library/FireEye/xagt"
BINDIRBASE="/Library/FireEye"
DATADIR="/Library/Application Support/FireEye/xagt"
DATADIRBASE="/Library/Application Support/FireEye"
SHAREDDIR="/Library/Application Support/FireEye/shared"
DRIVERKEXT="/Library/Extensions/FireEye.kext/"

#echo '  __ _          '
#echo ' / _(_)         '
#echo '| |_ _ _ __ ___ '
#echo '|  _| | '__/ _ \'
#echo '| | | | | |  __/'
#echo '|_| |_|_|  \___|guy'
                
echo "Removing Fireeye. Let it burn."
echo "Begin...."

if [ -f "$PLIST" ]; then
    echo "$PLIST exists. Removing now." 
    if pkgutil --pkg-info "com.fireeye.xagt" &> /dev/null; then
        if pgrep -q -x xagt ; then
            launchctl unload -w "$PLIST"
        fi
        rm -f "$PLIST"
    fi
fi
if [ -f "$NOTIF_PLIST" ]; then
    echo "$NOTIF_PLIST exists. Removing now."
    #unload xagtnotif from all users sessions
    for process_info in $(ps -axo uid=,user=,args= | grep -i "[x]agtnotif.app" | awk '{print $1 "," $2}'); do
        user_uid=$(echo $process_info | cut -d, -f1)
        user_name=$(echo $process_info | cut -d, -f2)
        launchctl asuser $user_uid launchctl unload -w "$NOTIF_PLIST"
    done
    rm -f "$NOTIF_PLIST"
fi
if [ -f "$EXE" ]; then 
    echo "$EXE exists. Removing now."
    "$EXE" --uninstall
    rm -rf "$BINDIR"
fi
if [ -d "$DATADIR" ]; then
    echo "$DATADIR exists. Removing now." 
    rm -rf "$DATADIR"
fi
if [ -d "$SHAREDDIR" ]; then
    echo "$SHAREDDIR exists.  Removing now." 
    rm -rf "$SHAREDDIR"
fi
if [ -d "$BINDIRBASE" ]; then
    echo "$BINDIRBASE exists. Removing now."
    if [ -z "$(ls -A "$BINDIRBASE")" ]; then
        rm -rf "$BINDIRBASE"
    fi
fi
if [ -d "$DATADIRBASE" ]; then
    echo "$DATADIRBASE exists. Removing now."
    if [ -z "$(ls -A "$DATADIRBASE")" ]; then
        rm -rf "$DATADIRBASE"
    fi
fi
if pkgutil --pkg-info "com.fireeye.xagt" &> /dev/null; then
    pkgutil --forget com.fireeye.xagt &> /dev/null;
fi

if pkgutil --pkg-info "com.fireeye.xagtnotif" &> /dev/null; then
    pkgutil --forget com.fireeye.xagtnotif &> /dev/null;
fi

if [ -d "$DRIVERKEXT" ]; then 
    echo "$DRIVERKEXT exists. Removing now."
    rm -rf "$DRIVERKEXT"
fi

echo "Change dir to tmp"
cd /tmp
echo "What dir are you in?"
pwd
echo "Attaching FireEye DMG image."
hdiutil attach IMAGE_HX_AGENT_OSX_29.7.8.dmg
#cd "/Volumes/FireEye\ Agent\"
cd "/Volumes/FireEye Agent"/""
echo "Changing dir"
sudo installer -pkg xagtSetup_29.7.8.pkg -target "/"
hdiutil detach "/Volumes/FireEye Agent"/"" -force
hdiutil detach "/Volumes/FireEye Agent 1"/"" -force
echo "Finished installing."
echo "zzzzzzz........"
