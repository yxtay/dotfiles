{
  self,
  pkgs,
  lib,
  ...
}:
{
  home.packages = [ pkgs.chezmoi ];

  home.activation.chezmoi = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [[ -v DRY_RUN ]]; then exit; fi

    chezmoi=${pkgs.chezmoi}/bin/chezmoi
    source_path=$("$chezmoi" source-path)

    args=(apply --force)
    if [[ $source_path == */.local/share/chezmoi || $source_path == /nix/store/* ]]; then
      args+=(--init --source "${self}")
    fi
    "$chezmoi" "''${args[@]}"
  '';
}
