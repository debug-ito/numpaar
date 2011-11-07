package Numpaar::Engine::DebugIto::XTile;
use strict;
use base 'Numpaar::Engine';

sub new {
    my ($class) = @_;
    return $class->setupBasic('^[xX]-tile\.');
}

sub handler0_right {
    my ($self, $connection, $want_help) = @_;
    return '水平タイル' if defined($want_help);
    $connection->comKeyString('ctrl+h');
    return 0;
}

sub handler0_left {
    my ($self, $connection, $want_help) = @_;
    return '垂直タイル' if defined($want_help);
    $connection->comKeyString('ctrl+v');
    return 0;
}

sub handler0_home {
    my ($self, $connection, $want_help) = @_;
    return '最大化' if defined($want_help);
    $connection->comKeyString('ctrl+m');
    return 0;
}

sub handler0_page_up {
    my ($self, $connection, $want_help) = @_;
    return '全て選択' if defined($want_help);
    $connection->comKeyString('ctrl+a');
    return 0;
}

sub handler0_page_down {
    my ($self, $connection, $want_help) = @_;
    return '全て選択解除' if defined($want_help);
    $connection->comKeyString('ctrl+shift+a');
    return 0;
}


sub handler0_plus      { my ($self, $connection, $want_help) = @_; return $self->handler_minus($connection, $want_help); }
sub handler0_end       { my ($self, $connection, $want_help) = @_; return $self->handler_minus($connection, $want_help); }
sub handler0_insert    { my ($self, $connection, $want_help) = @_; return $self->handler_minus($connection, $want_help); }
sub handler0_delete    { my ($self, $connection, $want_help) = @_; return $self->handler_minus($connection, $want_help); }

1;
