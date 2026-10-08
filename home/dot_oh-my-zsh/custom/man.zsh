fman() {
  print -rl -- ${(k)commands} | fzf | xargs man
}
