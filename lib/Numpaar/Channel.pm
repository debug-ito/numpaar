package Numpaar::Channel;
use strict;
use Encode;

sub new {
    my ($class) = @_;
    my $self = {
        "description_pattern_list" => {},
    };
    bless $self, $class;
    return $self;
}

sub putEngine {
    my ($self, $prio, $engine) = @_;
    $self->{"description_pattern_list"}->{$prio} = $engine;
}

sub pushEngine {
    my ($self, $engine) = @_;
    my @keylist = sort {$a<=>$b} keys(%{$self->{"description_pattern_list"}});
    if(!@keylist) {
        $self->{'description_pattern_list'}->{0} = $engine;
    }else {
        $self->{'description_pattern_list'}->{$keylist[@keylist-1] + 1} = $engine;
    }
}

sub getActiveEngine {
    my ($self, $win_description) = @_;
    $win_description = decode('utf8', $win_description);
    foreach my $prio (sort {$a<=>$b} keys(%{$self->{"description_pattern_list"}})) {
        my $engine = $self->{"description_pattern_list"}->{$prio};
        my $pattern = decode('utf8', $engine->accessPattern());
        if($win_description =~ /$pattern/) {
            return $engine;
        }
    }
    return undef;
}

sub getExplanations {
    my ($self, $win_desc) = @_;
    my $engine = $self->getActiveEngine($win_desc);
    return $engine->getExplanations();
}

sub processCommand {
    my ($self, $connection, $command, $win_id, $win_desc, $status_interface) = @_;
    my $engine = $self->getActiveEngine($win_desc);
    if(!defined($engine)) {
        print STDERR "No active Engine found.\n";
        return 0;
    }
    $engine->show($command);
    $engine->accessConnection($connection);
    $engine->accessWindowDescription($win_desc);
    $engine->accessStatusInterface($status_interface);
    $engine->accessWindowID($win_id);
    $engine->processCommand($command);
    return $engine->getStateString();
}
1;
