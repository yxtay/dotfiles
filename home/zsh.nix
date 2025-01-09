{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    # fzf-git-sh
    nix-zsh-completions
    zsh
    zsh-autosuggestions
    zsh-completions
    zsh-fast-syntax-highlighting
    # zsh-forgit
    zsh-fzf-tab
    zsh-history-substring-search
    # zsh-you-should-use
  ];

  programs.zsh = {
    enable = true;

    envExtra = ''
      [[ -v sourced_home_zshenv ]] && return
      sourced_home_zshenv=1

      zdotdir_zshenv=${config.xdg.configHome}/zsh/.zshenv
      [[ -f $zdotdir_zshenv ]] && source $zdotdir_zshenv
    '';

    defaultKeymap = "emacs";

    initExtraBeforeCompInit = ''
      ZSH_AUTOSUGGEST_MANUAL_REBIND=1
      ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd history completion)
    '';

    # zprof.enable = true;
    enableCompletion = true;
    # autosuggestion = {
    #   enable = true;
    #   strategy = ["match_prev_cmd" "history" "completion"];
    # };

    plugins = with pkgs; [
      # {
      #   name = "fzf-git-sh";
      #   src = "${fzf-git-sh}/share/fzf-git-sh";
      #   file = "fzf-git.sh";
      # }
      # {
      #   name = "forgit";
      #   src = "${zsh-forgit}/share/zsh/zsh-forgit";
      # }
      # {
      #   name = "you-should-use";
      #   src = "${zsh-you-should-use}/share/zsh/plugins/you-should-use";
      # }
      {
        # before zsh-autosuggestion and fast-syntax-highlighting
        name = "fzf-tab";
        src = "${zsh-fzf-tab}/share/fzf-tab";
      }
      {
        name = "fast-syntax-highlighting";
        src = "${zsh-fast-syntax-highlighting}/share/zsh/site-functions";
      }
      {
        # after syntax-highting
        name = "zsh-history-substring-search";
        src = "${zsh-history-substring-search}/share/zsh-history-substring-search";
        file = "zsh-history-substring-search.zsh";
      }
      {
        # should be last
        name = "zsh-autosuggestions";
        src = "${zsh-autosuggestions}/share/zsh-autosuggestions";
        file = "zsh-autosuggestions.zsh";
      }
    ];

    history = {
      append = true;
      expireDuplicatesFirst = true;
      extended = true;
      ignoreAllDups = true;
    };
    autocd = true;

    initExtra = ''
      bindkey "^[[A" history-substring-search-up
      bindkey "^[[B" history-substring-search-down

      (( $+commands[brew] )) && eval "$(brew shellenv)"
    '';
    shellAliases = config.home.shellAliases;

    # syntaxHighlighting.enable = true;
    # historySubstringSearch.enable = true;
  };
}
