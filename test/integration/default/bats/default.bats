#!/usr/bin/env bats

@test "has deployment directory" {
  [ -d "/srv/funnies" ]
}

@test "does not have extra home directory" {
  [ ! -d "/home/funnies" ]
}
