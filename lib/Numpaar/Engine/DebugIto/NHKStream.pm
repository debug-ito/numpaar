package Numpaar::Engine::DebugIto::NHKStream;
use strict;
use base ('Numpaar::Engine::DebugIto::Firefox', 'Numpaar::Visgrep');

my $WAIT_TIME = 100;
my $COORD_PLAY = {'x' => 0, 'y' => 0};
my $COORD_OUT  = {'x' => -118, 'y' => 48};
my $COORD_SPEAKER = {'x' => 79, 'y' => -1};
my $COORD_CH1 = {'x' => 0,   'y' => -90};
my $COORD_CH2 = {'x' => 140, 'y' => -90};
my $COORD_CH3 = {'x' => 265, 'y' => -90};

sub new {
    my ($class) = @_;
    my $self = $class->setupBasic('^Navigator\.Firefox NHK語学番組 .*Mozilla Firefox$');
    $self->initVisgrep(0, 0);
    $self->{'init_done'} = 0;
    $self->setDeferTimes();
    return $self;
}


sub channelSelect {
    my ($self, $connection, $channel_coord) = @_;
    if(!$self->{'init_done'}) {
        return 0 if !$self->setBaseFromPattern('pat_nhk_speaker.pat', $COORD_SPEAKER->{x}, $COORD_SPEAKER->{y});
        $self->clickFromBase($connection, $channel_coord->{x}, $channel_coord->{y});
        $self->{'init_done'} = 1;
    }else {
        $self->clickFromBase($connection, $channel_coord->{x}, $channel_coord->{y});
    }
    $self->setState('NHK', $connection);
    return 1;
}

sub handlerExtended_end {
    my ($self, $connection, $want_help) = @_;
    return 'NHK 左チャネル' if defined($want_help);
    $self->channelSelect($connection, $COORD_CH1);
    return 0;
}

sub handlerExtended_down {
    my ($self, $connection, $want_help) = @_;
    return 'NHK 中チャネル' if defined($want_help);
    $self->channelSelect($connection, $COORD_CH2);
    return 0;
}

sub handlerExtended_page_down {
    my ($self, $connection, $want_help) = @_;
    return 'NHK 右チャネル' if defined($want_help);
    $self->channelSelect($connection, $COORD_CH3);
    return 0;
}

sub handlerNHK_center {
    my ($self, $connection, $want_help) = @_;
    return '再生/停止' if defined($want_help);
    $self->clickFromBase($connection, $COORD_PLAY->{x}, $COORD_PLAY->{y});
    $connection->comWaitMsec($WAIT_TIME);
    $self->clickFromBase($connection, $COORD_SPEAKER->{x}, $COORD_PLAY->{y});
    return 0;
}

sub handlerNHK_insert {
    my ($self, $connection, $want_help) = @_;
    return 'NHK OUT' if defined($want_help);
    $self->clickFromBase($connection, $COORD_OUT->{x}, $COORD_OUT->{y});
    $self->setState(0, $connection);
    $self->{'init_done'} = 0;
    return 0;
}

sub handlerNHK_end       { my ($self, $connection, $want_help) = @_; return $self->handlerExtended_end($connection, $want_help); }
sub handlerNHK_down      { my ($self, $connection, $want_help) = @_; return $self->handlerExtended_down($connection, $want_help); }
sub handlerNHK_page_down { my ($self, $connection, $want_help) = @_; return $self->handlerExtended_page_down($connection, $want_help); }


1;
