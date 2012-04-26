package Numpaar::Engine::DebugIto::Firefox;
use strict;
use base "Numpaar::Engine";

our $keys_link = ['ctrl+u', 'e'];
our $keys_link_newtab = ['ctrl+u', 'shift+e'];
our $keys_left_tab = ['ctrl+Page_Up'];
our $keys_right_tab = ['ctrl+Page_Down'];
our $keys_close_tab = ['ctrl+q', 'ctrl+w'];
our $keys_restore_tab = ['ctrl+c', 'u'];
our $keys_focus_frame = ['ctrl+u', 'ctrl+c', 'ctrl+f'];

our $keys_back = ['shift+b'];
our $keys_forward = ['shift+f'];
our $keys_bookmark  = ['ctrl+q', 'ctrl+b'];
our $keys_bookmark_finish = ['ctrl+Return', 'ctrl+q', 'ctrl+b'];
our $keys_bookmark_cancel = ['ctrl+q', 'ctrl+b'];
our $keys_fontsize_increase = ['ctrl+q', 'ctrl+plus'];
our $keys_fontsize_decrease = ['ctrl+q', 'ctrl+minus'];
our $keys_fontsize_normal   = ['ctrl+q', 'ctrl+0'];
our $keys_reload = ['F5'];
our $keys_home = ['alt+Home'];
our $defer_immediate = 300;
our $defer_load = 1500;

sub new {
    my ($class) = @_;
    my $self = $class->setupBasic('^Navigator\.Firefox');
    return $self;
}

sub setupBasic {
    my ($class, $pattern) = @_;
    my $self = $class->SUPER::setupBasic($pattern);
    return $self;
}

sub updateLoad {
    my $self = shift;
    $self->getConnection()->comUpdateActive($defer_load);
}

sub updateImmediate {
    my $self = shift;
    $self->getConnection()->comUpdateActive($defer_immediate);
}


sub handler0_left {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'Left tab' if defined($want_help);
    $connection->comKeyString(@$keys_left_tab);
    $self->updateImmediate();
    return 0;
}

sub handler0_right {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'Right tab' if defined($want_help);
    $connection->comKeyString(@$keys_right_tab);
    $self->updateImmediate();
    return 0;
}

sub handler0_end {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'Close tab' if defined($want_help);
    $connection->comKeyString(@$keys_close_tab);
    $self->updateImmediate();
    return 0;
}

sub handler0_insert {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'Bookmark' if defined($want_help);
    $connection->comKeyString(@$keys_bookmark);
    $self->setState('BookMark');
    return 0;
}

sub handler0_center {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'Link' if defined($want_help);
    $connection->comKeyString(@$keys_link);
    $self->setState('Link');
    $self->heap->{'doAfterLink'} = 0;
    return 0;
}

sub handler0_home {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'Ext.' if defined($want_help);
    $self->setState('Extended');
    return 0;
}

sub handlerBookMark_center {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'OK' if defined($want_help);
    $connection->comKeyString(@$keys_bookmark_finish);
    $self->setState(0);
    $self->updateLoad();
    return 0;
}

sub handlerBookMark_insert {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'Cancel' if defined($want_help);
    $connection->comKeyString(@$keys_bookmark_cancel);
    $self->setState(0);
    return 0;
}

sub handlerBookMark_end {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'Tab' if defined($want_help);
    $connection->comKeyString("Tab");
    return 0;
}

sub handlerBookMark_home {
    my ($self, $want_help) = @_; return $self->handlerBookMark_insert($want_help);
}

sub handlerBookMark_delete {
    my ($self, $want_help) = @_; return $self->handlerBookMark_insert($want_help);
}

sub handlerLink_up {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'OK' if defined($want_help);
    $connection->comKeyString('Return');
    $self->setState(0);
    $self->updateLoad();
    if($self->heap->{'doAfterLink'}) {
        &{$self->heap->{'doAfterLink'}}($self, $connection);
    }
    return 0;
}

sub handlerLink_left {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return '4' if defined($want_help);
    $connection->comKeyString('4');
    return 0;
}

