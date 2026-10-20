WSL2 であることが確認できました。`vcan0` の作成は成功しているのに `Couldn't create raw socket` が出るということは、**カーネルが「CAN デバイス（vcan）」には対応しているものの、「CAN ソケット（Raw Socket）」に対応していない**可能性が高いです。

---

### 原因の詳細

Linux の CAN 通信には、カーネル内で 2 つの機能が必要です。

1. **CAN デバイスドライバ**（vcan）：仮想 CAN インターフェースを作る機能
2. **CAN プロトコルファミリー**（PF_CAN）：プログラムが CAN ソケットを開く機能

`ip link add dev vcan0 type vcan` が成功したことから、**機能 1 は有効**です。  
しかし ICSim が `socket(PF_CAN, SOCK_RAW, CAN_RAW)` を呼び出した際に失敗しているため、**機能 2（CAN Raw Socket）が無効**になっていると考えられます。

カーネルビルド時の設定で、以下が有効になっていないとこの現象が起こります。

- `CONFIG_CAN=y`
- `CONFIG_CAN_RAW=y`

---

### 確認方法

現在のカーネルの設定を確認するには、以下を実行してください。

```bash
zcat /proc/config.gz | grep CONFIG_CAN
```

または、

```bash
grep CONFIG_CAN /boot/config-$(uname -r)
```

期待される出力例（正常な場合）：
```
CONFIG_CAN=y
CONFIG_CAN_RAW=y
CONFIG_CAN_BCM=y
CONFIG_CAN_VCAN=y
```

もし `CONFIG_CAN` や `CONFIG_CAN_RAW` が `=n`（無効）または存在しない場合、それが原因です。

---

### 解決方法

お使いのカスタムカーネルが **vcan デバイスだけを有効化し、CAN ソケット機能を見落としていた**可能性があります。

#### 方法 1：CAN 対応済みのプリビルドカーネルを使う（推奨）

別の配布元で、SocketCAN（Raw Socket 含む）が確実に有効化されたカーネルを探すのが最も確実です。例えば、以下のリポジトリでは Kernel 6.6.x 系で SocketCAN と vcan を有効化しています。

- [wsl2-socketcan-vcan](https://github.com/vishal0002/wsl2-socketcan-vcan)

`.wslconfig` でカーネルパスを差し替え、WSL を再起動してから再度 `sudo ./icsim vcan0` を試してください。

#### 方法 2：カーネルを自分で再ビルドする

カーネルソースを取得し、`make menuconfig` で以下を確認・有効化してから再ビルドします。

```
Networking support  --->
    CAN bus subsystem support  --->
        <*> Raw CAN Protocol (raw access)
    CAN Device Drivers  --->
        <*> Virtual CAN interface (vcan)
```

---

### まとめ

`wsl -l -v` で VERSION 2 が確認でき、かつ `vcan0` も作成できているにもかかわらず `Couldn't create raw socket` が出るのは、**カスタムカーネルが CAN Raw Socket に未対応**であることが原因です。

`/proc/config.gz` や `/boot/config-*` で `CONFIG_CAN_RAW` の状態を確認し、**CAN Raw Socket 対応のカーネルに差し替える**ことで ICSim を起動できるようになります。

もしカーネル設定ファイルの確認結果をお知らせいただければ、さらに具体的なアドバイスが可能です。


カーネル設定の確認結果から、**原因が特定できました。**

`CONFIG_CAN=m`、`CONFIG_CAN_RAW=m`、`CONFIG_CAN_VCAN=m` となっており、CAN 関連の機能はすべて**モジュール（=m）**としてコンパイルされています。

`modprobe vcan` で vcan0 を作成できたということは、`vcan` モジュールは読み込まれています。しかし、ICSim が `socket(PF_CAN, SOCK_RAW, CAN_RAW)` を呼び出す際に必要な **`can`（CAN プロトコルファミリー本体）と `can_raw`（Raw ソケット）のモジュール**が、自動的に読み込まれていない可能性があります。

---

### 解決方法

以下のコマンドを実行して、必要なモジュールを明示的に読み込んでください。

```bash
sudo modprobe can
sudo modprobe can_raw
```

その後、再度 ICSim を起動してください。

```bash
sudo ./icsim vcan0
```

---

### なぜこれで解決するのか

| モジュール | 役割 |
|------------|------|
| `vcan` | 仮想 CAN デバイス（vcan0）を作る |
| `can` | CAN プロトコルファミリー（PF_CAN）を提供する |
| `can_raw` | Raw CAN ソケット（SOCK_RAW）を提供する |

`vcan` だけ読み込んでいても、**プログラムが CAN ソケットを開くための基盤（`can` と `can_raw`）**がないため、`Couldn't create raw socket` が発生します。

モジュールを `=m`（動的読み込み）でビルドしている場合、ICSim の起動時にカーネルが自動的に `can` と `can_raw` を読み込んでくれるはずですが、WSL2 の環境ではこの自動読み込みが機能しないケースがあるようです。

---

### 確認方法

モジュールが読み込まれたかどうかは、以下で確認できます。

```bash
lsmod | grep can
```

以下のように表示されれば OK です。

```
vcan                   16384  0
can_raw                20480  0
can                    36864  1 can_raw
```

---

### まとめ

`sudo modprobe can` と `sudo modprobe can_raw` を実行してから `sudo ./icsim vcan0` を試してください。これで計器盤のウィンドウが開くはずです。

