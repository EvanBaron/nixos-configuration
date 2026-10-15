# NVIDIA configuration for monolith (desktop)
{ ... }:

{
  imports = [ ./default.nix ];

  # The NVIDIA card drives the displays here, so send everything to it. Not set
  # on the PRIME laptop: there they'd pull every app onto the dGPU and keep it
  # from runtime-suspending (use `nvidia-offload <app>` instead).
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    WLR_NO_HARDWARE_CURSORS = "1";
  };
}