sub handlerLink_center {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return '5' if defined($want_help);
    $connection->comKeyString('5');
    return 0;
}

sub handlerLink_right {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return '6' if defined($want_help);
    $connection->comKeyString('6');
    return 0;
}

sub handlerLink_down {
    my ($self, $want_help) = @_;
    return $self->handlerLink_up($want_help);
}

sub handlerLink_home {
    my ($self, $want_help) = @_;
    return $self->handler_delete($want_help);
}

sub handlerLink_page_up {
    my ($self, $want_help) = @_;
    return $self->handler_delete($want_help);
}

sub handlerLink_end {
    my ($self, $want_help) = @_;
    return $self->handler_delete($want_help);
}

sub handlerLink_page_down {
    my ($self, $want_help) = @_;
    return $self->handler_delete($want_help);
}

sub handlerLink_insert {
    my ($self, $want_help) = @_;
    return $self->handler_delete($want_help);
}

sub handlerExtended_home {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'Link (new tab)' if defined($want_help);
    $connection->comKeyString(@$keys_link_newtab);
    $self->setState('Link');
    $self->heap->{'doAfterLink'} = 0;
    return 0;
}

sub handlerExtended_left {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'Back' if defined($want_help);
    $connection->comKeyString(@$keys_back);
    $self->updateLoad();
    $self->setState(0);
    return 0;
}

sub handlerExtended_right {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'Forward' if defined($want_help);
    $connection->comKeyString(@$keys_forward);
    $self->updateLoad();
    $self->setState(0);
    return 0;
}

sub handlerExtended_up {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'Larger font' if defined($want_help);
    $connection->comKeyString(@$keys_fontsize_increase);
    $self->setState("FontSize");
    return 0;
}

sub handlerExtended_down {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'Smaller font' if defined($want_help);
    $connection->comKeyString(@$keys_fontsize_decrease);
    $self->setState("FontSize");
    return 0;
}

sub handlerExtended_page_up {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'Reload' if defined($want_help);
    $connection->comKeyString(@$keys_reload);
    $self->updateLoad();
    $self->setState(0);
    return 0;
}

sub handlerExtended_page_down {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'Home' if defined($want_help);
    $connection->comKeyString(@$keys_home);
    $self->updateLoad();
    $self->setState(0);
    return 0;
}

sub handlerExtended_center {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'Normal font' if defined($want_help);
    $connection->comKeyString(@$keys_fontsize_normal);
    $self->setState(0);
    return 0;
}

## sub afterStringCopy {
##     my ($self, $connection) = @_;
##     $connection->comKeyString('ctrl+x', "g", "ctrl+a", "space", "Left");
##     $self->setState("Search");
## }
## 
## sub handlerExtended_insert {
##     my ($self, $want_help) = @_;
##     my $connection = $self->getConnection();
##     return '文字列コピー' if defined($want_help);
##     $connection->comKeyType(';Y');
##     $self->setState('Link');
##     $self->heap->{'doAfterLink'} = \&afterStringCopy;
##     return 0;
## }

sub handlerExtended_insert {
    my ($self, $want_help) = @_;
    return 'Focus on a frame' if defined($want_help);
    $self->getConnection()->comKeyString(@$keys_focus_frame);
    $self->setState('Link');
    $self->heap->{'doAfterLink'} = 0;
    return 0;
}

sub handlerExtended_end {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'Restore tab' if defined($want_help);
    $connection->comKeyString(@$keys_restore_tab);
    $self->updateLoad();
    $self->setState(0);
    return 0;
}

sub handlerFontSize_center {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'End' if defined($want_help);
    $self->setState(0);
    return 0;
}

