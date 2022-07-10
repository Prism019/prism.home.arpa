{ suites, lib, config, pkgs, ... }:
{
  imports = suites.base;

  boot = {
    initrd = {
      availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
      supportedFilesystems = [ "btrfs" "vfat" ];
      luks.devices."nixos".device = "/dev/disk/by-uuid/2f4b8396-1c98-4b2d-a5a2-9cc0952b50d5";
    };
    supportedFilesystems = [ "ntfs" ];
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelModules = [ "kvm-amd" ];
  };

  environment = {
    gnome.excludePackages = (with pkgs; [
      gnome-photos
      gnome-console
      gnome-tour
    ]) ++ (with pkgs.gnome; [
      cheese
      gnome-calendar
      gnome-music
      geary
      epiphany
      gnome-maps
      seahorse
      gnome-weather
      simple-scan
      gnome-software
      gnome-contacts
      totem
    ]);
    systemPackages = (with pkgs; [
      firefox-wayland
      element-desktop
      gimp
      kicad
      libreoffice-fresh
      mpv
      mpd
      gmpc
      vscodium
      discord
      virt-manager
      openhmd-git
    ]) ++ (with pkgs.gnomeExtensions; [
      appindicator
      just-perfection
      dash-to-panel
    ]);
  };

  hardware = {
    opengl.driSupport32Bit = true;
    pulseaudio.enable = false;
  };

  time.timeZone = "America/Los_Angeles";

  services = {
    avahi = {
      enable = true;
      openFirewall = true;
    };
    flatpak.enable = true;
    gnome = {
      tracker.enable = false;
      gnome-remote-desktop.enable = true;
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      config.pipewire = {
        "context.properties" = {
          "default.clock.min-quantum" = 128;
          "default.clock.quantum" = 128;
          "default.clock.max-quantum" = 512;
        };
      };
    };
    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };
    openssh = {
      enable = true;
      openFirewall = true;
      forwardX11 = true;
    };
    udev = {
      packages = with pkgs; [
        xr-hardware
        gnome.gnome-settings-daemon
      ];
    };
  };

  location.provider = "geoclue2";

  security.rtkit.enable = true;

  networking = {
    useDHCP = false;
    interfaces.enp34s0.useDHCP = true;
    hostName = "ristaccia";
    domain = "prism.home.arpa";
    firewall = {
      allowPing = true;
      allowedUDPPorts = [ 3389 ];
      allowedTCPPorts = [ 3389 ];
    };
  };

  programs = {
    wireshark.enable = true;
    gnome-terminal.enable = true;
  };
  virtualisation = {
    libvirtd.enable = true;
    spiceUSBRedirection.enable = true;
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/35ca9b44-6aba-4c1e-9a16-b05823e46fed";
      fsType = "btrfs";
      options = [ "defaults" "subvol=@root" ];
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/EFEB-37AD";
      fsType = "vfat";
    };
    "/home" = {
      device = "/dev/disk/by-uuid/35ca9b44-6aba-4c1e-9a16-b05823e46fed";
      fsType = "btrfs";
      options = [ "defaults" "subvol=@home" ];
    };
    "/nix" = {
      device = "/dev/disk/by-uuid/35ca9b44-6aba-4c1e-9a16-b05823e46fed";
      fsType = "btrfs";
      options = [ "defaults" "subvol=@nix" ];
    };
  };

  swapDevices = [
    {
      device = "/dev/disk/by-uuid/9f5c439b-642d-44a9-be96-096ecfd33822";
    }
  ];

  xdg.portal.enable = true;
}
