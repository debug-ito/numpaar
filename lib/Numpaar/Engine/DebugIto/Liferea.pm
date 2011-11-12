package Numpaar::Engine::DebugIto::Liferea;
use strict;
use base 'Numpaar::Engine';

sub new {
    my ($class) = @_;
    return $class->setupBasic('^liferea\.Liferea');
}

sub handler0_down {
    my ($self, $connection, $want_help) = @_;
    return '左ペインへ' if defined($want_help);
    $self->setState('LeftPane', $connection);
    $connection->comKeyString('Tab');
    return 0;
}

sub handlerLeftPane_right {
    my ($self, $connection, $want_help) = @_;
    return '右ペインへ' if defined($want_help);
    $self->setState("RightPane", $connection);
    $connection->comKeyString('Tab');
    return 0;
}

sub handlerRightPane_left {
    my ($self, $connection, $want_help) = @_;
    return '左ペインへ' if defined($want_help);
    $self->setState('LeftPane', $connection);
    $connection->comKeyString('shift+Tab', 'shift+Tab');
    return 0;
}

sub handler_home {
    my ($self, $connection, $want_help) = @_;
    return '更新' if defined($want_help);
    $connection->comKeyString('ctrl+a');
    return 0;
}

sub handler_end {
    my ($self, $connection, $want_help) = @_;
    return 'マーク' if defined($want_help);
    $connection->comKeyString('ctrl+t');
    return 0;
}

sub handler_insert {
    my ($self, $connection, $want_help) = @_;
    return '全て既読' if defined($want_help);
    $connection->comKeyString("ctrl+r");
    return 0;
}

1;

