#!perl -T

use Test::More 'no_plan';

use Class::Constant
    ALPHA            => "alpha",
    ALPHA_UNDERSCORE => "alpha with underscore",
    ALPHA_NUMBER_0   => "alpha with numbers";

is(ALPHA,            "alpha");
is(ALPHA_UNDERSCORE, "alpha with underscore");
is(ALPHA_NUMBER_0,   "alpha with numbers");
