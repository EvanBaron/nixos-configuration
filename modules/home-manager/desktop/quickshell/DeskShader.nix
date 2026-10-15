{ pkgs }:
let
  # Living wallpaper: with every input at 0 this is a plain texture lookup.
  #  bass   → heat-haze UV ripple, strongest toward the bottom of the screen
  #  treble → faint luminance shimmer
  #  glow   → accent light rising from the ground (the bass level, plus a bump per kick)
  #  tintMix → a light pull toward the album art's colour
  #  scrim  → darkening (more toward the bottom) so the poster and lyrics stay legible
  frag = pkgs.writeText "desk.frag" ''
    #version 440
    layout(location = 0) in vec2 qt_TexCoord0;
    layout(location = 0) out vec4 fragColor;
    layout(std140, binding = 0) uniform buf {
        mat4 qt_Matrix;
        float qt_Opacity;
        float time;
        float bass;
        float treble;
        float glow;
        float tintMix;
        float scrim;
        vec4 accent;
        vec4 tint;
        vec2 resolution;
    };
    layout(binding = 1) uniform sampler2D source;

    float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }

    void main() {
        vec2 uv = qt_TexCoord0;
        float low = smoothstep(0.2, 1.0, uv.y);          // haze rises off the ground
        float amp = 0.0045 * bass * (0.35 + 0.65 * low);
        uv.x += amp * sin(uv.y * 38.0 + time * 2.1);
        uv.y += amp * 0.6 * sin(uv.x * 27.0 - time * 1.7);
        vec4 c = texture(source, uv);

        float n = hash(floor(qt_TexCoord0 * resolution / 2.0) + floor(time * 24.0)) - 0.5;
        c.rgb += treble * 0.035 * n;

        c.rgb = mix(c.rgb, tint.rgb, tintMix * 0.06);
        c.rgb *= 1.0 - scrim * (0.22 + 0.3 * smoothstep(0.55, 1.0, qt_TexCoord0.y));

        // Light spilling up from below the horizon, screen-blended so it lifts the image
        // instead of painting over it; brightest at the bottom edge, gone by ~45% height.
        float ground = pow(smoothstep(0.55, 1.0, qt_TexCoord0.y), 1.6);
        float sway = 0.85 + 0.15 * sin(qt_TexCoord0.x * 5.0 + time * 0.7);
        c.rgb = 1.0 - (1.0 - c.rgb) * (1.0 - accent.rgb * ground * sway * glow * 0.35);
        fragColor = c * qt_Opacity;
    }
  '';
in
pkgs.runCommand "desk.frag.qsb" { nativeBuildInputs = [ pkgs.qt6.qtshadertools ]; } ''
  qsb --glsl "100 es,120,150" --hlsl 50 --msl 12 -o $out ${frag}
''
