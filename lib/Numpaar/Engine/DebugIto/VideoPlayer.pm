package Numpaar::Engine::DebugIto::VideoPlayer;
use strict;

my @video_key_list = qw(play_pause volume_up volume_down back_normal forward_normal back_big forward_big back_small forward_small);

sub videoPlayerSetKeys {
    my ($self, %params) = @_;
    my %videokeys = ();
    foreach my $key_symbol (@video_key_list) {
        $videokeys{$key_symbol} = defined($params{$key_symbol}) ? $params{$key_symbol} : [];
    }
    $self->heap->{videoplayer_keys} = \%videokeys;
}

sub videoPlayerSend {
    my ($self, $key_symbol) = @_;
    my $keys_hash = $self->heap->{videoplayer_keys};
    return if !defined($keys_hash->{$key_symbol});
    my $keylist_ref = ref($keys_hash->{$key_symbol}) ? $keys_hash->{$key_symbol} : [$keys_hash->{$key_symbol}];
    $self->getConnection()->comKeyString(@$keylist_ref);
}

sub videoPlayerState {
    my ($self, $set_state) = @_;
    $self->heap->{videoplayer_state} = lc($set_state) if defined($set_state);
    return $self->heap->{videoplayer_state};
}

sub handlerVideo_center {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'Play/Pause' if defined($want_help);
    $self->videoPlayerSend('play_pause');
    if(defined($self->videoPlayerState)) {
        if($self->videoPlayerState eq 'play') {
            $self->videoPlayerState('pause');
        }else {
            $self->videoPlayerState('play');
        }
    }
    return 0;
}

sub handlerVideo_up {
    my ($self, $want_help) = @_;
    ## my $connection = $self->getConnection();
    return 'Vol up' if defined($want_help);
    $self->videoPlayerSend('volume_up');
    ## $connection->comKeyString(@{$self->{'volume_up'}});
    return 0;
}

sub handlerVideo_down {
    my ($self, $want_help) = @_;
    ## my $connection = $self->getConnection();
    return 'Vol down' if defined($want_help);
    $self->videoPlayerSend('volume_down');
    ## $connection->comKeyString(@{$self->{'volume_down'}});
    return 0;
}

sub handlerVideo_home {
    my ($self, $want_help) = @_;
    ## my $connection = $self->getConnection();
    return 'Back (L)' if defined($want_help);
    $self->videoPlayerSend('back_big');
    ## $connection->comKeyString(@{$self->{'back_big'}});
    return 0;
}

sub handlerVideo_left {
    my ($self, $want_help) = @_;
    ## my $connection = $self->getConnection();
    return 'Back (M)' if defined($want_help);
    $self->videoPlayerSend('back_normal');
    ## $connection->comKeyString(@{$self->{'back_normal'}});
    return 0;
}

sub handlerVideo_end {
    my ($self, $want_help) = @_;
    ## my $connection = $self->getConnection();
    return 'Back (S)' if defined($want_help);
    $self->videoPlayerSend('back_small');
    ## $connection->comKeyString(@{$self->{'back_small'}});
    return 0;
}

sub handlerVideo_page_up {
    my ($self, $want_help) = @_;
    ## my $connection = $self->getConnection();
    return 'Forward (L)' if defined($want_help);
    $self->videoPlayerSend('forward_big');
    ## $connection->comKeyString(@{$self->{'forward_big'}});
    return 0;
}

sub handlerVideo_right {
    my ($self, $want_help) = @_;
    ## my $connection = $self->getConnection();
    return 'Forward (M)' if defined($want_help);
    $self->videoPlayerSend('forward_normal');
    ## $connection->comKeyString(@{$self->{'forward_normal'}});
    return 0;
}

sub handlerVideo_page_down {
    my ($self, $want_help) = @_;
    ## my $connection = $self->getConnection();
    return 'Forward (S)' if defined($want_help);
    $self->videoPlayerSend('forward_small');
    ## $connection->comKeyString(@{$self->{'forward_small'}});
    return 0;
}


1;
