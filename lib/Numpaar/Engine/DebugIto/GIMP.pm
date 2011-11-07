package Numpaar::Engine::DebugIto::GIMP;
use strict;
use base 'Numpaar::Engine';

sub new {
    my ($class) = @_;
    return $class->setupBasic('^[gG]imp.*\.Gimp[^ ]*');
}

sub handler0_center {
    my ($self, $connection, $want_help) = @_;
    return 'ペン' if defined($want_help);
    $connection->comKeyString('p');
    return 0;
}

sub handler0_delete {
    my ($self, $connection, $want_help) = @_;
    return '鉛筆' if defined($want_help);
    $connection->comKeyString('n');
    return 0;
}

sub handler0_left {
    my ($self, $connection, $want_help) = @_;
    return 'スポイト' if defined($want_help);
    $connection->comKeyString('o');
    return 0;
}


sub handler0_right {
    my ($self, $connection, $want_help) = @_;
    return '消しゴム' if defined($want_help);
    $connection->comKeyString('shift+e');
    return 0;
}

sub handler0_home {
    my ($self, $connection, $want_help) = @_;
    return '矩形選択' if defined($want_help);
    $connection->comKeyString('r');
    return 0;
}

sub handler0_up {
    my ($self, $connection, $want_help) = @_;
    return '色スワップ' if defined($want_help);
    $connection->comKeyString('F12');
    return 0;
}

sub handler0_page_up {
    my ($self, $connection, $want_help) = @_;
    return 'パス' if defined($want_help);
    $connection->comKeyString('b');
    return 0;
}

sub handler0_end {
    my ($self, $connection, $want_help) = @_;
    return 'やり直し' if defined($want_help);
    $connection->comKeyString('ctrl+z');
    return 0;
}

sub handler0_down {
    my ($self, $connection, $want_help) = @_;
    return '縮小' if defined($want_help);
    $connection->comKeyString('minus');
    return 0;
}

sub handler0_insert {
    my ($self, $connection, $want_help) = @_;
    return '保存' if defined($want_help);
    $connection->comKeyString('ctrl+s');
    return 0;
}

sub handler0_page_down {
    my ($self, $connection, $want_help) = @_;
    return '拡大' if defined($want_help);
    $connection->comKeyString('plus');
    return 0;
}

1;

