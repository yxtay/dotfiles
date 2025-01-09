{
  pkgs,
  lib,
  self,
  ...
}: {
  home.packages = [pkgs.chezmoi];

  home.activation.chezmoi = lib.hm.dag.entryAfter ["writeBoundary"] ''
    [[ ! -v DRY_RUN ]] && ${pkgs.chezmoi}/bin/chezmoi apply
  '';
}
