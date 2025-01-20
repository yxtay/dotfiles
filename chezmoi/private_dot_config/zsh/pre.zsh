#!/usr/bin/env zsh
# Ensure path arrays do not contain duplicates.
typeset -U fpath

for profile in ${(z)NIX_PROFILES}; do
  fpath=(${profile}/share/zsh/site-functions ${profile}/share/zsh/${ZSH_VERSION}/functions ${profile}/share/zsh/vendor-completions ${fpath})
done

fpath=(${^fpath}(FN))

# -----------------
# Zsh configuration
# -----------------

#
# Input/output
#

# Set editor default keymap to emacs (`-e`) or vi (`-v`)
# bindkey -e

# Prompt for spelling correction of commands.
# setopt CORRECT

# Customize spelling correction prompt.
# SPROMPT='zsh: correct %F{red}%R%f to %F{green}%r%f [nyae]? '

# --------------------
# Prezto configuration
# --------------------

#
# General
#

# Set case-sensitivity for completion, history lookup, etc.
# zstyle ':prezto:*:*' case-sensitive 'yes'

# Color output (auto set to 'no' on dumb terminals).
# zstyle ':prezto:*:*' color 'yes'

# Add additional directories to load prezto modules from
# zstyle ':prezto:load' pmodule-dirs $HOME/.zprezto-contrib

# Allow module overrides when pmodule-dirs causes module name collisions
# zstyle ':prezto:load' pmodule-allow-overrides 'yes'

# Set the Zsh modules to load (man zshmodules).
# zstyle ':prezto:load' zmodule 'attr' 'stat'

# Set the Zsh functions to load (man zshcontrib).
# zstyle ':prezto:load' zfunction 'zargs' 'zmv'

# Set the Prezto modules to load (browse modules).
# The order matters.
# zstyle ':prezto:load' pmodule \
#   'environment' \
#   'terminal' \
#   'editor' \
#   'history' \
#   'directory' \
#   'spectrum' \
#   'utility' \
#   'completion' \
#   'history-substring-search' \
#   'prompt'

#
# Autosuggestions
#

# Set the query found color.
# zstyle ':prezto:module:autosuggestions:color' found ''

#
# Completions
#

# Set the entries to ignore in static '/etc/hosts' for host completion.
# zstyle ':prezto:module:completion:*:hosts' etc-host-ignores \
#   '0.0.0.0' '127.0.0.1'

#
# Editor
#

# Set the characters that are considered to be part of a word.
# zstyle ':prezto:module:editor' wordchars '*?_-.[]~&;!#$%^(){}<>'

# Set the key mapping style to 'emacs' or 'vi'.
zstyle ':prezto:module:editor' key-bindings 'emacs'

# Auto convert .... to ../..
zstyle ':prezto:module:editor' dot-expansion 'yes'

# Allow the zsh prompt context to be shown.
zstyle ':prezto:module:editor' ps-context 'yes'

#
# Git
#

# Ignore submodules when they are 'dirty', 'untracked', 'all', or 'none'.
# zstyle ':prezto:module:git:status:ignore' submodules 'all'

#
# GNU Utility
#

# Set the command prefix on non-GNU systems.
# zstyle ':prezto:module:gnu-utility' prefix 'g'

#
# History
#

# Set the file to save the history in when an interactive shell exits.
# zstyle ':prezto:module:history' histfile "${ZDOTDIR:-$HOME}/.zsh_history"

# Set the maximum  number  of  events  stored  in  the  internal history list.
# zstyle ':prezto:module:history' histsize 10000

# Set the maximum number of history events to save in the history file.
# zstyle ':prezto:module:history' savehist 10000

#
# History Substring Search
#

# Set the query found color.
# zstyle ':prezto:module:history-substring-search:color' found ''

# Set the query not found color.
# zstyle ':prezto:module:history-substring-search:color' not-found ''

# Set the search globbing flags.
# zstyle ':prezto:module:history-substring-search' globbing-flags ''

# Enable search case-sensitivity.
# zstyle ':prezto:module:history-substring-search' case-sensitive 'yes'

# Enable search for fuzzy matches.
# zstyle ':prezto:module:history-substring-search' fuzzy 'yes'

# Enable search uniqueness.
# zstyle ':prezto:module:history-substring-search' unique 'yes'

# Enable prefixed search.
# zstyle ':prezto:module:history-substring-search' prefixed 'yes'

#
# macOS
#

# Set the keyword used by `mand` to open man pages in Dash.app
# zstyle ':prezto:module:osx:man' dash-keyword 'manpages'

#
# Pacman
#

# Set the Pacman frontend.
# zstyle ':prezto:module:pacman' frontend 'yaourt'

#
# Prompt
#

# Set the prompt theme to load.
# Setting it to 'random' loads a random theme.
# Auto set to 'off' on dumb terminals.
# zstyle ':prezto:module:prompt' theme 'sorin'

# Set the working directory prompt display length.
# By default, it is set to 'short'. Set it to 'long' (without '~' expansion)
# for longer or 'full' (with '~' expansion) for even longer prompt display.
# zstyle ':prezto:module:prompt' pwd-length 'short'

