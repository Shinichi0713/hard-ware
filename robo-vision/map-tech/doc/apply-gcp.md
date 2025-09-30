# GCPの適用

OpenDroneMap (ODM) が 3D マップ（点群・メッシュ・DSM/DTM）を生成するとき、内部では「**SfM（Structure from Motion）+ MVS（Multi-View Stereo）」の流れ」を辿ります。そのため、**基準となるポイント（特徴点 / コントロールポイント）を検出・利用 → カメラの位置姿勢を最適化 → 点群生成 → メッシュ化** という手順になります。

以下に、**基準ポイント取得からマップ生成までの流れ** を整理しました。

---

## ODM の3Dマップ生成の流れ

### 1. 入力データ

* ドローン撮影の  **オーバーラップした画像** （通常 70%以上）
* EXIF メタデータに含まれる **GPS位置・高度・カメラ情報**
* （任意で）**Ground Control Points (GCPファイル)** → 精度向上用

---

### 2. 特徴点抽出（基準となるポイントの検出）

* 各画像から **特徴点 (SIFT, SURF, ORB など)** を検出
* 画像間で特徴点をマッチングし、**tie-points（結び付き点）** を生成

  → これが ODM の計算基準となるポイント群
* ここで作られるのが「Sparse Point Cloud（疎点群）」です

---

### 3. カメラポーズ推定（SfM）

* 検出された tie-points を使って、**各画像の相対的な位置と姿勢（外部パラメータ）** を最適化
* **バンドル調整（Bundle Adjustment）** により、カメラ位置と3D点群の誤差を最小化
* GPS/GCP がある場合は、それを拘束条件として利用し、**座標系を現実の地理座標系（例: UTM）に合わせる**

---

### 4. 密な点群生成（MVS）

* 最適化されたカメラポーズを使い、**Multi-View Stereo** により各ピクセルに対して3D座標を推定
* これにより、**Dense Point Cloud（密な点群）** が得られる

---

### 5. メッシュ生成

* 点群から **Delaunay三角形分割** や **Poisson Surface Reconstruction** を行い、**3Dメッシュモデル** を生成
* メッシュにテクスチャを貼ることで、**フォトリアリスティックな3Dマップ** ができる

---

### 6. DEM/DSM/DTM 生成（必要な場合）

* 点群を raster 化して **Digital Surface Model (DSM)** を作成
* 地物（建物や樹木）を取り除いた **Digital Terrain Model (DTM)** も生成可能

---

## 基準点（GCP）を適用する流れ

* ODM に **GCP ファイル（通常 .txt または .csv）** を与えると、処理の SfM 段階で tie-points に加えて **絶対基準座標** として利用
* これにより、最終出力（点群やメッシュ）が **正しい地理座標系（UTM / WGS84）** に整合する

---

## まとめると

1. **特徴点抽出 → tie-points を生成** （相対的な基準点）
2. **SfM → カメラ位置推定 & 座標最適化** （GCP/GPSを使えば絶対座標に）
3. **MVS → 密な点群生成**
4. **メッシュ化 & テクスチャマッピング**
5. **DSM/DTM生成（オプション）**

---

👉 もし「実際に OpenDroneMap の出力から  **どのステージで基準点がどう使われているか確認したい** 」というのであれば、`opensfm` フォルダのログや `reconstruction.json` の中身を見ると、tie-points やカメラ位置が確認できます。



マップ生成まで

了解しました！OpenDroneMap (ODM) で **3Dマップ生成の基準点を取得して適用し、最終的にマップを生成するまでの流れ** を整理して説明しますね。

---

## 🔹 ODMでの3Dマップ生成と基準点適用の流れ

### 1. 入力データの準備

* **入力画像** （ドローンで撮影したオーバーラップを持つ写真群）
* **GPS/IMU情報** （EXIF に含まれる）
* 緯度 (lat), 経度 (lon), 高度 (alt)
* 通常は WGS84 (EPSG:4326)
* （任意）**Ground Control Points (GCPs)** や **チェックポイント**
  * 精度を高めるための基準点
  * 地上で測量機器（GNSSなど）を用いて正確に測定された座標

---

### 2. GCPファイルの準備

ODMにおいて、基準点は **GCPファイル** として渡します。

フォーマットは以下のようになります：

```
EPSG:32654   # UTMゾーン番号など座標系のEPSGコード
# Easting   Northing    Elevation   image_name   pixel_x   pixel_y
345678.123   4123456.789   53.21     IMG_0001.JPG   1234   567
345682.456   4123459.321   52.98     IMG_0002.JPG   1340   678
...
```

