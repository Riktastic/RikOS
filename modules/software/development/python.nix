# Python Development Suite
#
# This suite provides tools for Python development, packaging, and code quality.
# Supports both desktop (GUI + CLI) and server (CLI only) modes.
#
# Packages are grouped and ordered as follows:
#   1. Python Interpreter & Environment (interpreter, pip, virtualenv)
#   2. Code Quality & Linting (formatter, linter, type checker)
#   3. Interactive & Notebook (IPython, Jupyter)
#
{ config, pkgs, lib, ... }:

let
  cfg = config.device;
in
{
  environment.systemPackages = with pkgs; [
    # --- Core Python Tools (Both modes) ---
    (python3.withPackages (ps: with ps; [
      pip        # Python package manager
      virtualenv # Virtual environments

      # --- Code Quality & Linting ---
      black      # Python code formatter
      flake8     # Python linter
      mypy       # Static type checker

      # --- Interactive & Notebook ---
      ipython    # Interactive Python shell
      jupyter    # Jupyter notebook

      # --- Database Drivers ---
      psycopg2-binary   # PostgreSQL driver
      mysqlclient       # MySQL driver
      pymongo           # MongoDB driver
      redis             # Redis client
      sqlalchemy        # Database agnostic client

      # --- Data Analysis, Utilities & Testing ---
      requests          # HTTP library
      pandas            # Data analysis library
      beautifulsoup4    # HTML/XML parser (bs4)
      pipenv            # Python dependency manager
      pytest            # Testing framework
      numpy             # Numerical computing
      scipy             # Scientific computing
    ]))

    uv # Really fast pip alternative
  ];
}

