{
  pkgs ? import (fetchTarball https://nixos.org/channels/nixos-23.11/nixexprs.tar.xz) { 
    config = {
      android_sdk.accept_license = true; 
      allowUnfree = true;
    };
  }
}:

with pkgs;

let
  installerApk = fetchurl {
    url = "https://github.com/Aliucord/Aliucord/releases/download/1.2.0/Installer-release.apk";
    hash = "sha256-yqssswbL5+Nw70CpYYv5bwbODSugCVzE3RPvL7nsLCI=";
  };

  androidComposition = androidenv.composeAndroidPackages {
    cmdLineToolsVersion = "10.0";
    buildToolsVersions = [ "30.0.2" ];
    platformVersions = [ "30" ];
    includeSources = false;
    includeSystemImages = true;
    includeEmulator = true;
    systemImageTypes = [ "default" "google_apis_playstore" ];
    abiVersions = [ "x86_64" ];
    includeNDK = false;
    useGoogleAPIs = false;
    useGoogleTVAddOns = false;
  };

  androidEmulator = androidenv.emulateApp {
    name = "emulate-MyAndroidApp";
    platformVersion = "30";
    abiVersion = "x86_64";
    systemImageType = "google_apis_playstore";
    app = installerApk;  # Use the downloaded APK directly
    package = "?";
    activity = "?";
  };

in
mkShell {
  buildInputs = [
    androidComposition.androidsdk
    androidEmulator
    jdk11
  ];
  
  ANDROID_SDK_ROOT = "${androidComposition.androidsdk}/libexec/android-sdk";
  ANDROID_HOME = "${androidComposition.androidsdk}/libexec/android-sdk";
  JAVA_HOME = jdk11.home;

  shellHook = ''
    ln -s ${installerApk} ./aliucordInstaller.apk

    echo "Android SDK is available at: $ANDROID_SDK_ROOT"
    echo "Java Home is set to: $JAVA_HOME"
    echo "To start emulator: run-test-emulator"
  '';
}