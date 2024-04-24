import pyvista as pv
import numpy as np



def get_fresh_plotter():
    plotter = pv.Plotter()
    xyz_arr = np.random.rand(30000).reshape(10000, 3)
    wire_cloud = pv.PolyData(xyz_arr)
    plotter.add_mesh(wire_cloud, opacity=0.5, color=(1.0, 0.5, 0.5))

    xyz_arr = np.random.rand(30000).reshape(10000, 3)
    xyz_arr[:, 0] += 3.0
    wire_cloud = pv.PolyData(xyz_arr)
    plotter.add_mesh(wire_cloud, opacity=0.5, color=(0.5, 0.5, 1.0))

    return plotter

get_fresh_plotter().show(interactive=False, screenshot="pyvista_out_1.jpg")
get_fresh_plotter().show(interactive=True, screenshot="pyvista_out_2.jpg")