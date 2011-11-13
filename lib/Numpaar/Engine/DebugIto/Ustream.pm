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

sub handlerExtended_up {
    my ($self, $connection, $want_help, $status_if) = @_;
    return 'UST IN' if defined($want_help);
    $status_if->changeStatusIcon("busy");
    ## my $ret = $self->clickPattern($connection, 'pat_ust_full.pat', {'x' => 3, 'y' => 3}, undef, $COORD_FULL);
    my $ret = $self->setBaseFromPattern('pat_ust_full.pat', $COORD_FULL->{x}, $COORD_FULL->{y});
    if(!$ret) {
        $status_if->changeStatusIcon("normal");
        return 0;
    }
    $self->clickFromBase($connection, 3, 3);
    $self->setState('Ust', $connection);
    $status_if->changeStatusIcon("normal");
    return 0;
}

sub handlerUst_insert {
    my ($self, $connection, $want_help) = @_;
    return 'Ust OUT' if defined($want_help);
    $connection->comKeyString('Escape');
    $connection->comWaitMsec(500);
    $self->clickFromBase($connection, $COORD_OUT->{x}, $COORD_OUT->{y});
    $self->setState(0, $connection);
    return 0;
}

1;
