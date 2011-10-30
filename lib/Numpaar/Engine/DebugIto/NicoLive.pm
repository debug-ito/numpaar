package Numpaar::Engine::DebugIto::NicoLive;
use strict;
use base ('Numpaar::Engine::DebugIto::Firefox', 'Numpaar::Visgrep');
use Numpaar::Config ('configElement');
use IO::Pipe;

my $WAIT_TIME = 100;
my $COORD_COMMENT    = {'x' => 0,    'y' => 0};
my $COORD_BATSU      = {'x' => -76,  'y' => -349};
my $COORD_PREMIUM_OK = {'x' => -22,  'y' => -366};
my $COORD_COMBOX     = {'x' => -143, 'y' => 10};
## my $COORD_OUT        = {'x' => -498, 'y' => 0};
my $COORD_OUT        = {'x' => -490, 'y' => 0};
my $COORD_RELOAD     = {'x' => 0,    'y' => -24};
my $COORD_COMERROR_BATSU = {'x' => -75, 'y' => -292};


sub new() {
    my ($class) = @_;
    my $self = $class->setupBasic('^Navigator\.Firefox .* ニコニコ生放送 - Mozilla Firefox$');
    $self->{'base_x'} = $self->{'base_y'} = 0;
    $self->setDeferTimes();
    return $self;
}

sub sendString() {
    my ($self, $connection, $want_help, $str, $short_str) = @_;
    return (defined($short_str) ? $short_str : $str) if defined($want_help);
    my $xclip = IO::Pipe->new();
    $xclip->writer(&configElement('extern_program', 'xclip') . " -selection c");
    $xclip->print($str);
    $xclip->close();
    $connection->comWaitMsec(200);
    $connection->comKeyString('ctrl+v');
    return 0;
}

sub mapExtended_up() {
    my ($self, $connection, $want_help, $status_pipe) = @_;
    return 'ニコ生 IN' if defined($want_help);
    $self->changeStatusIcon($status_pipe, 'busy');
    ## my $ret = $self->clickPattern($connection, 'pat_nico_comment.pat',
    ##                               {'x' => $COORD_PREMIUM_OK->{'x'} - $COORD_COMMENT->{'x'},
    ##                                'y' => $COORD_PREMIUM_OK->{'y'} - $COORD_COMMENT->{'y'}}, undef, $COORD_COMMENT);
    my $ret = $self->setBase('pat_nico_comment.pat', $COORD_COMMENT);
    if(!$ret) {
        $self->changeStatusIcon($status_pipe, 'normal');
        return 0;
    }
    $self->clickFromBase($connection, $COORD_PREMIUM_OK);
    $connection->comWaitMsec($WAIT_TIME);
    $self->clickFromBase($connection, $COORD_BATSU);
    $connection->comWaitMsec($WAIT_TIME);
    $self->clickFromBase($connection, $COORD_COMERROR_BATSU);
    $connection->comWaitMsec($WAIT_TIME);
    $self->clickFromBase($connection, $COORD_COMBOX);
    $self->changeToState($connection, 'NicoLive');
    $self->changeStatusIcon($status_pipe, 'normal');
    return 0;
}

sub mapNicoLive_insert() {
    my ($self, $connection, $want_help) = @_;
    return 'ニコ生 OUT' if defined($want_help);
    ## $self->clickPattern($connection, 'pat_nico_comment.pat', {'x'=>0, 'y'=>35}, 1);
    $self->clickFromBase($connection, $COORD_OUT);
    $self->changeToState($connection, 0);
    return 0;
}
sub mapNicoLive_delete() { my ($self, $conn, $wh) = @_; return $self->mapNicoLive_insert($conn, $wh); }

sub mapNicoLive_page_up() {
    my ($self, $connection, $want_help) = @_;
    return '更新' if defined($want_help);
    $self->clickFromBase($connection, $COORD_RELOAD);
    $connection->comWaitMsec(200);
    $self->clickFromBase($connection, $COORD_COMBOX);
    return 0;
}

sub mapNicoLive_up() { my ($self, $connection, $want_help) = @_; return $self->sendString($connection, $want_help, 'www'); }
sub mapNicoLive_home() { my ($self, $connection, $want_help) = @_; return $self->sendString($connection, $want_help, 'm9'); }
sub mapNicoLive_left() { my ($self, $connection, $want_help) = @_; return $self->sendString($connection, $want_help, 'わこつ'); }
sub mapNicoLive_end() { my ($self, $connection, $want_help) = @_; return $self->sendString($connection, $want_help, '初見'); }
sub mapNicoLive_down() { my ($self, $connection, $want_help) = @_; return $self->sendString($connection, $want_help, '8888888'); }
sub mapNicoLive_right() { my ($self, $connection, $want_help) = @_; return $self->sendString($connection, $want_help, 'つこうた'); }
sub mapNicoLive_page_down() {
    my ($self, $connection, $want_help) = @_;
    return $self->sendString($connection, $want_help, '【審議中】　(　´・ω) (´・ω・) (・ω・｀) (ω・｀ )', '審議中');
}

1;
