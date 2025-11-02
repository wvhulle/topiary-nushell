# Topiary Home Manager Module

A [Home Manager](https://github.com/nix-community/home-manager) module for [Topiary](https://github.com/tweag/topiary) formatter with built-in Nushell support.

## Installation

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
  programs.topiary.enable = true;
}
```

## Configuration

### Basic Usage (Nushell only)
```nix
programs.topiary.enable = true;
```

### Multiple Languages
```nix
programs.topiary = {
  enable = true;
  languages.nickel = {
    extensions = [ "ncl" ];
    queryFile = ./nickel.scm;
    grammar.source.git = {
      git = "https://github.com/nickel-lang/tree-sitter-nickel";
      rev = "some-revision-hash";
    };
  };
};
```

### Disable Nushell
```nix
programs.topiary = {
  enable = true;
  nushell.enable = false;
};
```

## Usage

```bash
topiary format script.nu
cat script.nu | topiary format --language nu
```

The module automatically:
- Installs topiary package
- Fetches Nushell query file from this repository
- Generates `languages.ncl` configuration
- Sets `TOPIARY_CONFIG_FILE` and `TOPIARY_LANGUAGE_DIR` environment variables for VS Code compatibility