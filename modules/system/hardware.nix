{ config
, lib
, pkgs
, ...
}:

# Graphics and NVIDIA configuration.

{
  nixpkgs.config.allowUnfree = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver # 推荐，适用于 Gen 8+ 显卡 (LIBVA_DRIVER_NAME=iHD)
      # libva-intel-driver # 如果你的 CPU 非常老（Haswell 或更早），用这个 (LIBVA_DRIVER_NAME=i965)
      vpl-gpu-rt # Intel 视频处理库 (OneVPL)
      mangohud
    ];
    extraPackages32 = with pkgs; [
      # 32位应用（如 Steam 里的老游戏）需要的驱动
      intel-media-driver
      pkgsi686Linux.mangohud
    ];
  };

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;
    powerManagement.enable = true; # 休眠后唤醒不会花屏
    powerManagement.finegrained = false;
    open = true;
    nvidiaSettings = true;
    package =
      let
        gpioPatch =
          drv:
          drv.overrideAttrs (old: {
            postPatch = (if (old.postPatch or null) == null then "" else old.postPatch) + ''
              f=kernel-open/common/inc/nv-linux.h
              [ -e "$f" ] || f=common/inc/nv-linux.h
              substituteInPlace "$f" \
                --replace-fail "struct gpio_chip *chip = gpio_device_get_chip(gdev);" \
                               "struct gpio_chip *chip = gpio_device_get_chip((struct gpio_device *)gdev);"
            '';
          });
        base = config.boot.kernelPackages.nvidiaPackages.latest;
      in
      base.overrideAttrs (old: {
        postPatch = (if (old.postPatch or null) == null then "" else old.postPatch) + ''
          f=kernel-open/common/inc/nv-linux.h
          [ -e "$f" ] || f=common/inc/nv-linux.h
          substituteInPlace "$f" \
            --replace-fail "struct gpio_chip *chip = gpio_device_get_chip(gdev);" \
                           "struct gpio_chip *chip = gpio_device_get_chip((struct gpio_device *)gdev);"
        '';
        passthru = (old.passthru or { }) // {
          mod = gpioPatch base.mod;
          open = gpioPatch base.open;
        };
      }); # package = pkgs.linuxPackages_cachyos-lto.nvidiaPackages.stable;
  };
  services.xserver.videoDrivers = [ "nvidia" ];
}
