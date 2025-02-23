{
  pkgs,
  inShell ? false
}:
pkgs.python3Packages.buildPythonPackage {
  pname = "pymilter";
  version = "1.0.5";
  src = if inShell then null else ./.;
  propagatedBuildInputs = [ pkgs.libmilter ];
  
  nativeBuildInputs = pkgs.lib.optionals pkgs.stdenv.isDarwin [ pkgs.unzip pkgs.patchelf pkgs.zip];
  postInstall = pkgs.lib.optionalString pkgs.stdenv.isDarwin ''
    find $out -name "*.so" -exec install_name_tool -change libmilter.dylib ${pkgs.libmilter}/lib/libmilter.dylib {} \;
  '';

  doCheck = false;  # to avoid the missing `makemap` executable of Sendmail
  pythonImportsCheck = [ "Milter" ];
  meta = {
    homepage = https://github.com/sdgathman/pymilter;
    description = ''
      A python extension module to enable python scripts to attach to Sendmail's libmilter API, enabling filtering of messages as they arrive. Since it's a script, you can do anything you want to the message - screen out viruses, collect statistics, add or modify headers, etc. You can, at any point, tell Sendmail to reject, discard, or accept the message.

      Additional python modules provide for navigating and modifying MIME parts, and sending DSNs or doing CBVs.'';
    license = pkgs.lib.licenses.gpl2Only;
  };
}
