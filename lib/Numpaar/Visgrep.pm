package Numpaar::Visgrep;

use strict;
use warnings;
use FindBin;
use Numpaar::Config qw(configGet configCheck);

my $SCREENSHOT_PATH = '/tmp/numpaar_visgrep_screenshot.png';

sub new {
    my ($class) = @_;
    my $self = bless {}, $class;
    $self->baseX(0);
    $self->baseY(0);
    return $self;
}

sub getPatternDir {
    my $class_self = shift;
    my $pattern_dir;
    eval {
        $pattern_dir = &configGet('directory', 'visgrep_patterns');
    };
    if($@) {
        print STDERR ("Warning: No config for directory visgrep_patterns. Use HOME\n");
        $pattern_dir = $ENV{HOME};
    }
    $pattern_dir .= '/' if $pattern_dir !~ m|/$|;
    return $pattern_dir;
}

sub getLocation {
    my ($class_self, $pattern_filename, $not_take_shot) = @_;
    &configCheck('extern_program', 'visgrep', 'import');
    if(!defined($not_take_shot) || $not_take_shot != 0) {
        system(sprintf(&configGet('extern_program', 'import') . ' -depth 8 -window root %s', $SCREENSHOT_PATH));
    }
    my $visgrep_command = &configGet('extern_program', 'visgrep');
    my $visgrep_pattern_dir = $class_self->getPatternDir();
    print STDERR qq(EXEC: $visgrep_command "$SCREENSHOT_PATH" "${visgrep_pattern_dir}${pattern_filename}"\n);
    my $visgrep_ret = `$visgrep_command "$SCREENSHOT_PATH" "${visgrep_pattern_dir}${pattern_filename}"`;
    chomp $visgrep_ret;
    print STDERR qq(RESULT: $visgrep_ret\n);
    if($visgrep_ret eq '') {
        return;
    }
    my ($x, $y, $index) = split(/[, ]/, $visgrep_ret);
    return ($x, $y);
}

sub setBaseFromPattern {
    my ($self, $pattern_file, $pattern_coord_x, $pattern_coord_y, $not_take_shot) = @_;
    my ($x, $y) = $self->getLocation($pattern_file, $not_take_shot);
    if(!defined($x) || !defined($y)) {
        return 0;
    }
    $pattern_coord_x = 0 if !defined($pattern_coord_x);
    $pattern_coord_y = 0 if !defined($pattern_coord_y);
    $self->baseX($x - $pattern_coord_x);
    $self->baseY($y - $pattern_coord_y);
    return 1;
}

sub baseX {
    my ($self, $arg) = @_;
    $self->{'visgrep_base_x'} = $arg if defined($arg);
    return $self->{'visgrep_base_x'};
}

sub baseY {
    my ($self, $arg) = @_;
    $self->{'visgrep_base_y'} = $arg if defined($arg);
    return $self->{'visgrep_base_y'};
}

sub toAbsolute {
    my ($self, $vis_x, $vis_y) = @_;
    return ($self->baseX + $vis_x, $self->baseY + $vis_y);
}

1;

__END__

=pod

=head1 NAME

Numpaar::Visgrep - support module for using visgrep to target your mouse pointer


=head1 SYNOPSIS

In .numpaar configuration file

  directory 'visgrep_patterns', '/path/to/pattern/directory';
  extern_program 'visgrep', '/path/to/visgrep';
  extern_program 'import', '/path/to/import';


In an Engine module file

  package Numpaar::Engine::Sample;
  use base qw(Numpaar::Engine);
  use Numpaar::Visgrep;
  
  sub new {
      my ($class) = @_;
      my $self = $class->setupBasic('.*');
      $self->heap->{visgrep} = Numpaar::Visgrep->new();
      return $self;
  }
  
  sub handler_down {
      my ($self, $want_help) = @_;
      return 'Show coordinate' if defined($want_help);

      ## You can get absolute coordinates of the pattern base_pattern.pat without Visgrep object.
      my ($x, $y) = Numpaar::Visgrep->getLocation('base_pattern.pat', 0);
      if(defined($x) && defined($y)) {
          print STDERR ("The pattern is at ($x, $y)\n");
      }else {
          print STDERR ("The pattern is not found.");
      }
      return 0;
  }
  
  sub handler_up {
      my ($self, $want_help) = @_;
      return 'Set coordinate base' if defined($want_help);
      
      ## Set the Visgrep coordinates of the pattern base_pattern.pat to (0, 0)
      $self->heap->{visgrep}->setBaseFromPattern("base_pattern.pat", 0, 0);
      
      return 0;
  }
  
  sub handler_center {
      my ($self, $want_help) = @_;
      return 'Click' if defined($want_help);
      
      ## Click at (100, 50) in the Visgrep coordinates.
      my $visgrep = $self->heap->{visgrep};
      $self->getConnection()->comMouseLeftClick($visgrep->toAbsolute(100, 50));
      return 0;
  }

  1;


=head1 DESCRIPTION

Numpaar provides the way to move your mouse pointer and generate click events.
However, we rarely know where to click in advance.
We usually click on visual markers, e.g. buttons, icons and menu items, which can pop up anywhere.

Numpaar::Visgrep makes it possible to click at coordinates relative to a specific image in the screen.
It works like the following.

=over

=item 1.

