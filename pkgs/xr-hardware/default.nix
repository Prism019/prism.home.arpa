{ lib
, stdenv
, python3 }:
stdenv.mkDerivation {
  pname = "xr-hardware";
  version = "1.0.0";

  src = fetchTarball {
    url = "https://gitlab.freedesktop.org/monado/utilities/xr-hardware/-/archive/1.0.0/xr-hardware-1.0.0.tar.gz";
    sha256 = "03arbkynva2paz92f7xjp6ckk1v9lbspxhj12i5x2zwzmj67d5xq";
  };

  nativeBuildInputs = [ python3 ];

  installPhase = ''
    mkdir -p $out/etc/udev/rules.d
    cp $src/70-xrhardware.rules $out/etc/udev/rules.d
  '';
}