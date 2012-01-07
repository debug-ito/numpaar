package Numpaar::Config;
use base 'Exporter';
use strict;
use warnings;
use FindBin;

our @EXPORT_OK = qw(configLoad configSet configGet configEngineList configCheck);

my %numpaar_config = (
    engine_list => [],
    extern_program => {},
    directory => {},
    );

sub configLoad {
    my (@filenames) = @_;
    foreach my $filename (@filenames) {
        if(-r $filename) {
            require ($filename);
            print STDERR ("Config file $filename is loaded.\n");
        }
    }
}

sub engine( @ ) {
    push(@{$numpaar_config{engine_list}}, [@_]);
}

sub extern_program( % ) {
    my (%kvpairs) = @_;
    &configSet('extern_program', %kvpairs);
}

sub directory( % ) {
    my (%kvpairs) = @_;
    &configSet('directory', %kvpairs);
}

sub configEngineList {
    return $numpaar_config{engine_list};
}

sub configGet {
    my ($category, @keys) = @_;
    my @vals = map {&configElement($category, $_)} @keys;
    return wantarray ? @vals : $vals[0];
}

sub configSet {
    my ($category, %kvpairs) = @_;
    while(my ($key, $val) = each(%kvpairs)) {
        &configElement($category, $key, $val);
    }
}

sub configElement {
    my ($category, $key, $val) = @_;
    if(defined($val)) {
        $numpaar_config{$category}{$key} = $val;
    }
    if(!defined($numpaar_config{$category}{$key})) {
        die "CONFIG ERROR: Config value for '$key' must be specified by $category directive.";
    }
    return $numpaar_config{$category}{$key};
}

sub configCheck {
    my ($category, @required_keys) = @_;
    my $err = '';
    foreach my $required_key (@required_keys) {
        eval {
            &configElement($category, $required_key);
        };
        if($@) {
            $err .= "$@\n";
        }
    }
    if($err) {
        die $err;
    }
}

1;
