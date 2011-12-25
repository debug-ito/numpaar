package Numpaar::Engine::DebugIto::Thunar;
use strict;
use base 'Numpaar::Engine';

sub new {
    my ($class) = @_;
    return $class->setupBasic('^[tT]hunar\.Thunar');
}

sub handler0_page_up {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'Parent' if defined($want_help);
    $connection->comKeyString('alt+Up');
    return 0;
}

sub handler0_home {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'Home dir' if defined($want_help);
    $connection->comKeyString('alt+Home');
    return 0;
}

1;
