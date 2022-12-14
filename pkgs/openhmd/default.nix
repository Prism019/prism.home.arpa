{ lib, stdenv
, fetchFromGitHub
, cmake
, pkg-config
, hidapi
, libusb
, opencv
, SDL2
, libGL
, glew
, withExamples ? true
}:

let examplesOnOff = if withExamples then "ON" else "OFF"; in

stdenv.mkDerivation rec {
  pname = "openhmd";
  version = "git+dfac0203";

  src = fetchFromGitHub {
    owner = "thaytan";
    repo = "OpenHMD";
    rev = "rift-correspondence-search";
    hash = "sha256-IL0G+UDoo3NDs5UioEI4hIakcqcElcgC5VYXXf0Pak8=";
  };

  nativeBuildInputs = [ cmake pkg-config ];

  buildInputs = [
    hidapi
    libusb
    opencv
  ] ++ lib.optionals withExamples [
    SDL2
    glew
    libGL
  ];

  cmakeFlags = [
    "-DBUILD_BOTH_STATIC_SHARED_LIBS=ON"
    "-DOPENHMD_EXAMPLE_SIMPLE=${examplesOnOff}"
    "-DOPENHMD_EXAMPLE_SDL=${examplesOnOff}"
    "-DOpenGL_GL_PREFERENCE=GLVND"
  ];

  postInstall = lib.optionalString withExamples ''
    mkdir -p $out/bin
    install -D examples/simple/simple $out/bin/openhmd-example-simple
    install -D examples/opengl/openglexample $out/bin/openhmd-example-opengl
  '';

  meta = with lib; {
    homepage = "http://www.openhmd.net"; # https does not work
    description = "Library API and drivers immersive technology";
    longDescription = ''
      OpenHMD is a very simple FLOSS C library and a set of drivers
      for interfacing with Virtual Reality (VR) Headsets aka
      Head-mounted Displays (HMDs), controllers and trackers like
      Oculus Rift, HTC Vive, Windows Mixed Reality, and etc.
    '';
    license = licenses.boost;
    maintainers = with maintainers; [ oxij ];
    platforms = platforms.unix;
  };
}