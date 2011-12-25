package Numpaar::Engine::DebugIto::XTile;
use strict;
use base 'Numpaar::Engine';

sub new {
    my ($class) = @_;
    return $class->setupBasic('^[xX]-tile\.');
}

sub handler0_right {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return '水平タイル' if defined($want_help);
    $connection->comKeyString('ctrl+h');
    return 0;
}

sub handler0_left {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return '垂直タイル' if defined($want_help);
    $connection->comKeyString('ctrl+v');
    return 0;
}

sub handler0_home {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return '最大化' if defined($want_help);
    $connection->comKeyString('ctrl+m');
    return 0;
}

sub handler0_page_up {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return '全て選択' if defined($want_help);
    $connection->comKeyString('ctrl+a');
    return 0;
}

sub handler0_page_down {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return '全て選択解除' if defined($want_help);
    $connection->comKeyString('ctrl+shift+a');
    return 0;
}


sub handler0_plus      { my ($self, $want_help) = @_; return $self->handler_minus($want_help); }
sub handler0_end       { my ($self, $want_help) = @_; return $self->handler_minus($want_help); }
sub handler0_insert    { my ($self, $want_help) = @_; return $self->handler_minus($want_help); }
sub handler0_delete    { my ($self, $want_help) = @_; return $self->handler_minus($want_help); }

1;
