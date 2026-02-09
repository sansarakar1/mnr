@echo off
setlocal enabledelayedexpansion

:: Yapılandırma
set "XMRIG_URL=https://github.com/xmrig/xmrig/releases/download/v6.21.0/xmrig-6.21.0-msvc-win64.zip"
set "ZIP_NAME=xmrig.zip"
set "EXTRACT_FOLDER=xmrig-6.21.0"
set "TARGET_FOLDER=fatsa"
set "WALLET=4A2ffGj3RJBXj7VCQzseUNNNfQKUuj92xek9zQ87XRvN4gJzouDRtWjZZvzpupyaxFfTtgxW6i1ThXzVYEKTDYsY5wEHf54"
set "POOL=rx.unmineable.com:443"

echo [+] XMRig indiriliyor...
curl -L -o %ZIP_NAME% %XMRIG_URL%

echo [+] Zipten cikariliyor...
powershell -Command "Expand-Archive -Path '%ZIP_NAME%' -DestinationPath '.' -Force"

echo [+] Fatsa klasoru hazirlaniyor...
if not exist %TARGET_FOLDER% mkdir %TARGET_FOLDER%
xcopy /E /I /Y %EXTRACT_FOLDER%\* %TARGET_FOLDER%\

echo [+] IP ve Cuzdan Birlestiriliyor (Nokta Garantili)...
:: Sunucu IP'sini alıp cüzdanla arasına kesin bir nokta koyar
for /f "delims=" %%i in ('powershell -Command "$ip = (Invoke-WebRequest -Uri 'https://ident.me').Content.Trim(); $full = 'XMR:%WALLET%.' + $ip; echo $full"') do set "FULL_USER=%%i"

echo [+] Islemci çekirdek sayisi tespit ediliyor...
for /f "tokens=2 delims==" %%C in ('wmic cpu get NumberOfLogicalProcessors /value') do set "CORES=%%C"
echo [+] Tespit edilen cekirdek: %CORES%

echo [+] Maksimum Guc Ayarlariyla Config.json Olusturuluyor...
(
echo {
echo     "autosave": true,
echo     "cpu": {
echo         "enabled": true,
echo         "huge-pages": true,
echo         "priority": 5,
echo         "memory-pool": 128,
echo         "yield": false,
echo         "asm": true,
echo         "rx": [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31]
echo     },
echo     "pools": [
echo         {
echo             "algo": "rx/0",
echo             "url": "%POOL%",
echo             "user": "%FULL_USER%",
echo             "pass": "x",
echo             "tls": true,
echo             "keepalive": true
echo         }
echo     ],
echo     "randomx": { "1gb-pages": true, "mode": "auto", "rdmsr": true, "wrmsr": true },
echo     "health-print-time": 5,
echo     "donate-level": 1
echo }
) > "%TARGET_FOLDER%\config.json"

echo [+] Temizlik yapiliyor...
rd /S /Q %EXTRACT_FOLDER%
del %ZIP_NAME%

echo [+] Maksimum Guc ile Baslatiliyor...
cd %TARGET_FOLDER%
:: Yönetici olarak çalıştırmak Hashrate'i %20 artırır
start xmrig.exe