sub handlerFontSize_up   { my ($self, $want_help) = @_; return $self->handlerExtended_up  ($want_help); }
sub handlerFontSize_down { my ($self, $want_help) = @_; return $self->handlerExtended_down($want_help); }
sub handlerFontSize_home { my ($self, $want_help) = @_; return $self->handlerFontSize_center($want_help); }
sub handlerFontSize_end { my ($self, $want_help) = @_; return $self->handlerFontSize_center($want_help); }
sub handlerFontSize_left { my ($self, $want_help) = @_; return $self->handlerFontSize_center($want_help); }
sub handlerFontSize_right { my ($self, $want_help) = @_; return $self->handlerFontSize_center($want_help); }
sub handlerFontSize_page_up { my ($self, $want_help) = @_; return $self->handlerFontSize_center($want_help); }
sub handlerFontSize_page_down { my ($self, $want_help) = @_; return $self->handlerFontSize_center($want_help); }
sub handlerFontSize_insert { my ($self, $want_help) = @_; return $self->handlerFontSize_center($want_help); }

## sub handlerSearch_page_up {
##     my ($self, $want_help) = @_;
##     my $connection = $self->getConnection();
##     return '前の検索エンジン' if defined($want_help);
##     $connection->comKeyString('ctrl+Up');
##     return 0;
## }
## 
## sub handlerSearch_page_down {
##     my ($self, $want_help) = @_;
##     my $connection = $self->getConnection();
##     return '次の検索エンジン' if defined($want_help);
##     $connection->comKeyString('ctrl+Down');
##     return 0;
## }
## 
## sub handlerSearch_up {
##     my ($self, $want_help) = @_;
##     my $connection = $self->getConnection();
##     return 'Backspace' if defined($want_help);
##     $connection->comKeyString('BackSpace');
##     return 0;
## }
## 
## sub handlerSearch_home {
##     my ($self, $want_help) = @_;
##     my $connection = $self->getConnection();
##     return 'クリアして貼り付け' if defined($want_help);
##     $connection->comKeyString('ctrl+a', 'ctrl+k', 'ctrl+y', 'alt+y');
##     return 0;
## }
## 
## sub handlerSearch_end {
##     my ($self, $want_help) = @_;
##     my $connection = $self->getConnection();
##     return '貼り付け' if defined($want_help);
##     $connection->comKeyString('ctrl+y');
##     return 0;
## }
## 
## sub handlerSearch_center {
##     my ($self, $want_help) = @_;
##     my $connection = $self->getConnection();
##     return '検索' if defined($want_help);
##     $connection->comKeyString('Return');
##     $self->updateLoad();
##     $self->setState(0);
##     return 0;
## }

sub handler_delete {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'Cancel' if defined($want_help);
    $connection->comKeyString('ctrl+g');
    $self->setState(0);
    return 0;
}

1;

__END__

=pod

=head1 NAME

Numpaar::Engine::DebugIto::Firefox - Engine for Firefox

=head1 SYNOPSIS

In configuration file

  engine 'DebugIto::Firefox';
  
  ## Configure key sequences if necessary
  engine_config 'DebugIto::Firefox',
      keys_link =>   ['ctrl+e'],
      restore_tab => ['ctrl+x', 'ctrl+u'];


=head1 DESCRIPTION

This Numpaar Engine is activated for Firefox, a Web browser.
With the help of some addons for Firefox (see L<"PREREQUISITES"> below),
this engine makes it possible to do the following with a number pad:

=over

=item *

Navigate through web pages vertically.

=item *

Navigate through links (in the current tab and/or a new tab).

=item *

Switch tabs.

=item *

Close and restore tabs.

=item *

Select buttons, frames and other controls.

=item *

Visit bookmarked web site in a new tab.

=item *

Move back and forward in browsing history.

=item *

Change font size.

=item *

Visit home.

=item *

Reload.

=back


Based on this module, there are some Engines for specific web sites such as YouTube and NicoNico Douga.
(L<"SEE ALSO"> section lists them)


=head1 PREREQUISITES

In order to use DebugIto::Firefox engine, you need to install the following two packages into your Firefox.

=over

=item 1.

Keysnail: https://github.com/mooz/keysnail/wiki

=item 2.

HoK (modified for Numpaar): https://raw.github.com/debug-ito/keysnail/master/plugins/hok.ks.js

=back

