package Numpaar::Engine::DebugIto::Totem_DVD;
use strict;
use base ('Numpaar::Engine::DebugIto::Totem');

sub new {
    my ($class) = @_;
    my $self = $class->setupBasic('^[tT]otem\.Totem_DVD');
    $self->totemSetVideoKeys();
    $self->videoPlayerState('play');
    $self->setState('DVDExtended');
    return $self;
}

sub setState {
    my ($self, $to_state) = @_;
    if($to_state eq '0') {
        $self->videoPlayerState('play');
        ## $self->{'video_play_state'} = 'play';
        $to_state = 'DVDExtended';
    }
    $self->SUPER::setState($to_state);
}

sub handlerVideo_delete {
    my ($self, $want_help) = @_;
    return 'DVD mode' if defined($want_help);
    $self->setState('DVDExtended');
    return 0;
}

sub handlerDVDExtended_delete {
    my ($self, $want_help) = @_;
    return 'normal mode' if defined($want_help);
    $self->setState('Video');
    return 0;
}

sub handlerDVDExtended_page_down {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'Toggle menu' if defined($want_help);
    if($self->videoPlayerState eq 'pause') {
        $self->handlerVideo_center($want_help);
        $connection->comWaitMsec(100);
    }
    $connection->comKeyString('m');
    return 0;
}

sub handlerDVDExtended_insert { my ($self, $want_help) = @_; return $self->handlerVideo_insert($want_help); }

1;

__END__

=pod

=head1 NAME

Numpaar::Engine::DebugIto::Totem_DVD - Engine for Totem media player (DVD mode)


=head1 SYNOPSIS

In configuration file

  ## load Totem_DVD before Totem
  engine 'DebugIto::Totem_DVD';
  engine 'DebugIto::Totem';


=head1 DESCRIPTION

This Numpaar Engine is for Totem media player.

Unlike Numpaar::Engine::DebugIto::Totem, this Engine has a state for operating DVD menus,
which is enabled by default.

To get along with Numpaar::Engine::DebugIto::Totem, this Engine uses a different window matcher.
Therefore if you want to use this module, Totem must be started with C<--class> option, like

  $ totem --class Totem_DVD dvd:///dev/sr0

Most of the key bindings are provided by L<Numpaar::Engine::DebugIto::VideoPlayer> module.


=head1 STATES

=head2 DVD Menu state

This is the initial state. The keybindings are

=over

=item delete

Go to Video state.

=item page down

Toggle DVD menu.

=item insert

Toggle full-screen.

=back


=head2 Video state

In this state, the same keybindings as Numpaar::Engine::DebugIto::Totem are available
except for C<delete>, which takes you to the DVD Menu state.

=head1 AUTHOR

Toshio ITO

=head1 SEE ALSO

L<Numpaar::Engine::DebugIto::Totem>

=cut
