#!/usr/bin/env python3
"""
OpenDroneMap (ODM) サンプルコード集

このファイルには以下のサンプルが含まれています：
1. ODMコマンドライン実行
2. WebODM REST API使用
3. NodeODM API使用
4. カスタムパラメータでの実行
"""

import os
import subprocess
import requests
import json
import time
from pathlib import Path
from typing import Dict, List, Optional


class OpenDroneMapProcessor:
    """OpenDroneMapを使用した3D復元処理クラス"""
    
    def __init__(self, odm_path: str = "odm"):
        """
        Args:
            odm_path: ODMの実行パス（Docker使用時は "docker run -it --rm -v ..." など）
        """
        self.odm_path = odm_path
        self.project_path = None
    
    def run_basic_processing(self, images_folder: str, output_folder: str) -> bool:
        """
        基本的なODM処理を実行
        
        Args:
            images_folder: ドローン画像が格納されたフォルダパス
            output_folder: 出力フォルダパス
            
        Returns:
            処理成功時True
        """
        try:
            # ODMコマンドの構築
            cmd = [
                self.odm_path,
                "--project-path", output_folder,
                images_folder
            ]
            
            print(f"ODM処理を開始: {' '.join(cmd)}")
            
            # 処理実行
            result = subprocess.run(cmd, capture_output=True, text=True)
            
            if result.returncode == 0:
                print("ODM処理が正常に完了しました")
                return True
            else:
                print(f"ODM処理でエラーが発生: {result.stderr}")
                return False
                
        except Exception as e:
            print(f"実行エラー: {str(e)}")
            return False
    
    def run_advanced_processing(self, images_folder: str, output_folder: str, 
                              custom_params: Dict[str, str] = None) -> bool:
        """
        高度なパラメータを使用したODM処理
        
        Args:
            images_folder: 画像フォルダパス
            output_folder: 出力フォルダパス
            custom_params: カスタムパラメータ辞書
        """
        if custom_params is None:
            custom_params = {
                "--mesh-size": "200000",           # メッシュサイズ
                "--mesh-octree-depth": "9",        # オクトリー深度
                "--feature-quality": "high",       # 特徴点品質
                "--pc-quality": "high",            # 点群品質
                "--orthophoto-resolution": "2",    # オルソフォト解像度(cm/px)
                "--dem-resolution": "2",           # DEM解像度(cm/px)
                "--use-hybrid-bundle-adjustment": "true"  # ハイブリッドバンドル調整
            }
        
        try:
            # コマンド構築
            cmd = [self.odm_path, "--project-path", output_folder]
            
            # カスタムパラメータ追加
            for param, value in custom_params.items():
                cmd.extend([param, value])
            
            cmd.append(images_folder)
            
            print(f"高度なODM処理を開始: {' '.join(cmd)}")
            
            # 処理実行
            result = subprocess.run(cmd, capture_output=True, text=True)
            
            if result.returncode == 0:
                print("高度なODM処理が正常に完了しました")
                self._print_output_files(output_folder)
                return True
            else:
                print(f"ODM処理でエラーが発生: {result.stderr}")
                return False
                
        except Exception as e:
            print(f"実行エラー: {str(e)}")
            return False
    
    def _print_output_files(self, output_folder: str):
        """出力ファイルリストを表示"""
        output_path = Path(output_folder)
        
        print("\n=== 生成された出力ファイル ===")
        
        # 主要な出力ファイル
        output_files = {
            "点群データ": "odm_georeferencing/odm_georeferenced_model.ply",
            "テクスチャ付きメッシュ": "odm_texturing/odm_textured_model.obj",
            "オルソフォト": "odm_orthophoto/odm_orthophoto.tif",
            "DEM": "odm_dem/dsm.tif",
            "カメラパラメータ": "opensfm/reconstruction.json"
        }
        
        for description, file_path in output_files.items():
            full_path = output_path / file_path
            if full_path.exists():
                print(f"✓ {description}: {full_path}")
            else:
                print(f"✗ {description}: ファイルが見つかりません")


