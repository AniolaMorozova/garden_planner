# Відправка лабораторної №4 на GitHub
# git add -> git commit -> git push у репозиторій AniolaMorozova/garden_planner
# Лог: scripts\logs\git_log.txt

$ErrorActionPreference = 'Continue'
$ProjectDir = Split-Path -Parent $PSScriptRoot
$LogDir = Join-Path $PSScriptRoot 'logs'
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
Start-Transcript -Path (Join-Path $LogDir 'git_log.txt') -Force | Out-Null
Set-Location $ProjectDir

function Step($text) { Write-Host ''; Write-Host "===== $text =====" -ForegroundColor Green }
function Run($cmd) { cmd /c "$cmd 2>&1" | Out-Host; return $LASTEXITCODE }

Step '1. Перевірка git'
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host 'git не знайдено. Встанови Git for Windows і запусти скрипт ще раз.' -ForegroundColor Red
    Stop-Transcript | Out-Null; Read-Host 'Натисни Enter'; exit 1
}
Run 'git --version' | Out-Null
Run 'git remote -v' | Out-Null

# імʼя та пошта автора коміту (лише для цього репозиторію)
$name = (git config user.name)
$mail = (git config user.email)
if (-not $name) { $name = Read-Host 'Введи своє імʼя для комітів (наприклад, Anna Morozova)'; git config user.name "$name" }
if (-not $mail) { $mail = Read-Host 'Введи пошту свого GitHub-акаунта'; git config user.email "$mail" }
Write-Host "Автор комітів: $name <$mail>"

# файли звітів у корені проєкту на GitHub не відправляємо
$ignore = Get-Content .gitignore -Raw
if ($ignore -notmatch 'Lab reports') {
    Add-Content .gitignore "`r`n# Lab reports (не відправляємо на GitHub)`r`n/*.docx`r`n/*.pdf`r`n"
}

Step '2. Які файли змінено'
Run 'git add -A' | Out-Null
Run 'git status --short' | Out-Null

Step '3. Коміт'
$msgFile = Join-Path $LogDir 'commit_msg.txt'
$msg = @'
Лабораторна №4: інтеграція Firebase та автентифікація

- Firebase Core, Auth, Analytics, Crashlytics (flutterfire configure)
- AuthRepository та FirebaseAuthRepository: реєстрація, вхід, вихід,
  відновлення пароля, редагування профілю, зміна пароля
- AuthGate: відновлення сеансу після перезапуску
- Валідація форм через Form і TextFormField.validator
- Тести з фейковим репозиторієм та інтеграційний тест
'@
# UTF-8 без BOM, щоб у повідомленні коміту не було зайвого символу
[IO.File]::WriteAllText($msgFile, $msg, (New-Object System.Text.UTF8Encoding $false))
Run "git commit -F `"$msgFile`"" | Out-Null

Step '4. Відправка на GitHub (може відкритись вікно входу в GitHub)'
$code = Run 'git push origin main'
if ($code -eq 0) {
    Step 'ГОТОВО. Зміни на GitHub: https://github.com/AniolaMorozova/garden_planner'
} else {
    Write-Host 'Push не вдався. Надішли Claude скриншот цього вікна.' -ForegroundColor Red
}
Run 'git log --oneline -3' | Out-Null
Stop-Transcript | Out-Null
Read-Host 'Натисни Enter, щоб закрити'
