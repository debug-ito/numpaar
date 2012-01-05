######################
package Numpaar::Engine;
use strict;
use FindBin;
use IO::Pipe;
use Time::HiRes qw( usleep );
use Class::Inspector;
use Numpaar::Config qw(configElement);

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
        $elem = &configElement('directory', 'default');
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
    $self->getConnection()->comKeyString('alt+F10');
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
    $self->getConnection->comKeyString('alt+F4');
    return 0;
}

sub handler_multiply {
    my ($self, $want_help) = @_;
    return 'File' if defined($want_help);
    if(!fork()) {
        ## exec(&extPathOf('file-manager'), $self->{'menu_dir'});
        print STDERR "Open " . $self->accessMenuDir(). "\n";
        exec(&configElement('extern_program', 'file-manager'), $self->accessMenuDir());
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
        exec(&configElement('extern_program', 'switcher'), &configElement('extern_program', 'xdotool'));
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
    print STDERR ("----Win list\n", map {sprintf (">>>>0x%08x %s\n", $_->{wid}, $_->{title})} @winlist);
    &createSwitcherProcess(@winlist);
    return 0;
}

1;
