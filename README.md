# NoReboot-WinHome
Windows 10をサーバーとして使用する環境での自動再起動抑制、ネットワークドライブ再接続、B-CASカードエラー対策を提供する自動化ツール


<p align="center">
  <img src="docs/images/logo.png" alt="NoReboot-WinHome Logo" width="200"/>
</p>

<p align="center">
  <a href="#概要">日本語</a> | <a href="#overview">English</a>
</p>

---

## 概要

**NoReboot-WinHome**は、Windows 10をサーバーとして使用する環境で発生する一般的な問題を解決するための包括的な自動化ツールです。主に以下の問題に対処します：

- Windows Updateによる予期せぬ自動再起動
- 再起動後のネットワークドライブ接続エラー
- B-CASカードの認識エラー

クライアント向けOSであるWindows 10をサーバー環境で使用する場合の安定性と信頼性を向上させることを目的としています。

## 主な機能

- **Windows Update制御**：意図しない再起動を防止し、更新適用を管理
- **ネットワークドライブ自動再接続**：再起動後のドライブ接続を確実に復元
- **B-CASカードエラー対策**：関連サービスの最適起動順序を設定
- **一括自動設定**：すべての問題を一度に解決するスクリプト

## システム要件

- Windows 10 Pro/Enterprise (バージョン 1809以降)
- PowerShell 5.1以上
- 管理者権限

## インストール方法

### 方法1：PowerShellから直接実行（推奨）

管理者権限でPowerShellを開き、以下のコマンドを実行します：
リポジトリをクローン
git clone https://github.com/yourusername/Win10-ServerGuard.git
cd Win10-ServerGuard

スクリプトを実行
.\Install-ServerGuard.ps1


### 方法2：リリースパッケージからインストール

1. [リリースページ](https://github.com/yourusername/Win10-ServerGuard/releases)から最新バージョンをダウンロード
2. ZIPファイルを展開
3. フォルダ内の`Install-ServerGuard.ps1`を管理者権限で実行

## 使用方法

インストール後、以下の機能が自動的に有効になります：

- Windows Updateの自動再起動抑制
- ネットワークドライブの自動再接続
- B-CASカード関連サービスの最適化

設定を確認または変更するには：

現在の設定を確認
Get-ServerGuardStatus

設定を変更
Set-ServerGuardConfig -ActiveHoursStart 7 -ActiveHoursEnd 22



## トラブルシューティング

よくある問題とその解決方法：

| 問題 | 解決策 |
|------|---------|
| スクリプトが実行できない | `Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process` を実行 |
| 設定が適用されない | `gpupdate /force` コマンドを実行、または再起動 |
| B-CASエラーが解消されない | `Repair-BCASService` コマンドを実行 |

詳細な診断ログは `C:\ProgramData\Win10-ServerGuard\logs` に保存されます。

## よくある質問（FAQ）

<details>
  <summary>Q: Windows 10のセキュリティ更新は正常に適用されますか？</summary>
  A: はい。更新プログラムは通常通りダウンロードされ、指定された時間帯に適用されます。ただし、自動再起動が制御されます。
</details>

<details>
  <summary>Q: サーバー以外のPCでも使用できますか？</summary>
  A: はい。ただし、このツールはサーバー用途のPCの問題解決に特化しています。
</details>

<details>
  <summary>Q: Windows Serverでも動作しますか？</summary>
  A: 一部機能は動作しますが、正式にはWindows 10向けに最適化されています。
</details>

## ライセンス

[MIT License](LICENSE)

## 貢献方法

1. このリポジトリをフォーク
2. 新しいブランチを作成 (`git checkout -b feature/amazing-feature`)
3. 変更をコミット (`git commit -m 'Add some amazing feature'`)
4. ブランチをプッシュ (`git push origin feature/amazing-feature`)
5. プルリクエストを送信

## 謝辞

このプロジェクトは、以下のオープンソースプロジェクトのアイデアを参考にしています：

- [network-share-reconnecter](https://github.com/thexmanxyz/network-share-reconnecter)
- [Auto-Reconnect-Mapped-Network-Drives](https://github.com/yashielsookdeo/Auto-Reconnect-Mapped-Network-Drives)
- [ChocoAutomateWindowsUpdates](https://github.com/simeononsecurity/ChocoAutomateWindowsUpdates)

---

## Overview

**Win10-ServerGuard** is a comprehensive automation tool designed to solve common issues when using Windows 10 as a server environment. It addresses the following key problems:

- Unexpected automatic reboots caused by Windows Update
- Network drive connection errors after system restart
- B-CAS card recognition errors

The goal is to improve stability and reliability when using Windows 10 (a client-oriented OS) in server environments.

## Key Features

- **Windows Update Control**: Prevents unintended reboots and manages update application
- **Automatic Network Drive Reconnection**: Reliably restores drive connections after restart
- **B-CAS Card Error Prevention**: Optimizes related service startup order
- **All-in-One Automation**: Script that addresses all issues in one go

## System Requirements

- Windows 10 Pro/Enterprise (version 1809 or later)
- PowerShell 5.1 or higher
- Administrator privileges

## Installation

### Method 1: Direct PowerShell Execution (Recommended)

Open PowerShell with administrator privileges and run:

Clone the repository
git clone https://github.com/yourusername/Win10-ServerGuard.git
cd Win10-ServerGuard

Run the installation script
.\Install-ServerGuard.ps1



### Method 2: Install from Release Package

1. Download the latest version from the [releases page](https://github.com/yourusername/Win10-ServerGuard/releases)
2. Extract the ZIP file
3. Run `Install-ServerGuard.ps1` with administrator privileges

## Usage

After installation, the following features are automatically enabled:

- Windows Update automatic reboot prevention
- Network drive automatic reconnection
- B-CAS card service optimization

To check or modify settings:

Check current status
Get-ServerGuardStatus

Modify configuration
Set-ServerGuardConfig -ActiveHoursStart 7 -ActiveHoursEnd 22



## Troubleshooting

Common issues and their solutions:

| Issue | Solution |
|-------|----------|
| Cannot execute scripts | Run `Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process` |
| Settings not applied | Run `gpupdate /force` command or restart the system |
| B-CAS errors persist | Run `Repair-BCASService` command |

Detailed diagnostic logs are saved in `C:\ProgramData\Win10-ServerGuard\logs`.

## Frequently Asked Questions

<details>
  <summary>Q: Will Windows 10 security updates be applied normally?</summary>
  A: Yes. Update programs are downloaded as usual and applied during the specified time period. However, automatic restarts are controlled.
</details>

<details>
  <summary>Q: Can this be used on non-server PCs?</summary>
  A: Yes, although this tool is specialized for solving PC issues used as servers.
</details>

<details>
  <summary>Q: Does it work on Windows Server?</summary>
  A: Some features will work, but it's officially optimized for Windows 10.
</details>

## License

[MIT License](LICENSE)

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Acknowledgements

This project was inspired by ideas from the following open-source projects:

- [network-share-reconnecter](https://github.com/thexmanxyz/network-share-reconnecter)
- [Auto-Reconnect-Mapped-Network-Drives](https://github.com/yashielsookdeo/Auto-Reconnect-Mapped-Network-Drives)
- [ChocoAutomateWindowsUpdates](https://github.com/simeononsecurity/ChocoAutomateWindowsUpdates)