First you need B<Keysnail>, an awesome addon for Firefox.
Keysnail constructs an Emacs-like environment on top of Firefox, so you can do almost every operation
on Firefox with Emacs-like key sequences.
Numpaar translates push events on number pad keys to these key sequences, which are handled by Keysnail.

  User --[Push on number pad keys]--> Numpaar --[Key sequences]--> Keysnail --[operation]--> Firefox

Second you need B<HoK>, which is a plugin for Keysnail.
HoK provides a way to select links, buttons, frames and many other objects in a browser WITHOUT a mouse.
It operates like this:

=over

=item 1.

When browsing, hit 'e' key to start HoK.

=item 2.

HoK searches the current view of the web page for links and other clickable objects.

=item 3.

For each link, HoK assigns a hint string and shows it near the link.

=item 4.

Then you hit the hint string for the link you want to select.

=item 5.

HoK selects the link for you and go to the next page.

=back

Numpaar relies on HoK to select the links.

When you use Keysnail and HoK, you can customize their keybindings freely, but in this case you have to
configure DebugIto::Firefox Engine to emit the correct key sequences (See L<"CONFIGURATION"> for detail).
The default configuration of this Engine emits the key sequences that are the default (or recommended) by Keysnail and HoK.


B<NOTE>: The original version of HoK does not work well with Numpaar,
so I modified its code a bit. Use the modified version of HoK shown above.

=over

The original HoK: https://raw.github.com/mooz/keysnail/master/plugins/hok.ks.js

=back


=head1 ENGINE STATES

Basically DebugIto::Firefox engine has two states: normal and extended.

=head2 Normal state

Normal state is the default.

You can use Up, Down, PageUp and PageDown for page navigation.
The other keys are bound to the following operations.


=over

=item Home:

Enter the extended state.

=item End:

Close the current tab.

=item Left:

Go to the tab on the left.

=item Right:

Go to the tab on the right.

=item Center (5):

Select and open link in the current tab.

=item Insert:

Show bookmarks to select.

=item Delete:

Cancel

=back


=head2 Extended state

You can enter the extended state by hitting Home in the normal state.
In the extended state, you can do the following operations.

=over

=item Home:

Select and open link in a new tab.

=item End:

Restore the most recently closed tab.

=item Left:

Go back in the browsing history.

=item Right:

Go forward in the browsing history.

=item Up:

Make font size larger.

=item Center (5):

Make font size normal.

=item Down:

Make font size smaller.

=item PageUp:

Reload the current page.

=item PageDown:

Go home.

=item Insert:

Select a frame.

=item Delete:

Cancel and go to the normal state.

=back


=head1 HOW TO USE

In the following usage guide, B<BUTTON1 + BUTTON2> means "hit B<BUTTON1> followed by B<BUTTON2>".


=head2 Cancel operation

B<Delete> key is always assigned to "cancel the current operation and go to the normal mode".
When you think something weird is going on, just hit B<Delete> several times,
as you would hit C-g when you use Emacs.

=head2 Page navigation

You can navigate through web pages with B<Up>, B<Down>, B<PageUp> and B<PageDown> in the normal mode.
Note that you cannot use B<Home> and B<End>, which are assigned to other functions.

Note also that you cannot navigate horizontally with Numpaar.


=head2 Links

To select a link (or any clickable object), hit B<Center (5)> key in the normal mode.
This starts HoK, which shows hint strings near links in the page.
Hint strings consist of 4, 5, and 6, so hit the number sequences you want to select,
then hit B<Up> or B<Down> to end input.

If you want to go to a link in a new tab, hit B<Home + Home> in the normal mode.


=head2 Browsing history, reload and home

You can go back and forward in the browsing history by hitting B<Home + Left> and B<Home + Right>, respectively.

To reload the current page, hit B<Home + PageUp>.

To go to your home page, hit B<Home + PageDown>.


=head2 Tabs

You can use B<Left> and B<Right> to switch tabs.

To close the currently selected tab, hit B<End>.
The closed tab can be restored by hitting B<Home + End>.


=head2 Bookmarks

