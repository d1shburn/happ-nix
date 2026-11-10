{ config, lib, pkgs, ... }:

let
    cfg = config.services.happ;
in
{
    options.services.happ = {
        enable = lib.mkEnableOption "Happ proxy client";

        package = lib.mkOption {
            type = lib.types.package;
            default = pkgs.callPackage ./package.nix {};
            description = "Happ package to use.";
        };
    };

    config = lib.mkIf cfg.enable {
        environment.systemPackages = [
            cfg.package
        ];

        boot.kernelModules = [
            "tun"
        ];

        systemd.services.happd = {
            description = "Happ Process Control Daemon";
            wantedBy = [ "multi-user.target" ];
            after = [ "network.target" ];

            serviceConfig = {
                Type = "simple";
                User = "root";
                Group = "root";
                ExecStart = "${cfg.package}/bin/happd";
                Restart = "always";
                RestartSec = "5s";
                TimeoutStopSec = "10s";
                KillMode = "mixed";
                KillSignal = "SIGTERM";
            };
        };
    };
}
