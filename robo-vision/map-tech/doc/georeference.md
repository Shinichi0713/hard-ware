いいですね 👍

**Geo reference を使って ODM (OpenDroneMap) で 3D点群を作成する流れ** を整理してみます。

---

## 🔹 ODM における Geo reference の意味

ODM はドローンで撮影した写真から SfM (Structure from Motion) を用いて 3D再構成を行いますが、写真に **位置情報（GPS座標）** がある場合、点群やモデルを **実世界の座標系（例: WGS84 / UTM）** に合わせて生成できます。

そのための仕組みが **Geo reference** です。

* EXIF の GPS 情報（撮影位置・高度）
* または GCP (Ground Control Points, 地上基準点) ファイル

  を ODM に入力して座標基準を整えます。

---

## 🔹 3D点群生成の流れ（Geo reference を使う場合）

### 1. データ準備

* ドローン撮影した画像（JPEG, TIFF）
  * できれば EXIF に GPS 情報を含む（標準的なドローンなら含まれている）
* 必要なら **GCPファイル** を用意
  * CSV形式で `地上点のID, 緯度, 経度, 高度, 画像上のピクセル座標` を記録

---

### 2. ODM プロジェクトを実行

ターミナルで ODM を実行します：

```bash
docker run -ti --rm \
    -v /path/to/images:/datasets/images \
    -v /path/to/output:/datasets/output \
    opendronemap/odm \
    --project-path /datasets \
    --orthophoto-resolution 5 \
    --dsm \
    --dtm \
    --mesh \
    --pc-quality high
```

📌 ポイント

* `--project-path` で入力画像と出力ディレクトリを指定
* `--dsm` `--dtm` `--mesh` `--pc-quality` はオプション
* GCP を使う場合は `--gcp` を追加して GCP ファイルを読み込ませる

---

### 3. Geo reference の適用

ODM は次のように座標を決定します：

1. **GPS情報付き画像のみ →** SfMのスケールを GPS 座標に合わせる
2. **GCP を指定 →** GPS より正確にジオリファレンス補正
3. **GPSなし・GCPなし →** 任意スケールの「ローカル座標系」で点群生成

---

### 4. 出力

ODM は処理完了後、以下を出力します：

* `odm_georeferencing/odm_georeferenced_model.ply` → Geo reference された点群
* `odm_orthophoto/odm_orthophoto.tif` → ジオリファレンス付きオルソ画像（GeoTIFF）
* `odm_texturing/odm_textured_model.obj` → テクスチャ付き3Dモデル

点群（PLY）は **UTM座標系** で保存されるのが一般的です。

（緯度経度ではなく、メートル単位の投影座標系）

---

## 🔹 フローまとめ（簡略図）

```
📷 画像 (EXIF GPSあり) ＋ 🗺️ (任意でGCP)
        │
        ▼
   ODM処理 (SfM + MVS)
        │
        ▼
  Geo reference 適用
        │
        ▼
  3D点群 (PLY, UTM座標)
  DSM/DTM (GeoTIFF)
  3D Mesh (OBJ, MTL, PNG)
```

---

## 🔹 もし複数フライトをマージしたい場合

* 全フライト画像をまとめて ODM に投入 → 1つの統合マップを作る
* もしくは フライトごとに ODM で点群生成 → 後で Open3D などでレジストレーション



# Georeference VS GCP

**Geo reference（ジオリファレンス）** と **GCP（Ground Control Points, 地上基準点）** は密接に関係していますが、役割は少し違います。

---

## 🔹 Geo reference とは

* **モデルや点群を現実世界の座標系に対応付けること**
* 例:
  * ただの SfM (Structure from Motion) → ローカル座標系（任意スケール）
  * Geo reference をすると → 緯度経度や UTM 座標に変換される
* 入力として使えるのは：
  * 写真の  **EXIF GPS座標** （ドローンが自動的に埋め込む）
  * **GCP（地上基準点）**

---

## 🔹 GCP とは

* **実際の地面に置いたマーカーの座標（測量で正確に測った値）**
* 精密な GNSS 受信機や測量機器で測定
* 画像中でもマーカーの位置を手動で指定する
* これにより、SfM で再構築された座標を「正しい世界座標」に強制的に合わせられる

---

## 🔹 両者の関係

* **Geo reference = 出力を世界座標に合わせる処理**
* その方法のひとつが **GCPを利用すること**
* GCP を使うと、GPS情報だけより **ずっと高精度（数 cm レベル）** に位置合わせできる

---

## 🔹 例でまとめると

* **GPSだけ** → 位置は数 m の誤差あり（ドローン内蔵 GPS の精度に依存）
* **GCPあり** → 数 cm ～ 数十 cm の誤差に抑えられる
* **Geo reference = GCP を含む処理全体のこと**

---

✅ つまり、 **GCPは Geo reference を行うための1つの入力データ** 、

そして  **Geo reference は出力点群やモデルを世界座標に合わせる処理全般** 、という関係です。
