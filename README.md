# Happ for NixOS

A NixOS flake for packaging and running [Happ](https://github.com/Happ-proxy/happ-desktop).

**Features**
- Declarative NixOS module
- Native Wayland support
- systemd-managed daemon
- TUN support
- Desktop integration

**Installation**

Add the flake input:

```nix
inputs.happ-nix = {
    url = "github:d1shburn/happ-nix";
    inputs.nixpkgs.follows = "nixpkgs";
};
```

Import and enable the module:

```nix
{
    imports = [
        inputs.happ-nix.nixosModules.default
    ];

    nixpkgs.config.allowUnfreePredicate = pkg:
        builtins.elem (pkgs.lib.getName pkg) [
            "happ"
        ];

    services.happ.enable = true;
}
```

Apply the configuration:

```bash
sudo nixos-rebuild switch --flake /etc/nixos#nixos
```

**Build**

```bash
NIXPKGS_ALLOW_UNFREE=1 nix build --impure github:d1shburn/happ-nix
```

**License**

The packaging and NixOS module code are licensed under the MIT License.

Happ and its bundled components are third-party software and remain subject to their respective licenses and terms.
