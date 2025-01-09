{
  pkgs,
  lib,
  self,
  ...
}: {
  home.packages = [pkgs.chezmoi];

  home.activation.chezmoi = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [[ ! -v DRY_RUN ]]; then
      [[ $(${pkgs.chezmoi}/bin/chezmoi state data) == "null" ]] && args="--init --source ${self}"
      ${pkgs.chezmoi}/bin/chezmoi apply ''${args:-}
    fi
  '';
}
