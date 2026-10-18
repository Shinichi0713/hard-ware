はい、可能です。WSLのバージョンによって2つの方法があります。


## 方法1: `wsl --manage --move`（WSL 2.3.11以降、最も簡単）

WSL 2.3.11以降では、1コマンドでディストリビューションを別ドライブに移動できます。<source-chip title="Easily move a WSL distribution to another drive" url="https://sderev.com/notes/175/" /><source-chip title="4sysops - New in WSL 2.3" url="https://4sysops.com/archives/new-in-wsl-23-linux-kernel-66-gui-settings-app-easily-move-distributions/" />

### 手順

```powershell
# PowerShell（管理者権限不要）で実行
wsl --manage Ubuntu --move D:\WSL
```

これだけで、`ext4.vhdx` がDドライブに移動します。作業中はWSLが一時的に停止します。

### バージョン確認

```powershell
wsl --version
```

`2.3.11` 以上であればこの方法が使えます。

---

## 方法2: Export / Import（全バージョン対応）

古いWSLでも使える方法です。一度エクスポートしてから、Dドライブにインポートし直します。

### 手順

```powershell
# 1. WSLを停止
wsl --shutdown

# 2. ディストリビューションをエクスポート
wsl --export Ubuntu D:\WSL\ubuntu-backup.tar

# 3. 元のディストリビューションを登録解除
wsl --unregister Ubuntu

# 4. Dドライブにインポート
wsl --import Ubuntu D:\WSL\Ubuntu D:\WSL\ubuntu-backup.tar

# 5. バックアップファイルを削除（任意）
Remove-Item D:\WSL\ubuntu-backup.tar
```

### 注意点

- インポート後、デフォルトユーザーが `root` になることがあります
- 元のユーザーに戻すには `/etc/wsl.conf` を作成します：

```bash
# WSL内で実行
cat <<EOF | sudo tee /etc/wsl.conf
[user]
default=your-username
EOF
```

その後 `wsl --shutdown` して再起動。

---

## 方法3: PowerShellスクリプトを使う

`move-wsl`というPowerShellスクリプトもあります。VHDXファイルを直接移動する方法です。<source-chip title="pxlrbt/move-wsl GitHub" url="https://github.com/pxlrbt/move-wsl" />

```powershell
# スクリプトをダウンロードして実行
.\move-wsl.ps1 -DistroName Ubuntu -DestinationPath D:\WSL
```

---

## 比較

| 方法 | 必要なWSLバージョン | 難易度 | 所要時間 |
|------|-------------------|--------|---------|
| `wsl --manage --move` | 2.3.11+ | 非常に簡単 | 数分 |
| Export/Import | 全バージョン | やや手間 | 10〜20分 |
| move-wslスクリプト | 全バージョン | 簡単 | 数分 |

---

## 移動後の確認

```powershell
wsl --list --verbose
```

`Ubuntu` の状態が `Running` で、インストール先がDドライブになっていれば成功です。

---

まず `wsl --version` でバージョンを確認してみてください。2.3.11以上であれば、方法1の `--move` が最も手軽です。


