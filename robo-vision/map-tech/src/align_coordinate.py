import open3d as o3d
import numpy as np

# -------- helpers --------
def preprocess(pcd, voxel):
    pcd = pcd.voxel_down_sample(voxel)
    pcd.remove_statistical_outlier(nb_neighbors=20, std_ratio=2.0)
    pcd.estimate_normals(o3d.geometry.KDTreeSearchParamHybrid(radius=voxel*2.0, max_nn=30))
    return pcd

def pca_align(src_pts, tgt_pts):
    # 重心合わせ + PCAで回転を推定（符号反転に注意）
    mu_s = src_pts.mean(axis=0)
    mu_t = tgt_pts.mean(axis=0)
    X = src_pts - mu_s
    Y = tgt_pts - mu_t
    # SVD
    Ux, _, _ = np.linalg.svd(X.T @ X)
    Uy, _, _ = np.linalg.svd(Y.T @ Y)
    R = Uy @ Ux.T
    # fix reflection
    if np.linalg.det(R) < 0:
        Uy[:, -1] *= -1
        R = Uy @ Ux.T
    T = np.eye(4)
    T[:3,:3] = R
    T[:3,3] = mu_t - R @ mu_s
    return T

# -------- load --------
src = o3d.io.read_point_cloud("src_utm.ply")
tgt = o3d.io.read_point_cloud("tgt_utm.ply")

# --- coarse downsample ---
voxel_coarse = 1.0   # (m) データスケールに応じて調整
src_ds = preprocess(src, voxel_coarse)
tgt_ds = preprocess(tgt, voxel_coarse)

# --- PCA初期合わせ（簡易） ---
src_pts = np.asarray(src_ds.points)
tgt_pts = np.asarray(tgt_ds.points)
T_pca = pca_align(src_pts, tgt_pts)
print("PCA initial T:\n", T_pca)

# --- TEASER++ を使う場合（頑健な推定） ---
use_teaser = True
if use_teaser:
    try:
        import teaserpp_python as teaser
        # 対応点生成（ここは工夫が必要：descriptorベースが望ましい）
        # ここでは近傍マッチで仮対応（実務では特徴量/画像対応を推奨）
        from sklearn.neighbors import NearestNeighbors
        nn = NearestNeighbors(n_neighbors=1).fit(tgt_pts)
        dists, idxs = nn.kneighbors(src_pts)
        mask = dists[:,0] < 5.0  # coarse閾値（m）
        src_corr = src_pts[mask]
        tgt_corr = tgt_pts[idxs[mask].flatten()]
        # TEASER solver
        params = teaser.default_teaserpp_parameters()
        params.noise_bound = 2.0   # データに合わせて調整
        solver = teaser.RobustRegistrationSolver(params)
        solver.solve(src_corr.T, tgt_corr.T)
        sol = solver.getSolution()
        R = sol.rotation
        t = sol.translation
        T_teaser = np.eye(4)
        T_teaser[:3,:3] = R
        T_teaser[:3,3] = t
        print("TEASER T:\n", T_teaser)
        init_T = T_teaser
    except Exception as e:
        print("TEASER failed or not installed:", e)
        init_T = T_pca
else:
    init_T = T_pca

# --- refine with ICP (multi-scale) ---
# 1) 中間解像度で粗く調整
voxel_mid = 0.5
src_mid = preprocess(src, voxel_mid)
tgt_mid = preprocess(tgt, voxel_mid)
icp1 = o3d.pipelines.registration.registration_icp(
    src_mid, tgt_mid, max_correspondence_distance=voxel_mid*1.5,
    init=init_T,
    estimation_method=o3d.pipelines.registration.TransformationEstimationPointToPlane()
)
print("ICP stage1 fitness:", icp1.fitness, "rmse:", icp1.inlier_rmse)

# 2) フル解像度で最終微調整
icp2 = o3d.pipelines.registration.registration_icp(
    src, tgt, max_correspondence_distance=0.2,  # 最終閾値、対象に応じて調整
    init=icp1.transformation,
    estimation_method=o3d.pipelines.registration.TransformationEstimationPointToPlane()
)
print("ICP final fitness:", icp2.fitness, "rmse:", icp2.inlier_rmse)
T_final = icp2.transformation

# --- apply and save ---
src_aligned = src.transform(T_final)
merged = tgt + src  # src は transform 済みなので OK
o3d.io.write_point_cloud("merged_utm.ply", merged)
print("Saved merged_utm.ply")