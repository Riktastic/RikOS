# Data Science, Engineering, and Database Suite
#
# This suite provides tools for data science, engineering, and database administration.
# Supports both desktop (GUI + CLI) and server (CLI only) modes.
#
# Packages are grouped and ordered as follows:
#   1. Data Science IDEs (RStudio, JupyterLab)
#   2. Data Science Tools (plotting, data formats, version control)
#   3. Python Data Science Environment (all major Python data science libraries)
#   4. Database Administration (universal and specific DB tools)
#
{ config, pkgs, lib, ... }:

let
  cfg = config.device;
in
{
  environment.systemPackages = with pkgs; [
    # --- Core Data Science Tools (Both modes) ---
    # Python Data Science Environment
    (python3.withPackages (ps: with ps; [
      jupyter              # Jupyter notebook (Python)
      pandas               # Data analysis library
      polars               # Fast DataFrame library
      numpy                # Numerical computing
      scipy                # Scientific computing
      matplotlib           # Plotting library
      seaborn              # Statistical data visualization
      plotly               # Interactive plotting
      scikit-learn         # Machine learning
      statsmodels          # Statistical modeling
      tensorflow           # Deep learning
      torch                # PyTorch deep learning
      xgboost              # Gradient boosting
      lightgbm             # LightGBM boosting
    ]))

    # CLI Database Tools
    sqlite                # SQLite command line tool
    postgresql            # PostgreSQL command line tools
    mysql80               # MySQL command line tools
    redis                 # Redis command line tools
    octave                # MATLAB alternative (CLI)
    gnuplot               # Plotting utility (CLI)

    # --- Desktop-specific tools ---
  ] ++ lib.optionals (cfg.mode == "desktop") [
    # Database Administration (GUI)
    dbeaver-bin           # Universal database tool (GUI)
    sqlitebrowser         # SQLite database browser (GUI)
    pgadmin4              # PostgreSQL admin tool (GUI)
  ];
}
