# Запуск GardenPlan на емуляторі та збір скриншотів для звіту (лабораторна №4)
# 1) запускає емулятор (якщо не запущений)
# 2) вмикає DebugView для Firebase Analytics
# 3) flutter analyze + flutter test
# 4) інтеграційний тест проходить сценарії, скрипт робить скриншоти через adb
# 5) перезапускає застосунок, щоб показати відновлення сеансу
# Лог: scripts\logs\run_log.txt, скриншоти: report_screens\

$ErrorActionPreference = 'Continue'
$ProjectDir = Split-Path -Parent $PSScriptRoot
$LogDir = Join-Path $PSScriptRoot 'logs'
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
$Log = Join-Path $LogDir 'run_log.txt'
Start-Transcript -Path $Log -Force | Out-Null
Set-Location $ProjectDir

$Package = 'com.example.lab1'
$Screens = Join-Path $ProjectDir 'report_screens'

function Step($text) { Write-Host ''; Write-Host "===== $text =====" -ForegroundColor Green }
# вивід зовнішніх програм пропускаємо через конвеєр, щоб він потрапив у лог
function Run($cmd) { cmd /c "$cmd 2>&1" | Out-Host; return $LASTEXITCODE }

# --- шляхи до Flutter і Android SDK з android\local.properties
$props = Get-Content (Join-Path $ProjectDir 'android\local.properties')
function Prop($name) { (($props | Where-Object { $_ -like "$name=*" }) -replace "$name=", '') -replace '\\\\', '\' -replace '\\:', ':' }
$FlutterSdk = Prop 'flutter.sdk'
$AndroidSdk = Prop 'sdk.dir'
$env:Path = "$FlutterSdk\bin;$AndroidSdk\platform-tools;$AndroidSdk\emulator;$env:Path"
$adb = Join-Path $AndroidSdk 'platform-tools\adb.exe'
$emulator = Join-Path $AndroidSdk 'emulator\emulator.exe'

# --- 1. емулятор
Step '1. Емулятор'
$devices = & $adb devices | Select-String -Pattern 'emulator-\d+\s+device'
if (-not $devices) {
    $avds = & $emulator -list-avds
    Write-Host "Доступні емулятори: $($avds -join ', ')"
    $avd = ($avds | Where-Object { $_ -match 'Pixel_7' } | Select-Object -First 1)
    if (-not $avd) { $avd = $avds | Select-Object -First 1 }
    Write-Host "Запускаю $avd ..."
    Start-Process -FilePath $emulator -ArgumentList "-avd $avd"
    & $adb wait-for-device
    do { Start-Sleep -Seconds 3; $boot = (& $adb shell getprop sys.boot_completed).Trim() } while ($boot -ne '1')
    Start-Sleep -Seconds 5
}
$device = ((& $adb devices | Select-String -Pattern '^(emulator-\d+)\s+device').Matches[0].Groups[1].Value)
Write-Host "Пристрій: $device"

# --- 2. DebugView для Analytics (події видно в консолі одразу)
Step '2. Firebase Analytics DebugView'
& $adb -s $device shell setprop debug.firebase.analytics.app $Package
& $adb -s $device shell setprop log.tag.FA VERBOSE

# --- 3. перевірка коду
Step '3. flutter pub get / analyze / test'
Run 'flutter pub get' | Out-Null
Run 'flutter analyze' | Out-Null
Run 'flutter test' | Out-Null

# --- 4. інтеграційний тест; скриншоти знімаємо через adb за позначками GP_SHOT
Step '4. Інтеграційний тест на емуляторі (~5-10 хв), не клікай в емуляторі'
if (Test-Path $Screens) { Remove-Item -Recurse -Force $Screens }
New-Item -ItemType Directory -Force -Path $Screens | Out-Null
$script:account = ''
$script:password = 'Garden2026'
cmd /c "flutter test integration_test/app_test.dart -d $device --reporter expanded 2>&1" | ForEach-Object {
    Write-Host $_
    if ($_ -match 'GP_ACCOUNT:(\S+)') { $script:account = $Matches[1] }
    if ($_ -match 'GP_PASSWORD_CHANGED') { $script:password = 'Sadivnyk2026' }
    if ($_ -match 'GP_SHOT:([A-Za-z0-9_]+)') {
        $name = $Matches[1]
        & $adb -s $device shell screencap -p /sdcard/gp_shot.png
        & $adb -s $device pull /sdcard/gp_shot.png (Join-Path $Screens "$name.png") | Out-Null
        Write-Host "   >>> скриншот: $name.png" -ForegroundColor Cyan
    }
}
Write-Host "flutter test exit code: $LASTEXITCODE"

# --- 5. звичайний запуск: відновлення сеансу + відправка звіту crashlytics
Step '5. Перезапуск застосунку (відновлення сеансу)'
Run 'flutter build apk --debug' | Out-Null
& $adb -s $device install -r 'build\app\outputs\flutter-apk\app-debug.apk' | Out-Host
& $adb -s $device shell am force-stop $Package
& $adb -s $device shell monkey -p $Package -c android.intent.category.LAUNCHER 1 | Out-Null
Start-Sleep -Seconds 20
if ($script:account) {
    # вхід тестовим акаунтом через adb (екран 1080x2400)
    Write-Host "Вхід акаунтом $script:account"
    & $adb -s $device shell input tap 500 912
    & $adb -s $device shell input text $script:account
    & $adb -s $device shell input tap 500 1108
    & $adb -s $device shell input text $script:password
    & $adb -s $device shell input keyevent 111
    Start-Sleep -Seconds 1
    & $adb -s $device shell input tap 500 1292
    Start-Sleep -Seconds 10
    # закриваємо і знову відкриваємо: має зʼявитись «Сеанс відновлено»
    & $adb -s $device shell am force-stop $Package
    Start-Sleep -Seconds 2
    & $adb -s $device shell monkey -p $Package -c android.intent.category.LAUNCHER 1 | Out-Null
    Start-Sleep -Seconds 12
}
New-Item -ItemType Directory -Force -Path $Screens | Out-Null
$script:account = ''
$script:password = 'Garden2026'
cmd /c "flutter test integration_test/app_test.dart -d $device --reporter expanded 2>&1" | ForEach-Object {
    Write-Host $_
    if ($_ -match 'GP_ACCOUNT:(\S+)') { $script:account = $Matches[1] }
    if ($_ -match 'GP_PASSWORD_CHANGED') { $script:password = 'Sadivnyk2026' }
    if ($_ -match 'GP_SHOT:([A-Za-z0-9_]+)') {
        $name = $Matches[1]
        & $adb -s $device shell screencap -p /sdcard/gp_shot.png
        & $adb -s $device pull /sdcard/gp_shot.png (Join-Path $Screens "$name.png") | Out-Null
        Write-Host "   >>> скриншот: $name.png" -ForegroundColor Cyan
    }
}
Write-Host "flutter test exit code: $LASTEXITCODE"

# --- 5. звичайний запуск: відновлення сеансу + відправка звіту crashlytics
Step '5. Перезапуск застосунку (відновлення сеансу)'
Run 'flutter build apk --debug' | Out-Null
& $adb -s $device install -r 'build\app\outputs\flutter-apk\app-debug.apk' | Out-Host
& $adb -s $device shell am force-stop $Package
& $adb -s $device shell monkey -p $Package -c android.intent.category.LAUNCHER 1 | Out-Null
Start-Sleep -Seconds 25
New-Item -ItemType Directory -Force -Path $Screens | Out-Null
& $adb -s $device shell screencap -p /sdcard/gp_session.png
& $adb -s $device pull /sdcard/gp_session.png (Join-Path $Screens '99_session_restored.png') | Out-Host

Step 'Скриншоти'
Get-ChildItem $Screens | Select-Object Name, Length | Format-Table | Out-Host

Step 'ГОТОВО. Можна закрити це вікно і повернутись у чат з Claude.'
Stop-Transcript | Out-Null
Read-Host 'Натисни Enter, щоб закрити'