* 最初の行：対象座標系のEPSGコード（例: UTM）
* 各行：GCPの座標と、その点が写っている画像内でのピクセル座標

👉 **ピクセル座標の対応付け**は、QGIS などのGISソフトや専用のマッチングツールで行います。

---

### 3. ODMの実行（GCP適用）

ODMをコマンドラインで実行するとき、以下のように `--gcp` オプションを指定します：

```bash
docker run -ti --rm -v /path/to/dataset:/datasets opendronemap/odm \
  --project-path /datasets --gcp /datasets/gcp_list.txt my_project
```

* `--gcp` : 作成したGCPファイルを指定
* これにより、ODM内部で SfM (Structure from Motion) の最適化時に、

  **GCPが拘束条件**として働き、点群やメッシュが正確な座標系に合わせられます。

---

### 4. 処理フロー（ODM内部）

1. **画像特徴点抽出**
   * OpenSfM によって SIFT/SURF 特徴点が検出
   * 画像間のマッチング → スパース点群生成
2. **初期座標合わせ**
   * EXIFのGPS座標で大まかに配置
3. **Bundle Adjustment (BA)**
   * 誤差最小化処理（カメラ位置・姿勢・点群位置を調整）
   * GCPがある場合はこれを基準に座標を補正
4. **点群生成**
   * MVS (Multi View Stereo) により密な点群を構築
5. **点群フィルタリング・メッシュ化**
   * ノイズ除去
   * 三角メッシュ生成
6. **座標系の保持**
   * 出力は GCPに基づく座標系（例: UTM, EPSG指定）

---

### 5. 出力

* `odm_georeferencing/odm_georeferenced_model.ply`（点群）
* `odm_texturing/odm_textured_model.obj`（メッシュ）
* これらの座標は **指定したEPSG座標系** に整合されています。
* 複数フライトを処理する場合も、同じEPSGかつ同じGCPを共有すれば、座標系上で一致させられます。

---

## 🔹 まとめ

* 画像入力 → ODM処理 → 3Dモデル生成
* **基準点（GCP）を事前に測量** → GCPファイル作成 → ODMに渡す
* ODMの **SfM + BA** 処理で、GCPを拘束条件にして正しい座標に調整
* 出力点群やメッシュは **UTMなどの実世界座標** で整合



# マージの基準として活用

では **「複数フライトで撮影したデータを後でマージするために、座標基準を整える」** 方法にフォーカスして整理しますね。

---

## 🔹 基本の考え方

複数フライトの点群をマージしたい場合、**すべてのデータが同じ座標基準（同じEPSG, 同じ原点・スケール）で出力されること** が大前提です。

このために主に次の手段があります：

---

## 1. 共通のGCPを使う

* 各フライトのエリアに**共通のGCP（基準点）**を配置・測量する
* それぞれのODMプロジェクトで同じGCPファイルを指定して処理
* 出力点群は同じUTM座標系に揃うため、そのままマージ可能

👉 精度を求める場合はこの方法が一番確実です。

　（誤差はcm〜数cmレベルに抑えられます）

---

## 2. 同じ座標系 (EPSG) を指定する

* ODMはデフォルトで EXIF(GPS) の座標を利用してスケーリングします
* 各フライトの入力画像に含まれるGPS情報が **同じ測位基準（WGS84, EGM96など）** であれば、UTMに投影することで大枠で一致します
* ただし **誤差は数m〜数十m** 出ることが多いので、そのままマージするとズレが見えます

👉 この場合は後処理で **点群レジストレーション (ICP, RANSAC)** が必要になります。

---

## 3. 後処理で位置合わせする

* 出力された各フライトの点群を **Open3D, PCL, CloudCompare** などで読み込み
* 点群同士をレジストレーションして統合する
  * 初期合わせ：RANSACや特徴ベース
  * 精密合わせ：ICP（Iterative Closest Point）
* 最後に1つの点群として保存

👉 GPS誤差が大きい場合でも、この方法で結合できます。

👉 ただし「基準の絶対座標」ではなく、「フライトごとの相対合わせ」になることに注意。

---

## 4. 実運用での流れ例

1. ドローンで複数フライト撮影
2. 各フライトごとにODM処理
   * GCPがある → GCPファイル指定
   * GCPがない → GPS座標(EXIF)をそのまま使う
3. 点群出力 (`.ply`) を取得
4. 共通座標系が保証されている場合
   * GISソフト（QGIS, CloudCompare）で直接統合
5. 共通座標系が保証されていない場合
   * レジストレーション処理（Open3DなどPythonで自動化可能）

---

