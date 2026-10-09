{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.opencode.desktopGpuUrl = lib.mkOption {
    type = lib.types.str;
    default = "http://localhost:8080/v1";
    description = "OpenAI-compatible endpoint of the desktop GPU server";
  };

  config.home.packages = with pkgs; [
    opencode
    typescript-language-server
  ];

  config.home.file.".config/opencode/opencode.json".text = builtins.toJSON {
    "\$schema" = "https://opencode.ai/config.json";
    provider = {
      desktop-gpu = {
        npm = "@ai-sdk/openai-compatible";
        name = "Desktop-GPU";
        options = {
          baseURL = config.opencode.desktopGpuUrl;
        };
        models = {
          "gemma-4-12b" = {
            name = "gemma-4-12b";
          };
        };
      };
    };
    model = "desktop-gpu/gemma-4-12b";
    lsp = true;
    plugin = [ "opencode-websearch" ];
  };
}
