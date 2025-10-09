{ pkgs, ... }:

{
  home.packages = with pkgs; [
    steam-run
    geany
    xterm
    qt5.qtbase
    gcc
  ];

  home.file.".config/geany/filedefs/filetypes.common".text = ''
    [build-menu]
    ASM_LB=_Assemble
    ASM_CM=steam-run /home/ebaron/68000/a68k "%f" -o"%e.hex" -s -n -rmal
    ASM_WD=%d
  '';
}
