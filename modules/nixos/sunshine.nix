{ config, ... }:
{
  # Sunshine host for Moonlight, so the laptop's niri desktop can be
  # driven remotely (e.g. from the Windows desktop over the LAN).
  #
  # niri doesn't implement the XDG remote-desktop/screencast portals well
  # enough for RustDesk/wayvnc, so we bypass Wayland entirely and capture
  # straight from KMS (needs CAP_SYS_ADMIN). Input injection goes through
  # uinput, which works regardless of compositor.

  # hardware.uinput.enable (set by services.sunshine below) only creates
  # the "uinput" group + udev rule -- it doesn't add anyone to it, so
  # without this Sunshine can capture video but has no permission to
  # write input events to /dev/uinput.
  users.groups.uinput.members = [ config.user.username ];

  services.sunshine = {
    enable = true;
    capSysAdmin = true;
    # Holds the NVIDIA GPU open (and captures continuously) while running,
    # so start it on demand: `systemctl --user start sunshine`.
    autoStart = false;
    openFirewall = true;
    settings = {
      sunshine_name = "laptop";
      capture = "kms";
      # This laptop is Intel/NVIDIA PRIME offload, so the display scanout
      # (what KMS capture reads) lives on the Intel iGPU, not the NVIDIA
      # card. Use its VAAPI/QuickSync encoder rather than trying to route
      # frames to the NVIDIA GPU for NVENC.
      encoder = "vaapi";
    };
  };
}
