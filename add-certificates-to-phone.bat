@echo off
:: Set environment variable
set CERT_DIR=certs
set TEMP=tmp
set CERT=cert9.db
set KEY=key4.db
set PKCS11=pkcs11.txt
for /f %%i in ('adb shell "ls -d /data/b2g/mozilla/*.default 2>/dev/null" ^|^| "bin/sed.exe" "s/default.*$/default/g"') do set DB_DIR=%%i

if DB_DIR == "" (
    echo "Profile directory does not exists. Please start the b2g process at least once before running this script."
    pause
)

:: Cleanup
rmdir /s /q %TEMP%
mkdir %TEMP%

:: Pull files from phone
@echo Getting %CERT%
adb pull %DB_DIR%/%CERT% ./%TEMP%/

@echo Getting %KEY%
adb pull %DB_DIR%/%KEY% ./%TEMP%/

@echo Getting %PKCS11%
adb pull %DB_DIR%/%PKCS11% ./%TEMP%/

:: Clear password and add certificates
@echo Set password (hit enter twice to set an empty password)
"bin/nss/certutil.exe" -d %TEMP% -N

@echo Adding certificats
for %%i in (%CERT_DIR%/*) do (
    echo Adding certificate %%i
    "bin/nss/certutil.exe" -d %TEMP% -A -n "`basename %%i`" -t "C,C,TC" -i %CERT_DIR%/%%i
)

:: Push files to phone
@echo Stopping B2G
adb shell stop b2g

@echo copying %CERT%
adb push ./%TEMP%/%CERT% %DB_DIR%/%CERT%
@echo copying %KEY%
adb push ./%TEMP%/%KEY% %DB_DIR%/%KEY%
@echo copying %PKCS11%
adb push ./%TEMP%/%PKCS11% %DB_DIR%/%PKCS11%

@echo Starting B2G
adb shell start b2g

@echo Finished.

pause