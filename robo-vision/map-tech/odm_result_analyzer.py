#!/usr/bin/env python3
"""
ODM結果可視化・分析スクリプト

ODMで生成された3Dデータを可視化・分析するサンプル
"""

import numpy as np
import open3d as o3d
import matplotlib.pyplot as plt
from pathlib import Path
import json
import cv2
from typing import Tuple, Optional
import rasterio
from rasterio.plot import show


class ODMResultAnalyzer:
    """ODM結果分析クラス"""
    
    def __init__(self, project_folder: str):
        """
        Args:
            project_folder: ODMプロジェクトフォルダパス
        """
        self.project_path = Path(project_folder)
        self.point_cloud = None
        self.mesh = None
        self.reconstruction_data = None
    
    def load_point_cloud(self) -> bool:
        """点群データを読み込み"""
        ply_path = self.project_path / "odm_georeferencing" / "odm_georeferenced_model.ply"
        
        if not ply_path.exists():
            print(f"点群ファイルが見つかりません: {ply_path}")
            return False
        
        try:
            self.point_cloud = o3d.io.read_point_cloud(str(ply_path))
            print(f"点群読み込み成功: {len(self.point_cloud.points)}点")
            return True
        except Exception as e:
            print(f"点群読み込みエラー: {str(e)}")
            return False
    
    def load_mesh(self) -> bool:
        """メッシュデータを読み込み"""
        obj_path = self.project_path / "odm_texturing" / "odm_textured_model.obj"
        ply_path = self.project_path / "odm_texturing" / "odm_textured_model.ply"
        
        # OBJファイル優先
        mesh_path = obj_path if obj_path.exists() else ply_path
        
        if not mesh_path.exists():
            print(f"メッシュファイルが見つかりません")
            return False
        
        try:
            self.mesh = o3d.io.read_triangle_mesh(str(mesh_path))
            print(f"メッシュ読み込み成功: {len(self.mesh.vertices)}頂点, {len(self.mesh.triangles)}面")
            return True
        except Exception as e:
            print(f"メッシュ読み込みエラー: {str(e)}")
            return False
    
    def load_reconstruction_info(self) -> bool:
        """OpenSfM復元情報を読み込み"""
        json_path = self.project_path / "opensfm" / "reconstruction.json"
        
        if not json_path.exists():
            print(f"復元情報ファイルが見つかりません: {json_path}")
            return False
        
        try:
            with open(json_path, 'r') as f:
                self.reconstruction_data = json.load(f)
            print("復元情報読み込み成功")
            return True
        except Exception as e:
            print(f"復元情報読み込みエラー: {str(e)}")
            return False
    
    def visualize_point_cloud(self, downsample_factor: float = 1.0):
        """点群を可視化"""
        if self.point_cloud is None:
            if not self.load_point_cloud():
                return
        
        # ダウンサンプリング
        if downsample_factor < 1.0:
            self.point_cloud = self.point_cloud.random_down_sample(downsample_factor)
        
        # 可視化
        print("点群を可視化中...")
        o3d.visualization.draw_geometries(
            [self.point_cloud],
            window_name="ODM点群データ",
            width=1200,
            height=800
        )
    
    def visualize_mesh(self, show_wireframe: bool = False):
        """メッシュを可視化"""
        if self.mesh is None:
            if not self.load_mesh():
                return
        
        # 法線計算
        if not self.mesh.has_vertex_normals():
            self.mesh.compute_vertex_normals()
        
        # 可視化設定
        geometries = [self.mesh]
        
        if show_wireframe:
            # ワイヤーフレーム追加
            wireframe = o3d.geometry.LineSet.create_from_triangle_mesh(self.mesh)
            wireframe.paint_uniform_color([0, 0, 0])
            geometries.append(wireframe)
        
        print("3Dメッシュを可視化中...")
        o3d.visualization.draw_geometries(
            geometries,
            window_name="ODM 3Dメッシュ",
            width=1200,
            height=800
        )
    
    def analyze_point_cloud_statistics(self) -> dict:
        """点群の統計情報を分析"""
        if self.point_cloud is None:
            if not self.load_point_cloud():
                return {}
        
        points = np.asarray(self.point_cloud.points)
        colors = np.asarray(self.point_cloud.colors) if self.point_cloud.has_colors() else None
        
        stats = {
            "点数": len(points),
            "バウンディングボックス": {
                "最小値": points.min(axis=0).tolist(),
                "最大値": points.max(axis=0).tolist(),
                "サイズ": (points.max(axis=0) - points.min(axis=0)).tolist()
            },
            "中心座標": points.mean(axis=0).tolist(),
            "標準偏差": points.std(axis=0).tolist()
        }
        
        if colors is not None:
            stats["色情報"] = {
                "平均RGB": colors.mean(axis=0).tolist(),
                "色の標準偏差": colors.std(axis=0).tolist()
            }
        
        # 統計情報表示
        print("\n=== 点群統計情報 ===")
        for key, value in stats.items():
            print(f"{key}: {value}")
        
        return stats
    
    def analyze_mesh_quality(self) -> dict:
        """メッシュ品質を分析"""
        if self.mesh is None:
            if not self.load_mesh():
                return {}
        
        # メッシュ情報
        vertices = np.asarray(self.mesh.vertices)
        triangles = np.asarray(self.mesh.triangles)
        
        # エッジ長統計
        edge_lengths = []
        for triangle in triangles:
            for i in range(3):
                v1 = vertices[triangle[i]]
                v2 = vertices[triangle[(i + 1) % 3]]
                edge_lengths.append(np.linalg.norm(v1 - v2))
        
        edge_lengths = np.array(edge_lengths)
        
        quality_stats = {
            "頂点数": len(vertices),
            "面数": len(triangles),
            "エッジ統計": {
                "平均長": float(edge_lengths.mean()),
                "最小長": float(edge_lengths.min()),
                "最大長": float(edge_lengths.max()),
                "標準偏差": float(edge_lengths.std())
            }
        }
        
        # 非多様体エッジチェック
        if self.mesh.is_edge_manifold():
            quality_stats["エッジ多様体"] = "正常"
        else:
            quality_stats["エッジ多様体"] = "異常"
        
        # 頂点多様体チェック
        if self.mesh.is_vertex_manifold():
            quality_stats["頂点多様体"] = "正常"
        else:
            quality_stats["頂点多様体"] = "異常"
        
        print("\n=== メッシュ品質分析 ===")
        for key, value in quality_stats.items():
            print(f"{key}: {value}")
        
        return quality_stats
    
    def display_orthophoto(self):
        """オルソフォトを表示"""
        ortho_path = self.project_path / "odm_orthophoto" / "odm_orthophoto.tif"
        
        if not ortho_path.exists():
            print(f"オルソフォトが見つかりません: {ortho_path}")
            return
        
        try:
            # rasterioで読み込み
            with rasterio.open(ortho_path) as src:
                print(f"オルソフォト情報:")
                print(f"  サイズ: {src.width} x {src.height}")
                print(f"  バンド数: {src.count}")
                print(f"  座標系: {src.crs}")
                print(f"  解像度: {src.res}")
                
                # プロット
                fig, ax = plt.subplots(figsize=(12, 8))
                show(src, ax=ax, title="ODM オルソフォト")
                plt.tight_layout()
                plt.show()
                
        except Exception as e:
            print(f"オルソフォト表示エラー: {str(e)}")
    
    def display_dem(self):
        """DEMを表示"""
        dem_path = self.project_path / "odm_dem" / "dsm.tif"
        
        if not dem_path.exists():
            print(f"DEMが見つかりません: {dem_path}")
            return
        
        try:
            with rasterio.open(dem_path) as src:
                dem_data = src.read(1)
                
                print(f"DEM情報:")
                print(f"  サイズ: {src.width} x {src.height}")
                print(f"  座標系: {src.crs}")
                print(f"  標高範囲: {dem_data.min():.2f} - {dem_data.max():.2f}")
                
                # プロット
                fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(15, 6))
                
                # DEM表示
                im1 = ax1.imshow(dem_data, cmap='terrain')
                ax1.set_title("DEM (Digital Surface Model)")
                plt.colorbar(im1, ax=ax1, label="標高 (m)")
                
                # 標高ヒストグラム
                ax2.hist(dem_data.flatten(), bins=50, alpha=0.7)
                ax2.set_xlabel("標高 (m)")
                ax2.set_ylabel("頻度")
                ax2.set_title("標高分布")
                
                plt.tight_layout()
                plt.show()
                
        except Exception as e:
            print(f"DEM表示エラー: {str(e)}")
    
    def analyze_camera_positions(self):
        """カメラ位置を分析・可視化"""
        if self.reconstruction_data is None:
            if not self.load_reconstruction_info():
                return
        
        if not self.reconstruction_data:
            print("復元データが空です")
            return
        
        # 最初の復元結果を使用
        reconstruction = self.reconstruction_data[0]
        cameras = reconstruction.get('cameras', {})
        shots = reconstruction.get('shots', {})
        
        print(f"\n=== カメラ分析 ===")
        print(f"カメラ数: {len(cameras)}")
        print(f"ショット数: {len(shots)}")
        
        # カメラ位置取得
        positions = []
        for shot_name, shot_data in shots.items():
            translation = shot_data.get('translation', [0, 0, 0])
            positions.append(translation)
        
        if positions:
            positions = np.array(positions)
            
            # 統計情報
            print(f"カメラ位置範囲:")
            print(f"  X: {positions[:, 0].min():.2f} - {positions[:, 0].max():.2f}")
            print(f"  Y: {positions[:, 1].min():.2f} - {positions[:, 1].max():.2f}")
            print(f"  Z: {positions[:, 2].min():.2f} - {positions[:, 2].max():.2f}")
            
            # 3Dプロット
            fig = plt.figure(figsize=(10, 8))
            ax = fig.add_subplot(111, projection='3d')
            
            ax.scatter(positions[:, 0], positions[:, 1], positions[:, 2], 
                      c='red', marker='o', s=50)
            ax.set_xlabel('X')
            ax.set_ylabel('Y')
            ax.set_zlabel('Z')
            ax.set_title('カメラ位置分布')
            
            plt.show()
    
    def generate_full_report(self) -> str:
        """完全な分析レポートを生成"""
        report_path = self.project_path / "analysis_report.md"
        
        # 各種分析実行
        pc_stats = self.analyze_point_cloud_statistics()
        mesh_stats = self.analyze_mesh_quality()
        
        # レポート作成
        report_lines = [
            f"# ODM処理結果分析レポート",
            f"",
            f"**プロジェクト**: {self.project_path.name}",
            f"**分析日時**: {Path().ctime()}",
            f"",
            f"## 点群統計",
            f"",
        ]
        
        for key, value in pc_stats.items():
            report_lines.append(f"- **{key}**: {value}")
        
        report_lines.extend([
            f"",
            f"## メッシュ品質",
            f"",
        ])
        
        for key, value in mesh_stats.items():
            report_lines.append(f"- **{key}**: {value}")
        
        # ファイル存在確認
        report_lines.extend([
            f"",
            f"## 出力ファイル確認",
            f"",
        ])
        
        output_files = [
            "odm_georeferencing/odm_georeferenced_model.ply",
            "odm_texturing/odm_textured_model.obj",
            "odm_orthophoto/odm_orthophoto.tif",
            "odm_dem/dsm.tif"
        ]
        
        for file_path in output_files:
            full_path = self.project_path / file_path
            status = "✅" if full_path.exists() else "❌"
            size = f"({full_path.stat().st_size / 1024 / 1024:.1f} MB)" if full_path.exists() else ""
            report_lines.append(f"- {status} `{file_path}` {size}")
        
        # レポート保存
        with open(report_path, 'w', encoding='utf-8') as f:
            f.write('\n'.join(report_lines))
        
        print(f"分析レポート生成完了: {report_path}")
        return str(report_path)


def main():
    """使用例"""
    
    # 分析対象プロジェクトパス（実際のパスに変更）
    project_folder = r"C:\path\to\odm\output\project"
    
    # アナライザー作成
    analyzer = ODMResultAnalyzer(project_folder)
    
    print("=== ODM結果分析・可視化サンプル ===\n")
    
    # 各種分析・可視化（実際の実行はコメントアウト）
    
    # 1. 点群可視化
    # analyzer.visualize_point_cloud(downsample_factor=0.5)
    
    # 2. メッシュ可視化
    # analyzer.visualize_mesh(show_wireframe=False)
    
    # 3. 統計分析
    # analyzer.analyze_point_cloud_statistics()
    # analyzer.analyze_mesh_quality()
    
    # 4. オルソフォト・DEM表示
    # analyzer.display_orthophoto()
    # analyzer.display_dem()
    
    # 5. カメラ位置分析
    # analyzer.analyze_camera_positions()
    
    # 6. 完全レポート生成
    # analyzer.generate_full_report()
    
    print("プロジェクトパスを設定後、各メソッドのコメントアウトを解除して実行してください")


if __name__ == "__main__":
    main()
