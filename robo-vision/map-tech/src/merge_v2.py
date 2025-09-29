import open3d as o3d
import numpy as np

pcd = o3d.io.read_point_cloud("odm_georeferenced_model.ply")
pts = np.asarray(pcd.points)

print("X range:", pts[:,0].min(), "to", pts[:,0].max())
print("Y range:", pts[:,1].min(), "to", pts[:,1].max())
print("Z range:", pts[:,2].min(), "to", pts[:,2].max())