{ ... }:

{
  # Drawing tablets (XP-Pen Deco Mini7 V2). Blacklists hid-uclogic/wacom so the
  # daemon owns the device; configure with otd-gui.
  hardware.opentabletdriver.enable = true;
}
