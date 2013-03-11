#!/usr/bin/env bats

@test "has deployment directory" {
  [ -d "/srv/funnies" ]
}

@test "does not have extra home directory" {
  [ ! -d "/home/funnies" ]
}

@test "installs rvm" {
  [ "type rvm | cat | head -1 | grep -q '^rvm is a function$'" ]
}
