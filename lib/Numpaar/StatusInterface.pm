package Numpaar::StatusInterface;
use IO::Pipe;

use strict;
use warnings;

sub new {
    my ($class, $status_script_path) = @_;
    my $pipe = IO::Pipe->new();
    $pipe->writer($status_script_path);
    return bless { 'pipe' =>  $pipe}, $class;
}

sub send {
    my ($self, $message) = @_;
    my $debug = 0;
    return 0 if !defined($self->{pipe});
    if($self->{pipe}->error() || !$self->{pipe}->opened()) {
        delete $self->{pipe};
        return 0;
    }
    ## ** Looks like there is no simple way to capture the error of "broken pipe" as return value or something.
    $self->{pipe}->print($message);
    $self->{pipe}->flush();
    return 1;
}

sub toggleShowHide {
    my ($self) = @_;
    $self->send("toggle it\n");
}

sub changeStatusIcon {
    my ($self, $icon_id) = @_;
    return if !defined($icon_id);
    $self->send("icon $icon_id\n");
}


1;
