#!/bin/sh

#        -lf/nf/cf color
#            Defines the foreground color for low, normal and critical notifications respectively.
#
#        -lb/nb/cb color
#            Defines the background color for low, normal and critical notifications respectively.
#
#        -lfr/nfr/cfr color
#            Defines the frame color for low, normal and critical notifications respectively.

pidof dunst && killall dunst

DUNST_FILE=~/.config/dunst/dunstrc

dunst -config ~/.config/dunst/dunstrc > /dev/null 2>&1 &
