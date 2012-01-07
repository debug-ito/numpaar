package Numpaar::Engine::DebugIto::NicoLive;
use strict;
use base ('Numpaar::Engine::DebugIto::Firefox');
use Numpaar::Config ('configGet');
use Numpaar::Visgrep;
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


sub new {
    my ($class) = @_;
    my $self = $class->setupBasic('^Navigator\.Firefox .* ニコニコ生放送 - Mozilla Firefox$');
    $self->heap->{visgrep} = Numpaar::Visgrep->new();
    ## $self->setDeferTimes();
    return $self;
}

sub sendString {
    my ($self, $want_help, $str, $short_str) = @_;
    return (defined($short_str) ? $short_str : $str) if defined($want_help);
    my $connection = $self->getConnection();
    my $xclip = IO::Pipe->new();
    $xclip->writer(&configGet('extern_program', 'xclip') . " -selection c");
    $xclip->print($str);
    $xclip->close();
    $connection->comWaitMsec(200);
    $connection->comKeyString('ctrl+v');
    return 0;
}

sub handlerExtended_up {
    my ($self, $want_help) = @_;
    return 'ニコ生 IN' if defined($want_help);
    my $connection = $self->getConnection();
    my $status_if = $self->getStatusInterface();
    my $visgrep = $self->heap->{visgrep};
    $status_if->changeStatusIcon('busy');
    my $ret = $visgrep->setBaseFromPattern('pat_nico_comment.pat', $COORD_COMMENT->{x}, $COORD_COMMENT->{y});
    if(!$ret) {
        $status_if->changeStatusIcon('normal');
        return 0;
    }
    $connection->comMouseLeftClick($visgrep->toAbsolute($COORD_PREMIUM_OK->{x}, $COORD_PREMIUM_OK->{y}));
    $connection->comWaitMsec($WAIT_TIME);
    $connection->comMouseLeftClick($visgrep->toAbsolute($COORD_BATSU->{x}, $COORD_BATSU->{y}));
    $connection->comWaitMsec($WAIT_TIME);
    $connection->comMouseLeftClick($visgrep->toAbsolute($COORD_COMERROR_BATSU->{x}, $COORD_COMERROR_BATSU->{y}));
    $connection->comWaitMsec($WAIT_TIME);
    $connection->comMouseLeftClick($visgrep->toAbsolute($COORD_COMBOX->{x}, $COORD_COMBOX->{y}));
    $self->setState('NicoLive');
    $status_if->changeStatusIcon('normal');
    return 0;
}

sub handlerNicoLive_insert {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'ニコ生 OUT' if defined($want_help);
    my $visgrep = $self->heap->{visgrep};
    $connection->comMouseLeftClick($visgrep->toAbsolute($COORD_OUT->{x}, $COORD_OUT->{y}));
    $self->setState(0);
    return 0;
}
sub handlerNicoLive_delete { my ($self, $wh) = @_; return $self->handlerNicoLive_insert($wh); }

sub handlerNicoLive_page_up {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return '更新' if defined($want_help);
    my $visgrep = $self->heap->{visgrep};
    $connection->comMouseLeftClick($visgrep->toAbsolute($COORD_RELOAD->{x}, $COORD_RELOAD->{y}));
    $connection->comWaitMsec(200);
    $connection->comMouseLeftClick($visgrep->toAbsolute($COORD_COMBOX->{x}, $COORD_COMBOX->{y}));
    return 0;
}

sub handlerNicoLive_up    { my ($self, $want_help) = @_; return $self->sendString($want_help, 'www'); }
sub handlerNicoLive_home  { my ($self, $want_help) = @_; return $self->sendString($want_help, 'm9'); }
sub handlerNicoLive_left  { my ($self, $want_help) = @_; return $self->sendString($want_help, 'わこつ'); }
sub handlerNicoLive_end   { my ($self, $want_help) = @_; return $self->sendString($want_help, '初見'); }
sub handlerNicoLive_down  { my ($self, $want_help) = @_; return $self->sendString($want_help, '8888888'); }
sub handlerNicoLive_right { my ($self, $want_help) = @_; return $self->sendString($want_help, 'つこうた'); }
sub handlerNicoLive_page_down {
    my ($self, $want_help) = @_;
    return $self->sendString($want_help, '【審議中】　(　´・ω) (´・ω・) (・ω・｀) (ω・｀ )', '審議中');
}

1;
