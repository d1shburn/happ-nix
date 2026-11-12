{ lib
, stdenv
, fetchurl
, dpkg
, autoPatchelfHook
, makeWrapper
, coreutils
, iproute2
, iptables
, procps
, net-tools
, lsb-release
, libglvnd
, libX11
, wayland
, qt6
, fontconfig
, freetype
, libgpg-error
, e2fsprogs
, zlib
, openssl
}:

let
    version = "4.7.2-341";
    release = "4.7.2";

    runtimeDeps = [
        coreutils
        iproute2
        iptables
        procps
        net-tools
        lsb-release
    ];
in
stdenv.mkDerivation {
    pname = "happ";
    inherit version;

    src = fetchurl {
        url = "https://github.com/Happ-proxy/happ-desktop/releases/download/${release}/Happ.linux.x64.deb";
        hash = "sha256-hRQPLKB98Lol0C1IKkj2UjdQkxxH/CS6O+bclwK5KfQ=";
    };

    nativeBuildInputs = [
        dpkg
        autoPatchelfHook
        makeWrapper
    ];

    buildInputs = [
        stdenv.cc.cc.lib
        libglvnd
        libX11
        wayland
        qt6.qtwayland
        fontconfig
        freetype
        libgpg-error
        e2fsprogs
        zlib
        openssl
    ];

    dontUnpack = true;
    dontWrapQtApps = true;

    installPhase = ''
        runHook preInstall

        dpkg-deb -x "$src" unpacked

        mkdir -p "$out"

        cp -a unpacked/opt "$out/"
        cp -a unpacked/usr/share "$out/"

        chmod +x "$out"/opt/happ/bin/Happ
        chmod +x "$out"/opt/happ/bin/happ-tcping
        chmod +x "$out"/opt/happ/bin/happd
        chmod +x "$out"/opt/happ/bin/happ-diag
        chmod +x "$out"/opt/happ/bin/core/*
        chmod +x "$out"/opt/happ/bin/tun/*
        chmod +x "$out"/opt/happ/bin/tun2/*
        chmod +x "$out"/opt/happ/bin/antifilter/*

        mkdir -p "$out/bin"

        makeWrapper "$out/opt/happ/bin/Happ" "$out/bin/happ" \
            --prefix PATH : "${lib.makeBinPath runtimeDeps}" \
            --prefix LD_LIBRARY_PATH : "${lib.getLib openssl}/lib"

        makeWrapper "$out/opt/happ/bin/happd" "$out/bin/happd" \
            --prefix PATH : "${lib.makeBinPath runtimeDeps}" \
            --prefix LD_LIBRARY_PATH : "${lib.getLib openssl}/lib"

        substituteInPlace "$out/share/applications/Happ.desktop" \
            --replace-fail "/opt/happ/bin/Happ" "$out/bin/happ"

        ln -sf "${lib.getLib openssl}/lib/libssl.so.3" "$out/opt/happ/lib/libssl.so"
        ln -sf "${lib.getLib openssl}/lib/libcrypto.so.3" "$out/opt/happ/lib/libcrypto.so"
        ln -sf "${lib.getLib openssl}/lib/libssl.so.3" "$out/opt/happ/lib/libssl.so.3"
        ln -sf "${lib.getLib openssl}/lib/libcrypto.so.3" "$out/opt/happ/lib/libcrypto.so.3"

        runHook postInstall
    '';

    meta = {
        description = "Happ proxy desktop client";
        homepage = "https://github.com/Happ-proxy/happ-desktop";
        platforms = [ "x86_64-linux" ];
        mainProgram = "happ";
        license = lib.licenses.unfree;
    };
}
