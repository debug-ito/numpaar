package Numpaar::Engine::DebugIto::Liferea;
use strict;
use base 'Numpaar::Engine';

sub new {
    my ($class) = @_;
    return $class->setupBasic('^liferea\.Liferea');
}

sub handler0_down {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return '左ペインへ' if defined($want_help);
    $self->setState('LeftPane');
    $connection->comKeyString('Tab');
    return 0;
}

sub handlerLeftPane_right {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return '右ペインへ' if defined($want_help);
    $self->setState("RightPane");
    $connection->comKeyString('Tab');
    return 0;
}

sub handlerRightPane_left {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return '左ペインへ' if defined($want_help);
    $self->setState('LeftPane');
    $connection->comKeyString('shift+Tab', 'shift+Tab');
    return 0;
}

sub handler_home {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return '更新' if defined($want_help);
    $connection->comKeyString('ctrl+a');
    return 0;
}

sub handler_end {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'マーク' if defined($want_help);
    $connection->comKeyString('ctrl+t');
    return 0;
}

sub handler_insert {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return '全て既読' if defined($want_help);
    $connection->comKeyString("ctrl+r");
    return 0;
}

1;

