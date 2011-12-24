package Numpaar::Engine::DebugIto::Stickam;
use strict;
use base ('Numpaar::Engine::DebugIto::Firefox', 'Numpaar::Visgrep');

my $COORD_PASTE_BUTTON = {'x' => 0, 'y' => 0};
my $COORD_OUT = {'x' => -10, 'y' => 0};
my $COORD_START = {'x' => 101, 'y' => -117};

sub new {
    my ($class) = @_;
    my $self = $class->setupBasic('^Navigator\.Firefox .*Stickam .*Firefox$');
    ## $self->setDeferTimes();
    return $self;
}

sub handlerExtended_up {
    my ($self, $connection, $want_help) = @_;
    return 'ステカム 開始' if defined($want_help);
    if($self->setBaseFromPattern('pat_stickam_paste.pat', $COORD_PASTE_BUTTON->{x}, $COORD_PASTE_BUTTON->{y})) {
        $self->clickFromBase($connection, $COORD_START->{x}, $COORD_START->{y});
        $connection->comWaitMsec(100);
        $self->clickFromBase($connection, $COORD_OUT->{x}, $COORD_OUT->{y});
    }
    $self->setState(0, $connection);
    return 0;
}


