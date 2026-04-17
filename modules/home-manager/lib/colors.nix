{ lib }:

{
  hexToRgb =
    hex:
    let
      r = builtins.substring 0 2 hex;
      g = builtins.substring 2 2 hex;
      b = builtins.substring 4 2 hex;

      toDecimal =
        h:
        let
          chars = lib.strings.stringToCharacters (lib.strings.toLower h);
          val =
            c:
            {
              "0" = 0;
              "1" = 1;
              "2" = 2;
              "3" = 3;
              "4" = 4;
              "5" = 5;
              "6" = 6;
              "7" = 7;
              "8" = 8;
              "9" = 9;
              "a" = 10;
              "b" = 11;
              "c" = 12;
              "d" = 13;
              "e" = 14;
              "f" = 15;
            }
            .${c};
        in
        (val (builtins.elemAt chars 0) * 16) + (val (builtins.elemAt chars 1));
    in
    "${toString (toDecimal r)},${toString (toDecimal g)},${toString (toDecimal b)}";
}
