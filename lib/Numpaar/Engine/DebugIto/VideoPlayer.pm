package Numpaar::Engine::DebugIto::VideoPlayer;
use strict;

sub setVideoKeys() {
    my ($self) = @_;
    $self->{'play_pause'}     = [];
    $self->{'volume_up'}      = [];
    $self->{'volume_down'}    = [];
    $self->{'back_normal'}    = [];
    $self->{'forward_normal'} = [];
    $self->{'back_big'}       = [];
    $self->{'forward_big'}    = [];
    $self->{'back_small'}     = [];
    $self->{'forward_small'}  = [];
}

sub mapVideo_center() {
    my ($self, $connection, $want_help) = @_;
    return '再生/停止' if defined($want_help);
    $connection->comKeyString(@{$self->{'play_pause'}});
    if(defined($self->{'video_play_state'})) {
        if($self->{'video_play_state'} eq 'play') {
            $self->{'video_play_state'} = 'pause';
        }else {
            $self->{'video_play_state'} = 'play';
        }
    }
    return 0;
}

sub mapVideo_up() {
    my ($self, $connection, $want_help) = @_;
    return '音量 大' if defined($want_help);
    $connection->comKeyString(@{$self->{'volume_up'}});
    return 0;
}

sub mapVideo_down() {
    my ($self, $connection, $want_help) = @_;
    return '音量 小' if defined($want_help);
    $connection->comKeyString(@{$self->{'volume_down'}});
    return 0;
}

sub mapVideo_home() {
    my ($self, $connection, $want_help) = @_;
    return '←(大)' if defined($want_help);
    $connection->comKeyString(@{$self->{'back_big'}});
    return 0;
}

sub mapVideo_left() {
    my ($self, $connection, $want_help) = @_;
    return '←' if defined($want_help);
    $connection->comKeyString(@{$self->{'back_normal'}});
    return 0;
}

sub mapVideo_end() {
    my ($self, $connection, $want_help) = @_;
    return '←(小)' if defined($want_help);
    $connection->comKeyString(@{$self->{'back_small'}});
    return 0;
}

sub mapVideo_page_up() {
    my ($self, $connection, $want_help) = @_;
    return '→(大)' if defined($want_help);
    $connection->comKeyString(@{$self->{'forward_big'}});
    return 0;
}

sub mapVideo_right() {
    my ($self, $connection, $want_help) = @_;
    return '→' if defined($want_help);
    $connection->comKeyString(@{$self->{'forward_normal'}});
    return 0;
}

sub mapVideo_page_down() {
    my ($self, $connection, $want_help) = @_;
    return '→(小)' if defined($want_help);
    $connection->comKeyString(@{$self->{'forward_small'}});
    return 0;
}


1;
