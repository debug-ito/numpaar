package Numpaar::Connection;

use strict;
use IO::Socket::UNIX;
use IO::Select;

sub new {
    my ($class, $port) = @_;
    my $self = {
        'port' => $port,
    };
    return bless $self, $class;
}

sub init {
    my ($self) = @_;
    $self->{'conn_sock'} = IO::Socket::UNIX->new(Type => SOCK_STREAM, Peer => $self->{'port'});
    if(!defined($self->{'conn_sock'})) {
        return 0;
    }
    ## if(!$self->{'conn_sock'}->connect($self->{'port'})) {
    ##     print STDERR "Cannot connect to " . $self->{'port'} . ".\n";
    ##     return 0;
    ## }
    return 1;
}

sub getLine {
    my ($self) = @_;
    return $self->{'conn_sock'}->getline();
}

sub getEvent {
    my ($self) = @_;
    my $GET_LINE_NUM = 4;
    my @notifylines = ();
    for(my $i = 0 ; $i < $GET_LINE_NUM ; $i++) {
        $notifylines[$i] = $self->getLine();
        if(!defined($notifylines[$i])) {
            print STDERR "Connection to Numpaar core has been closed.\n";
            exit 0;
        }
        chomp $notifylines[$i];
        print STDERR "<<NOT ".$notifylines[$i]."\n";
    }
    my ($command_event, $channel_number, $window_id, $window_desc) = @notifylines;
    return ($command_event, $channel_number, $window_id, $window_desc);
}

sub print {
    my ($self, @strings) = @_;
    $self->{'conn_sock'}->print(@strings);
}

sub end {
    my ($self) = @_;
    $self->{'conn_sock'}->print("end\n");
    $self->{'conn_sock'}->flush();
}

sub close {
    my ($self) = @_;
    if(defined($self->{'conn_sock'})) {
        $self->{'conn_sock'}->close();
        $self->{'conn_sock'} = undef;
    }
}

sub multiCommands {
    my ($self, $command, @args) = @_;
    my $retstr = "";
    foreach my $arg (@args) {
        $retstr .= "$command,$arg\n";
    }
    $self->{'conn_sock'}->print($retstr);
}

sub comKeyString {
    my ($self, @keyseqs) = @_;
    $self->multiCommands('xdokey', @keyseqs);
}

sub comKeyType {
    my ($self, @keytypes) = @_;
    foreach my $keytype (@keytypes) {
        my @vals = unpack("C*", $keytype);
        my $encoded_str = "";
        foreach my $val (@vals) {
            $encoded_str .= sprintf("%02x", $val);
        }
        $self->{'conn_sock'}->print("xdotype,$encoded_str\n");
    }
}

sub comKeyGrabSetOn {
    my ($self, @keylist) = @_;
    my $ret_str = "keygrabseton";
    foreach my $grab_key (@keylist) {
        $ret_str .= ",$grab_key";
    }
    $self->{'conn_sock'}->print($ret_str . "\n");
}

sub comWaitMsec {
    my ($self, $wait_msec) = @_;
    $self->{'conn_sock'}->printf("waitmsec,%d\n", $wait_msec);
}

sub comUpdateActive {
    my ($self, $defer_time_msec) = @_;
    $self->{'conn_sock'}->printf("updateactive,%d\n", $defer_time_msec);
}

sub comMouseClick {
    my ($self, $button, $x, $y) = @_;
    if(!defined($button)) {
        $button = 0;
    }
    if(!defined($x) || !defined($y)) {
        $x = $y = -1;
    }
    $self->{'conn_sock'}->printf("mouseclick,%d,%d,%d\n", $button, $x, $y);
}

sub comMouseMove         { my ($self, $x, $y) = @_; $self->comMouseClick(0, $x, $y); }
sub comMouseLeftClick    { my ($self, $x, $y) = @_; $self->comMouseClick(1, $x, $y); }
sub comMouseMiddleClick  { my ($self, $x, $y) = @_; $self->comMouseClick(2, $x, $y); }
sub comMouseRightClick   { my ($self, $x, $y) = @_; $self->comMouseClick(3, $x, $y); }
sub comMouseScrollUp     { my ($self, $x, $y) = @_; $self->comMouseClick(4, $x, $y); }
sub comMouseScrollDown   { my ($self, $x, $y) = @_; $self->comMouseClick(5, $x, $y); }

