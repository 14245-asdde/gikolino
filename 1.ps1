# 1. Проверка прав Администратора
\$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not \$isAdmin) {
    Write-Error "КРИТИЧЕСКАЯ ОШИБКА: Скрипт должен быть запущен ОТ ИМЕНИ АДМИНИСТРАТОРА!"
    Exit
}

Write-Host "--- Запуск процесса удаления среды восстановления и безопасного режима ---" -ForegroundColor Cyan

# 2. Отключение среды восстановления (WinRE)
Write-Host "2. Отключение службы WinRE..." -ForegroundColor Yellow
reagentc /disable

# 3. Физическое удаление файла-образа восстановления
Write-Host "3. Удаление файла winre.wim..." -ForegroundColor Yellow
\$winrePath = "C:\Windows\System32\Recovery\winre.wim"
if (Test-Path \$winrePath) {
    Remove-Item -Path \$winrePath -Force -ErrorAction SilentlyContinue
    Write-Host "Файл успешно удален." -ForegroundColor Green
} else {
    Write-Host "Файл winre.wim не найден (возможно, уже удален)." -ForegroundColor Gray
}

# 4. Полное удаление веток безопасного режима из реестра
Write-Host "4. Уничтожение конфигураций Безопасного режима (SafeBoot)..." -ForegroundColor Yellow
Remove-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SafeBoot\Minimal" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SafeBoot\Network" -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "Ветки реестра SafeBoot удалены." -ForegroundColor Green

# 5. Блокировка автоматического вызова восстановления при сбоях загрузки
Write-Host "5. Настройка bcdedit для игнорирования сбоев..." -ForegroundColor Yellow
bcdedit /set `{default`} bootstatuspolicy ignoreallfailures
bcdedit /set `{default`} recoveryenabled no

# 6. Итоговая проверка статуса
Write-Host "`n--- Проверка текущего статуса WinRE ---" -ForegroundColor Cyan
reagentc /info

Write-Host "`nГотово! Безопасный режим и среда восстановления полностью вырезаны." -ForegroundColor Green
