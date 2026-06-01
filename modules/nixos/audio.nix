{ pkgs, ... }:

{
  # Enable sound with pipewire.
  security.rtkit.enable = true;
  security.pam.loginLimits = [
    {
      domain = "@audio";
      item = "memlock";
      type = "-";
      value = "unlimited";
    }
    {
      domain = "@audio";
      item = "rtprio";
      type = "-";
      value = "99";
    }
    {
      domain = "@audio";
      item = "nofile";
      type = "soft";
      value = "99999";
    }
    {
      domain = "@audio";
      item = "nofile";
      type = "hard";
      value = "99999";
    }
  ];
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;

    wireplumber.extraConfig."10-bluez" = {
      "monitor.bluez.properties" = {
        "bluez5.enable-sbc-xq" = true;
        "bluez5.enable-msbc" = true;
        "bluez5.enable-hw-volume" = true;
        "bluez5.roles" = [
          "hsp_hs"
          "hsp_ag"
          "hfp_hf"
          "hfp_ag"
          "a2dp_sink"
          "a2dp_source"
        ];
      };
    };

    # High-quality audio configuration
    extraConfig.pipewire."92-low-latency" = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.quantum" = 256;
        "default.clock.min-quantum" = 256;
        "default.clock.max-quantum" = 2048;
        "default.clock.allowed-rates" = [
          44100
          48000
          88200
          96000
          176400
          192000
        ];
      };
    };

    extraConfig.pipewire."99-input-mixer" = {
      "context.modules" = [
        {
          name = "libpipewire-module-loopback";
          args = {
            "node.description" = "Mixed Input";
            "capture.props" = {
              "node.name" = "mixed_input_sink";
              "media.class" = "Audio/Sink";
              "audio.position" = [ "FL" "FR" ];
              "node.passive" = true;
              "node.latency" = "256/48000";
            };
            "playback.props" = {
              "node.name" = "mixed_input_source";
              "media.class" = "Audio/Source";
              "audio.position" = [ "FL" "FR" ];
              "node.passive" = true;
            };
          };
        }
      ];
    };
  };

  boot.kernelParams = [ "usbcore.autosuspend=-1" ];

  # Prevent PowerTop/System from suspending the Scarlett Solo
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="1235", ATTR{idProduct}=="8211", ATTR{power/control}="on"
  '';

  # Enable the Scarlett Mixer interface for 3rd Gen Solo
  boot.extraModprobeConfig = ''
    options snd_usb_audio vid=0x1235 pid=0x8211 device_setup=1
  '';

  # Audio related system packages
  environment.systemPackages = with pkgs; [
    pulsemixer
    pavucontrol
    qpwgraph
    alsa-utils
  ];

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.blueman.enable = true;

}
