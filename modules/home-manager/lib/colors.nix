{ lib }:

let
  # "rrggbb" -> [ r g b ] as integers in 0-255
  channels =
    hex:
    let
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
    map (i: toDecimal (builtins.substring i 2 hex)) [
      0
      2
      4
    ];

  round = x: builtins.floor (x + 0.5);
in
{
  hexToRgb = hex: lib.concatMapStringsSep "," toString (channels hex);

  # "rrggbb" -> { h = degrees; s = percent; l = percent; } rounded to integers
  hexToHsl =
    hex:
    let
      c = channels hex;
      r = builtins.elemAt c 0;
      g = builtins.elemAt c 1;
      b = builtins.elemAt c 2;
      max = lib.max r (lib.max g b);
      min = lib.min r (lib.min g b);
      d = (max - min) * 1.0;
      sum = max + min;
      h =
        if d == 0 then
          0.0
        else if max == r then
          60 * ((g - b) / d)
        else if max == g then
          60 * ((b - r) / d + 2)
        else
          60 * ((r - g) / d + 4);
      s = if d == 0 then 0.0 else d / (255 - (if sum > 255 then sum - 255 else 255 - sum));
    in
    {
      h = lib.mod (round h + 360) 360;
      s = round (s * 100);
      l = round (sum / 5.1);
    };
}
