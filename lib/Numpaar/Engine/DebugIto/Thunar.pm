package Numpaar::Engine::DebugIto::Thunar;
use strict;
use base 'Numpaar::Engine';

sub new() {
    my ($class) = @_;
    return $class->setupBasic('^[tT]hunar\.Thunar');
}

sub map0_page_up() {
    my ($self, $connection, $want_help) = @_;
    return '上へ' if defined($want_help);
    $connection->comKeyString('alt+Up');
    return 0;
}

sub map0_home() {
    my ($self, $connection, $want_help) = @_;
    return 'ホーム' if defined($want_help);
    $connection->comKeyString('alt+Home');
    return 0;
}

1;
