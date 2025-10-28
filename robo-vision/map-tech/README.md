# OpenDroneMap Python サンプルコード

このリポジトリには、OpenDroneMap (ODM) を使用してドローン画像から3D地形データを復元するためのPythonサンプルコードが含まれています。

## 📁 ファイル構成

```
3d-data-processing/
├── opendronemap_samples.py     # ODM基本サンプルコード
├── odm_batch_processor.py      # バッチ処理スクリプト
├── odm_result_analyzer.py      # 結果分析・可視化
├── odm_config.ini             # 設定ファイル
└── README.md                  # このファイル
```

## 🚀 クイックスタート

### 1. 必要なソフトウェアのインストール

#### OpenDroneMapのインストール

**Docker版（推奨）:**
```bash
# Dockerをインストール後
docker pull opendronemap/odm
```

**直接インストール:**
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y git
git clone https://github.com/OpenDroneMap/ODM.git
cd ODM
bash configure.sh install
```

#### Python依存関係のインストール

```bash
# 基本パッケージ
pip install requests configparser

# 3D処理・可視化用（オプション）
pip install open3d numpy matplotlib opencv-python

# 地理空間データ処理用（オプション）
pip install rasterio geopandas
```

### 2. 設定ファイルの編集

`odm_config.ini`を編集して、あなたの環境に合わせてパスを設定してください：

```ini
[paths]
images_folder = C:\path\to\drone\images
output_folder = C:\path\to\output\project

[docker]
use_docker = true
docker_image = opendronemap/odm
```

### 3. サンプル実行

#### 基本的な使用方法

```python
from opendronemap_samples import OpenDroneMapProcessor

# ODMプロセッサー作成
odm = OpenDroneMapProcessor()

# 基本処理実行
images_folder = r"C:\path\to\drone\images"
output_folder = r"C:\path\to\output"
odm.run_basic_processing(images_folder, output_folder)
```

#### バッチ処理

```python
from odm_batch_processor import ODMBatchProcessor

# バッチプロセッサー作成
processor = ODMBatchProcessor("odm_config.ini")

# 複数プロジェクトを処理
projects = {
    "project_001": r"C:\drone_data\project_001\images",
    "project_002": r"C:\drone_data\project_002\images"
}
processor.batch_process(projects)
```

#### 結果分析・可視化

```python
from odm_result_analyzer import ODMResultAnalyzer

# 分析ツール作成
analyzer = ODMResultAnalyzer(r"C:\path\to\odm\output\project")

# 点群可視化
analyzer.visualize_point_cloud()

# メッシュ可視化
analyzer.visualize_mesh()

# 統計分析
analyzer.analyze_point_cloud_statistics()
```

## 🛠️ 高度な設定

### カスタムパラメータ

```python
custom_params = {
    "--mesh-size": "300000",           # メッシュサイズ
    "--feature-quality": "ultra",      # 特徴点品質
    "--pc-quality": "ultra",           # 点群品質
    "--orthophoto-resolution": "1",    # オルソフォト解像度(cm/px)
    "--dem-resolution": "1",           # DEM解像度(cm/px)
    "--use-hybrid-bundle-adjustment": "true"
}

