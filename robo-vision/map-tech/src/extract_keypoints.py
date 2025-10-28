import open3d as o3d

# 1. サンプル点群を読み込み
pcd = o3d.io.read_point_cloud(o3d.data.DemoICPPointClouds().paths[0])

# 2. 法線推定
pcd.estimate_normals(
    search_param=o3d.geometry.KDTreeSearchParamHybrid(radius=0.05, max_nn=30)
)

# 3. ISS Keypoint 抽出
keypoints = o3d.geometry.keypoint.compute_iss_keypoints(
    pcd,
    salient_radius=0.05,
    non_max_radius=0.05,
    gamma_21=0.5,
    gamma_32=0.5
)

# 4. 可視化のために特徴点を赤い球で表示
pcd.paint_uniform_color([0.6, 0.6, 0.6])   # 元点群は灰色
keypoints.paint_uniform_color([1.0, 0.0, 0.0])  # 特徴点は赤色

# 特徴点を大きめの球として描画
spheres = []
for kp in keypoints.points:
    sphere = o3d.geometry.TriangleMesh.create_sphere(radius=0.01)
    sphere.translate(kp)
    sphere.paint_uniform_color([1, 0, 0])
    spheres.append(sphere)

o3d.visualization.draw_geometries([pcd, *spheres])
