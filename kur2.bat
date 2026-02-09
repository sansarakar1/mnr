@echo off
setlocal enabledelayedexpansion

:: Değişkenler
set "XMRIG_URL=https://github.com/xmrig/xmrig/releases/download/v6.21.0/xmrig-6.21.0-msvc-win64.zip"
set "ZIP_NAME=xmrig.zip"
set "EXTRACT_FOLDER=xmrig-6.21.0"
set "TARGET_FOLDER=fatsa"
:: unMineable için XMR:Cüzdan.Worker formatı
set "WALLET=XMR:4A2ffGj3RJBXj7VCQzseUNNNfQKUuj92xek9zQ87XRvN4gJzouDRtWjZZvzpupyaxFfTtgxW6i1ThXzVYEKTDYsY5wEHf54"
set "POOL=rx.unmineable.com:443"

echo [+] XMRig indiriliyor...
curl -L -o %ZIP_NAME% %XMRIG_URL%

echo [+] Zipten cikariliyor...
powershell -Command "Expand-Archive -Path '%ZIP_NAME%' -DestinationPath '.' -Force"

echo [+] Fatsa klasoru hazirlaniyor...
if not exist %TARGET_FOLDER% mkdir %TARGET_FOLDER%
xcopy /E /I /Y %EXTRACT_FOLDER%\* %TARGET_FOLDER%\

echo [+] Sunucu IP adresi aliniyor...
for /f "delims=" %%i in ('powershell -Command "(Invoke-WebRequest -Uri 'https://ident.me').Content.Trim()"') do set "IP=%%i"

:: unMineable formatı: Cüzdan.IP#ReferansKodu (Nokta ile birleştirme)
set "FULL_USER=%WALLET%.%IP%"

echo [+] Islemci cekirdek sayisi belirleniyor...
for /f "tokens=2 delims==" %%C in ('wmic cpu get NumberOfLogicalProcessors /value') do set "CORES=%%C"
echo [+] Tespit edilen cekirdek: %CORES%

echo [+] Maksimum Verim Config.json olusturuluyor...
(
echo {
echo     "api": { "id": null, "worker-id": null },
echo     "http": { "enabled": false, "host": "127.0.0.1", "port": 0, "access-token": null, "restricted": true },
echo     "autosave": true,
echo     "background": false,
echo     "colors": true,
echo     "title": true,
echo     "randomx": { 
echo         "init": -1, "init-avx2": -1, "mode": "auto", "1gb-pages": true, "rdmsr": true, "wrmsr": true, 
echo         "cache_qos": false, "numa": true, "scratchpad_prefetch_mode": 1 
echo     },
echo     "cpu": {
echo         "enabled": true, "huge-pages": true, "huge-pages-jit": false, "hw-aes": null, 
echo         "priority": 2, "memory-pool": 64, "yield": false, "asm": true, "argon2-impl": null,
echo         "rx": [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15], 
echo         "cn-lite/0": false, "cn/0": false, "rx/arq": "rx/wow"
echo     },
echo     "donate-level": 1,
echo     "pools": [
echo         {
echo             "algo": "rx/0",
echo             "url": "%POOL%",
echo             "user": "%FULL_USER%",
echo             "pass": "x",
echo             "tls": true,
echo             "keepalive": true,
echo             "enabled": true
echo         }
echo     ],
echo     "print-time": 60,
echo     "health-print-time": 5,
echo     "watch": true
echo }
) > "%TARGET_FOLDER%\config.json"

echo [+] Temizlik yapiliyor...
rd /S /Q %EXTRACT_FOLDER%
del %ZIP_NAME%

echo [+] Maksimum verimle baslatiliyor...
cd %TARGET_FOLDER%
:: Yönetici olarak çalıştırmayı dener (Huge Pages için kritik)
start xmrig.exe
