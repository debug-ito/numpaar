######################
package Numpaar::Engine;
use strict;
use warnings;
use FindBin;
use IO::Pipe;
use Time::HiRes qw( usleep );
use Class::Inspector;
use Numpaar::Config qw(configGet);

our $keys_maximize_window = ['alt+F10'];
our $keys_close_window = ['alt+F4'];

my $HANDLER_PREFIX = 'handler';

sub new {
    my ($class, $pattern) = @_;
    return $class->setupBasic($pattern);
}

sub setupBasic {
    my ($class, $pattern) = @_;
    $pattern = '.*' if !defined($pattern);
    my $self = {
        engine_obj => {
            state => 0,
            old_state => 0,
            pattern => $pattern,
            menu_dir => Numpaar::Engine->getDefaultDirectory(),
            connection => undef,
            status_interface => undef,
            window_description => undef,
            window_id => undef,
            grab_list => undef,
            global_grabs => undef,
        },
        heap => {},
    };
    ($self->{engine_obj}->{grab_list}, $self->{engine_obj}->{"global_grabs"}) = $class->initGrabList();
    bless $self, $class;
    return $self;
}

## ** DO shell-command-on-region
## perl -ne 'chomp $_; $t = $_; $t =~ s/^(.)/uc($1)/e; $t =~ s/_(.)/uc($1)/eg; print "sub access$t {\n    my (\$self, \$arg) = \@_;\n    \$self->{engine_obj}->{$_} = \$arg if defined(\$arg);\n    return \$self->{engine_obj}->{$_};\n}\n\n"'

sub accessState {
    my ($self, $arg) = @_;
    $self->{engine_obj}->{state} = $arg if defined($arg);
    return $self->{engine_obj}->{state};
}
sub accessOldState {
    my ($self, $arg) = @_;
    $self->{engine_obj}->{old_state} = $arg if defined($arg);
    return $self->{engine_obj}->{old_state};
}

sub accessPattern {
    my ($self, $arg) = @_;
    $self->{engine_obj}->{pattern} = $arg if defined($arg);
    return $self->{engine_obj}->{pattern};
}

sub accessMenuDir {
    my ($self, $arg) = @_;
    $self->{engine_obj}->{menu_dir} = $arg if defined($arg);
    return $self->{engine_obj}->{menu_dir};
}

sub accessConnection {
    my ($self, $arg) = @_;
    $self->{engine_obj}->{connection} = $arg if defined($arg);
    return $self->{engine_obj}->{connection};
}

sub accessStatusInterface {
    my ($self, $arg) = @_;
    $self->{engine_obj}->{status_interface} = $arg if defined($arg);
    return $self->{engine_obj}->{status_interface};
}

sub accessGrabList {
    my ($self, $arg) = @_;
    $self->{engine_obj}->{grab_list} = $arg if defined($arg);
    return $self->{engine_obj}->{grab_list};
}

sub accessGlobalGrabs {
    my ($self, $arg) = @_;
    $self->{engine_obj}->{global_grabs} = $arg if defined($arg);
    return $self->{engine_obj}->{global_grabs};
}

sub accessConnection {
    my ($self, $arg) = @_;
    $self->{engine_obj}->{connection} = $arg if defined($arg);
    return $self->{engine_obj}->{connection};
}

sub accessStatusInterface {
    my ($self, $arg) = @_;
    $self->{engine_obj}->{status_interface} = $arg if defined($arg);
    return $self->{engine_obj}->{status_interface};
}

sub accessWindowDescription {
    my ($self, $arg) = @_;
    $self->{engine_obj}->{window_description} = $arg if defined($arg);
    return $self->{engine_obj}->{window_description};
}

sub accessWindowID {
    my ($self, $arg) = @_;
    $self->{engine_obj}->{window_id} = $arg if defined($arg);
    return $self->{engine_obj}->{window_id};
}


