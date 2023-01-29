#!/bin/bash
# set -x

# RLL 27JUL22
#
# Discover the CAT port for the Yaesu device currently in use by RumLogNG and set it into its
# config. This script can be adapted to cater for other transceivers if needed. Please get in
# touch if needed.

# MIT License

# Copyright (c) 2022 Rafal Lukawiecki

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# Required software
RIGCTL=${RIGCTL:-"rigctl"}
RIGCTLOPT=${RIGCTLOPT:-"/usr/local/bin/rigctl"}
RUMLOGDOM=${RUMLOGDOM:-"de.dl2rum.RUMlogNG"}
YAESU=${YAESU:-"Yaesu"}
SLAB=${SLAB:-"SLAB"}

# Main section
RIGCTLCMD=`which $RIGCTL`
if [ -z "$RIGCTLCMD" ]; then
    if [ -f "$RIGCTLOPT" ]; then
        RIGCTLCMD="$RIGCTLOPT"
    else
        echo "Error: hamlib rigctl not installed. Please install and run again."
        exit 1
    fi
fi

defaults domains | grep -q $RUMLOGDOM
if [ $? -ne 0 ]; then
    echo "Error: RumLogNG not installed. This utility is designed to work with RumLogNG only."
    exit 1
fi

# Figure out which Trx config (1 or 2) to use
TRXID=`defaults read $RUMLOGDOM | grep -im1 $YAESU | awk '{print($1)}'`
if [ -z "$TRXID" ]; then
    echo "Error: Cannot find a $YAESU transceiver in RumLogNG configuration. This utility only works with $YAESU devices."
    exit 1
fi

if [[ $TRXID =~ "_2" ]]; then
    TRXSERIALPORTKEY="TrxSerialPort_2"
    TRXMODELKEY="TrxName_2"
else
    TRXSERIALPORTKEY="TrxSerialPort"
    TRXMODELKEY="TrxName"
fi

# Find the hamlib ID of the matching transceiver
TRXMODEL=`defaults read $RUMLOGDOM $TRXMODELKEY`
TRXFAMILY=`sed -E 's/(..).*/\1/' <<< $TRXMODEL`
TRXNUMERICCODE=`sed -E 's/[^[:digit:]]*([[:digit:]]+).*/\1/' <<< $TRXMODEL`

HAMLIBID=`$RIGCTLCMD -l | grep -iE "$YAESU.*$TRXFAMILY.*-$TRXNUMERICCODE " | awk '{print($1)}'`
if [ -z "$HAMLIBID" ]; then
    echo "Error: $YAESU $TRXMODEL is not supported by hamlib and therefor not by this utility."
    exit 1
fi

TRXSERIALPORTNAME=""
for f in /dev/tty.*$SLAB*; do
    $RIGCTLCMD -m $HAMLIBID -r $f _ 2> /dev/null >/dev/null
    if [ $? -eq 0 ]; then
        TRXSERIALPORTNAME=`sed -E 's/.*tty\.(.*)/\1/' <<< $f`
        break
    fi
done

if [ -z "$TRXSERIALPORTNAME" ]; then
    echo "Error: Could not discover the serial port name. Is the $YAESU device plugged in and turned on?"
    exit 1
fi

# Set the port name as found
echo "Port name is $TRXSERIALPORTNAME"
defaults write $RUMLOGDOM $TRXSERIALPORTKEY $TRXSERIALPORTNAME

exit 0
