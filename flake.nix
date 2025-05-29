{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config = {
          android_sdk.accept_license = true;
          allowUnfree = true;
        };
      };
      buildToolsVersion = "34.0.0";
      androidComposition = pkgs.androidenv.composeAndroidPackages {
        buildToolsVersions = [buildToolsVersion];
        platformVersions = ["34"];
        abiVersions = ["armeabi-v7a" "arm64-v8a"];
      };
      androidSdk = androidComposition.androidsdk;
      # androidSdk = pkgs.androidenv.androidPkgs_9_0.androidsdk;
    in {
      devShell = with pkgs;
        mkShell {
          ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
          ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
          JAVA_HOME = jdk21.home;
          FLUTTER_ROOT = flutter;
          GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${androidSdk}/libexec/android-sdk/build-tools/${buildToolsVersion}/aapt2";
          buildInputs = [
            androidSdk
            flutter
            jdk21

            # pkg-config
            # gtk3.dev
            # libsecret.dev
            # sysprof.dev
          ];
          # CMAKE_PREFIX_PATH = "${pkgs.lib.makeLibraryPath [libsecret.dev gtk3.dev]}";
        };
    });
}