sub getConnection { return $_[0]->accessConnection(); }
sub getStatusInterface { return $_[0]->accessStatusInterface(); }
sub getWindowDescription { return $_[0]->accessWindowDescription(); }
sub getWindowID {return $_[0]->accessWindowID(); }

sub heap { return $_[0]->{heap} };

sub getSymbolList {
    my ($class_or_self) = @_;
    my $class = (ref($class_or_self) ? ref($class_or_self) : $class_or_self);
    return Class::Inspector->methods($class);
}

sub getDefaultDirectory {
    my $elem;
    eval {
        $elem = &configGet('directory', 'default');
    };
    if($@) {
        $elem = '';
    }
    return $elem;
}

sub getStateString {
    my ($self) = @_;
    return $self->accessPattern() . ' ' . $self->accessState();
}

sub getExplanations {
    my ($self) = @_;
    my $explanation = '';
    my %keylist = (
        'divide' =>   '/',
        'multiply' => '*',
        'minus' =>    '-',
        'home' =>     'Home',
        'up' =>       'Up',
        'page_up' =>  'PgUp',
        'plus' =>     '+',
        'left' =>     'Left',
        'center' =>   '5',
        'right' =>    'Right',
        'end' =>      'End',
        'down' =>     'Down',
        'page_down' =>'PgDn',
        'enter' =>    'Enter',
        'insert' =>   'Ins',
        'delete' =>   'Del',
        );
    foreach my $key (keys(%keylist)) {
        my $method = $self->getMethodName($key);
        my $help_msg;
        if($method) {
            $help_msg = $self->$method(1);
        }else {
            $help_msg = $keylist{$key};
        }
        $explanation .= "$key $help_msg\n";
    }
    return $explanation; 
}


sub initGrabList {
    my ($class) = @_;
    my $grab_list = {};
    my $global_grabs = [];
    my $handler_list = $class->getSymbolList();
    foreach my $handler_name (@$handler_list) {
        if($handler_name =~ /^${HANDLER_PREFIX}_([a-zA-Z0-9_]+)$/) {
            push(@$global_grabs, $1);
            next;
        }
        next if $handler_name !~ /^${HANDLER_PREFIX}([^_]+)_([a-zA-Z0-9_]+)$/;
        my ($state, $command) = ($1, $2);
        if(!defined($grab_list->{$state})) {
            $grab_list->{$state} = [];
        }
        push(@{$grab_list->{$state}}, $command);
    }
    return ($grab_list, $global_grabs);
}

sub getMethodName {
    my ($self, $command) = @_;
    my $state = $self->accessState();
    my $method = "${HANDLER_PREFIX}${state}_$command";
    my $global_method = "${HANDLER_PREFIX}_$command";
    my $is_success = 0;
    if($self->can($method)) {
        return $method;
    }elsif($self->can($global_method)) {
        return $global_method;
    }
    return '';
}

sub processCommand {
    my ($self, $command) = @_;
    my $method = $self->getMethodName($command);
    if(!$method) {
        print STDERR "Key $command is not handled in state ". $self->accessState() .".\n";
        return 0;
    }
    return $self->$method();
}

sub getGrabKeyListForState {
    my ($self, $state) = @_;
    my $grab_list = $self->accessGrabList();
    my @ret_list = ();
    if(defined($self->accessGlobalGrabs())) {
        push(@ret_list, @{$self->accessGlobalGrabs()});
    }
    if(defined($grab_list->{$state})) {
        push(@ret_list, @{$grab_list->{$state}});
    }
    return @ret_list;
}

sub getState {
    my ($self) = @_;
    return wantarray ? ($self->accessState(), $self->accessOldState()) : $self->accessState();
}

sub checkStateString {
    my ($class_self, $state_str) = @_;
    return 1 if $state_str =~ /^[a-zA-Z_0-9]+$/;
    return 0;
}