To open a bookmark, first hit B<Insert> to open the bookmark pane.
The key focus is initially on the text box for searching, so hit B<End> once to move the focus onto the bookmarks tree view.
Once you focus on the tree view, you can navigate through the list with B<Up>, B<Down>, B<Left>, B<Right>, B<PageUp>, B<PageDown>,
then select a bookmark with B<Center (5)>.
To cancel this operation, hit B<Insert> or B<Delete>.

Note that if you hit B<End> more than once after hitting B<Insert>,
you may move the focus too much and so cannot move the cursor in the bookmark pane.
If you are in this situation, just hit B<Insert> or B<Delete> to cancel.


=head2 Font size

To make font size larger, first hit B<Home + Up>, then repeatedly hit B<Up> until it's big enough, and finally hit B<Center (5)> to end.
Making font size smaller is the same except that you have to hit B<Down> instead of B<Up>.

To reset the font size to normal, hit B<Home + Center (5)>.


=head2 Frames

Some nasty web sites use frames. In this case hit B<Home + Insert>, then HoK shows hint strings for all visible frames.
Hit the hint string you want to select, and hit B<Up> to finish.

=head1 CONFIGURATION

=head2 engine_config parameters

The following C<engine_config> parameters are defined in DebugIto::Firefox Engine
to configure the key sequences it emits.

=over

=item keys_link (default: ['ctrl+u', 'e'])

The key sequence emitted on "Link" operation (B<Center (5)>).

=item keys_link_newtab (default: ['ctrl+u', 'shift+e'])

The key sequence emitted on "Link (new tab)" operation (B<Home + Home>).

=item keys_left_tab (default: ['ctrl+Page_Up'])

The key sequence emitted on "Left tab" operation (B<Left>).

=item keys_right_tab (default: ['ctrl+Page_Down'])

The key sequence emitted on "Right tab" operation (B<Right>).

=item keys_close_tab (default: ['ctrl+q', 'ctrl+w'])

The key sequence emitted on "Close tab" operation (B<End>).

=item keys_restore_tab (default: ['ctrl+c', 'u'])

The key sequence emitted on "Restore tab" operation (B<Home + End>).

=item keys_focus_frame (default: ['ctrl+u', 'ctrl+c', 'ctrl+f'])

The key sequence emitted on "Focus on a frame" operation (B<Home + Insert>).

=item keys_back (default: ['shift+b'])

The key sequence emitted on "Back" operation (B<Home + Left>).

=item keys_forward (default: ['shift+f'])

The key sequence emitted on "Forward" operation (B<Home + Right>).

=item keys_bookmark (default: ['ctrl+q', 'ctrl+b'])

The key sequence emitted on "Bookmark" operation (B<Insert>).

=item keys_bookmark_finish (default: ['ctrl+Return', 'ctrl+q', 'ctrl+b'])

The key sequence emitted on selecting a bookmark entry (B<Center (5)> in Bookmark state).

=item keys_bookmark_cancel (default: ['ctrl+q', 'ctrl+b'])

The key sequence emitted on canceling Bookmark state.

=item keys_fontsize_increase (default: ['ctrl+q', 'ctrl+plus'])

The key sequence emitted on "Larger font" operation (B<Home + Up>).

=item keys_fontsize_decrease (default: ['ctrl+q', 'ctrl+minus'])

The key sequence emitted on "Smaller font" operation (B<Home + Down>).

=item keys_fontsize_normal (default: ['ctrl+q', 'ctrl+0'])

The key sequence emitted on "Normal font" operation (B<Home + Center (5)>).

=item keys_reload (default: ['F5'])

The key sequence emitted on "Reload" operation (B<Home + PageUp>).

=item keys_home (default: ['alt+Home'])

The key sequence emitted on "Home" operation (B<Home + PageDown>).

=back



=head1 SEE ALSO

L<Numpaar::Engine::DebugIto::YouTube>,
L<Numpaar::Engine::DebugIto::NicoLive>,
L<Numpaar::Engine::DebugIto::NicoVideo>

=head1 AUTHOR

Toshio ITO

=cut
