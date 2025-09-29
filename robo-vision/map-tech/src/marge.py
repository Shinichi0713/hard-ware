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