sub comKeyDown {
    my ($self, @keylist) = @_;
    $self->{'conn_sock'}->print(join("", map {"xdokeychange,$_,1\n"} @keylist));
}

sub comKeyUp {
    my ($self, @keylist) = @_;
    $self->{'conn_sock'}->print(join("", map {"xdokeychange,$_,0\n"} @keylist));
}

sub comWindowListForPager {
    my ($self) = @_;
    $self->print("winlist\n");
    my $line;
    my @winlist = ();
    while(($line = $self->getLine()) ne "endlist\n") {
        chomp $line;
        next if $line !~ /^(\d+) (.+?)$/;
        my ($wid, $title) = ($1, $2);
        push(@winlist, {"wid" => $wid , "title" => $title});
    }
    return wantarray ? @winlist : $winlist[0];
}


1;

__END__

=pod

=head1 NAME

Numpaar::Connection - connection to Numpaar core


=head1 SYNOPSIS

  ## In a key handler
  
  sub handler_center {
      my ($self, $want_help) = @_;
      return 'explanation' if defined($want_help);
      
      ## Get the Connection object
      my $connection = $self->getConnection();
      
      ## Type Hello, world!
      $connection->comKeyType('Hello, world!');
      
      ## Generate various key events
      $connection->comKeyString('j');                      ## Type j
      $connection->comKeyString('ctrl+a');                 ## Select all
      $connection->comKeyString('alt+Tab');                ## Window switch
      $connection->comKeyString('ctrl+x', 'Return', 'f');  ## Change file encoding in Emacs
      
      ## Move the mouse pointer to the coordinate (150, 200) and generate a left-click event.
      $connection->comMouseLeftClick(150, 200);

      ## Move the mouse pointer to the coordinate (100, 10)
      $connection->comMouseMove(100, 10);

      ## ..and generate a right-click event here.
      $connection->comMouseRightClick();
      
      ## Wait for a sec..
      $connection->comWaitMsec(1000);
      
      $connection->comKeyString('F5');    ## Reload
      
      ## update active window in 0.5 second
      $connection->comUpdateActive(500);

      ## Get and print window list
      my @winlist = $connection->comWindowListForPager();
      print STDERR ("----Win list\n", map {sprintf (">>>>0x%08x %s\n", $_->{wid}, $_->{title}) @winlist});
      
      return 0;
  }


=head1 DESCRIPTION

Numpaar::Connection object represents the connection to the "Numpaar core" process.
Using the methods provided by Numpaar::Connection, Numpaar Engines can make the core
execute various tasks such as generating key/mouse events.



=head1 PUBLIC INSTANCE METHODS

=head2 comKeyString (KEY_STRINGS)

Makes key events on keys specified by KEY_STRINGS arguments in the specified order.
The key event generated by this method is a pair of "press" and "release" events on the specified key.

KEY_STRINGS is a list of strings, each of which represents a key or combination of a key and some modifier keys.
See L</HOW TO SPECIFY KEY_STRING> for detail.



=head2 comKeyType (KEY_TYPES)

Makes key events that would type the given strings KEY_TYPES in the specified order.

KEY_TYPES is a list of strings that you want Numpaar to type.
Because this method tries to type the given strings as-is, you cannot specify any modifier key.


=head2 comMouseClick (BUTTON, [X, Y])

Moves the mouse pointer to the coordinate (X, Y), and generates a mouse click event there.
This is a raw-level method for mouse operations. You may want to use more intuitive methods below.

BUTTON is the button number you want Numpaar to push.
If BUTTON == 0, it does move the pointer but not generate any click event.

X and Y are integers that specify the target coordinate of the pointer.
If either of is undefined, it does not move the pointer.

=head2 comMouseMove (X, Y)

Moves the mouse pointer to the coordinate (X, Y).

=head2 comMouseLeftClick ([X, Y])

Moves the mouse pointer to the coordinate (X, Y), and generates a left-click event.

If either X or Y is omitted, it does not move the pointer but does generate a left-click event.


=head2 comMouseMiddleClick ([X, Y])

Same as C<comMouseLeftClick> except for this generates middle-click event.


=head2 comMouseRightClick ([X, Y])

Same as C<comMouseLeftClick> except for this generates right-click event.


=head2 comMouseScrollUp ([X, Y])

Same as C<comMouseLeftClick> except for this generates the mouse wheel's scroll up event.


=head2 comMouseScrollDown ([X, Y])

Same as C<comMouseLeftClick> except for this generates the mouse wheel's scroll down event.


