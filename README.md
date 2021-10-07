# b2g-certificates

A shell script to add root certificates to Firefox OS

[Original README](README-original.md)

Linux (Debian & Ubuntu): 

```bash
sudo apt-get install libnss3-tools adb wget
git clone https://github.com/openGiraffes/b2g-certificates
cd b2g-certificates

chmod +x ./add-certificates-to-phone.sh
./add-certificates-to-phone.sh

# If you are using WSL, please run this (Need to add Android Platform Tools directory to PATH)
chmod +x ./add-certificates-to-phone-wsl.sh
./add-certificates-to-phone-wsl.sh
```

Windows Batch(Need to add Android Platform Tools directory to PATH):

```batch
add-certificates-to-phone.bat
```

P.S.: NSS certutil compiled by myself.
