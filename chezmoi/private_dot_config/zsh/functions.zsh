# functions
profzsh() {
  zsh -il -c exit
  time ZPROF=1 zsh -il -c exit
}
