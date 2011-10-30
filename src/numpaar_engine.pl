#!/usr/bin/perl -w

use strict;
use IO::Socket::UNIX;
use IO::Select;
use IO::Pipe;
use POSIX ':sys_wait_h';
use FindBin;
use Module::Load;
use Numpaar::Channel;
use Numpaar::Connection;
use Numpaar::Engine;
use Numpaar::Config qw(configLoad configElement configEngineList configCheck);

my $connection;

sub main() {
    if(@ARGV < 1) {
        &usage();
        exit 1;
    }
    my $socket_path = $ARGV[0];
    &init_sighandlers();
    $connection = Numpaar::Connection->new($socket_path);
    if(!$connection->init()) {
        print STDERR "Cannot establish connection at $socket_path\n";
        exit 1;
    }
    
    &configElement('extern_program', 'switcher', $FindBin::Bin . '/window_switcher.pl');
    &configLoad('/etc/numpaar.conf.pl', $ENV{HOME}."/.numpaar");
    &configCheck('extern_program', qw(switcher xdotool file-manager));
    ## Numpaar::Engine->setDefaultMenuDir($FindBin::Bin . '/resources/menu_numpaar');

    my $channel = &makeMainChannel();
    my $status_pipe = IO::Pipe->new();
    $status_pipe->writer($FindBin::Bin . '/numpaar_status.py');

    my $old_state_str = '';
    while(1) {
        my ($command_event, $channel_number, $window_title) = $connection->getEvent();
        my $cur_state_str = $old_state_str;
        $cur_state_str = $channel->processCommand($connection, $command_event, $window_title, $status_pipe);
        $connection->end();

        if(defined($status_pipe)) {
            if(!$status_pipe->error() && $status_pipe->opened()) {
                if($old_state_str ne $cur_state_str) {
                    $status_pipe->print($channel->getExplanations($window_title));
                    $status_pipe->flush();
                    $old_state_str = $cur_state_str;
                }
            }else {
                $status_pipe = undef;
            }
        }
    }
}


END() {
    &finish();
}

sub finish() {
    $connection->close() if defined($connection);
    exit 0;
}

sub init_sighandlers() {
    $SIG{HUP} = $SIG{TERM} = $SIG{INT} = $SIG{QUIT} = \&finish;
    $SIG{CHLD} = \&childProcessReaper;
}

sub childProcessReaper() {
    ## ** Reaper that prevents zombie processes persist.
    ## ** http://perldoc.perl.org/perlipc.html#Signals
    my $child;
    while (($child = waitpid(-1,WNOHANG)) > 0) {
        ;
    }
    $SIG{CHLD} = \&childProcessReaper;
}

sub usage() {
    print STDERR "$0 SOCKET_PATH\n";
}

sub makeMainChannel() {
    my $channel = Numpaar::Channel->new();
    my $elist_ref = &configEngineList();
    foreach my $engine (@$elist_ref) {
        my @args = ();
        my $engine_name = 'Numpaar::Engine::';
        if(ref($engine)) {
            @args = @$engine;
            $engine_name .= shift @args;
        }else {
            $engine_name .= $engine;
        }
        load $engine_name;
        $channel->pushEngine($engine_name->new(@args));
    }
    $channel->pushEngine(Numpaar::Engine->new());
    return $channel;
}


&main();
