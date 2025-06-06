{
  pkgs,
  lib,
  config,
  ...
}:
{
  home.packages = with pkgs; [ zsh ];

  programs.zsh = {
    enable = true;

    envExtra = ''
      [[ -v sourced_home_zshenv ]] && return || true
      sourced_home_zshenv=1

      zdotdir_zshenv=${config.xdg.configHome}/zsh/.zshenv
      [[ -f $zdotdir_zshenv ]] && source $zdotdir_zshenv || true
    '';

    initContent =
      let
        initFirst = lib.mkBefore ''
          [[ -v sourced_home_zsherc ]] && return || true
          sourced_home_zsherc=1
        '';
        initBeforeCompInit = lib.mkOrder 550 "";
        initContent = "";
        initLast = lib.mkAfter "";
      in
      lib.mkMerge [
        initFirst
        initBeforeCompInit
        initContent
        initLast
      ];

    # defaultKeymap = "emacs";

    # initExtraBeforeCompInit = ''
    #   ZSH_AUTOSUGGEST_MANUAL_REBIND=1
    #   ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd history completion)
    # '';

    # zprof.enable = true;
    enableCompletion = false;
    # autosuggestion = {
    #   enable = true;
    #   strategy = ["match_prev_cmd" "history" "completion"];
    # };

    # plugins = with pkgs; [
    #   {
    #     name = "fzf-git-sh";
    #     src = "${fzf-git-sh}/share/fzf-git-sh";
    #     file = "fzf-git.sh";
    #   }
    #   {
    #     name = "forgit";
    #     src = "${zsh-forgit}/share/zsh/zsh-forgit";
    #   }
    #   {
    #     name = "you-should-use";
    #     src = "${zsh-you-should-use}/share/zsh/plugins/you-should-use";
    #   }
    #   {
    #     # before zsh-autosuggestion and fast-syntax-highlighting
    #     name = "fzf-tab";
    #     src = "${zsh-fzf-tab}/share/fzf-tab";
    #   }
    #   {
    #     name = "fast-syntax-highlighting";
    #     src = "${zsh-fast-syntax-highlighting}/share/zsh/site-functions";
    #   }
    #   {
    #     # after syntax-highlighting
    #     name = "zsh-history-substring-search";
    #     src = "${zsh-history-substring-search}/share/zsh-history-substring-search";
    #     file = "zsh-history-substring-search.zsh";
    #   }
    #   {
    #     # should be last
    #     name = "zsh-autosuggestions";
    #     src = "${zsh-autosuggestions}/share/zsh-autosuggestions";
    #     file = "zsh-autosuggestions.zsh";
    #   }
    # ];

    history = {
      append = true;
      expireDuplicatesFirst = true;
      extended = true;
      ignoreAllDups = true;
      ignoreDups = true;
      ignoreSpace = true;
    };
    autocd = true;

    # initExtra = ''
    #   bindkey "^[[A" history-substring-search-up
    #   bindkey "^[[B" history-substring-search-down

    #   (( $+commands[brew] )) && eval "$(brew shellenv)" || true
    # '';
    # shellAliases = config.home.shellAliases;

    # syntaxHighlighting.enable = true;
    # historySubstringSearch.enable = true;
  };
}
