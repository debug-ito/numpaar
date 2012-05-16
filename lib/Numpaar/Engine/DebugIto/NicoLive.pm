package Numpaar::Engine::DebugIto::NicoLive;
use strict;
use base ('Numpaar::Engine::DebugIto::Firefox');
use Numpaar::Config ('configGet');
use Numpaar::Visgrep;
use IO::Pipe;

my $WAIT_TIME = 100;
my $COORD_COMMENT    = {'x' => 0,    'y' => 0};
my $COORD_BATSU      = {'x' => -76,  'y' => -349};
my $COORD_PREMIUM_OK = {'x' => -5,  'y' => -366};
my $COORD_COMBOX     = {'x' => -143, 'y' => 10};
my $COORD_OUT        = {'x' => -490, 'y' => 0};
my $COORD_RELOAD     = {'x' => 50,   'y' => -24};
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

__END__

=pod

=head1 NAME

Numpaar::Engine::DebugIto::NicoLive - Engine for Nico Nico Live

=head1 SYNOPSIS

Install GreaseMonkey and video_mark.user.js (See L</"CONFIGURATION"> below).

In configuration file

 ## Load NicoLive before Firefox
 engine 'DebugIto::NicoLive';
 engine 'DebugIto::Firefox';
 
 ## This Engine uses Visgrep support module
 directory "visgrep_patterns", "/numpaar/install/path/resources/visgrep_patterns";
 extern_program 'visgrep', '/path/to/visgrep';
 extern_program 'import', '/path/to/import';

 ## This Engine uses 'xclip' to input prepared comments.
 extern_program 'xclip', '/path/to/xclip';


=head1 DESCRIPTION

This Engine is a child of L<Numpaar::Engine::DebugIto::Firefox> and is activated in live streaming pages
in Nico Nico Live L<http://live.nicovideo.jp/>.

Using this Engine, you can quickly focus on the Nico Nico Live Player, close the ad and focus on the
comment box. Then you can input prepared comments to the box from Numpaar.


=head1 CONFIGURATION

As said in L</"SYNOPSIS">, this Engine uses L<Numpaar::Visgrep> support module.
The Engine uses the pattern file C<pat_nico_comment.pat> located in C<resources/visgrep_patterns> directory
in the Numpaar installation directory.
You have to set C<visgrep_patterns> config item to the patterns directory.

You have to install GreaseMonkey addon from L<https://addons.mozilla.org/ja/firefox/addon/greasemonkey/> (You already have, haven't you?),
and install C<resources/video_mark.user.js> in the Numpaar installation directory.

And if you want to put prepared comments to the live, you have to install C<xclip> (L<http://sourceforge.net/projects/xclip/>) program.


=head1 HOW TO USE

In a live streaming page push C<Home + Up>, then the mouse pointer dances above the player
to close ads and focus on the comment box. This state is called NicoLive state.

Key bindings in the NicoLive state is as follows.

=over

=item Insert, Delete

Quit NicoLive state and go to Normal state.

=item PageUp

Reload the player.

=item Other keys

Put the comment associated to the key.

=back



=head1 SEE ALSO

L<Numpaar::Visgrep>, L<Numpaar::Firefox>

=head1 AUTHOR

Toshio ITO


=cut

