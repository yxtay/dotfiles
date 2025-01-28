_: {
  perSystem =
    { pkgs, ... }:
    {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          cowsay
          fastfetch
          figlet
          lolcat
        ];
      };
    };
}