=head2 comWaitMsec (WAIT_MSEC)

Makes the Numpaar core wait for the specified time.

WAIT_MSEC is the time for which the Numpaar core sleeps, in milli-seconds.

In most cases, you may use Perl's C<sleep> function instead.
Even I'm not sure if this method is useful now.
However, note that C<sleep> and C<comWaitMsec> are different.
While C<sleep> makes the Engine process sleep, C<comWaitMsec> stops the Numpaar core,
which is a separate process.
Therefore, C<comWaitMsec> does not stop the key handler any more than the communication overhead with the core.
What is delayed due to C<comWaitMsec> is execution of operations submitted to the core by
subsequent calls of C<com*> methods of the Connection object.



=head2 comUpdateActive (DEFER_TIME_MSEC)

Makes the Numpaar core update the currently active window in DEFER_TIME_MSEC milli-seconds.

This method is useful when you want to switch the active Engine without switching the active window.

Numpaar tracks the active window every time window switching occurs.
However, it cannot track the internal state of the currently active window.
For example, when you use a Web browser, you move to various Web sites using the browser's single window
(and possibly multiple tabs within the window).
If you want to use a specific Numpaar Engine in a specific Web site,
Numpaar cannot enable the engine, because it cannot detect when the browser opens the Web site.
Using C<comUpdateActive>, you can tell the Numpaar core to check the currently active window
and switch the active Numpaar Engine if necessary.


=head2 comKeyDown (KEY_STRINGS)

Makes "press" events on the keys specified by KEY_STRINGS.
You should release the keys by calling C<comKeyUp> in the future.

KEY_STRINGS is a list of strings that follow the same format as the ones for C<comKeyString>.


=head2 comKeyUp (KEY_STRINGS)

Makes "release" events on the keys specified by KEY_STRINGS.

KEY_STRINGS is a list of strings that follow the same format as the ones for C<comKeyString>.


=head2 WIN_LIST = comWindowListForPager

Returns a list of windows which should be selectable by a pager (a window switcher).

WIN_LIST is a list of hash references, each of which represents a window.
The hash reference contains the following members.

=over

=item wid

(Integer) Window ID of the window.

=item title

(String) Title of the window

=back



=head1 HOW TO SPECIFY KEY_STRING

KEY_STRING is passed to libxdo, a backend library for C<xdotool> utility program.
For complete detail of KEY_STRING specification, see [[xdotool documents|http://www.semicomplete.com/projects/xdotool/]].

KEY_STRING consists of a main key and zero or more modifier keys.
Modifier keys are such as "ctrl", "alt", "shift" and "super", and they are prepended to the main key string with "+".

A main key is a string that specifies an independent key.
For alphabet keys and number keys, you can use "a", "b", "c" ... "z" and "0" to "9".
However, you may find it difficult to specify special keys such as tab, backspace, enter and arrow keys.

To learn the key strings for special keys, I recommend using C<xev> utility program.
Start C<xev> in your shell, then a window pops up.
When you set focus on the window and hit a key, the detail of the key event will be shown in your terminal.
This includes the key string for the key you just hit.

For example, when you hit the backspace key on C<xev> window, the output will be like the following.

  KeyPress event, serial 34, synthetic NO, window 0x1c00001,
      root 0xba, subw 0x0, time 5516137, (259,229), root:(850,522),
      state 0x0, keycode 22 (keysym 0xff08, BackSpace), same_screen YES,
      XLookupString gives 1 bytes: (08) "
      XmbLookupString gives 1 bytes: (08) "
      XFilterEvent returns: False
  
  KeyRelease event, serial 34, synthetic NO, window 0x1c00001,
      root 0xba, subw 0x0, time 5516178, (259,229), root:(850,522),
      state 0x0, keycode 22 (keysym 0xff08, BackSpace), same_screen YES,
      XLookupString gives 1 bytes: (08) "
      XFilterEvent returns: False

Check out "(keysym 0xff08, BackSpace)" in the above output.
This tells us that the KEY_STRING for the backspace key is "BackSpace".


=head2 Examples of KEY_STRING

   a              ## "A" key
   5              ## "5" key
   Tab            ## tab
   Return         ## Return/Enter key
   alt+F4         ## Alt + F4 (close window)
   ctrl+shift+s   ## Control + Shift + s (save as)
   BackSpace      ## backspace
   Up             ## Up arrow key
   Left           ## Left arrow key



=head1 AUTHOR

Toshio ITO



=cut



