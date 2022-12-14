{ self, config, lib, pkgs, ... }:
let inherit (lib) fileContents;
in
{
  # Sets nrdxp.cachix.org binary cache which just speeds up some builds
  imports = [ ../cachix ];

  # For rage encryption, all hosts need a ssh key pair
  services.openssh = {
    enable = true;
    openFirewall = lib.mkDefault false;
  };

  environment = {

    # Selection of sysadmin tools that can come in handy
    systemPackages = with pkgs; [
      binutils
      coreutils
      curl
      direnv
      dnsutils
      dosfstools
      fd
      git
      bottom
      gptfdisk
      iputils
      jq
      moreutils
      nix-index
      nmap
      ripgrep
      skim
      tealdeer
      usbutils
      utillinux
      whois
    ];

    # Starship is a fast and featureful shell prompt
    # starship.toml has sane defaults that can be changed there
    shellInit = ''
      export STARSHIP_CONFIG=${
        pkgs.writeText "starship.toml"
        (fileContents ./starship.toml)
      }
    '';

    shellAliases =
      let ifSudo = lib.mkIf config.security.sudo.enable;
      in
      {
        # quick cd
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";
        "....." = "cd ../../../..";

        # git
        g = "git";

        # grep
        grep = "rg";
        gi = "grep -i";

        # internet ip
        myip = "dig +short myip.opendns.com @208.67.222.222 2>&1";

        # nix
        n = "nix";
        np = "n profile";
        ni = "np install";
        nr = "np remove";
        ns = "n search --no-update-lock-file";
        nf = "n flake";
        nepl = "n repl '<nixpkgs>'";
        srch = "ns nixos";
        orch = "ns override";
        nrb = ifSudo "sudo nixos-rebuild";

        # fix nixos-option
        nixos-option = "nixos-option -I nixpkgs=${self}/lib/compat";

        # sudo
        s = ifSudo "sudo -E ";
        si = ifSudo "sudo -i";
        se = ifSudo "sudoedit";

        # top
        top = "btm";

        # systemd
        ctl = "systemctl";
        stl = ifSudo "s systemctl";
        utl = "systemctl --user";
        ut = "systemctl --user start";
        un = "systemctl --user stop";
        up = ifSudo "s systemctl start";
        dn = ifSudo "s systemctl stop";
        jtl = "journalctl";

      };
  };

  fonts = {
    fonts = with pkgs; [ noto-fonts noto-fonts-cjk-sans twemoji-color-font ];

    fontconfig.defaultFonts = {

      monospace = [ "Noto Sans Mono CJK JP" ];

      sansSerif = [ "Noto Sans CJK JP" ];

    };

    fontDir.enable = true;
  };

  nix = {
    settings = {
      # This is just a representation of the nix default
      system-features = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];

      # Prevents impurities in builds
      sandbox = true;

      # give root and @wheel special privileges with nix
      trusted-users = [ "root" "@wheel" ];

      # Improve nix store disk usage
      auto-optimise-store = true;
    };

    # Improve nix store disk usage
    gc.automatic = true;
    optimise.automatic = true;

    # Generally useful nix option defaults
    extraOptions = ''
      min-free = 536870912
      keep-outputs = true
      keep-derivations = true
      fallback = true
    '';

  };

  programs.bash = {
    # Enable starship
    promptInit = ''
      eval "$(${pkgs.starship}/bin/starship init bash)"
    '';
    # Enable direnv, a tool for managing shell environments
    interactiveShellInit = ''
      eval "$(${pkgs.direnv}/bin/direnv hook bash)"
    '';
  };

  # Service that makes Out of Memory Killer more effective
  services.earlyoom.enable = true;

}