## 🔹 まとめ

* **確実に整合したい → 共通GCPを使う**
* **GPSのみで処理 → 粗い整合、後処理でレジストレーション**
* **複数フライトの自動マージ → Python (Open3D) や CloudCompare でICP処理**

---

👉 ご質問です：

複数フライトの点群をマージしたいとき、

**(A) できるだけ自動で揃えたい（後処理でICPなどを多用する）** のか、

**(B) 現場でGCPを測量して精度を担保したい** のか、どちらに近いイメージでしょうか？



# 自動で生成

(A) **「現場ではGCPを使わず、後処理で自動的に複数フライト点群を整合・マージしたい」** というケースですね 👍

この場合は **レジストレーション処理を工夫する** のが肝になります。

---

## 🔹 手順の流れ（自動整合・マージ）

1. **点群読み込み**
   * 各フライトの `.ply` ファイルを Open3D などで読み込む。
2. **前処理**
   * ダウンサンプリング（例: voxel_size = 0.2m）
   * ノイズ除去（StatisticalOutlierRemovalなど）
3. **初期アライメント（粗合わせ）**
   * RANSACベースのレジストレーションを使う
   * FPFH特徴量を計算して、大きくずれている点群を大まかに位置合わせ
4. **精密アライメント（微調整）**
   * ICP (Iterative Closest Point) で細かく調整
   * "point-to-plane ICP" が効果的（法線がある場合）
5. **統合**
   * 各フライトの点群を変換・統合
   * 最終的に1つの大きな点群として保存

---

## 🔹 Python (Open3D) 実装例

```python
import open3d as o3d

def preprocess_point_cloud(pcd, voxel_size):
    pcd_down = pcd.voxel_down_sample(voxel_size)
    pcd_down.estimate_normals(
        o3d.geometry.KDTreeSearchParamHybrid(radius=voxel_size * 2, max_nn=30))
    pcd_fpfh = o3d.pipelines.registration.compute_fpfh_feature(
        pcd_down,
        o3d.geometry.KDTreeSearchParamHybrid(radius=voxel_size * 5, max_nn=100))
    return pcd_down, pcd_fpfh

def execute_global_registration(source_down, target_down, source_fpfh, target_fpfh, voxel_size):
    distance_threshold = voxel_size * 1.5
    result = o3d.pipelines.registration.registration_ransac_based_on_feature_matching(
        source_down, target_down, source_fpfh, target_fpfh, True,
        distance_threshold,
        o3d.pipelines.registration.TransformationEstimationPointToPoint(False),
        4, [
            o3d.pipelines.registration.CorrespondenceCheckerBasedOnEdgeLength(0.9),
            o3d.pipelines.registration.CorrespondenceCheckerBasedOnDistance(distance_threshold)
        ], o3d.pipelines.registration.RANSACConvergenceCriteria(4000000, 500))
    return result

def refine_registration(source, target, init_transformation, voxel_size):
    distance_threshold = voxel_size * 0.4
    result = o3d.pipelines.registration.registration_icp(
        source, target, distance_threshold, init_transformation,
        o3d.pipelines.registration.TransformationEstimationPointToPlane())
    return result

# --- メイン処理 ---
voxel_size = 1.0  # 調整ポイント: 点群スケールに応じて設定

pcd1 = o3d.io.read_point_cloud("flight1.ply")
pcd2 = o3d.io.read_point_cloud("flight2.ply")

pcd1_down, fpfh1 = preprocess_point_cloud(pcd1, voxel_size)
pcd2_down, fpfh2 = preprocess_point_cloud(pcd2, voxel_size)

# 粗合わせ (RANSAC)
ransac_result = execute_global_registration(pcd1_down, pcd2_down, fpfh1, fpfh2, voxel_size)

# 微調整 (ICP)
icp_result = refine_registration(pcd1, pcd2, ransac_result.transformation, voxel_size)

# 結合
pcd2.transform(icp_result.transformation)
merged = pcd1 + pcd2

o3d.io.write_point_cloud("merged.ply", merged)
print("✅ マージ完了: merged.ply")
```

---

## 🔹 ポイント

* **初期ずれが大きい → RANSACで大まかに位置合わせ**
* **微調整 → ICP (point-to-plane)**
* 点群が20万点レベル → voxelダウンサンプリング必須（高速化＆安定化）
* フライトが3つ以上の場合 → 1対1で順に整合させる or **全体最適化（PoseGraph）** を使う

---

👉 ご質問です：

フライトの数は **2つ** でしょうか？それとも **3つ以上（連続飛行マッピング的なイメージ）** ですか？
