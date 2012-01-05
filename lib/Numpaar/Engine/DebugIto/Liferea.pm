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

__END__

=pod


=head1 NAME

Numpaar::Engine::DebugIto::Liferea - Engine for Liferea

=head1 SYNOPSIS

In configuration file

  engine 'DebugIto::Liferea';


=head1 DESCRIPTION

This Numpaar Engine is activated for Liferea, a RSS feed aggregator.

=head1 ENGINE STATES

=over

=item 0 (default)

Keyboard focus is in the tool bar.

B<down> key changes the state to B<LeftPane> state.

=item LeftPane

Keyboard focus is in the left pane.

B<right> key changes the state to B<RightPane> state.

=item RightPane

Keyboard focus is in the right pane.

B<left> key changes the state to B<LeftPane> state.

=back


=head1 AUTHOR

Toshio ITO



=cut

