{
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    # Python interpreter and essential tools
    python3
    python3Packages.pip
    python3Packages.virtualenv

    # Basic development tools
    python3Packages.black
    python3Packages.pytest
    basedpyright

    # Package management
    poetry
  ];

  # Basic pip configuration
  home.file.".config/pip/pip.conf".text = ''
    [global]
    user = true

    [install]
    user = true
  '';

  # Simple shell aliases
  programs.bash.shellAliases = {
    py = "python3";
    venv = "python3 -m venv";
    activate = "source ./venv/bin/activate";
  };
}
