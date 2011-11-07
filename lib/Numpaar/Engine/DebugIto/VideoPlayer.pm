package Numpaar::Engine::DebugIto::VideoPlayer;
use strict;

sub setVideoKeys {
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

sub handlerVideo_center {
    my ($self, $connection, $want_help) = @_;
    return 'Play/Pause' if defined($want_help);
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

sub handlerVideo_up {
    my ($self, $connection, $want_help) = @_;
    return 'Vol up' if defined($want_help);
    $connection->comKeyString(@{$self->{'volume_up'}});
    return 0;
}

sub handlerVideo_down {
    my ($self, $connection, $want_help) = @_;
    return 'Vol down' if defined($want_help);
    $connection->comKeyString(@{$self->{'volume_down'}});
    return 0;
}

sub handlerVideo_home {
    my ($self, $connection, $want_help) = @_;
    return 'Back (L)' if defined($want_help);
    $connection->comKeyString(@{$self->{'back_big'}});
    return 0;
}

sub handlerVideo_left {
    my ($self, $connection, $want_help) = @_;
    return 'Back (M)' if defined($want_help);
    $connection->comKeyString(@{$self->{'back_normal'}});
    return 0;
}

sub handlerVideo_end {
    my ($self, $connection, $want_help) = @_;
    return 'Back (S)' if defined($want_help);
    $connection->comKeyString(@{$self->{'back_small'}});
    return 0;
}

sub handlerVideo_page_up {
    my ($self, $connection, $want_help) = @_;
    return 'Forward (L)' if defined($want_help);
    $connection->comKeyString(@{$self->{'forward_big'}});
    return 0;
}

sub handlerVideo_right {
    my ($self, $connection, $want_help) = @_;
    return 'Forward (M)' if defined($want_help);
    $connection->comKeyString(@{$self->{'forward_normal'}});
    return 0;
}

sub handlerVideo_page_down {
    my ($self, $connection, $want_help) = @_;
    return 'Forward (S)' if defined($want_help);
    $connection->comKeyString(@{$self->{'forward_small'}});
    return 0;
}


1;
