package Numpaar::Engine::DebugIto::NicoVideo;
use strict;
use base ("Numpaar::Engine::DebugIto::Firefox", 'Numpaar::Visgrep');

my $PAT_FILENAME = 'pat_nicovideo_speaker.pat';

my $COORD_SPEAKER        = {'x' =>    0, 'y' => 0};
my $COORD_IN             = {'x' =>    0, 'y' => -25};
my $COORD_PLAY           = {'x' => -370, 'y' => 5};
my $COORD_COMMENT_TOGGLE = {'x' =>  100, 'y' => 5};
my $COORD_REPEAT_TOGGLE  = {'x' =>   80, 'y' => 5};
my $COORD_OUT            = {'x' =>   50, 'y' => 60};
my $COORD_FULL           = {'x' =>  150, 'y' => 5};

sub new {
    my ($class) = @_;
    my $self = $class->setupBasic('^Navigator\.Firefox \[VIDEO\].*ニコニコ動画[^ ]* - Mozilla Firefox$');
    ## $self->setDeferTimes();
    $self->{'base_coords'} = {};
    $self->{'player_size'} = 'normal';
    return $self;
}

sub changePlayerSize {
    my ($self, $change_to) = @_;
    $self->{'player_size'} = $change_to;
    if(defined($self->{'base_coords'}->{$change_to})) {
        ## $self->{'base_x'} = $self->{'base_coords'}->{$change_to}->{'x'};
        ## $self->{'base_y'} = $self->{'base_coords'}->{$change_to}->{'y'};
        $self->baseX($self->{'base_coords'}->{$change_to}->{'x'});
        $self->baseY($self->{'base_coords'}->{$change_to}->{'y'});
        return 1;
    }
    return 0;
}

sub clickPoint {
    my ($self, $coord) = @_;
    my $connection = $self->getConnection();
    my $status_if = $self->getStatusInterface();
    if(!defined($self->{'base_coords'}->{$self->{'player_size'}})) {
        $status_if->changeStatusIcon('busy');
        ## my $ret = $self->clickPattern($connection, $PAT_FILENAME, $coord, undef, $COORD_SPEAKER);
        my $ret = $self->setBaseFromPattern($PAT_FILENAME, $COORD_SPEAKER->{x}, $COORD_SPEAKER->{y});
        if(!$ret) {
            $status_if->changeStatusIcon('normal');
            return 0;
        }
        $self->clickFromBase($connection, $coord->{x}, $coord->{y});
        $status_if->changeStatusIcon('normal');
        $self->{'base_coords'}->{$self->{'player_size'}} = {'x' => $self->baseX, 'y' => $self->baseY};
    }else {
        $self->clickFromBase($connection, $coord->{x}, $coord->{y});
    }
    return 1;
}

sub handlerExtended_up {
    my ($self, $want_help) = @_;
    return 'ニコ動 IN' if defined($want_help);
    my $connection = $self->getConnection();
    $self->changePlayerSize('normal');
    $self->clickPoint($COORD_IN);
    $connection->comWaitMsec(100);
    $connection->comKeyString('space');
    
    $self->setState('Video');
    return 0;
}

sub handlerVideo_center {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return '再生/停止' if defined($want_help);
    $connection->comKeyString('space');
    return 0;
}

sub handlerVideo_page_down {
    my ($self, $want_help) = @_;
    return 'コメントトグル' if defined($want_help);
    $self->clickPoint($COORD_COMMENT_TOGGLE);
    return 0;
}

sub handlerVideo_end {
    my ($self, $want_help) = @_;
    return 'リピートトグル' if defined($want_help);
    $self->clickPoint($COORD_REPEAT_TOGGLE);
    return 0;
}

sub handlerVideo_insert {
    my ($self, $want_help) = @_;
    return 'ニコ動 OUT' if defined($want_help);
    $self->clickPoint($COORD_OUT);
    $self->{'base_coords'} = {};
    $self->{'player_size'} = 'normal';
    $self->setState(0);
    return 0;
}

sub handlerVideo_right {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'フルスクリーン' if defined($want_help);
    $self->clickPoint($COORD_FULL);
    my $base_exists;
    if($self->{'player_size'} eq 'full') {
        $base_exists = $self->changePlayerSize('returned');
    }else {
        $base_exists = $self->changePlayerSize('full');
    }
    ## ** フォーカスをflash内に維持する
    if($base_exists) {
        $connection->comWaitMsec(500);
        $self->clickFromBase($connection, $COORD_IN->{x}, $COORD_IN->{y});
    }else {
        $connection->comWaitMsec(100);
        $connection->comKeyString('Up');
        $connection->comWaitMsec(100);
        $connection->comKeyString('Up', 'Down');
    }
    return 0;
}

