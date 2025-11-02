# Home Manager module for Topiary

A [Home Manager](https://github.com/nix-community/home-manager) module for [Topiary](https://github.com/tweag/topiary) formatter.

This module defines a home-manager option `topiary` can be used to auto-generate required config for specific languages in the home directory. It also sets some environment variables that may be required for some editor extensions.

## Usage

### Basic Nushell Support

```nix
{ pkgs, ... }:
let
  topiary-module = pkgs.fetchFromGitHub {
    owner = "blindfs";
    repo = "topiary-nushell";
    rev = "main";
    sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };
in
{
  imports = [ "${topiary-module}/default.nix" ];

  programs.topiary = {
    enable = true;
    languages.nu = {
      extensions = [ "nu" ];
      queryFile = "${topiary-module}/languages/nu.scm";
      grammar.source.git = {
        git = "https://github.com/nushell/tree-sitter-nu.git";
        rev = "18b7f951e0c511f854685dfcc9f6a34981101dd6";
      };
    };
  };
}
```

### Multiple Languages

```nix
programs.topiary = {
  enable = true;
  languages = {
    nu = {
      extensions = [ "nu" ];
      queryFile = "${topiary-module}/languages/nu.scm";
      grammar.source.git = {
        git = "https://github.com/nushell/tree-sitter-nu.git";
        rev = "18b7f951e0c511f854685dfcc9f6a34981101dd6";
      };
    };
    nickel = {
      extensions = [ "ncl" ];
      queryFile = ./nickel.scm;
      grammar.source.git = {
        git = "https://github.com/nickel-lang/tree-sitter-nickel";
        rev = "some-revision-hash";
      };
    };
  };
};
```

Automatically sets up topiary configuration and environment variables for VS Code compatibility.
