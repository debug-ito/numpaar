#!/usr/bin/perl -w

use strict;
use warnings;
use Test::More tests => 27;

package Numpaar::Engine::Test::Config;
our $CONFIG1 = 'foo';
our $CONFIG2 = undef;

package Numpaar::Engine::Test::Config::Another;
our $CONFIG1 = 'hoge';
our $CONFIG2 = 'HOGEHOGE';
our $CONFIG3 = undef;


package main;

BEGIN {
    use_ok('FindBin');
    use_ok('Numpaar::Config', qw(configLoad configSet configGet configEngineList configCheck));
}

my $test_configfile = $FindBin::Bin . '/dot.numpaar.test';

ok(-f $test_configfile, "does $test_configfile exists?");

eval {
    &configLoad($test_configfile);
};
ok(!$@, "is $test_configfile correct?");

foreach my $key (qw(test1 test2 test3 test4 test5)) {
    my $val = uc($key);
    is(&configGet('extern_program', $key), $val, "extern_program $key");
}

my ($test3, $test4) = &configGet('extern_program', 'test3', 'test4');
is($test3, 'TEST3');
is($test4, 'TEST4');

my $test5 = &configGet('extern_program', 'test5', 'test4', 'test3', 'test2');
is($test5, 'TEST5');

is(&configGet('directory', 'test6'), 'TEST6', 'test6');

my ($test7, $test8) = &configGet('file', 'TEST7', 'TEST8');
is($test7, 'test7');
is($test8, 'test8');

eval {
    &configGet('file', 'test7', 'test8');
};
like($@, qr/test7/);
diag("Error string: $@");

&configSet('file', "add1", "ADD1", "add2", "ADD2");
is(&configGet('file', 'add1'), 'ADD1');
is(&configGet('file', 'add2'), 'ADD2');

is(&configGet('misc', 'test9'), 'TEST9');
my @got_misc = &configGet('misc', 'test10', 'test11');
my @expected = qw(TEST10 TEST11);
ok(int(@got_misc) == int(@expected), 'get correct number of configs for misc');
for(my $i = 0 ; $i < @got_misc ; $i++) {
    is($got_misc[$i], $expected[$i]);
}

is($Numpaar::Engine::Test::Config::CONFIG1, 'foo');
is($Numpaar::Engine::Test::Config::CONFIG2, undef);
is($Numpaar::Engine::Test::Config::Another::CONFIG1, 'hoge');
is($Numpaar::Engine::Test::Config::Another::CONFIG2, 'hogehoge');
is($Numpaar::Engine::Test::Config::Another::CONFIG3, 'UNDEF');




