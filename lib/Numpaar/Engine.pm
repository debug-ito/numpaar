######################
package Numpaar::Engine;
use strict;
use FindBin;
use IO::Pipe;
use Time::HiRes qw( usleep );
use Class::Inspector;
use Numpaar::Config qw(configElement);

sub new() {
    my ($class, $pattern) = @_;
    return $class->setupBasic($pattern);
}

sub setupBasic() {
    my ($class, $pattern) = @_;
    $pattern = '.*' if !defined($pattern);
    my $self = {
        'state' => 0,
        'old_state' => 0,
        'pattern' => $pattern,
        'symbols' => $class->getSymbolList(),
        'menu_dir' => Numpaar::Engine->getDefaultDirectory(),
    };
    ($self->{'grab_list'}, $self->{"global_grabs"}) = $class->initGrabList($self->{'symbols'});
    bless $self, $class;
    return $self;
}

sub getSymbolList() {
    my ($class) = @_;
    return Class::Inspector->methods($class);
}

sub getDefaultDirectory() {
    my $elem;
    eval {
        $elem = &configElement('directory', 'default');
    };
    if($@) {
        $elem = '';
    }
    return $elem;
}

sub getStateString() {
    my ($self) = @_;
    return $self->{'pattern'} . ' ' . $self->{'state'};
}

sub getExplanations() {
    my ($self) = @_;
    my $explanation = '';
    my %keylist = (
        'divide' =>   '/',
        'multiply' => '*',
        'minus' =>    '-',
        'home' =>     'Home',
        'up' =>       '↑',
        'page_up' =>  'PgUp',
        'plus' =>     '+',
        'left' =>     '←',
        'center' =>   '5',
        'right' =>    '→',
        'end' =>      'End',
        'down' =>     '↓',
        'page_down' =>'PgDn',
        'enter' =>    'Enter',
        'insert' =>   'Ins',
        'delete' =>   'Del',
        );
    foreach my $key (keys(%keylist)) {
        my $method = $self->getMethodName($key);
        my $help_msg;
        if($method) {
            $help_msg = $self->$method(0, 1);
        }else {
            $help_msg = $keylist{$key};
        }
        $explanation .= "$key $help_msg\n";
    }
    return $explanation; 
}


sub initGrabList() {
    my ($class, $handler_list) = @_;
    my $grab_list = {};
    my $global_grabs = [];
    foreach my $handler_name (@$handler_list) {
        if($handler_name =~ /^map_([a-zA-Z0-9_]+)$/) {
            push(@$global_grabs, $1);
            next;
        }
        next if $handler_name !~ /^map([^_]+)_([a-zA-Z0-9_]+)$/;
        my ($state, $command) = ($1, $2);
        if(!defined($grab_list->{$state})) {
            $grab_list->{$state} = [];
        }
        push(@{$grab_list->{$state}}, $command);
    }
    return ($grab_list, $global_grabs);
}

sub getMethodName() {
    my ($self, $command) = @_;
    my $state = $self->{"state"};
    my $method = "map${state}_$command";
    my $global_method = "map_$command";
    my $is_success = 0;
    if(grep(/^$method$/, @{$self->{"symbols"}})) {
        return $method;
    }elsif(grep(/^$global_method$/, @{$self->{'symbols'}})) {
        return $global_method;
    }else {
        return '';
    }
}

sub processCommand() {
    my ($self, $connection, $command, $status_pipe) = @_;
    my $method = $self->getMethodName($command);
    if(!$method) {
        print STDERR "Key $command is not handled in state ". $self->{'state'} .".\n";
        return 0;
    }
    return $self->$method($connection, undef, $status_pipe);
}

sub getGrabKeyListForState() {
    my ($self, $state) = @_;
    my $grab_list = $self->{'grab_list'};
    my @ret_list = ();
    if(defined($self->{'global_grabs'})) {
        push(@ret_list, @{$self->{'global_grabs'}})
    }
    if(defined($grab_list->{$state})) {
        push(@ret_list, @{$grab_list->{$state}});
    }
    return @ret_list;
}

sub changeToState() {
    my ($self, $connection, $to_state) = @_;
    $self->{'old_state'} = $self->{'state'};
    $self->{'state'} = $to_state;
    printf STDERR ("Change state from %s to %s\n", $self->{'old_state'}, $to_state);
    if($self->{'old_state'} ne $to_state) {
        $self->restoreKeyGrab($connection);
    }
}

sub restoreKeyGrab() {
    my ($self, $connection) = @_;
    $connection->comKeyGrabSetOn($self->getGrabKeyListForState($self->{'state'}));
}

sub show() {
    my ($self, $event_name) = @_;
    print STDERR (">>PAT: " . $self->{"pattern"} . "  STATE: " . $self->{"state"});
    print STDERR (" EVENT: $event_name") if defined($event_name);
    print STDERR ("\n");
}

sub showSymbols() {
    my ($self) = @_;
    foreach my $symbol (@{$self->{'symbols'}}) {
        print STDERR "$symbol\n";
    }
}

sub showGrabs() {
    my ($self) = @_;
    print STDERR "Global Grab: ";
    print STDERR (join(",", @{$self->{'global_grabs'}}) . "\n");
    print STDERR "Stateful Grab:\n";
    foreach my $state (keys(%{$self->{'grab_list'}})) {
        my $grabs = $self->{'grab_list'}->{$state};
        print STDERR "  $state : ";
        print STDERR (join(",", @$grabs) . "\n");
    }
}

sub changeStatusIcon() {
    my ($self, $pipe, $icon_id) = @_;
    return if !defined($icon_id);
    $pipe->print("icon $icon_id\n");
    $pipe->flush();
}

## ** Default handler for "switch" event
sub map_switch() {
    my ($self, $connection, $want_help) = @_;
    return '' if defined($want_help);
    $self->restoreKeyGrab($connection);
    print STDERR "Default switch handler\n";
    return 0;
}

sub map_center() {
    my ($self, $connection, $want_help) = @_;
    return 'Enter' if defined($want_help);
    $connection->comKeyString('Return');
    return 0;
}

sub map_plus() {
    my ($self, $connection, $want_help) = @_;
    return '最大化' if defined($want_help);
    $connection->comKeyString('alt+F10');
    return 0;
}

sub map_enter() {
    my ($self, $connection, $want_help, $status_pipe) = @_;
    return 'ヘルプ' if defined($want_help);
    if(defined($status_pipe)) {
        $status_pipe->print("toggle it\n");
        $status_pipe->flush();
    }
    return 0;
}

sub map_minus() {
    my ($self, $connection, $want_help) = @_;
    return 'ウィンドウを閉じる' if defined($want_help);
    $self->changeToState($connection, 0);
    $connection->comKeyString('alt+F4');
    return 0;
}

sub map_multiply() {
    my ($self, $connection, $want_help) = @_;
    return 'ファイル' if defined($want_help);
    if(!fork()) {
        ## exec(&extPathOf('file-manager'), $self->{'menu_dir'});
        print STDERR "Open " . $self->{menu_dir} . "\n";
        exec(&configElement('extern_program', 'file-manager'), $self->{'menu_dir'});
    }
    return 0;
}

sub createSwitcherProcess() {
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
        $pipe->print($win_entry);
    }
    $pipe->close();
}

sub map_divide() {
    my ($self, $connection, $want_help) = @_;
    return "ウィンドウスイッチ" if defined($want_help);
    $connection->print("winlist\n");
    my $line;
    my @winlist = ();
    while(($line = $connection->getLine()) ne "endlist\n") {
        push(@winlist, $line);
    }
    &createSwitcherProcess(@winlist);
    return 0;
}

1;
