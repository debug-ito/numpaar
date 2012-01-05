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
        $notifylines[$i] = $self->{'conn_sock'}->getline();
        die "Cannot get event line from Numpaar core" if !defined($notifylines[$i]);
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
    $self->{'conn_sock'}->printf("mouseclick,%d,%d,%d\n", $button, $x, $y);
}

sub comKeyDown {
    my ($self, @keylist) = @_;
    $self->{'conn_sock'}->print(join("", map {"xdokeychange,$_,1\n"} @keylist));
}

sub comKeyUp {
    my ($self, @keylist) = @_;
    $self->{'conn_sock'}->print(join("", map {"xdokeychange,$_,0\n"} @keylist));
}


1;
