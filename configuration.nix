# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:


{
  imports =
    [ # Include the results of the hardware scan.
        ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Jakarta";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.yja = {
    isNormalUser = true;
    description = "Yahya J. Aifit";
    extraGroups = [ "networkmanager" "wheel"];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;



  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
        wget
        brightnessctl
        alacritty
        wl-clipboard
        dmenu
        gvfs
        wofi
        ripgrep
        fzf
        tree
        bat
        swayr
        fd
        gcc #nvim treesitter
        ffmpeg
        whois

  # Archive wrapper (otomatis detect format)
  atool

  # Backend tools (diperlukan oleh atool)
  unzip
  zip
  gnutar
  gzip
  bzip2
  xz
  p7zip
  unar

        gotop
        swaylock
        librewolf

        # dev
        docker
        python3
        nodejs_20
        pnpm
        go
        ruby
        yarn
        bun

        lazygit
        git
        tmux

        # bluetooth
        blueman

        # file manager
        yazi # terminal file manager
        ueberzugpp # preview gambar di terminal

        # external monitor and display
        kanshi
        wlr-randr # untuk ngecek property monitor

        # cursor
        adwaita-icon-theme
        gnome-themes-extra

        # status bar
        i3status

        # sound
        pavucontrol

        # cctv
        mediamtx
        mpv

        # overlay display volume dan brightness dll
        swayosd

        # screenshoot
        grim   # screenshot
        slurp  # pilih area

        # neofetch alternative
        fastfetch

        # IDE
        neovim

        # youtube client
        freetube

        trash-cli  # command line trash utility

        feh # lightweight image preview

        lazydocker

        # youtube viewer terminal
        pipe-viewer

        # alternatif ssh untuk koneksi internat tidak stabil 
        mosh

  ];

environment.variables.ALSA_CONFIG_UCM2 =
  "${pkgs.alsa-ucm-conf}/share/alsa/ucm2";


fonts.packages = with pkgs; [
  nerd-fonts.jetbrains-mono

];

# untuk enable docker service
virtualisation.docker.enable = true;

# file picker, screenshot, clipboard?
xdg.portal = {
  enable = true;
  extraPortals = [pkgs.xdg-desktop-portal-wlr];
};

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

        services.xserver.enable = false;
        programs.sway = {
                enable = true;
                wrapperFeatures.gtk = true;
                extraPackages = with pkgs; [];
        };


# Install zsh
programs.zsh = {
  enable = true;
  enableBashCompletion = true;
  autosuggestions.enable = true;
  syntaxHighlighting.enable = true;

  ohMyZsh = {
    enable = true;
    plugins = [ "git" ];
    custom = "$HOME/.oh-my-zsh/custom/";
    theme = "powerlevel10k/powerlevel10k";
  };
};

hardware.bluetooth = {
  enable = true;
  powerOnBoot = true;
  settings = {
    General = {
      Experimental = true;
      FastConnectable = true;
      ControllerMode = "dual";  # atau sesuai kebutuhan hardware Anda
    };
    Policy = {
      AutoEnable = true;
    };
  };
};

  # Audio untuk Chromebook Gemini Lake
  boot.extraModprobeConfig = ''
    "snd-intel-dspcfg.dsp_driver=1"
  '';

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;

# gak tau kenapa, setelah upgrade ke 25.11 sound tidak bisa diadjust.
# coba fix pakai ini:
  wireplumber.extraConfig = {
    "fix-volume-control" = {
      "monitor.alsa.rules" = [{
        matches = [{
          "node.name" = "~alsa_output.*";
        }];
        actions = {
          update-props = {
            "channelmix.max-volume" = 1.0;
          };
        };
      }];
    };
   };

  };
  hardware.enableAllFirmware = true;
  services.pulseaudio.enable = false;



  # aktifkan zram swap / harus nonaktifkan swap dulu
  zramSwap.enable = true;
  zramSwap.memoryPercent = 80;  # gunakan 80% dari RAM untuk zram (sekitar 3.2 GB)
  zramSwap.algorithm = "zstd";  # kompresi efisien & cepat

# mount my additional partition at /personal
fileSystems."/personal" = {
  device = "UUID=1c8f7cab-8571-4c20-8b2a-44d1e813f557"; # This UUID is specific to my hardware
  fsType = "ext4";
  options = [ "defaults" "nofail" "x-systemd.device-timeout=10s" ];
};

nix.settings.experimental-features = [ "nix-command" "flakes" ];

# Enable nix-ld untuk binary non-Nix (seperti Mason LSP)
programs.nix-ld.enable = true;
programs.nix-ld.libraries = with pkgs; [
  stdenv.cc.cc.lib  # ini penting untuk C++ standard library
  zlib
  glibc
];

environment.variables.EDITOR = "nvim";


}