odm.run_advanced_processing(images_folder, output_folder, custom_params)
```

### Docker実行例

```python
# Dockerでの実行
docker_cmd = [
    "docker", "run", "-it", "--rm",
    "-v", f"{images_folder}:/code/images",
    "-v", f"{project_folder}:/code/odm_data",
    "opendronemap/odm",
    "--project-path", "/code/odm_data",
    "--feature-quality", "ultra",
    "--pc-quality", "ultra",
    "/code/images"
]
```

## 📊 出力ファイル

ODM処理により以下のファイルが生成されます：

| ファイル | 説明 | パス |
|---------|------|------|
| 点群データ | PLYフォーマットの3D点群 | `odm_georeferencing/odm_georeferenced_model.ply` |
| 3Dメッシュ | テクスチャ付きOBJメッシュ | `odm_texturing/odm_textured_model.obj` |
| オルソフォト | 地理参照されたTIFF画像 | `odm_orthophoto/odm_orthophoto.tif` |
| DEM | Digital Elevation Model | `odm_dem/dsm.tif` |
| カメラパラメータ | 復元されたカメラ情報 | `opensfm/reconstruction.json` |

## 🎯 使用例とベストプラクティス

### 1. ドローン画像の準備

- **最小要件**: 3枚以上の画像
- **推奨**: 20-100枚程度
- **オーバーラップ**: 70-80%の重複
- **フォーマット**: JPEG, TIFF
- **EXIF情報**: GPS座標が含まれていることを推奨

### 2. 品質設定の選択

```python
# 高速処理（テスト用）
fast_params = {
    "--feature-quality": "low",
    "--pc-quality": "medium",
    "--mesh-size": "100000"
}

# 高品質処理（最終成果物用）
quality_params = {
    "--feature-quality": "ultra",
    "--pc-quality": "ultra",
    "--mesh-size": "500000",
    "--orthophoto-resolution": "1",
    "--dem-resolution": "1"
}
```

### 3. エラー対処

よくあるエラーと対処法：

| エラー | 原因 | 対処法 |
|--------|------|--------|
| 特徴点不足 | 画像の重複不足 | `--matcher-neighbors`を増加 |
| メモリ不足 | 大きなデータセット | `--mesh-size`を減少、`--optimize-disk-space`を使用 |
| 処理時間長い | 高品質設定 | 段階的に品質を下げて調整 |

## 🔧 WebODM API使用

WebODMサーバーとの連携：

```python
from opendronemap_samples import WebODMClient

# WebODMクライアント作成
client = WebODMClient("http://localhost:8000", "admin", "admin")

# ログイン
if client.login():
    # プロジェクト作成
    project_id = client.create_project("テストプロジェクト")
    
    # 画像アップロード・処理開始
    task_uuid = client.upload_images_and_process(project_id, images_folder)
    
    # 処理状況監視
    while True:
        status = client.check_task_status(project_id, task_uuid)
        if status.get("status", {}).get("code") == 40:  # 完了
            break
        time.sleep(30)
```

## 📈 パフォーマンス最適化

### システム要件

- **CPU**: 4コア以上（8コア推奨）
- **RAM**: 8GB以上（16GB推奨）
- **ストレージ**: SSD推奨
- **GPU**: CUDA対応GPU（オプション）

### 最適化設定

```ini
# odm_config.iniでの設定
[processing]
feature_quality = high          # ultra → high で高速化
pc_quality = high              # ultra → high で高速化

[advanced]
optimize_disk_space = true     # ディスク使用量削減
matcher_neighbors = 8          # デフォルト値で安定性確保
```

## 🐛 トラブルシューティング

### ログの確認

```python
# バッチ処理のログ確認
processor = ODMBatchProcessor()
# ログは odm_batch.log に出力される

# 個別プロジェクトのログ確認
# output/project_name/odm_log.txt をチェック
```

### デバッグモード

```python
# より詳細な情報を出力
custom_params = {
    "--verbose": "true",
    "--debug": "true"
}
```

## 📚 参考資料

- [OpenDroneMap公式ドキュメント](https://docs.opendronemap.org/)
- [ODMコマンドライン引数](https://docs.opendronemap.org/arguments/)
- [WebODM API](https://github.com/OpenDroneMap/WebODM/blob/master/app/api/README.md)
- [Docker Hub - ODM](https://hub.docker.com/r/opendronemap/odm)

## 📄 ライセンス

このサンプルコードはMITライセンスで提供されています。
OpenDroneMap自体はAGPLライセンスです。

## 🤝 コントリビューション

改善提案やバグ報告は以下まで：
- Issues: プロジェクトのIssueページ
- Pull Requests: 機能追加や修正