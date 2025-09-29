# ODMの座標系

OpenDroneMap (ODM) が生成する点群データ（例：`.ply`, `.las`, `.laz`）には、処理の流れに応じて座標系が決まります。

---

## 🔹 基本的な流れと座標系

1. **入力データ**
   * ドローンが撮影した画像（JPEG/PNG）＋撮影位置（EXIFのGPS情報）。
   * GPSなし画像だけの場合 → ODM はスケール・位置・方向が未定義の「任意座標系（ローカル座標）」で点群を生成。
2. **処理後の点群（`odm_georeferencing` の有無で変化）**
   * **ローカル座標系**
     * 画像にGPS情報がなかった場合、または「--force-gpsなし」で処理した場合。
     * 単位は「メートル」だが、原点は任意（初期のSFMで定義される座標系）。
     * 他の地図やGISデータとは直接重ね合わせできない。
   * **地理座標系 / 投影座標系**
     * 入力画像にEXIFのGPSが含まれている場合や、Ground Control Points (GCPs) を与えた場合。
     * その結果、点群は **WGS84（緯度経度）** か、または **投影座標系（UTMなど）** で保存される。
     * 多くの場合 `.las` / `.laz` 形式で出力すると、ヘッダに座標系（EPSGコード）が付与されている。`.ply` の場合は座標系情報が明示的に入らず、数値だけ保存される。
3. **スケール**
   * ODMの点群は通常「メートル単位」。
   * 緯度経度 (WGS84) の場合は単位が「度」なので、そのままの距離計算はできない。GISライブラリで投影変換が必要。

---

## 🔹 実際に保持されるデータ

点群ファイルには、少なくとも以下が入ります：

* **X, Y, Z** : 座標値（ローカル系 or 世界座標系）
* **R, G, B** : 画像から投影された色情報
* **(Optional)** Intensity, classification など（.las/.laz の場合）

---

## 🔹 確認方法

* **.las/.laz** の場合:

  ```bash
  lasinfo my_pointcloud.las
  ```

  → EPSGコード、座標範囲、単位などを確認できる。
* **.ply** の場合:

  Open3D や Meshlab で開いて座標値の範囲を見る。

  * 値が小さい（例: 0 ~ 数百） → ローカル座標系
  * 値が大きい（例: X ≈ 4,000,000, Y ≈ 500,0000） → UTM座標系
  * 値が緯度経度っぽい（例: X ≈ 139, Y ≈ 35） → WGS84（度単位）

---

## 🔹 まとめ

* **GPSなし → ローカル座標（任意の原点・メートル単位）**
* **GPSあり → WGS84 / UTM 等の世界座標（通常はメートル単位）**
* `.ply` は座標系情報がメタデータに入らないので、ファイル中の数値を見て判断する必要がある。
* `.las/.laz` はヘッダにEPSG座標系情報が保持されるので、GISソフトで確認できる。

---

👉 ご質問ですが、手元のODM点群は `.ply` と `.las` のどちらですか？

それによって「Pythonで扱うときの座標系の確認＆変換方法」を具体的にコード例を示せますよ。


# 座標確認

OpenDroneMap (ODM) が出力する `.ply` の点群は、通常 **GPS/測量情報（緯度・経度・標高を基準にした座標系）** を保持している場合と、ローカル座標系（処理時に内部基準を持たせてスケーリング・回転・平行移動されたもの）を保持している場合があります。

多くの場合、ODM の点群 (`odm_georeferencing/odm_georeferenced_model.ply`) は **EPSG:4326(WGS84緯度経度)** や **UTM座標系** で出力されます。これを確認するには、`.ply` のヘッダーを読むのが簡単です。

---

### Python実装例：PLYファイルの座標を読む

以下は **Open3D** を使って点群を読み込み、座標の範囲を調べる例です。

```python
import open3d as o3d
import numpy as np

# PLYファイル読み込み
pcd = o3d.io.read_point_cloud("odm_georeferenced_model.ply")

# 点群の座標を numpy に変換
points = np.asarray(pcd.points)

# 座標範囲を確認
print("点群の点数:", points.shape[0])
print("X範囲:", points[:, 0].min(), "～", points[:, 0].max())
print("Y範囲:", points[:, 1].min(), "～", points[:, 1].max())
print("Z範囲:", points[:, 2].min(), "～", points[:, 2].max())

# 最初の5点だけ表示
print("最初の5点:\n", points[:5])
```

---

### 出力の見方

* もし `X, Y` が **数百～数千程度** なら、ローカル座標系の可能性が高いです。
* もし `X, Y` が **数十万～数百万 (例: 36xxxxx, 139xxxxx)** のように大きい値なら、緯度経度や UTM のような **グローバル座標系** を保持しています。
* Z が **標高っぽい値 (例: 0～100m, 0～1000m)** なら、世界座標（地図座標系）になっています。

---

### 補足：ヘッダーを直接確認

PLY はテキスト形式で保存されている場合、先頭のヘッダーを見ると分かります。

```bash
head -n 20 odm_georeferenced_model.ply
```

ここに `comment` や `property float x/y/z` があり、ODM の場合は座標系に関する情報が書かれていることもあります。

---

👉 ご質問：Pythonで座標の確認だけでなく、

**座標系がワールド基準かローカル基準かを自動判定したいですか？**

それとも **複数のODM点群をマージするPythonコード** を見たいですか？



# 点群マージ

ODM が出力した複数の `.ply` 点群は、もし **同じ座標系（UTMや緯度経度ベース）で出力されている** なら、そのまま読み込んで **単純に結合して保存** するだけでマージできます。

ただし、もし **ローカル座標系** の `.ply` なら、事前に ICP（Iterative Closest Point）や RANSAC で座標変換を推定する必要があります。

ここではまず「同じ座標系前提」での結合コード例を示します。

---

## Python実装例：複数ODM点群をマージして保存

```python
import open3d as o3d
import numpy as np

# 複数のODM点群ファイル
ply_files = [
    "odm_project1/odm_georeferenced_model.ply",
    "odm_project2/odm_georeferenced_model.ply",
    "odm_project3/odm_georeferenced_model.ply"
]

merged_points = []
merged_colors = []

for f in ply_files:
    pcd = o3d.io.read_point_cloud(f)
    pts = np.asarray(pcd.points)
    merged_points.append(pts)

    if pcd.has_colors():
        colors = np.asarray(pcd.colors)
        merged_colors.append(colors)

# 結合
merged_points = np.vstack(merged_points)

if merged_colors:
    merged_colors = np.vstack(merged_colors)
else:
    merged_colors = None

# 新しい点群として保存
merged_pcd = o3d.geometry.PointCloud()
merged_pcd.points = o3d.utility.Vector3dVector(merged_points)

if merged_colors is not None:
    merged_pcd.colors = o3d.utility.Vector3dVector(merged_colors)

o3d.io.write_point_cloud("merged_odm_pointcloud.ply", merged_pcd)

print("マージ完了！ -> merged_odm_pointcloud.ply")
```

---

## 補足

1. **座標系が共通** （ODMがジオリファレンス済みならほぼそうです）なら、この方法で問題なく地図を統合できます。
2. **ローカル座標系** （ODMの途中生成物など）を扱う場合は、

* `o3d.pipelines.registration.registration_icp`
* `o3d.pipelines.registration.registration_ransac_based_on_feature_matching`

  を使って座標変換（回転・平行移動）を推定してから結合する必要があります。

---

👉 ご希望は

* **「同じ座標系前提で単純マージ」** のコードで十分ですか？
* それとも **「座標系が異なる場合のICP付きマージ」** まで実装例を見たいですか？
