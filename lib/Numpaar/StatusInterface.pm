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

__END__

=pod

=head1 NAME

Numpaar::StatusInterface - interface to Numpaar status notifier


=head1 SYNOPSIS

  ## In a key handler
  
  sub handler_center {
      my ($self, $want_help) = @_;
      return 'explanation' if defined($want_help);
      
      ## Get StatusInterface object
      my $status = $self->getStatusInterface();
      
      ## toggle help window
      $status->toggleShowHide();
      
      ## change status icon to busy
      $status->changeStatusIcon('busy');
      
      ## Some task...
      
      ## change status icon back to normal
      $status->changeStatusIcon('normal');
            
      return 0;
  }


=head1 DESCRIPTION

Numpaar::StatusInterface object represents the interface to the help window and the icon shown in
the notification area.
Numpaar Engines can interact with these objects using Numpaar::StatusInterface.


=head1 PUBLIC INSTANCE METHODS

=head2 toggleShowHide

Toggle show/hide of the help window.


=head2 changeStatusIcon (ICON_ID)

Change the icon in the notification area to the one specified by ICON_ID.

ICON_ID is a string, and is one of the following values.

=over

=item *

'normal': Normal icon. This is the detault icon.

=item *

'busy': An icon that indicates that Numpaar is busy now.

=back


=head1 AUTHOR

Toshio ITO


=cut

