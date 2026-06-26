# Docker containerization platform configuration
{ ... }:

{
  virtualisation.docker = {
    enable = true;
    extraOptions = "--dns 8.8.8.8 --dns 1.1.1.1";

    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  environment.variables = {
    DOCKER_HOST = "unix://$XDG_RUNTIME_DIR/docker.sock";
  };
}
