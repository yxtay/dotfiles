{ inputs, ... }:
{
  imports = [ inputs.git-hooks-nix.flakeModule ];

  perSystem = _: {
    pre-commit.settings.hooks = {
      actionlint.enable = true;
      biome.enable = true;
      deadnix.enable = true;
      editorconfig-checker.enable = true;
      hadolint.enable = true;
      markdownlint.enable = true;
      nixfmt-rfc-style.enable = true;
      statix.enable = true;
      taplo.enable = true;
      trufflehog.enable = true;
      yamlfmt.enable = true;

      shellcheck = {
        enable = true;
        excludes = [ "(\.|_)zsh(env|rc)?$" ];
      };
      shfmt = {
        enable = true;
        excludes = [ "(\.|_)zsh(env|rc)?$" ];
      };
    };
  };
}
