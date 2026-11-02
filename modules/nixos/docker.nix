# Docker containerization platform configuration
{ ... }:

{
  virtualisation.docker = {
    enable = true;
    # Socket-activated: the rootful daemon only starts when something uses it.
    enableOnBoot = false;
    extraOptions = "--dns 8.8.8.8 --dns 1.1.1.1";

    rootless = {
      enable = true;
      setSocketVariable = true;
      # CDI device injection (the NVIDIA GPU, from hardware.nvidia-container-toolkit on NVIDIA hosts).
      daemon.settings.features.cdi = true;
    };
  };

  environment.variables = {
    DOCKER_HOST = "unix://$XDG_RUNTIME_DIR/docker.sock";
  };
}
