#!/usr/bin/perl -w

use strict;
use warnings;
use Test::More;


BEGIN {
    use_ok('FindBin');
    use_ok('Numpaar::Config', qw(configLoad configSet configGet configEngineList configCheck));
}

push(@INC, $FindBin::Bin);

my $test_configfile = $FindBin::Bin . '/dot.numpaar.test';
my $test_configfile_error = $FindBin::Bin . '/dot.numpaar.error';

ok(-f $test_configfile, "does $test_configfile exists?");
ok(-f $test_configfile_error, "does $test_configfile_error exists?");

eval {
    &configLoad($test_configfile_error);
};
ok($@, "Error while loading $test_configfile_error");
note("Error string: $@");

eval {
    &configLoad($test_configfile);
};
ok(!$@, "is $test_configfile correct?");
if($@) {
    diag("configLoad: $@");
}

foreach my $key (qw(test1 test2 test3 test4 test5)) {
    my $val = uc($key);
    is(&configGet('extern_program', $key), $val, "extern_program $key");
}

my ($test3, $test4) = &configGet('extern_program', 'test3', 'test4');
is($test3, 'TEST3', 'test3');
is($test4, 'TEST4', 'test4');

my $test5 = &configGet('extern_program', 'test5', 'test4', 'test3', 'test2');
is($test5, 'TEST5', 'test5');

is(&configGet('directory', 'test6'), 'TEST6', 'test6');

my ($test7, $test8) = &configGet('file', 'TEST7', 'TEST8');
is($test7, 'test7', "test7");
is($test8, 'test8', 'test8');

eval {
    &configGet('file', 'test7', 'test8');
};
like($@, qr/test7/, '"test7" does not exists.');
diag("Error string: $@");

&configSet('file', "add1", "ADD1", "add2", "ADD2");
is(&configGet('file', 'add1'), 'ADD1', "addition to the config in script, 1");
is(&configGet('file', 'add2'), 'ADD2', "addition to the config in script, 2");

is(&configGet('misc', 'test9'), 'TEST9', "test9");
my @got_misc = &configGet('misc', 'test10', 'test11');
my @expected = qw(TEST10 TEST11);
ok(int(@got_misc) == int(@expected), 'get correct number of configs for misc');
for(my $i = 0 ; $i < @got_misc ; $i++) {
    is($got_misc[$i], $expected[$i], "test" . ($i + 10));
}

is($Numpaar::Engine::Test::Config::CONFIG1, 'FOO', "engine_config 1");
is($Numpaar::Engine::Test::Config::CONFIG2, undef, "engine_config 2");
is($Numpaar::Engine::Test::ConfigAnother::CONFIG1, 'hoge', "engine_config another 1");
is($Numpaar::Engine::Test::ConfigAnother::CONFIG2, 'hogehoge', "engine_config another 2");
is($Numpaar::Engine::Test::ConfigAnother::CONFIG3, 'UNDEF', "engine_config another 3");
is($Numpaar::Engine::Test::ConfigAbsolute::CONFIG1, 'QWERTY', 'engine_config absolute 1');
is($Numpaar::Engine::Test::ConfigAbsolute::CONFIG2, 'dvorak', 'engine_config absolute 2');

done_testing();
