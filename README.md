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

# If you are using WSL, please run this (Need to set Android Platform Tools as an environment variable)
chmod +x ./add-certificates-to-phone-wsl.sh
./add-certificates-to-phone-wsl.sh
```

Windows Batch(Testing and NSS `certutil` reported an error):

```batch
add-certificates-to-phone.bat
```

NSS (Windows, 3.35.0, fron AdGuard) `certutil` reported an error:
```
certutil.exe: function failed: SEC_ERROR_LEGACY_DATABASE: The certificate/key database is in an old, unsupported format.
```

