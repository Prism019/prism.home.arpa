{ lib, stdenv
, fetchFromGitHub
, cmake
, libusb
}:
stdenv.mkDerivation rec {
  pname = "libfreenect";
  version = "0.6.4";

  src = fetchFromGitHub {
    owner = "OpenKinect";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-G9Pa3EOUrHyfx+FyZZLsKTSk7MBpHtpJm7m/uSAoKTo=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ libusb ];

  postInstall = ''
    # install udev rules
    mkdir -p $out/etc/udev/rules.d/
    cp $src/platform/linux/udev/51-kinect.rules $out/etc/udev/rules.d/
  '';
}