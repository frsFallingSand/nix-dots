{
  pkgs,
  ...
}:

# Power, portals, and application services.

{
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

  services.mihomo.tunMode = true;

  programs.clash-verge = {
    enable = true;
    tunMode = true;
    serviceMode = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.nh = {
    enable = true;
    clean = {
      enable = false;
      dates = "weekly";
      extraArgs = "--keep 20 --keep-since 42d";
    };
    # 设置 NH_OS_FLAKE 变量
    flake = "/home/admin/workspace/nix-config";
  };

  zramSwap = {
    enable = true;
    priority = 100;
    algorithm = "lz4";
    memoryPercent = 50;
  };

  # Hyprland already adds xdg-desktop-portal-hyprland through
  # programs.hyprland. Keep GTK as the generic fallback and KDE available
  # for the explicit FileChooser preference in the user's portals.conf.
  # Do not select xdg-desktop-portal-wlr: it is not the correct backend
  # for Hyprland and may fail to initialize screencasting.
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.kdePackages.xdg-desktop-portal-kde
    ];
    config.common.default = [
      "hyprland"
      "gtk"
    ];
    config.hyprland.default = [
      "hyprland"
      "gtk"
    ];
  };

  programs.virt-manager.enable = true;
  programs.dconf.enable = true;

  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;
    package = (
      pkgs.obs-studio.override {
        cudaSupport = true;
      }
    );
    plugins = with pkgs.obs-studio-plugins; [
      input-overlay
      looking-glass-obs
      obs-media-controls
      obs-pipewire-audio-capture
      obs-backgroundremoval
      obs-vaapi
      obs-gstreamer
      obs-vkcapture
      waveform
      wlrobs
    ];
  };

  services.kanata = {
    enable = true;
    keyboards = {
      internalKeyboard = {
        # 空列表会让 Kanata 自动扫描并拦截本机所有接入的键盘
        devices = [ ];

        # 必须开启：让未被 defsrc 声明的其余所有按键正常直通
        extraDefCfg = "process-unmapped-keys yes";

        config = ''
          (defsrc
            esc
            grv  1    2    3    4    5    6    7    8    9    0    -    =
            tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
            caps a    s    d    f    g    h    j    k    l    ;    '    ret
            z    x    c    v    b    n    m    ,    .    /
            menu
          )

          (defalias
            ;; 原 Esc 键：短按 Esc，长按激活 media (多媒体/亮度)
            med-esc (tap-hold-press 200 200 esc (layer-toggle media))

            ;; CapsLock 键：短按 Esc，长按激活 nav (Vim导航/F区)
            nav-cap (tap-hold-press 200 200 esc (layer-toggle nav))

            ;; 原 Menu 键：短按 Menu，长按激活 numpad (右手照片定制小键盘)
            num-menu (tap-hold-press 200 200 menu (layer-toggle numpad))

            ;; 滚轮动作定义：(mwheel-方向 间隔毫秒 刻度步长)
            ;; 120 是 Linux 内核标准的鼠标滚轮“一格”刻度
            ;; 50 代表长按时每 50ms 滚一格（每秒 20 格，速度顺滑适中）
            mwu (mwheel-up 50 120)
            mwd (mwheel-down 50 120)
          )

          ;; ================= 1. 基础默认层 (Base Layer) =================
          (deflayer base
            @med-esc
            grv      1        2    3    4    5    6    7    8    9    0    -    =
            tab      q    w    e    r    t    y    u    i    o    p    [    ]    \
            @nav-cap a    s    d    f    g    h    j    k    l    ;    '    ret
            z        x    c    v    b    n    m    ,    .    /
            @num-menu
          )

          ;; ================= 2. 导航与 F 功能区 (Nav Layer) =================
          (deflayer nav
            mmid
            mrgt     f1       f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  f12
            mlft     _    C-right _ _    _    _    pgup pgdn _    _    _    _    _
            _        home @mwu    del  _    _    left down up   right _    _    _
            _        @mwd    caps _    _    _    end  C-left _    _
            _
          )

          ;; ================= 3. 多媒体与屏幕亮度 (Media Layer) =================
          (deflayer media
            _
            _        _        _    _    _    _    _    _    _    _    _    _    _
            _        _    _    _    _    _    _    prev next pp   _    _    _    _
            _        _    mute voldwn volu _  _    brdown brup _  _    _    _
            _        _    _    _    _    _    _    _    _    _
            _
          )

          ;; ================= 4. 右手定制小键盘 (NumPad Layer) =================
          (deflayer numpad
            _
            _        _        _    _    _    _    _    _    _    _    7    8    9
            _        _    _    _    _    _    _    _    _    4    5    6    kp-  kp+
            _        _    _    _    _    _    _    _    1    2    3    kp*  kprt
            _        _    _    _    _    _    _    0    kp.  kp/
            _
          )
        '';
      };
    };
  };
}
