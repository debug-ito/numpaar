package Numpaar::Engine::DebugIto::Ustream;
use strict;
use base ('Numpaar::Engine::DebugIto::Firefox');
use Numpaar::Visgrep;


my $COORD_FULL = {'x' => 0, 'y' => 0};
my $COORD_OUT  = {'x' => 0, 'y' => 30};

sub new {
    my ($class) = @_;
    my $self = $class->setupBasic('^Navigator\.Firefox USTREAM:');
    $self->heap->{visgrep} = Numpaar::Visgrep->new();
    return $self;
}

sub handlerExtended_up {
    my ($self, $want_help) = @_;
    return 'UST IN' if defined($want_help);
    my $connection = $self->getConnection();
    my $status_if = $self->getStatusInterface();
    $status_if->changeStatusIcon("busy");
    my $visgrep = $self->heap->{visgrep};
    ## my $ret = $self->clickPattern($connection, 'pat_ust_full.pat', {'x' => 3, 'y' => 3}, undef, $COORD_FULL);
    my $ret = $visgrep->setBaseFromPattern('pat_ust_full.pat', $COORD_FULL->{x}, $COORD_FULL->{y});
    if(!$ret) {
        $status_if->changeStatusIcon("normal");
        return 0;
    }
    $connection->comMouseLeftClick($visgrep->toAbsolute(3, 3));
    $self->setState('Ust');
    $status_if->changeStatusIcon("normal");
    return 0;
}

sub handlerUst_insert {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'Ust OUT' if defined($want_help);
    $connection->comKeyString('Escape');
    $connection->comWaitMsec(500);
    $connection->comMouseLeftClick($self->heap->{visgrep}->toAbsolute($COORD_OUT->{x}, $COORD_OUT->{y}));
    $self->setState(0);
    return 0;
}

1;
