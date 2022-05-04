{ lib
, fetchurl
, vscode-utils
, unzip
, gnutar
, gzip
, patchelf
, makeWrapper
, icu
, stdenv
, openssl
, mono
, dotnet-runtime
}:

let
  rtDepsSrcsFromJson = lib.importJSON ./rt-deps-bin-srcs.json;

  rtDepsBinSrcs = builtins.mapAttrs
    (k: v:
      let
        kSplit = builtins.split "(__)" k;
        name = builtins.elemAt kSplit 0;
        system = builtins.elemAt kSplit 2;
      in
      {
        inherit name system;
        installPath = v.installPath;
        binaries = v.binaries;
        bin-src = fetchurl {
          urls = v.urls;
          inherit (v) sha256;
        };
      })
    rtDepsSrcsFromJson;

  rtDepBinSrcByName = bSrcName:
    rtDepsBinSrcs."${bSrcName}__${stdenv.targetPlatform.system}";

  omnisharp = rtDepBinSrcByName "OmniSharp";
  omnisharpNet60 = rtDepBinSrcByName "OmniSharp-net6_0";
  netcoredbg = rtDepBinSrcByName "Debugger";
  razor = rtDepBinSrcByName "Razor";
in
vscode-utils.buildVscodeOpenVsxExtension {
  openVsxRef = {
    publisher = "muhammad-sammy";
    name = "csharp";
    version = "1.24.4";
    sha256 = "0yayp2spv83hnp9jzzg6jm03dr4ddzfjv23j37gflqcl4m1371r6";
  };

  nativeBuildInputs = [
    unzip
    gnutar
    gzip
    patchelf
    makeWrapper
  ];

  buildInputs = [
    dotnet-runtime
  ];

  postPatch = ''
    declare ext_unique_id
    ext_unique_id="$(basename "$out" | head -c 32)"

    unzip_to() {
      declare src_zip="''${1?}"
      declare target_dir="''${2?}"
      mkdir -p "$target_dir"
      if unzip "$src_zip" -d "$target_dir"; then
        true
      elif [[ "1" -eq "$?" ]]; then
        1>&2 echo "WARNING: unzip('$?' -> skipped files)."
      else
        1>&2 echo "ERROR: unzip('$?')."
      fi
    }

    untgz_to() {
      declare src_tgz="''${1?}"
      declare target_dir="''${2?}"
      mkdir -p "$target_dir"
      if tar -xzf "$src_tgz" -C "$target_dir"; then
        true
      elif [[ "1" -eq "$?" ]]; then
        1>&2 echo "WARNING: tar('$?' -> skipped files)."
      else
        1>&2 echo "ERROR: tar('$?')."
      fi
    }

    patchelf_add_icu_as_needed() {
      declare elf="''${1?}"
      declare icu_major_v="${with builtins; head (splitVersion (parseDrvName icu.name).version)}"

      for icu_lib in icui18n icuuc icudata; do
        patchelf --add-needed "lib''${icu_lib}.so.$icu_major_v" "$elf"
      done
    }

    patchelf_common() {
      declare elf="''${1?}"

      patchelf_add_icu_as_needed "$elf"
      patchelf --add-needed "libssl.so" "$elf"
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        --set-rpath "${lib.makeLibraryPath [ stdenv.cc.cc openssl.out icu.out ]}:\$ORIGIN" \
        "$elf"
    }

    declare omnisharp_dir="$PWD/${omnisharp.installPath}"
    unzip_to "${omnisharp.bin-src}" "$omnisharp_dir"
    rm "$omnisharp_dir/bin/mono"
    ln -s -T "${mono}/bin/mono" "$omnisharp_dir/bin/mono"
    chmod a+x "$omnisharp_dir/run"
    touch "$omnisharp_dir/install.Lock"

    declare omnisharp_net60_dir="$PWD/${omnisharpNet60.installPath}"
    unzip_to "${omnisharpNet60.bin-src}" "$omnisharp_net60_dir"
    chmod a+x "$omnisharp_net60_dir/OmniSharp"
    patchelf_common "$omnisharp_net60_dir/OmniSharp"
    touch "$omnisharp_net60_dir/install.Lock"

    declare netcoredbg_dir="$PWD/${netcoredbg.installPath}"
    untgz_to "${netcoredbg.bin-src}" "$netcoredbg_dir"
    chmod a+x "$netcoredbg_dir/netcoredbg/netcoredbg"
    patchelf_common "$netcoredbg_dir/netcoredbg/netcoredbg"
    touch "$netcoredbg_dir/install.Lock"

    declare razor_dir="$PWD/${razor.installPath}"
    unzip_to "${razor.bin-src}" "$razor_dir"
    chmod a+x "$razor_dir/rzls"
    patchelf_common "$razor_dir/rzls"
    touch "$razor_dir/install.Lock"
  '';
}
