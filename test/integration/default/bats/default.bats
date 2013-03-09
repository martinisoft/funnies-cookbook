#!/usr/bin/env bats

@test "should have deployment directory" {
  [ -d "/srv/funnies" ]
}
