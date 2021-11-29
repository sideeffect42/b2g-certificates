# b2g-certificates

A shell script to add root certificates to Firefox OS

[Original README](README-original.md)

## Usage
For Linux shell:
```bash
Usage: add-certificates-to-phone.sh [-r] (dir) | [-d] | [-h]

-r (dir) Enter the NSS DB root directory ( Such as Nokia, enter /data/b2g/mozilla )
         Some phones may be different.
         For more information, please visit: https://github.com/openGiraffes/b2g-certificates
-d Use default directory (/data/b2g/mozilla)
-h Output this help.
```

Linux (Debian & Ubuntu): 

```bash
sudo apt install libnss3-tools adb wget
git clone https://github.com/openGiraffes/b2g-certificates
cd b2g-certificates

chmod +x ./add-certificates-to-phone.sh
./add-certificates-to-phone.sh -d # For Nokia user

# If you are using WSL, please run this (Need to add Android Platform Tools directory to PATH)
chmod +x ./add-certificates-to-phone-wsl.sh
./add-certificates-to-phone-wsl.sh -d # For Nokia user
```

Windows Batch(Need to add Android Platform Tools directory to PATH):

```
add-certificates-to-phone.bat

Enter the NSS DB root directory ( Such as Nokia, enter /data/b2g/mozilla )
Some phones may be different.
For more information, please visit: https://github.com/openGiraffes/b2g-certificates

(Enter the path here)
```

NSS certutil compiled by myself.

`sed.exe` from [mbuilov/sed-windows](https://github.com/mbuilov/sed-windows)
