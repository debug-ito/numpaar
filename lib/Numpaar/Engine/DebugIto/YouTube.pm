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


__END__

=pod

=head1 NAME

Numpaar::Engine::DebugIto::YouTube - Engine for YouTube

=head1 SYNOPSIS

Install GreaseMonkey, video_mark.user.js and You keyboard junky (See L</"CONFIGURATION"> below).

In configuration file

 ## Load YouTube before Firefox
 engine 'DebugIto::YouTube';
 engine 'DebugIto::Firefox';

 
=head1 DESCRIPTION

This Engine is a child of L<Numpaar::Engine::DebugIto::Firefox> and is activated in YouTube L<http://www.youtube.com/> video pages.

Using this Engine, you can operate YouTube videos.
Most of the keybindings for operation are provided by L<Numpaar::Engine::DebugIto::VideoPlayer> module.


=head1 CONFIGURATION

This engine requires you to install GreaseMonkey addon
from L<https://addons.mozilla.org/ja/firefox/addon/greasemonkey/>,
and the following two userscripts.

=over

=item 1.

video_mark.user.js. This is available under C<resources> directory in the Numpaar installation package.

=item 2.

You keyboard junky from L<http://userscripts.org/scripts/show/62017>.

=back


=head1 Keybindings

Type C<Home + Up> to enter the Video state to operate video playback.

In the video state, C<Insert> will brings you back to the normal Firefox state.

See L<Numpaar::Engine::DebugIto::VideoPlayer> for keybindings for video operation.



=head1 SEE ALSO

L<Numpaar::Engine::DebugIto::Firefox>, L<Numpaar::Engine::DebugIto::VideoPlayer>

=head1 AUTHOR

Toshio ITO


=cut



