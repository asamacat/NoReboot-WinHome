# Windows 10サーバー環境最適化スクリプト
# 機能：Windows Update自動再起動抑制、ネットワークドライブ再接続対策、B-CASカードエラー対策

# 管理者権限チェック
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "このスクリプトは管理者権限で実行してください。"
    exit
}

Write-Host "Windows 10サーバー環境最適化を開始します..." -ForegroundColor Green

# 1. PSWindowsUpdate モジュールのインストール
Write-Host "1. PSWindowsUpdate モジュールのインストール..." -ForegroundColor Cyan
if (!(Get-Module -ListAvailable -Name PSWindowsUpdate)) {
    Install-PackageProvider -Name NuGet -Force
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    Install-Module -Name PSWindowsUpdate -Force
    Write-Host "  PSWindowsUpdate モジュールがインストールされました" -ForegroundColor Green
} else {
    Write-Host "  PSWindowsUpdate モジュールは既にインストール済みです" -ForegroundColor Yellow
}

Import-Module PSWindowsUpdate

# 2. Windows Update設定の最適化
Write-Host "2. Windows Update設定の最適化..." -ForegroundColor Cyan

# 2.1 自動更新の制御（グループポリシー設定をレジストリで実装）
$AUPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
if (!(Test-Path $AUPath)) {
    New-Item -Path $AUPath -Force | Out-Null
}

# 自動再起動の抑制
Set-ItemProperty -Path $AUPath -Name "NoAutoRebootWithLoggedOnUsers" -Value 1 -Type DWord
Write-Host "  ログオンユーザーがいる場合の自動再起動を抑制しました" -ForegroundColor Green

# アクティブ時間の設定（8:00-23:00）
Set-ItemProperty -Path $AUPath -Name "SetActiveHours" -Value 1 -Type DWord
Set-ItemProperty -Path $AUPath -Name "ActiveHoursStart" -Value 8 -Type DWord
Set-ItemProperty -Path $AUPath -Name "ActiveHoursEnd" -Value 23 -Type DWord
Write-Host "  アクティブ時間を8:00-23:00に設定しました" -ForegroundColor Green

# 更新プログラムの自動ダウンロードとインストール日時を指定（オプション4）
Set-ItemProperty -Path $AUPath -Name "AUOptions" -Value 4 -Type DWord
Set-ItemProperty -Path $AUPath -Name "ScheduledInstallDay" -Value 0 -Type DWord # 0=毎日
Set-ItemProperty -Path $AUPath -Name "ScheduledInstallTime" -Value 3 -Type DWord # 3:00
Write-Host "  更新プログラムの自動インストール時間を午前3時に設定しました" -ForegroundColor Green

# Microsoft Updateサービスの登録
try {
    Add-WUServiceManager -ServiceID "7971f918-a847-4430-9279-4a52d1efe18d" -Confirm:$false -ErrorAction SilentlyContinue
    Write-Host "  Microsoft Updateサービスを登録しました" -ForegroundColor Green
} catch {
    Write-Host "  Microsoft Updateサービスの登録に失敗しました: $_" -ForegroundColor Yellow
}

# 3. 自動再接続スクリプトの作成
Write-Host "3. ネットワークドライブ自動再接続機能の設定..." -ForegroundColor Cyan

# 3.1 スクリプトディレクトリの作成
$scriptsDir = "$env:SystemDrive\Scripts"
if (!(Test-Path $scriptsDir)) {
    New-Item -Path $scriptsDir -ItemType Directory -Force | Out-Null
}

