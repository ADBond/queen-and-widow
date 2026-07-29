#!/bin/sh
# https://stackoverflow.com/a/21370675
DaySuffix() {
  case `date +%d` in
    01|21|31) echo "st";;
    02|22)    echo "nd";;
    03|23)    echo "rd";;
    *)       echo "th";;
  esac
}

TZ='UTC' date "+%I:%M %p (%Z), %A the %d`DaySuffix` of %B %Y" 
