package Numpaar::Engine::DebugIto::GIMP;
use strict;
use base 'Numpaar::Engine';

sub new {
    my ($class) = @_;
    return $class->setupBasic('^[gG]imp.*\.Gimp[^ ]*');
}

sub handler0_center {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'ペン' if defined($want_help);
    $connection->comKeyString('p');
    return 0;
}

sub handler0_delete {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return '鉛筆' if defined($want_help);
    $connection->comKeyString('n');
    return 0;
}

sub handler0_left {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'スポイト' if defined($want_help);
    $connection->comKeyString('o');
    return 0;
}


sub handler0_right {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return '消しゴム' if defined($want_help);
    $connection->comKeyString('shift+e');
    return 0;
}

sub handler0_home {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return '矩形選択' if defined($want_help);
    $connection->comKeyString('r');
    return 0;
}

sub handler0_up {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return '色スワップ' if defined($want_help);
    $connection->comKeyString('F12');
    return 0;
}

sub handler0_page_up {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'パス' if defined($want_help);
    $connection->comKeyString('b');
    return 0;
}

sub handler0_end {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'やり直し' if defined($want_help);
    $connection->comKeyString('ctrl+z');
    return 0;
}

sub handler0_down {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return '縮小' if defined($want_help);
    $connection->comKeyString('minus');
    return 0;
}

sub handler0_insert {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return '保存' if defined($want_help);
    $connection->comKeyString('ctrl+s');
    return 0;
}

sub handler0_page_down {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return '拡大' if defined($want_help);
    $connection->comKeyString('plus');
    return 0;
}

1;

__END__

=pod

=head1 NAME

Numpaar::Engine::DebugIto::GIMP - Engine for drawing by GIMP


=head1 SYNOPSIS

In configuration file

  engine 'DebugIto::GIMP';



=head1 DESCRIPTION

This Numpaar Engine is activated for GIMP.

It provides the key bindings for drawing on GIMP.

=head1 AUTHOR

Toshio ITO

=cut


