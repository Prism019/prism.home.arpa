{ hmUsers, ... }:
{
  home-manager.users = { inherit (hmUsers) prism; };

  users.users.prism = {
    description = "Prism Daymon";
    isNormalUser = true;
    hashedPassword = "$6$VfBnY5c7i/V2Qi4M$ZUQ74IPZYMg.ryAk48vvqBF/gM5QgHWYd7I.breOhmYprgntravBuV47Czw7zInCCqnvdX/0Uzq8QJA7HtHzK0";
    extraGroups = [ "wheel" "wireshark" ];
  };
}
