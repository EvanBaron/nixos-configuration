{ lib, ... }:
{
  options.device = {
    type = lib.mkOption {
      type = lib.types.enum [ "desktop" "laptop" ];
      default = "desktop";
      description = "The type of device this configuration is for.";
    };
  };
}
