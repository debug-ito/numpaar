package Numpaar::Config;
use base 'Exporter';
use strict;
use warnings;
use Module::Load;

our @EXPORT_OK = qw(configLoad configSet configGet configEngineList configCheck);

my %numpaar_config = (
    engine_list => [],
    extern_program => {},
    directory => {},
    file => {},
    misc => {},
    );

sub configLoad {
    my (@filenames) = @_;
    foreach my $filename (@filenames) {
        if(-r $filename) {
            my $do_ret;
            eval {
                $do_ret = do ($filename);
            };
            die "ERROR: while loading config file $filename: $@" if $@;
            die "ERROR: while trying to read config file $filename: $!" if !defined($do_ret);
            print STDERR ("Config file $filename is loaded.\n");
        }
    }
}

sub engine( @ ) {
    push(@{$numpaar_config{engine_list}}, [@_]);
    return 1;
}

sub extern_program( % ) {
    my (%kvpairs) = @_;
    &configSet('extern_program', %kvpairs);
    return 1;
}

sub directory( % ) {
    my (%kvpairs) = @_;
    &configSet('directory', %kvpairs);
    return 1;
}

sub file ( % ) {
    my (%kvpairs) = @_;
    &configSet('file', %kvpairs);
    return 1;
}

sub misc ( % ) {
    my (%kvpairs) = @_;
    &configSet('misc', %kvpairs);
    return 1;
}

sub engine_config ( $ % ) {
    my ($engine_name, %kvpairs) = @_;
    my $module_name = &getModuleNameForEngine($engine_name);
    load $module_name;
    while(my ($varname, $value) = each(%kvpairs)) {
        my $fq_varname = sprintf("%s::%s", $module_name, $varname);
        {
            no strict 'refs';
            $$fq_varname = $value;
        }
    }
    return 1;
}

sub getModuleNameForEngine {
    my ($engine_name) = @_;
    my $module_name;
    if($engine_name =~ /^Numpaar::Engine/) {
        $module_name = $engine_name;
    }else {
        $module_name = 'Numpaar::Engine::' . $engine_name 
    }
    return $module_name;
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
