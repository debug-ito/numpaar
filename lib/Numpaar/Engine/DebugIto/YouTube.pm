package Numpaar::Engine::DebugIto::YouTube;
use strict;
use base ('Numpaar::Engine::DebugIto::Firefox', 'Numpaar::Engine::DebugIto::VideoPlayer');
use Numpaar::Visgrep;

sub new {
    my ($class) = @_;
    my $self = $class->setupBasic('^Navigator\.Firefox \[VIDEO\].*- YouTube - Mozilla Firefox$');
    ## $self->setDeferTimes();
    $self->videoPlayerSetKeys(
        play_pause     => ['ctrl+q', 'alt+p'],
        volume_up      => ['0'],
        volume_down    => ['9'],
        back_normal    => ['ctrl+q', 'bracketleft'],
        forward_normal => ['ctrl+q', 'bracketright'],
        back_big       => ['ctrl+q', 'less'],
        forward_big    => ['ctrl+q', 'greater'],
        back_small     => ['ctrl+q', 'comma'],
        forward_small  => ['ctrl+q', 'period'],
    );
    $self->heap->{visgrep} = Numpaar::Visgrep->new();
    return $self;
}

sub setVideoKeys {
    my ($self) = @_;
}

sub handlerExtended_up {
    my ($self, $want_help) = @_;
    return 'YouTube IN' if defined($want_help);
    $self->setState('Video');
    return 0;
}

## sub handlerVideo_home() { my ($self, $connection, $want_help) = @_; return $self->handlerExtended_home($want_help); }
## sub handlerVideo_page_up() { my ($self, $connection, $want_help) = @_; return $self->handlerExtended_page_up($want_help); }

sub handlerVideo_insert {
    my ($self, $want_help) = @_;
    return 'YouTube OUT' if defined($want_help);
    $self->setState(0);
    return 0;
}

sub handlerVideo_delete {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'Delete Ad' if defined($want_help);
    ## if($self->clickPattern($connection, 'pat_youtube_batsu.pat', {'x' => 2, 'y' => 2}, undef, {'x' => 0, 'y' => 0})) {
    my $visgrep = $self->heap->{visgrep};
    if($visgrep->setBaseFromPattern('pat_youtube_batsu.pat', 0, 0)) {
        $connection->comMouseLeftClick($visgrep->toAbsolute(2, 2));
        $connection->comWaitMsec(200);
        $connection->comMouseLeftClick($visgrep->toAbsolute(-570, 0));
    }
    return 0;
}

1;


