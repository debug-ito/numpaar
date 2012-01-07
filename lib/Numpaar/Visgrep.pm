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

## sub clickFromBase {
##     my ($self, $connection, $coord_x, $coord_y) = @_;
##     if(!defined($self->baseX) || !defined($self->baseY)) {
##         return 0;
##     }
##     $connection->comMouseClick(1, $self->baseX + $coord_x, $self->baseY + $coord_y);
##     return 1;
## }


1;