sub setState {
    my ($self, $to_state) = @_;
    return $self->accessState() if !$self->checkStateString($to_state);
    
    $self->accessOldState($self->accessState());
    $self->accessState($to_state);
    printf STDERR ("Change state from %s to %s\n", $self->accessOldState(), $to_state);
    if($self->accessOldState() ne $to_state) {
        if(!$self->restoreKeyGrab()) {
            print STDERR ("Warning: State is changed but key grab is not set because connection is not provided.\n");
        }
    }
    return $self->accessState();
}

sub restoreKeyGrab {
    my ($self) = @_;
    my $connection = $self->getConnection();
    return 0 if !defined($connection);
    $connection->comKeyGrabSetOn($self->getGrabKeyListForState($self->accessState()));
    return 1;
}

sub show {
    my ($self, $event_name) = @_;
    print STDERR (">>PAT: " . $self->accessPattern() . "  STATE: " . $self->accessState());
    print STDERR (" EVENT: $event_name") if defined($event_name);
    print STDERR ("\n");
}

sub showSymbols {
    my ($self) = @_;
    my $symbols = $self->getSymbolList();
    foreach my $symbol (@$symbols) {
        print STDERR "$symbol\n";
    }
}

sub showGrabs {
    my ($self) = @_;
    print STDERR "Global Grab: ";
    print STDERR (join(",", @{$self->accessGlobalGrabs()}) . "\n");
    print STDERR "Stateful Grab:\n";
    my $grab_list = $self->accessGrabList();
    foreach my $state (keys(%$grab_list)) {
        my $grabs = $grab_list->{$state};
        print STDERR "  $state : ";
        print STDERR (join(",", @$grabs) . "\n");
    }
}

## ** Default handler for "switch" event
sub handler_switch {
    my ($self, $want_help) = @_;
    return '' if defined($want_help);
    $self->restoreKeyGrab();
    print STDERR "Default switch handler\n";
    return 0;
}

sub handler_center {
    my ($self, $want_help) = @_;
    return 'Enter' if defined($want_help);
    $self->getConnection()->comKeyString('Return');
    return 0;
}

sub handler_plus {
    my ($self, $want_help) = @_;
    return 'Maximize' if defined($want_help);
    $self->getConnection()->comKeyString(@$keys_maximize_window);
    return 0;
}

sub handler_enter {
    my ($self, $want_help) = @_;
    return 'Help' if defined($want_help);
    $self->getStatusInterface()->toggleShowHide();
    return 0;
}

sub handler_minus {
    my ($self, $want_help) = @_;
    return 'Close Window' if defined($want_help);
    $self->setState(0);
    $self->getConnection->comKeyString(@$keys_close_window);
    return 0;
}

sub handler_multiply {
    my ($self, $want_help) = @_;
    return 'File' if defined($want_help);
    if(!fork()) {
        ## exec(&extPathOf('file-manager'), $self->{'menu_dir'});
        print STDERR "Open " . $self->accessMenuDir(). "\n";
        exec(&configGet('extern_program', 'file-manager'), $self->accessMenuDir());
    }
    return 0;
}

sub createSwitcherProcess {
    my (@winlist) = @_;
    my $pipe = IO::Pipe->new();
    my $child_pid = fork();
    if(!$child_pid) {
        ## ** Child process
        $pipe->reader();
        close(STDIN);
        open(STDIN, '<&', $pipe);
        ## exec(&extPathOf('switcher'), &extPathOf('xdotool'));
        exec(&configGet('extern_program', 'switcher'), &configGet('extern_program', 'xdotool'));
    }
    # waitpid($child_pid, WNOHANG);
    $pipe->writer();
    foreach my $win_entry (@winlist) {
        $pipe->printf("%d %s\n", $win_entry->{wid}, $win_entry->{title});
    }
    $pipe->close();
}

sub handler_divide {
    my ($self, $want_help) = @_;
    return "Switch Window" if defined($want_help);
    my @winlist = $self->getConnection()->comWindowListForPager();
    &createSwitcherProcess(@winlist);
    return 0;
}

