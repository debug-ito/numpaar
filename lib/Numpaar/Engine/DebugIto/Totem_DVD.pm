package Numpaar::Engine::DebugIto::Totem_DVD;
use strict;
use base ('Numpaar::Engine::DebugIto::Totem');

sub new {
    my ($class) = @_;
    my $self = $class->setupBasic('^[tT]otem\.Totem_DVD');
    $self->setVideoKeys();
    $self->{'video_play_state'} = 'play';
    ## $self->{'state'} = ;
    $self->setState('DVDExtended');
    return $self;
}

sub setState {
    my ($self, $to_state, $connection) = @_;
    if($to_state eq '0') {
        $self->{'video_play_state'} = 'play';
        $to_state = 'DVDExtended';
    }
    $self->SUPER::setState($to_state, $connection);
}

sub handlerVideo_delete {
    my ($self, $connection, $want_help) = @_;
    return 'DVD mode' if defined($want_help);
    $self->setState('DVDExtended', $connection);
    return 0;
}

sub handlerDVDExtended_delete {
    my ($self, $connection, $want_help) = @_;
    return 'normal mode' if defined($want_help);
    $self->setState('Video', $connection);
    return 0;
}

sub handlerDVDExtended_page_down {
    my ($self, $connection, $want_help) = @_;
    return 'Toggle menu' if defined($want_help);
    if($self->{'video_play_state'} eq 'pause') {
        $self->handlerVideo_center($connection, $want_help);
        $connection->comWaitMsec(100);
    }
    $connection->comKeyString('m');
    return 0;
}

sub handlerDVDExtended_insert { my ($self, $connection, $want_help) = @_; return $self->handlerVideo_insert($connection, $want_help); }

1;