class WebODMClient:
    """WebODM REST APIクライアント"""
    
    def __init__(self, base_url: str = "http://localhost:8000", 
                 username: str = "admin", password: str = "admin"):
        """
        Args:
            base_url: WebODMサーバーのURL
            username: ユーザー名
            password: パスワード
        """
        self.base_url = base_url
        self.username = username
        self.password = password
        self.token = None
        self.session = requests.Session()
    
    def login(self) -> bool:
        """WebODMにログイン"""
        try:
            response = self.session.post(
                f"{self.base_url}/api/token-auth/",
                data={"username": self.username, "password": self.password}
            )
            
            if response.status_code == 200:
                self.token = response.json()["token"]
                self.session.headers.update({"Authorization": f"JWT {self.token}"})
                print("WebODMログイン成功")
                return True
            else:
                print(f"ログイン失敗: {response.status_code}")
                return False
                
        except Exception as e:
            print(f"ログインエラー: {str(e)}")
            return False
    
    def create_project(self, name: str, description: str = "") -> Optional[int]:
        """新しいプロジェクトを作成"""
        try:
            data = {
                "name": name,
                "description": description
            }
            
            response = self.session.post(f"{self.base_url}/api/projects/", json=data)
            
            if response.status_code == 201:
                project_id = response.json()["id"]
                print(f"プロジェクト作成成功: ID={project_id}")
                return project_id
            else:
                print(f"プロジェクト作成失敗: {response.status_code}")
                return None
                
        except Exception as e:
            print(f"プロジェクト作成エラー: {str(e)}")
            return None
    
    def upload_images_and_process(self, project_id: int, images_folder: str, 
                                options: Dict = None) -> Optional[str]:
        """画像をアップロードして処理を開始"""
        try:
            # タスク作成
            task_data = {
                "project": project_id,
                "name": f"Task_{int(time.time())}",
                "options": options or {}
            }
            
            # 画像ファイルの準備
            files = []
            images_path = Path(images_folder)
            
            for img_file in images_path.glob("*.{jpg,jpeg,png,tiff,tif}"):
                files.append(("images", (img_file.name, open(img_file, "rb"), "image/jpeg")))
            
            # アップロード・処理開始
            response = self.session.post(
                f"{self.base_url}/api/projects/{project_id}/tasks/",
                data=task_data,
                files=files
            )
            
            # ファイルクローズ
            for _, (_, file_obj, _) in files:
                file_obj.close()
            
            if response.status_code == 201:
                task_uuid = response.json()["id"]
                print(f"タスク作成・処理開始: UUID={task_uuid}")
                return task_uuid
            else:
                print(f"タスク作成失敗: {response.status_code}")
                return None
                
        except Exception as e:
            print(f"アップロード・処理エラー: {str(e)}")
            return None
    
    def check_task_status(self, project_id: int, task_uuid: str) -> Dict:
        """タスクの処理状況を確認"""
        try:
            response = self.session.get(
                f"{self.base_url}/api/projects/{project_id}/tasks/{task_uuid}/"
            )
            
            if response.status_code == 200:
                task_info = response.json()
                status = task_info.get("status", {})
                
                print(f"タスク状況: {status.get('code', 'unknown')}")
                print(f"進捗: {task_info.get('running_progress', 0)}%")
                
                return task_info
            else:
                print(f"状況確認失敗: {response.status_code}")
                return {}
                
        except Exception as e:
            print(f"状況確認エラー: {str(e)}")
            return {}


def docker_odm_example():
    """DockerでODMを実行する例"""
    
    # 画像フォルダとプロジェクトフォルダの設定
    images_folder = r"C:\path\to\drone\images"
    project_folder = r"C:\path\to\output\project"
    
    # Dockerコマンドの構築
    docker_cmd = [
        "docker", "run", "-it", "--rm",
        "-v", f"{images_folder}:/code/images",
        "-v", f"{project_folder}:/code/odm_data",
        "opendronemap/odm",
        "--project-path", "/code/odm_data",
        "/code/images"
    ]
    
    print("Docker ODM実行例:")
    print(" ".join(docker_cmd))
    
    # 実際の実行（コメントアウト）
    # subprocess.run(docker_cmd)


def main():
    """メイン実行関数"""
    
    print("=== OpenDroneMap サンプルコード ===\n")
    
    # 1. 基本的なODM処理例
    print("1. 基本的なODM処理")
    odm_processor = OpenDroneMapProcessor()
    
    # 実際のパスに変更してください
    images_folder = r"C:\path\to\drone\images"
    output_folder = r"C:\path\to\output"
    
    # 基本処理（実際の実行はコメントアウト）
    # odm_processor.run_basic_processing(images_folder, output_folder)
    
    print("\n2. 高度なパラメータでのODM処理")
    
    # カスタムパラメータ
    custom_params = {
        "--mesh-size": "300000",
        "--feature-quality": "ultra",
        "--pc-quality": "ultra",
        "--orthophoto-resolution": "1",
        "--dem-resolution": "1"
    }
    
    # 高度な処理（実際の実行はコメントアウト）
    # odm_processor.run_advanced_processing(images_folder, output_folder, custom_params)
    
    print("\n3. WebODM API使用例")
    
    # WebODMクライアント
    webodm = WebODMClient()
    
    # ログイン（実際の実行はコメントアウト）
    # if webodm.login():
    #     project_id = webodm.create_project("ドローン測量プロジェクト", "説明文")
    #     if project_id:
    #         task_uuid = webodm.upload_images_and_process(project_id, images_folder)
    #         if task_uuid:
    #             # 処理状況の監視
    #             while True:
    #                 status = webodm.check_task_status(project_id, task_uuid)
    #                 if status.get("status", {}).get("code") == 40:  # 完了
    #                     break
    #                 time.sleep(30)  # 30秒待機
    
    print("\n4. Docker実行例")
    docker_odm_example()
    
    print("\n=== サンプルコード完了 ===")
    print("実際に実行する際は、パスを適切に設定し、コメントアウトを解除してください。")


if __name__ == "__main__":
    main()
