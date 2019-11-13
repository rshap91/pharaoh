#!/usr/bin/env bats
source pharaoh.sh

@test "many_args correctly reading args" {
    ARGS="foo bar baz --name rick"
    EXPECTED=( foo bar baz )
    many_args $ARGS
    str_vals=${VALS[@]}
    str_expected=${EXPECTED[@]}
    [ "$str_vals" = "$str_expected" ]
}

@test "script_args builds arg string" {
    ARGS="foo bar baz name=rick"
    EXPECTED="foo bar baz --name rick"
    script_args $ARGS
    [ "$ARGSTRING" = "$EXPECTED" ]
}