1;

__END__

=pod

=head1 NAME

Numpaar::Engine - the base class of all Numpaar Engines


=head1 SYNOPSIS


  package Numpaar::Engine::Sample;
  use base qw(Numpaar::Engine);
  
  
  sub new {
      my $class = shift;
      return $class->setupBasic('Sample Application$');
  }
  
  
  ## every key handler receives Numpaar::Engine object as the first argument
  
  sub handler_center {
      my ($self, $want_help) = @_;
      return "explanation" if defined($want_help);

      ## Get current window description
      my $win_desc = $self->getWindowDescription();

      ## Get current window ID
      my $win_id = $self->getWindowID();
  
      ## Get Numpaar::Connection object
      my $connection = $self->getConnection();
  
      ## Get Numpaar::StatusInterface object
      my $status = $self->getStatusInterface();
  
      ## Get current state of the engine
      my $cur_state = $self->getState();
  
      ## Set current state of the engine
      $self->setState('NextState');
  
      return 0;
  }
  
  1;



=head1 DESCRIPTION

Numpaar::Engine is the base class of all Numpaar Engines, which are Perl classes
where key handlers are implemented.

The methods provided by Numpaar::Engine are usually used by its subclasses in two kinds of methods;
the constructor (C<new>) and key handlers.
See [[Numpaar Wiki|https://github.com/debug-ito/numpaar/wiki/tutorial-Key-Handlers]] for details on key handlers.


=head1 PUBLIC CLASS METHODS


=head2 ENGINE_OBJ = setupBasic (PATTERN)


  my $self = $class->setupBasic('^WM_NAME\.WM_CLASS TITLE$'):


Instantiates the Engine object, initializes it and returns the reference to the object.
This method is used in constructors of Numpaar Engines.

The argument PATTERN is a string of regular expression that is matched against the window description
of the currently active window.
See [[Application Matching section in Numpaar Wiki|https://github.com/debug-ito/numpaar/wiki/tutorial-Application-Matching]].



=head1 PUBLIC INSTANCE METHODS


Instance methods are used in key handlers.



=head2 CONNECTION = getConnection


  my $connection = $self->getConnection();


Returns [[Numpaar::Connection|https://github.com/debug-ito/numpaar/wiki/reference-Connection]] object.



=head2 STATUS = getStatusInterface


  my $status = $self->getStatusInterface();


Returns [[Numpaar::StatusInterface|https://github.com/debug-ito/numpaar/wiki/reference-StatusInterface]] object.



=head2 STATE = getState


  my $cur_state = $self->getState();


Returns the current state of the Engine.



=head2 RESULT_STATE = setState (NEXT_STATE)


  $self->setState("NextState");


Set the state of the Engine to NEXT_STATE.
Because NEXT_STATE is used in names of key handlers,
it must be either an integer or a string consisting of alphabets, numbers and underscore ('_').

The return value RESULT_STATE is the resulted state of the Engine.
If NEXT_STATE is invalid, RESULT_STATE equals to the state before this method call.


=head2 WIN_DESC = getWindowDescription

  my $win_desc = $self->getWindowDescription();

Returns the window description of the currently active window.

A window description is a string that briefly describes the window.
Its format is detailed in [[Numpaar Wiki|https://github.com/debug-ito/numpaar/wiki/tutorial-Application-Matching]].


=head2 WIN_ID = getWindowID

  my $win_id = $self->getWindowID();

Returns the window ID of the currently active window.

Window ID is an integer that identifies an X window.


=head1 AUTHOR

Toshio ITO


=head1 SEE ALSO

[[Numpaar::Connection|https://github.com/debug-ito/numpaar/wiki/reference-Connection]],
[[Numpaar::StatusInterface|https://github.com/debug-ito/numpaar/wiki/reference-StatusInterface]]


=cut



