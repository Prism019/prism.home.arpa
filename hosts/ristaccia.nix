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
    kernelModules = [ "kvm-amd" "nct6775" ];
    extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
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
    opengl = {
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        rocm-opencl-icd
        rocm-opencl-runtime
      ];
    };
    pulseaudio.enable = false;
    fancontrol = {
      enable = true;
      config = ''
        # Configuration file generated by pwmconfig, changes will be lost
        INTERVAL=10
        FCTEMPS=/sys/devices/platform/nct6775.2592/hwmon/hwmon[[:print:]]*/pwm3=/sys/devices/platform/nct6775.2592/hwmon/hwmon[[:print:]]*/temp2_input /sys/devices/platform/nct6775.2592/hwmon/hwmon[[:print:]]*/pwm4=/sys/devices/platform/nct6775.2592/hwmon/hwmon[[:print:]]*/temp2_input /sys/devices/platform/nct6775.2592/hwmon/hwmon[[:print:]]*/pwm5=/sys/devices/platform/nct6775.2592/hwmon/hwmon[[:print:]]*/temp2_input /sys/devices/platform/nct6775.2592/hwmon/hwmon[[:print:]]*/pwm6=/sys/devices/platform/nct6775.2592/hwmon/hwmon[[:print:]]*/temp2_input /sys/devices/platform/nct6775.2592/hwmon/hwmon[[:print:]]*/pwm2=/sys/devices/platform/nct6775.2592/hwmon/hwmon[[:print:]]*/temp7_input
        FCFANS=/sys/devices/platform/nct6775.2592/hwmon/hwmon[[:print:]]*/pwm3=/sys/devices/platform/nct6775.2592/hwmon/hwmon[[:print:]]*/fan3_input /sys/devices/platform/nct6775.2592/hwmon/hwmon[[:print:]]*/pwm4=/sys/devices/platform/nct6775.2592/hwmon/hwmon[[:print:]]*/fan4_input /sys/devices/platform/nct6775.2592/hwmon/hwmon[[:print:]]*/pwm5=/sys/devices/platform/nct6775.2592/hwmon/hwmon[[:print:]]*/fan5_input /sys/devices/platform/nct6775.2592/hwmon/hwmon[[:print:]]*/pwm6=/sys/devices/platform/nct6775.2592/hwmon/hwmon[[:print:]]*/fan6_input /sys/devices/platform/nct6775.2592/hwmon/hwmon[[:print:]]*/pwm2=/sys/devices/platform/nct6775.2592/hwmon/hwmon[[:print:]]*/fan2_input
        MINTEMP=/sys/devices/platform/nct6775.2592/hwmon/hwmon[[:print:]]*/pwm3=40 /sys/devices/platform/nct6775.2592/hwmon/hwmon[[:print:]]*/pwm4=40 /sys/devices/platform/nct6775.2592/hwmon/hwmon[[:print:]]*/pwm5=40 /sys/devices/platform/nct6775.2592/hwmon/hwmon[[:print:]]*/pwm6=40 /sys/devices/platform/nct6775.2592/hwmon/hwmon[[:print:]]*/pwm2=40
        MAXTEMP=/sys/devices/platform/nct6775.2592/hwmon/hwmon[[:print:]]*/pwm3=65 /sys/devices/platform/nct6775.2592/hwmon/hwmon[[:print:]]*/pwm4=65 /sys/devices/platform/nct6775.2592/hwmon/hwmon[[:print:]]*/pwm5=65 /sys/devices/platform/nct6775.2592/hwmon/hwmon[[:print:]]*/pwm6=65 /sys/devices/platform/nct6775.2592/hwmon/hwmon[[:print:]]*/pwm2=85
        MINSTART=/sys/devices/platform/nct6775.2592/hwmon/hwmon[[:print:]]*/pwm3=75 /sys/devices/platform/nct6775.2592/hwmon/hwmon[[:print:]]*/pwm4=75 /sys/devices/platform/nct6775.2592/hwmon/hwmon[[:print:]]*/pwm5=75 /sys/devices/platform/nct6775.2592/hwmon/hwmon[[:print:]]*/pwm6=75 /sys/devices/platform/nct6775.2592/hwmon/hwmon[[:print:]]*/pwm2=150
        MINSTOP=/sys/devices/platform/nct6775.2592/hwmon/hwmon[[:print:]]*/pwm3=75 /sys/devices/platform/nct6775.2592/hwmon/hwmon[[:print:]]*/pwm4=75 /sys/devices/platform/nct6775.2592/hwmon/hwmon[[:print:]]*/pwm5=75 /sys/devices/platform/nct6775.2592/hwmon/hwmon[[:print:]]*/pwm6=75 /sys/devices/platform/nct6775.2592/hwmon/hwmon[[:print:]]*/pwm2=0
      '';
    };
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

  powerManagement.cpuFreqGovernor = "schedutil";

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
