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

      cmd="$chezmoi apply"
      [[ $source_path == /Users/yuxuantay/.local/share/chezmoi || $source_path == /nix/store/* ]] && cmd+=" --init --source ${self}"
      $cmd
    fi
  '';
}
