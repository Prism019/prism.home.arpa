final: prev:
let
  fetchVsixFromOpenVsx = openVsxRef: prev.fetchurl (
    ({ publisher, name, version, sha256 ? "" }:
      {
        url = "https://open-vsx.org/api/${publisher}/${name}/${version}/file/${publisher}.${name}-${version}.vsix";
        sha256 = sha256;
        name = "${publisher}-${name}.zip";
      }) openVsxRef
  );

  buildVscodeOpenVsxExtension =
    a@{ name ? ""
    , src ? null
    , vsix ? null
    , openVsxRef
    , ...
    }: assert "" == name; assert null == src;
    prev.vscode-utils.buildVscodeExtension ((removeAttrs a [ "openVsxRef" "vsix" ]) // {
      name = "${openVsxRef.publisher}-${openVsxRef.name}-${openVsxRef.version}";
      src =
        if (vsix != null)
        then vsix
        else fetchVsixFromOpenVsx openVsxRef;
      vscodeExtUniqueId = "${openVsxRef.publisher}.${openVsxRef.name}";
    });

  vscode-utils = prev.lib.recursiveUpdate
    prev.vscode-utils
    {
      inherit fetchVsixFromOpenVsx buildVscodeOpenVsxExtension;
    }
  ;
in
{
  inherit vscode-utils;
  vscode-extensions = prev.lib.recursiveUpdate
    prev.vscode-extensions
    {
      muhammad-sammy.csharp = prev.callPackage ../pkgs/vscode/muhammad-sammy-csharp { };
    }
  ;
}
