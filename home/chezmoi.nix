{
  pkgs,
  lib,
  self,
  ...
}: {
  home.packages = [pkgs.chezmoi];

  home.activation.chezmoi = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [[ ! -v DRY_RUN ]]; then
      chezmoi=${pkgs.chezmoi}/bin/chezmoi
      source_path=$("$chezmoi" source-path)

      args="apply"
      [[ $source_path == */.local/share/chezmoi || $source_path == /nix/store/* ]] && args+=" --init --source ${self}"
      "$chezmoi" $args
    fi
  '';
}