Obtain a screen capture using C<import> command from ImageMagick (L<http://www.imagemagick.org/>) utility.

=item 2. 

Search the captured image for a given image pattern using C<visgrep> command
from xautomation (L<http://hoopajoo.net/projects/xautomation.html>) project.


=item 3.

If the pattern is found, make the mapping between the "absolute" screen coordinates and
the Visgrep coordinates, which are maintained in the Numpaar::Visgrep object.


=item 4.

Now you can convert the Visgrep coordinates to the absolute coordinates, which are given to
C<comMouse*> methods of C<Numpaar::Connection> object.


=back

Because the Visgrep coordinates are relative to the image pattern,
they can be hard-coded in the Numpaar::Engine modules.

By the way, C<visgrep> is a handy utility program that does a simple image pattern matching.
It searches a given image file for a given pattern file,
and returns the coordinates of the pattern if found.
You have to prepare the pattern files in advance (see L</HOW TO CREATE VISGREP PATTERN FILES>).


=head1 CONFIG ELEMENTS

=head2 directory "visgrep_patterns", PATTERN_DIR;

Specifies the path to the directory that contains visgrep pattern files.


=head2 extern_program "visgrep", VISGREP_PATH;

Specifies the path to the C<visgrep> executable file.


=head2 extern_program "import", IMPORT_PATH;

Specifies the path to the C<import> executable file.


=head1 PUBLIC CLASS METHODS

=head2 OBJ = new

  my $visgrep_obj = Numpaar::Visgrep->new();

Creates a Numpaar::Visgrep object. It takes no argument.

=head2 (X, Y) = getLocation (PATTERN_FILE, [NOT_TAKE_SHOT])

  my ($x, $y) = Numpaar::Visgrep->getLocation('pattern_file.pat', 1);

Searches the screen capture for the pattern PATTERN_FILE, and returns its absolute coordinates if found.
If the pattern is not found, it returns an empty list.

PATTERN_FILE is the name of the pattern file in the C<visgrep_patterns> directory specified in the config file.

NOT_TAKE_SHOT is an optional flag. If it's true, C<getLocation> won't capture the screen.
Instead it will use the capture obtained last time.
This saves time but the result may not reflect the current status of the screen.

Note that if this method is called with NOT_TAKE_SHOT being false or undef,
the method blocks for some time, because it obtains the screen capture.


=head1 PUBLIC INSTANCE METHODS

=head2 RESULT = setBaseFromPattern (PATTERN_FILE, PATTERN_VISGREP_X, PATTERN_VISGREP_Y, [NOT_TAKE_SHOT])

  my $is_success = $visgrep_obj->setBaseFromPattern('pattern.pat', 20, 40);

Sets the mapping between the Visgrep coordinates and the absolute screen coordinates.
This is done by searching the screen capture for the pattern PATTERN_FILE,
and associating the absolute coordinates of the pattern's left-top corner with the given Visgrep coordinates
(PATTERN_VISGREP_X, PATTERN_VISGREP_Y).

If it successfully captures the screen and finds the pattern, it returns true.
Otherwise, it returns false.

PATTERN_FILE is the name of the pattern file in the C<visgrep_patterns> directory specified in the config file.

PATTERN_VISGREP_X and PATTERN_VISGREP_Y are the Visgrep x and y coordinates for the pattern, respectively.

If the optional flag NOT_TAKE_SHOT is true, C<setBaseFromPattern> won't take a screen capture, as in C<getLocation> method.


=head2 GET_ABS_X = baseX ([SET_ABS_X])

  my $abs_base_x = $visgrep_obj->baseX();

Get and set the absolute screen X coordinate of the origin in the Visgrep coordinates.

The argument SET_ABS_X, if specified, is used as the absolute X coordinate of the Visgrep origin.
You do not usually need to do it because the base coordinates can be set by C<setBaseFromPattern> method.

The return value GET_ABS_X is the current value of the absolute screen X coordinate of the origin.
If the argument SET_ABS_X is specified, SET_ABS_X == GET_ABS_X holds.



=head2 GET_ABS_Y = baseY ([SET_ABS_Y])

Get and set the absolute screen Y coordinate of the origin in the Visgrep coodinates.
See the explanation on C<baseX>.



=head2 (ABS_X, ABS_Y) = toAbsolute (VIS_X, VIS_Y)

  my ($abs_x, $abs_y) = $visgrep_obj->toAbsolute($vis_x, $vis_y);

Convert the Visgrep coodinates (VIS_X, VIS_Y) into the absolute screen coordinates (ABS_X, ABS_Y).

This method should be used after you set the mapping with C<setBaseFromPattern> method.


=head1 HOW TO CREATE VISGREP PATTERN FILES

visgrep pattern files can be generated from PNG files by C<png2pat> command
from xautomation (L<http://hoopajoo.net/projects/xautomation.html>) project.

Pattern files can be created in the following procedure.

=over

=item 1.

Get a screen capture using C<import> or any program you like.

=item 2.

Clip the capture so that the resulting image contains only the image pattern you want.
The pattern would be, for example, the image of a button or an icon.


=item 3.

Convert the PNG pattern file to PAT file.

  $ png2pat pattern.png > pattern.pat



=item 4.

Place the pattern file in the pattern directory specified in the config file.


=back



=head1 BUGS

In some situations. C<import> command cannot produce the correct screen capture.
It seems that some windows create black shodows in the capture even if they are behind other windows.
Workaround for this problem is to close or minimize such problematic windows.


=head1 AUTHOR

Toshio ITO

=cut




