## Overview
This module generates **synthetic spatial datasets** with both **continuous** and **discrete heterogeneity** on a regular grid.

## Functions

- **make_grid**  
  Build a regular grid and return flattened coordinates and grid indices.

- **assemble_gdf**  
  Package arrays into a `pandas.DataFrame` and `geopandas.GeoDataFrame` with point geometry and CRS.

- **plt_sub**  
  Visualize multiple fields as subplots on the grid, with optional colorbars.

- **gen_uniform**  
  Generate two independent uniformly distributed features.

- **gen_corr_grf**  
  Generate two correlated Gaussian Random Field features with target correlation `rho`.

- **comp_y**  
  Compute response values using the model:  
  `y = a1 * X1 + a2 * X2 + b + eps`  

- **gen_voronoi_data**  
  Create Voronoi-style regions (based on random seeds or given labels), expand region coefficients, and generate response data.

- **dis_surface**  
  Discretize a continuous surface using pivot-based rounding and optional upper/lower caps.

## Quick Start Example

```python

# Generate grid
x_spatial, y_spatial, u, v = make_grid(n_points=2500, x_min=0, x_max=10, y_min=0, y_max=10)

# Generate GRF features
X1, X2 = gen_corr_grf(n_points=2500, rho=0.3)

# Build dataset
df, gdf = gen_voronoi_data(n_points=2500, X1=X1, X2=X2, K = 5)


