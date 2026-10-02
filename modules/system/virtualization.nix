{ lib
, pkgs
, ...
}:

# Docker, libvirt, VMware, and VM passthrough specialisations.

{
  virtualisation = {
    docker = {
      enable = true;
      daemon.settings = {
        features = {
          containerd-snapshotter = false;
        };
        # 如果需要，也可以在此显式指定 storage-driver 为 overlay2
        # "storage-driver" = "overlay2";
      };
    };

    podman.enable = false;

    libvirtd = {
      enable = true;
      onBoot = "start";
      onShutdown = "shutdown";
      qemu = {
        runAsRoot = true;
        # ovmf submodule REMOVED: All OVMF images are now available by default in nixpkgs-unstable
        swtpm.enable = false; # TPM emulation
        vhostUserPackages = with pkgs; [ virtiofsd ];

        verbatimConfig = ''
          user = "qemu-libvirtd"
          group = "kvm"
          dynamic_ownership = 1
          remember_owner = 0
        '';
      };
      allowedBridges = [
        "enp7s0"
        "virbr0" # Default NAT bridge
        "br0" # Custom bridge if needed
      ];
    };

    # Kernel modules for better VM performance
    spiceUSBRedirection.enable = true;
  };

  specialisation.passthrough = {
    inheritParentConfig = true; # 继承父配置
    configuration =
      { config, pkgs, ... }:
      {
        imports = [ ../vfio-passthrough.nix ];
        vfio-passthrough = {
          enable = true;

          # 在正常启动的 Linux 下运行 `lspci -nn | grep -i nvidia` 获取
          gpuIds = "10de:2507,10de:228e";

          # 【关键】替换为你需要的大页数量。
          # 假设你给虚拟机分配 16G 内存，16*1024/2 = 8192，稍微大点写 8500
          hugepages2MCount = 16400;
        };
      };
  };

  specialisation.tmp-on-root = {
    configuration = {
      boot.tmp.useTmpfs = lib.mkForce false;
    };
  };

  specialisation.zen-kernel = {
    configuration = {
      boot.kernelPackages = lib.mkForce pkgs.linuxKernel.packages.linux_zen;
      virtualisation.vmware.host.enable = lib.mkForce true;
    };
  };
}
