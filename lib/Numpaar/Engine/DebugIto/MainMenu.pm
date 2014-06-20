package Numpaar::Engine::DebugIto::MainMenu;
use base 'Numpaar::Engine::DebugIto::Thunar';
use Numpaar::Config ('configGet');

sub new {
    my ($class, $winclass_winname_pattern, $window_title) = @_;
    my $self = $class->setupBasic("^$winclass_winname_pattern $window_title");
    $self->heap->{'title'} = $window_title;
    return $self;
}

sub handler0_center {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'Enter' if defined($want_help);
    $connection->comKeyString('Return');
    sleep 1;
    system(&configGet('extern_program', 'xdotool'), "search", '--name', $self->heap->{'title'}, 'windowkill');
    return 0;
}

1;

__END__

=pod

=head1 NAME

Numpaar::Engine::DebugIto::MainMenu - Engine for a window as a main menu

=head1 SYNOPSIS

In configuration file

  ## If your file-manager is thunar
  extern_program 'file-manager', '/usr/bin/thunar';
  ## ... and the default directory is named main_menu,
  directory 'default', '/home/your_name/main_menu';

  ###### then, the configuration will look like the following.
  
  ## Thunar as your file manager, and window title of the main menu.
  engine 'DebugIto::MainMenu', '[tT]hunar\.[tT]hunar', 'main_menu - File Manager';
  
  ## This engine needs xdotool command.
  extern_program 'xdotool', '/usr/local/bin/xdotool';


=head1 DESCRIPTION

This engine is meant to be activated for the "main menu" window, a file manager window that pops up when you hit B<\*> key.
Because the main menu window is often used to list some launchers, it might as well disappear after you select a launcher.
This engine uses C<xdotool> command to destroy the main menu window when you select something in the window.

=head1 CONFIGURATION

=head2 Arguments for engine directive

As you see in L<"SYNOPSIS">, this engine takes two arguments for C<engine> directive.

=over

=item 1.

The first argument is a regular expression that should be matched against "WM_NAME.WM_CLASS" strings of windows.

The easiest way to see windows' WM_NAME.WM_CLASS is to use C<wmctrl> command. Type

  $ wmctrl -xl

then, you will see WM_NAME.WM_CLASS parameters in the third column.
See Numpaar Wiki L<https://github.com/debug-ito/numpaar/wiki/tutorial-Application-Matching> for more info.

=item 2.

The second argument is the window title of the main menu window.
This is the string you see in the title bar of the window.

=back

=head1 SEE ALSO

L<Numpaar::Engine::DebugIto::Thunar>

=head1 AUTHOR

Toshio ITO

