#!/bin/bash
#set -x

# RLL 16JUL22
#
# Discover the CAT port for the Yaesu device currently in use by RumLogNG and set it into its
# config.

# Required software
RIGCTL=${RIGCTL:-"rigctl"}
RUMLOGDOM=${RUMLOGDOM:-"de.dl2rum.RUMlogNG"}
YAESU=${YAESU:-"Yaesu"}
SLAB=${SLAB:-"SLAB"}

# Main section
RIGCTLCMD=`which $RIGCTL`
if [ -z "$RIGCTLCMD" ]; then
    if [ -f "/opt/local/bin/rigctl" ]; then
        RIGCTLCMD="/opt/local/bin/rigctl"
    else
        echo "Error: hamlib rigctl not installed. Please install and run again."
        exit 1
    fi
else
    echo "Error: hamlib rigctl not installed. Please install and run again."
    exit 1
fi

defaults domains | grep -q $RUMLOGDOM
if [ $? -ne 0 ]; then
    echo "Error: RumLogNG not installed. This utility is designed to work with RumLogNG only."
    exit 1
fi

# Figure out which Trx config (1 or 2) to use
TRXID=`defaults read $RUMLOGDOM | grep -m1 $YAESU | awk '{print($1)}'`
if [ -z "$TRXID" ]; then
    echo "Error: Cannot find a $YAESU transceiver in RumLogNG configuration. This utility only works with Yaesu devices."
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

HAMLIBID=`$RIGCTLCMD -l | grep -E "$YAESU.*$TRXFAMILY.*$TRXNUMERICCODE" | awk '{print($1)}'`
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
    echo "Error: Could not discover the serial port name. Is the device plugged in and turned on? Are the drivers installed?"
    exit 1
fi

# Set the port name as found
echo "Port name is $TRXSERIALPORTNAME"
defaults write $RUMLOGDOM $TRXSERIALPORTKEY $TRXSERIALPORTNAME

exit 0
