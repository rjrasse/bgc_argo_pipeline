"""
BGC-Argo Multi-Panel Visualization Pipeline
------------------------------------------

Purpose:
This script generates a standardized multi-panel figure for BGC-Argo float data,
combining physical and biogeochemical variables in the upper ocean.

Panels:
(1) Potential density (σθ)
(2) Chlorophyll-a
(3) Particle backscattering (bbp700)

Physical-biological coupling indicators:
- Mixed Layer Depth (MLD)
- Productive layer depth

Author: Rafael Rasse
"""

# =========================
# 1. LIBRARIES
# =========================

import os
import numpy as np
import matplotlib.pyplot as plt
import matplotlib as mpl
import cmocean
from scipy.interpolate import griddata

# =========================
# 2. CONFIGURATION
# =========================

FLOAT_ID = "6901583"

# Generic project structure (GitHub-ready)
DATA_DIR = os.path.join("data", FLOAT_ID)
OUT_DIR = os.path.join("outputs", "figures")

os.makedirs(OUT_DIR, exist_ok=True)

# Time correction (Matlab/NetCDF compatibility)
JULD_SHIFT = 366

# Depth limits per variable (physical consistency)
DEPTH_LIMITS = {
    "sigma": 1000,
    "chl": 500,
    "bbp": 1000
}

# =========================
# 3. HELPER FUNCTION
# =========================

def load_xyz(file_path, shift=JULD_SHIFT):
    """
    Load processed float data in XYZ format.

    Parameters
    ----------
    file_path : str
        Path to .dat file (time, depth, variable)
    shift : float
        Time correction factor (Julian date alignment)

    Returns
    -------
    x, y, z : arrays
    """
    x, y, z = np.loadtxt(file_path, unpack=True, usecols=(0, 1, 2))
    return x - shift, y, z

# =========================
# 4. LOAD DATA
# =========================

xbbp, ybbp, zbbp = load_xyz(os.path.join(DATA_DIR, f"{FLOAT_ID}_bbp.dat"))
xsigma, ysigma, zsigma = load_xyz(os.path.join(DATA_DIR, f"{FLOAT_ID}_sigma.dat"))
xchl, ychl, zchl = load_xyz(os.path.join(DATA_DIR, f"{FLOAT_ID}_chl.dat"))

mld_time, mld = np.loadtxt(os.path.join(DATA_DIR, f"{FLOAT_ID}_mld.dat"), unpack=True)
prd_time, prd_depth = np.loadtxt(os.path.join(DATA_DIR, f"{FLOAT_ID}_productive_layer.dat"), unpack=True)

mld_time -= JULD_SHIFT
prd_time -= JULD_SHIFT

# =========================
# 5. SIGMA THETA INTERPOLATION
# =========================

xi = np.linspace(xsigma.min(), xsigma.max(), 1500)
yi = np.linspace(0, ysigma.max(), 400)
Xi, Yi = np.meshgrid(xi, yi)

Zi = griddata(
    (xsigma, ysigma),
    zsigma,
    (Xi, Yi),
    method="linear"
)

# =========================
# 6. FIGURE SETUP
# =========================

plt.close("all")
fig = plt.figure(figsize=(16, 12))

# =========================
# 7. PANEL 1 - SIGMA THETA (PHYSICAL STRUCTURE)
# =========================

ax1 = fig.add_subplot(311)

ax1.contour(Xi, Yi, Zi, levels=10, colors="white", linewidths=0.6)

sc1 = ax1.scatter(
    xsigma, ysigma,
    c=zsigma,
    s=12,
    cmap=cmocean.cm.dense,
    vmin=np.nanpercentile(zsigma, 1),
    vmax=np.nanpercentile(zsigma, 99)
)

ax1.plot(mld_time, mld, "r", lw=2, label="MLD")

ax1.invert_yaxis()
ax1.set_ylabel("Depth (m)")
ax1.set_title("Potential Density (σθ)")

plt.colorbar(sc1, ax=ax1, label="σθ (kg m⁻³)")

# =========================
# 8. PANEL 2 - CHLOROPHYLL (BIOLOGY)
# =========================

ax2 = fig.add_subplot(312)

sc2 = ax2.scatter(
    xchl, ychl,
    c=zchl,
    s=12,
    cmap="cividis",
    vmin=np.nanpercentile(zchl, 5),
    vmax=np.nanpercentile(zchl, 98)
)

ax2.plot(mld_time, mld, "b", lw=1.5, label="MLD")
ax2.plot(prd_time, prd_depth, "lime", lw=2, label="Productive layer")

ax2.invert_yaxis()
ax2.set_ylabel("Depth (m)")
ax2.set_title("Chlorophyll-a")

plt.colorbar(sc2, ax=ax2, label="Chl (mg m⁻³)")
ax2.legend()

# =========================
# 9. PANEL 3 - BACKSCATTERING (PARTICLES / CARBON)
# =========================

ax3 = fig.add_subplot(313)

sc3 = ax3.scatter(
    xbbp, ybbp,
    c=zbbp,
    s=12,
    cmap="magma",
    vmin=np.nanpercentile(zbbp, 1),
    vmax=np.nanpercentile(zbbp, 90)
)

ax3.plot(mld_time, mld, "r", lw=2, label="MLD")

ax3.invert_yaxis()
ax3.set_ylabel("Depth (m)")
ax3.set_title("Particle backscattering (bbp700)")

plt.colorbar(sc3, ax=ax3, label="bbp700 (m⁻¹)")

# =========================
# 10. EXPORT FIGURE
# =========================

fig.tight_layout()

output_file = os.path.join(OUT_DIR, f"{FLOAT_ID}_bgc_timeseries.png")
fig.savefig(output_file, dpi=300)

plt.show()

# =========================
# FINAL COMMENTS (FOR UNDERSTANDING)
# =========================

"""
WHAT THIS SCRIPT DOES:

1. Loads preprocessed BGC-Argo float data (time-depth-variable format)

2. Builds a standardized 3-panel figure:
   - Physical structure (σθ)
   - Biological response (chlorophyll-a)
   - Particle dynamics (bbp700)

3. Overlays key oceanographic diagnostics:
   - Mixed Layer Depth (MLD)
   - Productive layer depth (photic / biological proxy)

4. Applies interpolation to σθ for smoother structural interpretation

5. Produces a publication-quality figure ready for:
   - GitHub portfolio
   - Scientific reporting
   - Environmental data analysis

WHY THIS IS IMPORTANT:

This visualization captures coupling between:
- physics (stratification)
- biology (phytoplankton)
- particles (carbon proxy)

→ fundamental in ocean biogeochemistry and carbon cycle studies
"""