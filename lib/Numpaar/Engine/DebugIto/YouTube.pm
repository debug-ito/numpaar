package Numpaar::Engine::DebugIto::YouTube;
use strict;
use base ('Numpaar::Engine::DebugIto::Firefox', 'Numpaar::Engine::DebugIto::VideoPlayer', 'Numpaar::Visgrep');

sub new {
    my ($class) = @_;
    my $self = $class->setupBasic('^Navigator\.Firefox \[VIDEO\].*- YouTube - Mozilla Firefox$');
    $self->setDeferTimes();
    $self->setVideoKeys();
    return $self;
}

sub setVideoKeys {
    my ($self) = @_;
    $self->{'play_pause'}     = ['ctrl+q', 'alt+p'];
    $self->{'volume_up'}      = ['0'];
    $self->{'volume_down'}    = ['9'];
    $self->{'back_normal'}    = ['ctrl+q', 'bracketleft'];
    $self->{'forward_normal'} = ['ctrl+q', 'bracketright'];
    $self->{'back_big'}       = ['ctrl+q', 'less'];
    $self->{'forward_big'}    = ['ctrl+q', 'greater'];
    $self->{'back_small'}     = ['ctrl+q', 'comma'];
    $self->{'forward_small'}  = ['ctrl+q', 'period'];
}

sub handlerExtended_up {
    my ($self, $connection, $want_help) = @_;
    return 'YouTube IN' if defined($want_help);
    $self->changeToState($connection, 'Video');
    return 0;
}

## sub handlerVideo_home() { my ($self, $connection, $want_help) = @_; return $self->handlerExtended_home($connection, $want_help); }
## sub handlerVideo_page_up() { my ($self, $connection, $want_help) = @_; return $self->handlerExtended_page_up($connection, $want_help); }

sub handlerVideo_insert {
    my ($self, $connection, $want_help) = @_;
    return 'YouTube OUT' if defined($want_help);
    $self->changeToState($connection, 0);
    return 0;
}

sub handlerVideo_delete {
    my ($self, $connection, $want_help) = @_;
    return 'Delete Ad' if defined($want_help);
    ## if($self->clickPattern($connection, 'pat_youtube_batsu.pat', {'x' => 2, 'y' => 2}, undef, {'x' => 0, 'y' => 0})) {
    if($self->setBase('pat_youtube_batsu.pat', {'x' => 0, 'y' => 0})) {
        $self->clickFromBase($connection, {'x' => 2, 'y' => 2});
        $connection->comWaitMsec(200);
        $self->clickFromBase($connection, {'x' => -570, 'y' => 0});
    }
    return 0;
}

1;


