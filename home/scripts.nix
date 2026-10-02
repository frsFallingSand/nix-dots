# 用户脚本打包与 systemd 用户服务设置。
# 主要用于 Noctalia 自定义按钮脚本。
# 新手提示：scripts/ 下是原始脚本，这里负责“打包 + 安装 + 启动”。

{ pkgs, lib, ... }:

let
  # 将脚本包装为可执行程序（并注入依赖）
  mkScript =
    { name
    , runtimeInputs ? [ ]
    ,
    }:
    pkgs.writeShellApplication {
      inherit name runtimeInputs;
      text = builtins.readFile ./scripts/${name};
    };

  # 统一定义所有用户脚本（可在这里增删）
  scripts = {
    lock-screen = mkScript {
      name = "lock-screen";
    };

    wallpaper-random = mkScript {
      name = "wallpaper-random";
      runtimeInputs = [
        pkgs.coreutils
        pkgs.findutils
      ];
    };

    niri-run = mkScript {
      name = "niri-run";
    };

    noctalia-flake-updates = mkScript {
      name = "noctalia-flake-updates";
      runtimeInputs = [
        pkgs.coreutils
        pkgs.gawk
        pkgs.git
        pkgs.jq
        pkgs.util-linux
      ];
    };

    noctalia-gpu-mode = mkScript {
      name = "noctalia-gpu-mode";
      runtimeInputs = [
        pkgs.coreutils
        pkgs.findutils
      ];
    };

    noctalia-net-speed = mkScript {
      name = "noctalia-net-speed";
      runtimeInputs = [
        pkgs.coreutils
        pkgs.gawk
        pkgs.gnugrep
        pkgs.iproute2
      ];
    };

    noctalia-net-status = mkScript {
      name = "noctalia-net-status";
      runtimeInputs = [
        pkgs.coreutils
        pkgs.gawk
        pkgs.iproute2
        pkgs.networkmanager
      ];
    };

    noctalia-bluetooth = mkScript {
      name = "noctalia-bluetooth";
      runtimeInputs = [
        pkgs.coreutils
        pkgs.gawk
        pkgs.bluez
      ];
    };

    noctalia-cpu = mkScript {
      name = "noctalia-cpu";
      runtimeInputs = [
        pkgs.coreutils
      ];
    };

    noctalia-memory = mkScript {
      name = "noctalia-memory";
      runtimeInputs = [
        pkgs.coreutils
        pkgs.gawk
      ];
    };

    noctalia-temperature = mkScript {
      name = "noctalia-temperature";
      runtimeInputs = [
        pkgs.coreutils
      ];
    };

    noctalia-disk = mkScript {
      name = "noctalia-disk";
      runtimeInputs = [
        pkgs.coreutils
        pkgs.gawk
      ];
    };

    noctalia-power = mkScript {
      name = "noctalia-power";
    };

    noctalia-proxy-status = mkScript {
      name = "noctalia-proxy-status";
      runtimeInputs = [ pkgs.systemd ];
    };
  };
in
{
  # Install every script in the user profile.
  home.packages = lib.mkAfter (builtins.attrValues scripts);

  # Expose every packaged script under ~/.local/bin without maintaining a
  # second hand-written list.
  home.file = lib.mapAttrs'
    (
      name: script:
        lib.nameValuePair ".local/bin/${name}" {
          source = "${script}/bin/${name}";
        }
    )
    scripts;
}
