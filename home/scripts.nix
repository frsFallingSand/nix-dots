# 用户脚本打包与 systemd 用户服务设置。
# 主要用于用户自定义脚本。
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
    niri-run = mkScript {
      name = "niri-run";
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
