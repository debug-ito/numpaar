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

sub new() {
    my ($class) = @_;
    my $self = $class->setupBasic('^Navigator\.Firefox \[VIDEO\].*ニコニコ動画[^ ]* - Mozilla Firefox$');
    $self->setDeferTimes();
    $self->{'base_coords'} = {};
    $self->{'player_size'} = 'normal';
    return $self;
}

sub changePlayerSize() {
    my ($self, $change_to) = @_;
    $self->{'player_size'} = $change_to;
    if(defined($self->{'base_coords'}->{$change_to})) {
        $self->{'base_x'} = $self->{'base_coords'}->{$change_to}->{'x'};
        $self->{'base_y'} = $self->{'base_coords'}->{$change_to}->{'y'};
        return 1;
    }
    return 0;
}

sub clickPoint() {
    my ($self, $connection, $coord, $pipe) = @_;
    if(!defined($self->{'base_coords'}->{$self->{'player_size'}})) {
        $self->changeStatusIcon($pipe, 'busy');
        ## my $ret = $self->clickPattern($connection, $PAT_FILENAME, $coord, undef, $COORD_SPEAKER);
        my $ret = $self->setBase($PAT_FILENAME, $COORD_SPEAKER);
        if(!$ret) {
            $self->changeStatusIcon($pipe, 'normal');
            return 0;
        }
        $self->clickFromBase($connection, $coord);
        $self->changeStatusIcon($pipe, 'normal');
        $self->{'base_coords'}->{$self->{'player_size'}} = {'x' => $self->{'base_x'}, 'y' => $self->{'base_y'}};
    }else {
        $self->clickFromBase($connection, $coord);
    }
    return 1;
}

sub mapExtended_up() {
    my ($self, $connection, $want_help, $pipe) = @_;
    return 'ニコ動 IN' if defined($want_help);
    $self->changePlayerSize('normal');
    $self->clickPoint($connection, $COORD_IN, $pipe);
    $connection->comWaitMsec(100);
    $connection->comKeyString('space');
    
    $self->changeToState($connection, 'Video');
    return 0;
}

sub mapVideo_center() {
    my ($self, $connection, $want_help) = @_;
    return '再生/停止' if defined($want_help);
    $connection->comKeyString('space');
    return 0;
}

sub mapVideo_page_down() {
    my ($self, $connection, $want_help, $pipe) = @_;
    return 'コメントトグル' if defined($want_help);
    $self->clickPoint($connection, $COORD_COMMENT_TOGGLE, $pipe);
    return 0;
}

sub mapVideo_end() {
    my ($self, $connection, $want_help, $pipe) = @_;
    return 'リピートトグル' if defined($want_help);
    $self->clickPoint($connection, $COORD_REPEAT_TOGGLE, $pipe);
    return 0;
}

sub mapVideo_insert() {
    my ($self, $connection, $want_help, $pipe) = @_;
    return 'ニコ動 OUT' if defined($want_help);
    $self->clickPoint($connection, $COORD_OUT, $pipe);
    $self->{'base_coords'} = {};
    $self->{'player_size'} = 'normal';
    $self->changeToState($connection, 0);
    return 0;
}

sub mapVideo_right() {
    my ($self, $connection, $want_help, $pipe) = @_;
    return 'フルスクリーン' if defined($want_help);
    $self->clickPoint($connection, $COORD_FULL, $pipe);
    my $base_exists;
    if($self->{'player_size'} eq 'full') {
        $base_exists = $self->changePlayerSize('returned');
    }else {
        $base_exists = $self->changePlayerSize('full');
    }
    ## ** フォーカスをflash内に維持する
    if($base_exists) {
        $connection->comWaitMsec(500);
        $self->clickFromBase($connection, $COORD_IN);
    }else {
        $connection->comWaitMsec(100);
        $connection->comKeyString('Up');
        $connection->comWaitMsec(100);
        $connection->comKeyString('Up', 'Down');
    }
    return 0;
}

