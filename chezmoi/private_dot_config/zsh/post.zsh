source_files=(
    ${ZIM_HOME}/modules/prezto/modules/terminal/init.zsh
    ${ZIM_HOME}/modules/prezto/modules/spectrum/init.zsh
    ${ZIM_HOME}/modules/prezto/modules/archive/init.zsh
    ${ZIM_HOME}/modules/prezto/modules/docker/init.zsh
    ${ZIM_HOME}/modules/prezto/modules/tmux/init.zsh
    ${ZIM_HOME}/modules/input/init.zsh
    ${ZIM_HOME}/modules/termtitle/init.zsh
    ${ZIM_HOME}/modules/utility/init.zsh
    ${ZIM_HOME}/modules/git/init.zsh
    ${ZIM_HOME}/modules/magic-enter/init.zsh
    ${ZIM_HOME}/modules/run-help/init.zsh
    ${ZIM_HOME}/modules/exa/init.zsh
    ${ZIM_HOME}/modules/k/init.zsh
    ${ZIM_HOME}/modules/homebrew/init.zsh
    ${ZIM_HOME}/modules/fzf-git.sh/fzf-git.sh
    ${ZIM_HOME}/modules/forgit/forgit.plugin.zsh
    ${ZIM_HOME}/modules/zsh-you-should-use/zsh-you-should-use.plugin.zsh
    ${ZIM_HOME}/modules/zsh-smartcache/zsh-smartcache.plugin.zsh
    ${ZIM_HOME}/modules/fzf-tab/fzf-tab.plugin.zsh
    ${ZIM_HOME}/modules/fzf-tab-sources/fzf-tab-sources.plugin.zsh
    ${ZIM_HOME}/modules/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
    ${ZIM_HOME}/modules/zsh-history-substring-search/zsh-history-substring-search.plugin.zsh
    ${ZIM_HOME}/modules/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh
    ${ZDOTDIR}/functions.zsh
    ${ZDOTDIR}/evals.zsh
)
for file in $source_files; do
    source $file;
done

# ------------------------------
# Post-init module configuration
# ------------------------------

#
# zsh-history-substring-search
#

zmodload -F zsh/terminfo +p:terminfo
# Bind ^[[A/^[[B manually so up/down works both before and after zle-line-init
for key ('^[[A' '^P' ${terminfo[kcuu1]}) bindkey ${key} history-substring-search-up
for key ('^[[B' '^N' ${terminfo[kcud1]}) bindkey ${key} history-substring-search-down
for key ('k') bindkey -M vicmd ${key} history-substring-search-up
for key ('j') bindkey -M vicmd ${key} history-substring-search-down
unset key
# End configuration added by Zim install
