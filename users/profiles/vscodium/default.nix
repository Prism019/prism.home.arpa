{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    extensions = with pkgs.vscode-extensions; [
      matklad.rust-analyzer
      arrterian.nix-env-selector
      jnoortheen.nix-ide
      mhutchie.git-graph
      muhammad-sammy.csharp
    ];
  };
}
