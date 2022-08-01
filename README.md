# rumlog-portfix

This script attempts to solve the problem of a changing USB UART port name/number
when plugging in various amateur radio transceivers, such as Yaesu, which contain
the Silicon Labs CP210x, and in particular the CP2105 Dual controller.  Those USB
bridge controllers can present to macOS using ever-changing names and numbers.
This script uses hamlib rigctl utility to interrogate the ports until it finds the
correct one.  When it does, it saves the discovered port name and number into
RUMlogNG preferences.

## Prerequisites and Installation
1. You must have [hamlib](https://github.com/Hamlib/Hamlib) installed. The easiest
way to do that is to use [MacPorts](https://www.macports.org).  Once you have
installed MacPorts, issue `sudo port install hamlib`.
1. Configure RUMlogNG to use a supported device (Yaesu only at present).
1. Copy the script from where you have downloaded it `cp rumlog-portfix.sh
   /usr/local/bin/`
1. Allow it to be executable. This may be as easy as `sudo chmod +x
/usr/local/bin/rumlog-portfix.sh` or a little more complex, requiring removal of
quarantine flags, depending how you have copied the file.  If you need to remove
the Apple quarantine flag, issue `xattr -d com.apple.quarantine
/usr/local/bin/rumlog-portfix.sh`
1. If you want to automate the running of the script just prior to running
RUMlogNG, copy the supplied `RunRUMlogNG.app` Apple Script to your Applications
folder. The first time you want to use it you will get a warning that it is not safe
to run because it comes from an unidentified developer. To fix that:
   1. Open your Applications folder in Finder
   1. Right-click on RunRUMlogNG
   1. Select Open
   1. When you get the warning that the app has not been signed by a known developer,
click Open Anyway. That will let you run it from now on. Unfortunately, I am too cheap
to pay Apple for the digital signing certificate. If this utility ever becomes popular,
I may repackage it and pay for the signing cert.

## How to Use Manually

1. Make sure RUMlogNG is NOT running.
1. __Turn ON the radio__ before running the script. It cannot detect the port
   unless the radio is ON.
1. Run the script from terminal using `/usr/bin/rumlog-portfix.sh`
1. Start RUMlogNG

## How to Use Automatically

1. Make sure RUMlogNG is NOT running.
1. __Turn ON the radio.__
1. Run the supplied RunRUMlogNG Apple Script which will run the shell script and
   then it will start RUMlogNG.

## Support for other radios

Currently this script has only been tested with Yaesu FT450D, FTDX3000, and the
SCU-17 interface. There is no reason it should not work with any other models.

It would be quite easy to adapt the script to support other devices. I am happy to
accept contributions.

Rafal Lukawiecki EI6LA raf@rafal.net

## Licence
This software is licensed under the MIT licence. Please see the LICENSE file.
