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


sub new {
    my ($class) = @_;
    my $self = $class->setupBasic('^Navigator\.Firefox .* ニコニコ生放送 - Mozilla Firefox$');
    $self->initVisgrep(0, 0);
    $self->setDeferTimes();
    return $self;
}

sub sendString {
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

sub handlerExtended_up {
    my ($self, $connection, $want_help, $status_pipe) = @_;
    return 'ニコ生 IN' if defined($want_help);
    $self->changeStatusIcon($status_pipe, 'busy');
    my $ret = $self->setBaseFromPattern('pat_nico_comment.pat', $COORD_COMMENT->{x}, $COORD_COMMENT->{y});
    if(!$ret) {
        $self->changeStatusIcon($status_pipe, 'normal');
        return 0;
    }
    $self->clickFromBase($connection, $COORD_PREMIUM_OK->{x}, $COORD_PREMIUM_OK->{y});
    $connection->comWaitMsec($WAIT_TIME);
    $self->clickFromBase($connection, $COORD_BATSU->{x}, $COORD_BATSU->{y});
    $connection->comWaitMsec($WAIT_TIME);
    $self->clickFromBase($connection, $COORD_COMERROR_BATSU->{x}, $COORD_COMERROR_BATSU->{y});
    $connection->comWaitMsec($WAIT_TIME);
    $self->clickFromBase($connection, $COORD_COMBOX->{x}, $COORD_COMBOX->{y});
    $self->setState('NicoLive', $connection);
    $self->changeStatusIcon($status_pipe, 'normal');
    return 0;
}

sub handlerNicoLive_insert {
    my ($self, $connection, $want_help) = @_;
    return 'ニコ生 OUT' if defined($want_help);
    $self->clickFromBase($connection, $COORD_OUT->{x}, $COORD_OUT->{y});
    $self->setState(0, $connection);
    return 0;
}
sub handlerNicoLive_delete { my ($self, $conn, $wh) = @_; return $self->handlerNicoLive_insert($conn, $wh); }

sub handlerNicoLive_page_up {
    my ($self, $connection, $want_help) = @_;
    return '更新' if defined($want_help);
    $self->clickFromBase($connection, $COORD_RELOAD->{x}, $COORD_RELOAD->{y});
    $connection->comWaitMsec(200);
    $self->clickFromBase($connection, $COORD_COMBOX->{x}, $COORD_COMBOX->{y});
    return 0;
}

sub handlerNicoLive_up { my ($self, $connection, $want_help) = @_; return $self->sendString($connection, $want_help, 'www'); }
sub handlerNicoLive_home { my ($self, $connection, $want_help) = @_; return $self->sendString($connection, $want_help, 'm9'); }
sub handlerNicoLive_left { my ($self, $connection, $want_help) = @_; return $self->sendString($connection, $want_help, 'わこつ'); }
sub handlerNicoLive_end { my ($self, $connection, $want_help) = @_; return $self->sendString($connection, $want_help, '初見'); }
sub handlerNicoLive_down { my ($self, $connection, $want_help) = @_; return $self->sendString($connection, $want_help, '8888888'); }
sub handlerNicoLive_right { my ($self, $connection, $want_help) = @_; return $self->sendString($connection, $want_help, 'つこうた'); }
sub handlerNicoLive_page_down {
    my ($self, $connection, $want_help) = @_;
    return $self->sendString($connection, $want_help, '【審議中】　(　´・ω) (´・ω・) (・ω・｀) (ω・｀ )', '審議中');
}

1;
