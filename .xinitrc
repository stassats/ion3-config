#!/bin/sh

setxkbmap "us,ru(winkeys)" -option -option ctrl:nocaps,grp:toggle,grp_led:caps
xset r rate 500 30
xset m 2 9

exec ion3
