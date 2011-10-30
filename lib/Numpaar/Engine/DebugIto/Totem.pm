package Numpaar::Engine::DebugIto::Totem;
use strict;
use base ('Numpaar::Engine', 'Numpaar::Engine::DebugIto::VideoPlayer');

sub new() {
    my ($class) = @_;
    my $self = $class->setupBasic('^[tT]otem\.Totem');
    $self->setVideoKeys();
    $self->{'video_play_state'} = 'play';
    $self->{'state'} = 'Video';
    return $self;
}

sub changeToState() {
    my ($self, $connection, $to_state) = @_;
    if($to_state eq '0') {
        $self->{'video_play_state'} = 'play';
        $to_state = 'Video';
    }
    $self->SUPER::changeToState($connection, $to_state);
}

sub setVideoKeys() {
    my ($self) = @_;
    $self->{'play_pause'}     = ['p'];
    $self->{'volume_up'}      = ['Up'];
    $self->{'volume_down'}    = ['Down'];
    $self->{'back_normal'}    = ['Left'];
    $self->{'forward_normal'} = ['Right'];
    $self->{'back_big'}       = ['ctrl+Left'];
    $self->{'forward_big'}    = ['ctrl+Right'];
    $self->{'back_small'}     = ['shift+Left'];
    $self->{'forward_small'}  = ['shift+Right'];
}

sub mapVideo_insert() {
    my ($self, $connection, $want_help) = @_;
    return 'フルスクリーン' if defined($want_help);
    $connection->comKeyString('f');
    return 0;
}

sub mapVideo_delete() {
    my ($self, $connection, $want_help) = @_;
    return '表示' if defined($want_help);
    $connection->comMouseClick(1, 200, 200);
    $connection->comMouseClick(1, 210, 200);
}


1;
