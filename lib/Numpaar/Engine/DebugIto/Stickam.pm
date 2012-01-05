package Numpaar::Engine::DebugIto::Stickam;
use strict;
use base ('Numpaar::Engine::DebugIto::Firefox');
use Numpaar::Visgrep;

my $COORD_PASTE_BUTTON = {'x' => 0, 'y' => 0};
my $COORD_OUT = {'x' => -10, 'y' => 0};
my $COORD_START = {'x' => 101, 'y' => -117};

sub new {
    my ($class) = @_;
    my $self = $class->setupBasic('^Navigator\.Firefox .*Stickam .*Firefox$');
    $self->heap->{visgrep} = Numpaar::Visgrep->new();
    return $self;
}

sub handlerExtended_up {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'ステカム 開始' if defined($want_help);
    my $visgrep = $self->heap->{visgrep};
    if($visgrep->setBaseFromPattern('pat_stickam_paste.pat', $COORD_PASTE_BUTTON->{x}, $COORD_PASTE_BUTTON->{y})) {
        $connection->comMouseLeftClick($visgrep->toAbsolute($COORD_START->{x}, $COORD_START->{y}));
        $connection->comWaitMsec(100);
        $connection->comMouseLeftClick($visgrep->toAbsolute($COORD_OUT->{x}, $COORD_OUT->{y}));
    }
    $self->setState(0);
    return 0;
}


