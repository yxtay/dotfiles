# functions
zsh_prof() {
  time zsh -il -c exit
  time ZPROF=1 zsh -il -c exit
}

zsh_sourcetrace() {
  time SOURCETRACE=1 zsh -il -c exit
}

zsh_xtrace() {
  time XTRACE=1 zsh -il -c exit
}
