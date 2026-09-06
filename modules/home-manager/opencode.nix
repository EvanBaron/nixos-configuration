{
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    opencode
    typescript-language-server
  ];

  home.file.".config/opencode/opencode.json".text = builtins.toJSON {
    "\$schema" = "https://opencode.ai/config.json";
    provider = {
      desktop-gpu = {
        npm = "@ai-sdk/openai-compatible";
        name = "Desktop-GPU";
        options = {
          baseURL = "http://localhost:8080/v1";
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
