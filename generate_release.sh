#!/bin/sh

onquit() {
    rm $tmp
    test $clear && {
        clear
        echo cleared
    }
    echo done
}

dlg="dialog --clear --title `basename $0`"

version=
prerelease=
arch=
clear=`false`

# Open temp file
tmp=$(mktemp)

# Call onquit on exit
trap onquit EXIT

# Get version
$dlg --inputbox "Version Number:" 5 10 2> $tmp

if [ $? -eq 1 ]; then
    # cancel
    clear=`true`
    echo 'aborted'
    exit
fi

version=`cat $tmp`

# Prerelease
$dlg --yesno "Is this a prerelease?" 5 50

if [ $? -eq 0 ]; then
    # yes
    $dlg --inputbox "Prerelase Name:" 5 10 2> $tmp
    prerelease=`cat $tmp`
    prerelease="-$prerelease"
fi

# Arch
$dlg --menu "Choose Arch:" 15 40 10 linux "Linux/X11" windows "Windows Desktop" 2> $tmp

if [ $? -eq 1 ]; then
    # cancel
    clear=`true`
    echo 'aborted'
    exit
fi

arch=`cat $tmp`

# Dialogs are done, so clear the screen
clear

zipfile="todolist-v$version${prerelease}_$arch.zip"

zip -mT releases/$zipfile bin/$arch/*
