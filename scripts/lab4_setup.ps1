# Налаштування Firebase для GardenPlan (лабораторна №4)
# Виконує кроки 1-4 з методички: Firebase CLI, FlutterFire CLI,
# flutter pub add, flutterfire configure, а також перевірку коду.
# Лог зберігається в scripts\logs\setup_log.txt

$ErrorActionPreference = 'Continue'
$ProjectDir = Split-Path -Parent $PSScriptRoot
$LogDir = Join-Path $PSScriptRoot 'logs'
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
$Log = Join-Path $LogDir 'setup_log.txt'
Start-Transcript -Path $Log -Force | Out-Null
Set-Location $ProjectDir

$FirebaseProject = 'gardenplan-da4c8'
$AndroidPackage  = 'com.example.lab1'

function Step($text) { Write-Host ''; Write-Host "===== $text =====" -ForegroundColor Green }

# --- Flutter: беремо шлях з android\local.properties, якщо flutter не в PATH
Step 'Перевірка Flutter'
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    $props = Get-Content (Join-Path $ProjectDir 'android\local.properties')
    $sdk = ($props | Where-Object { $_ -like 'flutter.sdk=*' }) -replace 'flutter.sdk=', '' -replace '\\\\', '\'
    $env:Path = "$sdk\bin;$env:Path"
}
flutter --version

# --- Крок 1. Firebase CLI
Step 'Крок 1. Firebase CLI'
$env:Path = "$env:APPDATA\npm;$env:LOCALAPPDATA\Pub\Cache\bin;$LogDir;$env:Path"
if (-not (Get-Command firebase -ErrorAction SilentlyContinue)) {
    if (Get-Command npm -ErrorAction SilentlyContinue) {
        Write-Host 'Встановлюю firebase-tools через npm...'
        npm install -g firebase-tools
    } else {
        Write-Host 'npm не знайдено, завантажую автономний Firebase CLI...'
        Invoke-WebRequest -Uri 'https://firebase.tools/bin/win/instant/latest' -OutFile (Join-Path $LogDir 'firebase.exe')
    }
}
firebase --version

Step 'Вхід у Firebase (відкриється браузер — увійди тим самим Google-акаунтом)'
firebase login
firebase projects:list

# --- FlutterFire CLI
Step 'Активація FlutterFire CLI'
dart pub global activate flutterfire_cli

# --- Крок 3-4. Пакети Firebase
Step 'Крок 3-4. Додавання пакетів Firebase'
flutter pub add firebase_core firebase_auth firebase_analytics firebase_crashlytics

# --- Крок 2. Конфігурація (створює lib\firebase_options.dart і google-services.json)
Step 'Крок 2. flutterfire configure'
dart pub global run flutterfire_cli:flutterfire configure `
    --project=$FirebaseProject `
    --platforms=android `
    --android-package-name=$AndroidPackage `
    --yes

# --- Перевірка
Step 'flutter pub get'
flutter pub get
Step 'flutter analyze'
flutter analyze
Step 'flutter test'
flutter test

Step 'ГОТОВО. Можна закрити це вікно і повернутись у чат з Claude.'
Stop-Transcript | Out-Null
Read-Host 'Натисни Enter, щоб закрити'
