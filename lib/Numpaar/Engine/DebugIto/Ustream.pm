package Numpaar::Engine::DebugIto::Ustream;
use strict;
use base ('Numpaar::Engine::DebugIto::Firefox', 'Numpaar::Visgrep');

my $COORD_FULL = {'x' => 0, 'y' => 0};
my $COORD_OUT  = {'x' => 0, 'y' => 30};

sub new {
    my ($class) = @_;
    my $self = $class->setupBasic('^Navigator\.Firefox USTREAM:');
    return $self;
}

sub mapExtended_up() {
    my ($self, $connection, $want_help, $status_pipe) = @_;
    return 'UST IN' if defined($want_help);
    $self->changeStatusIcon($status_pipe, "busy");
    ## my $ret = $self->clickPattern($connection, 'pat_ust_full.pat', {'x' => 3, 'y' => 3}, undef, $COORD_FULL);
    my $ret = $self->setBase('pat_ust_full.pat', $COORD_FULL);
    if(!$ret) {
        $self->changeStatusIcon($status_pipe, "normal");
        return 0;
    }
    $self->clickFromBaser($connection, {'x' => 3, 'y' => 3});
    $self->changeToState($connection, 'Ust');
    $self->changeStatusIcon($status_pipe, "normal");
    return 0;
}

sub mapUst_insert() {
    my ($self, $connection, $want_help) = @_;
    return 'Ust OUT' if defined($want_help);
    $connection->comKeyString('Escape');
    $connection->comWaitMsec(500);
    $self->clickFromBase($connection, $COORD_OUT);
    $self->changeToState($connection, 0);
    return 0;
}

1;
