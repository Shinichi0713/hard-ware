#!/usr/bin/env python3
"""
ODMバッチ処理スクリプト

複数のプロジェクトを自動で処理するスクリプト
設定ファイル(odm_config.ini)を読み込んで実行
"""

import configparser
import subprocess
import json
import os
import shutil
from pathlib import Path
from datetime import datetime
import logging


class ODMBatchProcessor:
    """ODMバッチ処理クラス"""
    
    def __init__(self, config_file: str = "odm_config.ini"):
        """
        Args:
            config_file: 設定ファイルパス
        """
        self.config = configparser.ConfigParser()
        self.config.read(config_file, encoding='utf-8')
        
        # ログ設定
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler('odm_batch.log', encoding='utf-8'),
                logging.StreamHandler()
            ]
        )
        self.logger = logging.getLogger(__name__)
    
    def validate_inputs(self, images_folder: str) -> bool:
        """入力の検証"""
        images_path = Path(images_folder)
        
        if not images_path.exists():
            self.logger.error(f"画像フォルダが存在しません: {images_folder}")
            return False
        
        # 画像ファイルの確認
        image_extensions = {'.jpg', '.jpeg', '.png', '.tiff', '.tif'}
        image_files = [f for f in images_path.iterdir() 
                      if f.suffix.lower() in image_extensions]
        
        if len(image_files) < 3:
            self.logger.error(f"画像が不足しています (最小3枚必要): {len(image_files)}枚")
            return False
        
        self.logger.info(f"検証完了: {len(image_files)}枚の画像を検出")
        return True
    
    def build_odm_command(self, images_folder: str, output_folder: str) -> list:
        """ODMコマンドを構築"""
        
        # Docker使用時のコマンド
        if self.config.getboolean('docker', 'use_docker', fallback=False):
            cmd = [
                'docker', 'run', '-it', '--rm',
                '-v', f'{images_folder}:/code/images',
                '-v', f'{output_folder}:/code/odm_data'
            ]
            
            # GPU使用設定
            if self.config.getboolean('docker', 'docker_gpu', fallback=False):
                cmd.extend(['--gpus', 'all'])
            
            cmd.append(self.config.get('docker', 'docker_image', fallback='opendronemap/odm'))
            
            # パラメータ追加
            cmd.extend(['--project-path', '/code/odm_data'])
            
        else:
            # 直接実行
            cmd = [self.config.get('paths', 'odm_executable', fallback='odm')]
            cmd.extend(['--project-path', output_folder])
        
        # 処理パラメータ
        processing_params = {
            '--feature-quality': self.config.get('processing', 'feature_quality', fallback='high'),
            '--pc-quality': self.config.get('processing', 'pc_quality', fallback='high'),
            '--mesh-size': self.config.get('processing', 'mesh_size', fallback='200000'),
            '--mesh-octree-depth': self.config.get('processing', 'mesh_octree_depth', fallback='9'),
            '--orthophoto-resolution': self.config.get('output', 'orthophoto_resolution', fallback='2'),
            '--dem-resolution': self.config.get('output', 'dem_resolution', fallback='2'),
            '--texture-size': self.config.get('output', 'texture_size', fallback='4096')
        }
        
        # 高度なパラメータ
        if self.config.getboolean('advanced', 'use_hybrid_bundle_adjustment', fallback=True):
            processing_params['--use-hybrid-bundle-adjustment'] = 'true'
        
        if self.config.getboolean('advanced', 'optimize_disk_space', fallback=False):
            processing_params['--optimize-disk-space'] = 'true'
        
        # 途中から再実行
        rerun_from = self.config.get('advanced', 'rerun_from', fallback='')
        if rerun_from:
            processing_params['--rerun-from'] = rerun_from
        
        # パラメータをコマンドに追加
        for param, value in processing_params.items():
            cmd.extend([param, value])
        
        # 画像フォルダパス
        if self.config.getboolean('docker', 'use_docker', fallback=False):
            cmd.append('/code/images')
        else:
            cmd.append(images_folder)
        
        return cmd
    
    def process_project(self, project_name: str, images_folder: str) -> bool:
        """単一プロジェクトを処理"""
        
        self.logger.info(f"プロジェクト処理開始: {project_name}")
        
        # 入力検証
        if not self.validate_inputs(images_folder):
            return False
        
        # 出力フォルダ作成
        base_output = Path(self.config.get('paths', 'output_folder', fallback='./output'))
        output_folder = base_output / project_name
        output_folder.mkdir(parents=True, exist_ok=True)
        
        # プロジェクト情報保存
        project_info = {
            'project_name': project_name,
            'images_folder': str(images_folder),
            'output_folder': str(output_folder),
            'start_time': datetime.now().isoformat(),
            'config': dict(self.config.items())
        }
        
        with open(output_folder / 'project_info.json', 'w', encoding='utf-8') as f:
            json.dump(project_info, f, indent=2, ensure_ascii=False)
        
        # ODMコマンド構築・実行
        cmd = self.build_odm_command(str(images_folder), str(output_folder))
        
        self.logger.info(f"ODMコマンド: {' '.join(cmd)}")
        
        try:
            # 処理実行
            result = subprocess.run(
                cmd, 
                capture_output=True, 
                text=True,
                cwd=str(output_folder)
            )
            
            # 結果をログファイルに保存
            with open(output_folder / 'odm_log.txt', 'w', encoding='utf-8') as f:
                f.write(f"Command: {' '.join(cmd)}\n\n")
                f.write(f"Return code: {result.returncode}\n\n")
                f.write("STDOUT:\n")
                f.write(result.stdout)
                f.write("\n\nSTDERR:\n")
                f.write(result.stderr)
            
            if result.returncode == 0:
                self.logger.info(f"プロジェクト処理完了: {project_name}")
                self._generate_summary_report(output_folder)
                return True
            else:
                self.logger.error(f"処理エラー: {project_name}")
                self.logger.error(f"エラー内容: {result.stderr}")
                return False
                
        except Exception as e:
            self.logger.error(f"実行エラー: {str(e)}")
            return False
    
    def _generate_summary_report(self, output_folder: Path):
        """処理結果サマリーレポート生成"""
        
        report_lines = [
            f"# ODM処理結果レポート",
            f"",
            f"**処理日時**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
            f"**出力フォルダ**: {output_folder}",
            f"",
            f"## 生成ファイル",
            f""
        ]
        
        # 主要出力ファイルの確認
        output_files = {
            "点群データ (PLY)": "odm_georeferencing/odm_georeferenced_model.ply",
            "テクスチャ付きメッシュ (OBJ)": "odm_texturing/odm_textured_model.obj",
            "テクスチャ付きメッシュ (PLY)": "odm_texturing/odm_textured_model.ply",
            "オルソフォト": "odm_orthophoto/odm_orthophoto.tif",
            "DEM": "odm_dem/dsm.tif",
            "DTM": "odm_dem/dtm.tif",
            "3Dタイル": "odm_3dtiles/tileset.json",
            "カメラパラメータ": "opensfm/reconstruction.json"
        }
        
        for description, file_path in output_files.items():
            full_path = output_folder / file_path
            if full_path.exists():
                file_size = full_path.stat().st_size / (1024 * 1024)  # MB
                report_lines.append(f"- ✅ {description}: `{file_path}` ({file_size:.1f} MB)")
            else:
                report_lines.append(f"- ❌ {description}: ファイルなし")
        
        # レポートファイル保存
        report_path = output_folder / "processing_report.md"
        with open(report_path, 'w', encoding='utf-8') as f:
            f.write('\n'.join(report_lines))
        
        self.logger.info(f"処理レポート生成: {report_path}")
    
    def batch_process(self, projects: dict):
        """複数プロジェクトのバッチ処理
        
        Args:
            projects: {'project_name': 'images_folder_path', ...}
        """
        
        self.logger.info(f"バッチ処理開始: {len(projects)}プロジェクト")
        
        results = {}
        
        for project_name, images_folder in projects.items():
            success = self.process_project(project_name, images_folder)
            results[project_name] = success
        
        # バッチ処理結果サマリー
        successful = sum(results.values())
        total = len(results)
        
        self.logger.info(f"バッチ処理完了: {successful}/{total} プロジェクト成功")
        
        # 結果レポート
        for project_name, success in results.items():
            status = "✅ 成功" if success else "❌ 失敗"
            self.logger.info(f"  {project_name}: {status}")


def main():
    """使用例"""
    
    # バッチプロセッサー作成
    processor = ODMBatchProcessor()
    
    # 単一プロジェクト処理例
    # processor.process_project("test_project", r"C:\path\to\images")
    
    # バッチ処理例
    projects = {
        "project_001": r"C:\drone_data\project_001\images",
        "project_002": r"C:\drone_data\project_002\images",
        "project_003": r"C:\drone_data\project_003\images"
    }
    
    # 実際の実行（コメントアウト）
    # processor.batch_process(projects)
    
    print("ODMバッチ処理スクリプト")
    print("設定ファイル(odm_config.ini)を編集後、projects辞書を設定して実行してください")


if __name__ == "__main__":
    main()
