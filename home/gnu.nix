{pkgs, ...}: {
  home.packages = with pkgs; [
    # https://github.com/shinokada/macgnu

    # GNU programs non-existing in macOS
    autoconf
    procps # watch
    tree
    wdiff
    wget

    # GNU programs whose BSD counterpart is installed in macOS
    binutils
    coreutils
    diffutils
    ed
    findutils
    gawk
    gnugrep
    gnused
    gnutar
    gzip
    indent
    screen
    which

    # GNU programs existing in macOS which are outdated
    bash
    bison
    emacs
    gnum4
    gnumake
    gnupatch
    less
    nano

    # BSD programs existing in macOS which are outdated
    flex
  ];
}