# Set the prompt to display the return code along with an indicator for non-zero
# return codes. This is not supported by all prompts.
# zstyle ':prezto:module:prompt' show-return-val 'yes'

#
# Python
#

# Auto switch the Python virtualenv on directory change.
# zstyle ':prezto:module:python:virtualenv' auto-switch 'yes'

# Automatically initialize virtualenvwrapper if pre-requisites are met.
# zstyle ':prezto:module:python:virtualenv' initialize 'yes'

#
# Ruby
#

# Auto switch the Ruby version on directory change.
# zstyle ':prezto:module:ruby:chruby' auto-switch 'yes'

#
# Screen
#

# Auto start a session when Zsh is launched in a local terminal.
# zstyle ':prezto:module:screen:auto-start' local 'yes'

# Auto start a session when Zsh is launched in a SSH connection.
# zstyle ':prezto:module:screen:auto-start' remote 'yes'

#
# SSH
#

# Set the SSH identities to load into the agent.
# zstyle ':prezto:module:ssh:load' identities 'id_rsa' 'id_rsa2' 'id_github'

#
# Syntax Highlighting
#

# Set syntax highlighters.
# By default, only the main highlighter is enabled.
# zstyle ':prezto:module:syntax-highlighting' highlighters \
#   'main' \
#   'brackets' \
#   'pattern' \
#   'line' \
#   'cursor' \
#   'root'
#
# Set syntax highlighting styles.
# zstyle ':prezto:module:syntax-highlighting' styles \
#   'builtin' 'bg=blue' \
#   'command' 'bg=blue' \
#   'function' 'bg=blue'
#
# Set syntax pattern styles.
# zstyle ':prezto:module:syntax-highlighting' pattern \
#   'rm*-rf*' 'fg=white,bold,bg=red'

#
# Terminal
#

# Auto set the tab and window titles.
zstyle ':prezto:module:terminal' auto-title 'yes'

# Set the window title format.
zstyle ':prezto:module:terminal:window-title' format '%n@%m: %s'

# Set the tab title format.
zstyle ':prezto:module:terminal:tab-title' format '%m: %s'

# Set the terminal multiplexer title format.
zstyle ':prezto:module:terminal:multiplexer-title' format '%s'

#
# Tmux
#

# Auto start a session when Zsh is launched in a local terminal.
# zstyle ':prezto:module:tmux:auto-start' local 'yes'

# Auto start a session when Zsh is launched in a SSH connection.
# zstyle ':prezto:module:tmux:auto-start' remote 'yes'

# Integrate with iTerm2.
# zstyle ':prezto:module:tmux:iterm' integrate 'yes'

# Set the default session name:
# zstyle ':prezto:module:tmux:session' name 'YOUR DEFAULT SESSION NAME'

#
# Utility
#

# Enabled safe options. This aliases cp, ln, mv and rm so that they prompt
# before deleting or overwriting files. Set to 'no' to disable this safer
# behavior.
# zstyle ':prezto:module:utility' safe-ops 'yes'

# -----------------
# Zim configuration
# -----------------

# Use degit instead of git as the default tool to install and update modules.
zstyle ':zim:zmodule' use 'degit'

# --------------------
# Module configuration
# --------------------

#
# git
#

# Set a custom prefix for the generated aliases. The default prefix is 'G'.
# zstyle ':zim:git' aliases-prefix 'g'

#
# input
#

# Append `../` to your input for each `.` you type after an initial `..`
# zstyle ':zim:input' double-dot-expand yes

#
# termtitle
#

# Set a custom terminal title format using prompt expansion escape sequences.
# See http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html#Simple-Prompt-Escapes
# If none is provided, the default '%n@%m: %~' is used.
# zstyle ':zim:termtitle' format '%1~'

#
# zsh-syntax-highlighting
#

# Set what highlighters will be used.
# See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters.md
# ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern regex cursor root line)

# Customize the main highlighter styles.
# See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/main.md#how-to-tweak-it
# typeset -A ZSH_HIGHLIGHT_STYLES
# ZSH_HIGHLIGHT_STYLES[comment]='fg=242'

#
# zsh-history-substring-search
#

# HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=magenta,fg=white,bold'
# HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='bg=red,fg=white,bold'

# Its default value causes this script to perform a case-insensitive search.
# HISTORY_SUBSTRING_SEARCH_GLOBBING_FLAGS='i'

# If set to a non-empty value, causes this script to perform a fuzzy search by words,
# matching in given order e.g. ab c will match *ab*c*
HISTORY_SUBSTRING_SEARCH_FUZZY=1

# If set to a non-empty value, your query will be matched against the start of each history entry.
# HISTORY_SUBSTRING_SEARCH_PREFIXED=1

# If set to a non-empty value, then only unique search results are presented.
HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1

#
# zsh-autosuggestions
#

# Disable automatic widget re-binding on each precmd. This can be set when
# zsh-users/zsh-autosuggestions is the last module in your ~/.zimrc.
ZSH_AUTOSUGGEST_MANUAL_REBIND=1

# Customize the style that the suggestions are shown with.
# See https://github.com/zsh-users/zsh-autosuggestions/blob/master/README.md#suggestion-highlight-style
# ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=242'

ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd history completion)
