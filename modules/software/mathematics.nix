# Mathematics Suite
#
# This suite provides advanced mathematics and computational tools.
#
# Packages are grouped and ordered as follows:
#   1. Algebra (computer algebra systems)
#   2. Geometry (interactive geometry tools)
#   3. Numerical Computation (numerical and scientific computing)
#
{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
  # --- Algebra ---
  maxima      # Computer algebra system
  wxmaxima    # GUI for Maxima

  # --- Geometry ---
  geogebra    # Interactive geometry, algebra, statistics

  # --- Numerical Computation ---
  octave      # Numerical computations (MATLAB-like)
];
}
