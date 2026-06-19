{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.vfio-passthrough;
in
{
  options.vfio-passthrough = {
    enable = mkEnableOption "Enable VFIO GPU Passthrough";

    # 显卡和音频的 Vendor:Device ID (例如 "10de:28e0,10de:22be")
    gpuIds = mkOption {
      type = types.str;
      example = "10de:28e0,10de:22be";
      description = "Comma-separated list of PCI IDs to bind to vfio-pci.";
    };

    # 内存大页数量 (2MB 大页)
    hugepages2MCount = mkOption {
      type = types.int;
      default = 0;
      description = "Number of 2MB hugepages to allocate.";
    };

    # 需要加入 libvirtd/kvm 组的用户名
    userName = mkOption {
      type = types.str;
      default = "fgsd"; # 替换为你的默认用户名，或者在外部覆盖
    };
  };

  config = mkIf cfg.enable {
    # 1. 开启 IOMMU 和 VFIO 内核参数
    boot.kernelParams = [
      "intel_iommu=on" # AMD CPU 改为 "amd_iommu=on"
      "iommu=pt"
      "kvm.ignore_msrs=1"
      "vfio-pci.ids=${cfg.gpuIds}"
    ];

    # 2. 在 initrd 阶段尽早加载 VFIO 模块
    boot.initrd.kernelModules = [
      "vfio_pci"
      "vfio_iommu_type1"
      "vfio"
    ];

    # 3. 黑名单宿主机的 NVIDIA 驱动，防止其抢占显卡 (冷切换核心)
    boot.blacklistedKernelModules = [
      "nvidia"
      "nouveau"
    ];

    # 4. 配置内存大页 (2MB)
    boot.kernel.sysctl = mkIf (cfg.hugepages2MCount > 0) {
      "vm.nr_hugepages" = cfg.hugepages2MCount;
    };

    # 5. 准备 LookingGlass 的标准共享内存 (shmem 方式，无需编译内核模块)
    systemd.tmpfiles.rules = [
      "f /dev/shm/looking-glass 0660 ${cfg.userName} kvm -"
    ];

    # 6. Scream config
    systemd.user.services.scream = {
      description = "Scream Audio Receiver for KVM";
      wantedBy = [ "default.target" ];
      after = [
        "pipewire.service"
        "pulseaudio.service"
      ]; # 确保在音频服务后启动

      serviceConfig = {
        # 运行 scream 客户端，-o pulse 表示输出到 pulseaudio/pipewire
        # 如果你的网卡不是默认路由，可能需要加 -m 指定网卡 IP，例如 -m 192.168.1.100
        ExecStart = "${pkgs.scream}/bin/scream -o pulse";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}
