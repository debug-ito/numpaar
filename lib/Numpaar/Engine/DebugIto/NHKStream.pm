package Numpaar::Engine::DebugIto::NHKStream;
use strict;
use base ('Numpaar::Engine::DebugIto::Firefox');
use Numpaar::Visgrep;

my $WAIT_TIME = 100;
my $COORD_PLAY = {'x' => 0, 'y' => 0};
my $COORD_OUT  = {'x' => -39, 'y' => 48};
my $COORD_SPEAKER = {'x' => 79, 'y' => -1};
my $COORD_CH1 = {'x' => 0,   'y' => -90};
my $COORD_CH2 = {'x' => 140, 'y' => -90};
my $COORD_CH3 = {'x' => 265, 'y' => -90};

sub new {
    my ($class) = @_;
    my $self = $class->setupBasic('^Navigator\.Firefox NHK語学番組 .*Mozilla Firefox$');
    $self->heap->{visgrep} = Numpaar::Visgrep->new();
    $self->heap->{'init_done'} = 0;
    return $self;
}


sub channelSelect {
    my ($self, $connection, $channel_coord) = @_;
    my $visgrep = $self->heap->{visgrep};
    if(!$self->heap->{'init_done'}) {
        return 0 if !$visgrep->setBaseFromPattern('pat_nhk_speaker.pat', $COORD_SPEAKER->{x}, $COORD_SPEAKER->{y});
        $connection->comMouseLeftClick($visgrep->toAbsolute($channel_coord->{x}, $channel_coord->{y}));
        ## $self->clickFromBase($connection, $channel_coord->{x}, $channel_coord->{y});
        $self->heap->{'init_done'} = 1;
    }else {
        $connection->comMouseLeftClick($visgrep->toAbsolute($channel_coord->{x}, $channel_coord->{y}));
        ## $self->clickFromBase($connection, $channel_coord->{x}, $channel_coord->{y});
    }
    $self->setState('NHK');
    return 1;
}

sub handlerExtended_end {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'NHK 左チャネル' if defined($want_help);
    $self->channelSelect($connection, $COORD_CH1);
    return 0;
}

sub handlerExtended_down {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'NHK 中チャネル' if defined($want_help);
    $self->channelSelect($connection, $COORD_CH2);
    return 0;
}

sub handlerExtended_page_down {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'NHK 右チャネル' if defined($want_help);
    $self->channelSelect($connection, $COORD_CH3);
    return 0;
}

sub handlerNHK_center {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return '再生/停止' if defined($want_help);
    my $visgrep = $self->heap->{visgrep};
    $connection->comMouseLeftClick($visgrep->toAbsolute($COORD_PLAY->{x}, $COORD_PLAY->{y}));
    ## $self->clickFromBase($connection, $COORD_PLAY->{x}, $COORD_PLAY->{y});
    $connection->comWaitMsec($WAIT_TIME);
    $connection->comMouseLeftClick($visgrep->toAbsolute($COORD_SPEAKER->{x}, $COORD_SPEAKER->{y}));
    ## $self->clickFromBase($connection, $COORD_SPEAKER->{x}, $COORD_SPEAKER->{y});
    return 0;
}

sub handlerNHK_insert {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'NHK OUT' if defined($want_help);
    my $visgrep = $self->heap->{visgrep};
    $connection->comMouseLeftClick($visgrep->toAbsolute($COORD_OUT->{x}, $COORD_OUT->{y}));
    ## $self->clickFromBase($connection, $COORD_OUT->{x}, $COORD_OUT->{y});
    $self->setState(0);
    $self->heap->{'init_done'} = 0;
    return 0;
}

sub handlerNHK_end       { my ($self, $want_help) = @_; return $self->handlerExtended_end      ($want_help); }
sub handlerNHK_down      { my ($self, $want_help) = @_; return $self->handlerExtended_down     ($want_help); }
sub handlerNHK_page_down { my ($self, $want_help) = @_; return $self->handlerExtended_page_down($want_help); }


1;

__END__

=pod

=head1 NAME

Numpaar::Engine::DebugIto::NHKStream - Engine for radio streaming pages of NHK

=head1 SYNOPSIS

In configuration file

 ## Load NHKStream before Firefox
 engine 'DebugIto::NHKStream';
 engine 'DebugIto::Firefox';
 
 ## This Engine uses Visgrep support module
 directory "visgrep_patterns", "/numpaar/install/path/resources/visgrep_patterns";
 extern_program 'visgrep', '/path/to/visgrep';
 extern_program 'import', '/path/to/import';


=head1 DESCRIPTION

This Engine is a child of L<Numpaar::Engine::DebugIto::Firefox> and is activated in radio streaming pages
of NHK (Japan Broadcasting Corporation) such as L<http://www.nhk.or.jp/gogaku/english/business2/index.html>.

This Engine is designed to move the mouse pointer and push some buttons like "Play/Stop",
allowing basic control of streaming without a mouse.


=head1 CONFIGURATION

As said in L</"SYNOPSIS">, this Engine uses L<Numpaar::Visgrep> support module.
The Engine uses the pattern file C<pat_nhk_speaker.pat> located in C<resources/visgrep_patterns> directory
in the Numpaar installation directory.
You have to set C<visgrep_patterns> config item to the patterns directory.


=head1 SEE ALSO

L<Numpaar::Visgrep>

=head1 AUTHOR

Toshio ITO


=cut