# 3.2 ネットワークドライブ再接続用PowerShellスクリプトの作成
$reconnectPSPath = "$scriptsDir\MapDrives.ps1"
$reconnectPS = @'
$i = 3
while($True) {
    $error.clear()
    $MappedDrives = Get-SmbMapping | where -property Status -Value Unavailable -EQ | select LocalPath,RemotePath
    foreach($MappedDrive in $MappedDrives) {
        try {
            New-SmbMapping -LocalPath $MappedDrive.LocalPath -RemotePath $MappedDrive.RemotePath -Persistent $True
            Write-Host "再接続成功: $($MappedDrive.RemotePath) -> $($MappedDrive.LocalPath)"
        } catch {
            Write-Host "再接続エラー: $($MappedDrive.RemotePath) -> $($MappedDrive.LocalPath)"
        }
    }
    $i = $i - 1
    if($error.Count -eq 0 -Or $i -eq 0) {break}
    Start-Sleep -Seconds 30
}
'@
Set-Content -Path $reconnectPSPath -Value $reconnectPS -Force
Write-Host "  再接続PowerShellスクリプトを作成しました: $reconnectPSPath" -ForegroundColor Green

# 3.3 バッチファイルの作成
$reconnectCmdPath = "$scriptsDir\MapDrives.cmd"
$reconnectCmd = @"
@echo off
PowerShell -Command "Set-ExecutionPolicy -Scope CurrentUser Unrestricted" >> "%TEMP%\StartupLog.txt" 2>&1
PowerShell -File "$scriptsDir\MapDrives.ps1" >> "%TEMP%\StartupLog.txt" 2>&1
"@
Set-Content -Path $reconnectCmdPath -Value $reconnectCmd -Force
Write-Host "  再接続コマンドスクリプトを作成しました: $reconnectCmdPath" -ForegroundColor Green

# 3.4 スタートアップへの登録
$startupPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
$shortcutPath = "$startupPath\ReconnectDrives.lnk"
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($shortcutPath)
$Shortcut.TargetPath = $reconnectCmdPath
$Shortcut.Save()
Write-Host "  再接続スクリプトをスタートアップに登録しました" -ForegroundColor Green

# 4. 起動時のサービス依存関係設定
Write-Host "4. 起動時のサービス依存関係設定..." -ForegroundColor Cyan
Set-Service -Name "LanmanWorkstation" -StartupType Automatic
Set-Service -Name "MRxSmb" -StartupType Automatic
Write-Host "  ネットワーク関連サービスの自動起動を設定しました" -ForegroundColor Green

# 5. Windows Update再起動タスクの無効化
Write-Host "5. Windows Update再起動タスクの無効化..." -ForegroundColor Cyan
try {
    $task = Get-ScheduledTask -TaskName "Reboot" -TaskPath "\Microsoft\Windows\UpdateOrchestrator\" -ErrorAction SilentlyContinue
    if ($task) {
        Disable-ScheduledTask -TaskName "Reboot" -TaskPath "\Microsoft\Windows\UpdateOrchestrator\"
        Write-Host "  Windows Update再起動タスクを無効化しました" -ForegroundColor Green
    } else {
        Write-Host "  該当するタスクが見つかりません" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  タスクの無効化に失敗しました: $_" -ForegroundColor Yellow
}

# 6. B-CASカードエラー対策用のネットワークサービス優先起動設定
Write-Host "6. B-CASカードエラー対策..." -ForegroundColor Cyan
$bcasServices = @(
    "LanmanWorkstation",
    "MRxSmb",
    "Browser", 
    "LanmanServer"
)

foreach ($service in $bcasServices) {
    try {
        if (Get-Service -Name $service -ErrorAction SilentlyContinue) {
            Set-Service -Name $service -StartupType Automatic
            Write-Host "  サービス '$service' を自動起動に設定しました" -ForegroundColor Green
        }
    } catch {
        Write-Host "  サービス '$service' の設定に失敗しました: $_" -ForegroundColor Yellow
    }
}

Write-Host "`n設定が完了しました。再起動後に設定が反映されます。" -ForegroundColor Green
Write-Host "再起動しますか？ (Y/N)" -ForegroundColor Yellow
$restart = Read-Host

if ($restart -eq "Y" -or $restart -eq "y") {
    Restart-Computer -Force
}
