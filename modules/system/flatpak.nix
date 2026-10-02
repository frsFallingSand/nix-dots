{ pkgs
, ...
}:

# Flatpak and domestic mirror configuration.

{
  services.flatpak.enable = true;

  # GNOME Software 配置（备用）
  # environment.systemPackages = with pkgs; [
  #   gnome-software
  # ];

  # 国内 Flatpak 镜像源配置
  systemd.services.configure-flatpak-repo = {
    description = "Configure Flatpak Domestic Mirrors";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      # === 选项 A: 上海交通大学 (SJTU) - 推荐 ===
      flatpak remote-add --if-not-exists flathub https://mirror.sjtu.edu.cn/flathub/flathub.flatpakrepo
      flatpak remote-modify flathub --url=https://mirror.sjtu.edu.cn/flathub/

      # === 选项 B: 中国科学技术大学 (USTC) - 备用 ===
      # flatpak remote-add --if-not-exists flathub https://mirrors.ustc.edu.cn/flathub/flathub.flatpakrepo
      # flatpak remote-modify flathub --url=https://mirrors.ustc.edu.cn/flathub/

      # 强制刷新元数据，确保 GNOME Software 搜索结果及时更新
      flatpak update --appstream
    '';
  };
}
