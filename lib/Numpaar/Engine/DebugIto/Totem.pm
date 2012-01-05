package Numpaar::Engine::DebugIto::Totem;
use strict;
use base ('Numpaar::Engine', 'Numpaar::Engine::DebugIto::VideoPlayer');

sub new {
    my ($class) = @_;
    my $self = $class->setupBasic('^[tT]otem\.Totem');
    $self->totemSetVideoKeys();
    $self->videoPlayerState('play');
    $self->setState('Video');
    return $self;
}

sub setState {
    my ($self, $to_state) = @_;
    if($to_state eq '0') {
        ## $self->{'video_play_state'} = 'play';
        $self->videoPlayerState('play');
        $to_state = 'Video';
    }
    $self->SUPER::setState($to_state);
}

sub totemSetVideoKeys {
    my ($self) = @_;
    $self->videoPlayerSetKeys(
        play_pause     => ['p'],
        volume_up      => ['Up'],
        volume_down    => ['Down'],
        back_normal    => ['Left'],
        forward_normal => ['Right'],
        back_big       => ['ctrl+Left'],
        forward_big    => ['ctrl+Right'],
        back_small     => ['shift+Left'],
        forward_small  => ['shift+Right'],
    );
}

sub handlerVideo_insert {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'Full Screen' if defined($want_help);
    $connection->comKeyString('f');
    return 0;
}

sub handlerVideo_delete {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'Show Control' if defined($want_help);
    $connection->comMouseMove(200, 200);
    $connection->comMouseMove(210, 200);
    return 0;
}


1;

__END__

=pod


=head1 NAME

Numpaar::Engine::DebugIto::Totem - Engine for Totem media player


=head1 SYNOPSIS

In configuration file

  engine 'DebugIto::Totem';



=head1 DESCRIPTION

This Numpaar Engine is activated for Totem media player.

Most of the key bindings are provided by L<Numpaar::Engine::DebugIto::VideoPlayer> module.


=head1 KEYBINDINGS

=over

=item insert

Toggle full-screen mode


=item delete

Move the mouse pointer around.

When in the full-screen mode, this shows a control including the current seek position of the media.


=back


=head1 AUTHOR

Toshio ITO

=head1 SEE ALSO

L<Numpaar::Engine::DebugIto::VideoPlayer>



=cut


