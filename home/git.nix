{
  config,
  pkgs,
  lib,
  gitignore,
  gitalias,
  user,
  ...
}: let
  gitignore_files = ["macOS" "Linux"];
in {
  # `programs.git` will generate the config file: ~/.config/git/config
  # to make git use this config file, `~/.gitconfig` should not exist!
  #
  #    https://git-scm.com/docs/git-config#Documentation/git-config.txt---global
  home.activation.removeExistingGitconfig = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
    rm -f ~/.gitconfig
  '';

  home.packages = with pkgs; [
    delta
    gh
    git
    git-extras
    git-lfs
  ];

  # xdg.configFile = {
  #   "git/ignore".text = lib.concatLines (
  #     map (file: builtins.readFile "${gitignore}/Global/${file}.gitignore") gitignore_files
  #   );

  #   "git/alias".source = "${gitalias}/gitalias.txt";
  # };

  programs = {
    # git = {
    #   enable = true;
    #   lfs.enable = true;

    #   userName = user.name;
    #   userEmail = user.email;

    #   includes = [
    #     {
    #       condition = "gitdir:~/work/";
    #       contents = {
    #         user.email = user.workEmail;
    #         url = {
    #           "git@github-work:" = {
    #             insteadOf = "git@github.com:";
    #             pushInsteadOf = "https://github.com/";
    #           };
    #         };
    #       };
    #     }
    #     {
    #       path = "${config.xdg.configHome}/git/alias";
    #     }
    #   ];

    #   extraConfig = {
    #     commit.verbose = true;
    #     diff = {
    #       algorithm = "histogram";
    #       colorMoved = "default";
    #       renames = "copies";
    #     };
    #     fetch = {
    #       prune = true;
    #       prunetags = true;
    #     };
    #     help.autocorrect = 20;
    #     init.defaultbranch = "main";
    #     log.date = "human";
    #     merge.conflictstyle = "zdiff3";
    #     pull.rebase = true;
    #     push = {
    #       autosetupremote = true;
    #       default = "current";
    #       followtags = true;
    #     };
    #     rebase = {
    #       autosquash = true;
    #       autostash = true;
    #     };
    #     rerere = {
    #       enabled = true;
    #       autoupdate = true;
    #     };

    #     # fsckobjects
    #     fetch.fsckobjects = true;
    #     receive.fsckobjects = true;
    #     transfer.fsckobjects = true;

    #     # submodule
    #     diff.submodule = "log";
    #     status.submodulesummary = true;
    #     submodule.recurse = true;

    #     url = {
    #       "git@github.com:${user.githubName}" = {
    #         pushInsteadOf = "https://github.com/${user.githubName}";
    #       };
    #     };
    #   };

    #   delta = {
    #     enable = true;
    #     options = {
    #       dark = true;
    #       line-numbers = true;
    #       hyperlinks = true;
    #       navigate = true;
    #       side-by-side = true;
    #       syntax-theme = "Dracula";
    #     };
    #   };
    # };

    gh = {
      enable = true;
      # gitCredentialHelper.enable = true;
      settings.git_protocol = "ssh";
    };
  };
}
