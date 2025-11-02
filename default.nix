{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.topiary;

  # Language configuration type
  languageType = types.submodule {
    options = {
      extensions = mkOption {
        type = types.listOf types.str;
        description = "File extensions for this language";
        example = [ "nu" ];
      };


      queryFile = mkOption {
        type = types.path;
        description = "Path to the tree-sitter query file (.scm)";
      };

      grammar = mkOption {
        type = types.attrs;
        description = "Grammar configuration for the language";
        example = {
          source.git = {
            git = "https://github.com/nushell/tree-sitter-nu.git";
            rev = "18b7f951e0c511f854685dfcc9f6a34981101dd6";
          };
        };
      };
    };
  };

  # Create a merged languages.ncl file
  mergedLanguagesConfig = pkgs.writeText "languages.ncl" ''
    {
      languages = {
        ${concatStringsSep "\n    " (mapAttrsToList (name: lang: ''
          ${name} = {
            extensions = ${builtins.toJSON lang.extensions};
            grammar.source.git = ${builtins.toJSON lang.grammar.source.git};
          };
        '') cfg.languages)}
      };
    }
  '';

  # Create the topiary configuration package
  topiaryConfig = pkgs.stdenvNoCC.mkDerivation {
    name = "topiary-config";
    dontUnpack = true;
    dontBuild = true;
    dontConfigure = true;

    installPhase = ''
      mkdir -p $out/share/topiary
      cp ${mergedLanguagesConfig} $out/share/topiary/languages.ncl

      mkdir -p $out/share/topiary/languages
      ${concatStringsSep "\n      " (mapAttrsToList (name: lang: ''
        cp ${lang.queryFile} $out/share/topiary/languages/${name}.scm
      '') cfg.languages)}
    '';
  };
in
{
  options.programs.topiary = {
    enable = mkEnableOption "topiary formatter";

    package = mkOption {
      type = types.package;
      default = pkgs.topiary;
      defaultText = literalExpression "pkgs.topiary";
      description = "The topiary package to use.";
    };

    languages = mkOption {
      type = types.attrsOf languageType;
      default = {};
      description = "Language configurations for topiary";
      example = literalExpression ''
        {
          nu = {
            extensions = [ "nu" ];
            configFile = ./languages.ncl;
            queryFile = ./languages/nu.scm;
            grammar.source.git = {
              git = "https://github.com/nushell/tree-sitter-nu.git";
              rev = "18b7f951e0c511f854685dfcc9f6a34981101dd6";
            };
          };
        }
      '';
    };

    nushell = {
      enable = mkEnableOption "nushell language support for topiary" // { default = true; };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    # Base topiary configuration
    {
      home.packages = [ cfg.package ];

      # Set up topiary configuration if any languages are defined
      xdg.configFile = mkIf (cfg.languages != {}) {
        "topiary/languages.ncl".source = "${topiaryConfig}/share/topiary/languages.ncl";
      } // (mapAttrs' (name: lang: nameValuePair
        "topiary/languages/${name}.scm"
        { source = "${topiaryConfig}/share/topiary/languages/${name}.scm"; }
      ) cfg.languages);

      # Set environment variables for VS Code and other desktop applications
      home.sessionVariables = {
        TOPIARY_CONFIG_FILE = "${config.xdg.configHome}/topiary/languages.ncl";
        TOPIARY_LANGUAGE_DIR = "${config.xdg.configHome}/topiary/languages";
      };
    }

    # Nushell-specific configuration
    (mkIf cfg.nushell.enable {
      programs.topiary.languages.nu = {
        extensions = [ "nu" ];
        queryFile = "${pkgs.fetchFromGitHub {
          owner = "blindfs";
          repo = "topiary-nushell";
          rev = "fd78be3b7e4a8bd7d63b7ae3e5c7e4bb5c8b8b6f"; # commit with original queries
          sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
        }}/languages/nu.scm";
        grammar.source.git = {
          git = "https://github.com/nushell/tree-sitter-nu.git";
          rev = "18b7f951e0c511f854685dfcc9f6a34981101dd6";
        };
      };
    })
  ]);
}