# functions
zsh_prof() {
  for i in $(seq 1 10); do time zsh -il -c exit; done
  time ZPROF=1 zsh -il -c exit
}

zsh_sourcetrace() {
  time SOURCETRACE=1 zsh -il -c exit
}

zsh_xtrace() {
  time XTRACE=1 zsh -il -c exit
}
