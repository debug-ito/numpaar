package Numpaar::Visgrep;

use strict;
use FindBin;
use Numpaar::Config qw(configElement configCheck);

my $SCREENSHOT_PATH = '/tmp/numpaar_visgrep_screenshot.png';

sub getPatternDir {
    my $pattern_dir;
    eval {
        $pattern_dir = &configElement('directory', 'visgrep_patterns');
    };
    if($@) {
        $pattern_dir = $ENV{HOME};
    }
    $pattern_dir .= '/' if $pattern_dir !~ m|/$|;
    return $pattern_dir;
}

sub getLocation {
    my ($class, $pattern_filename, $not_take_shot) = @_;
    &configCheck('extern_program', 'visgrep', 'import');
    if(!defined($not_take_shot) || $not_take_shot != 0) {
        system(sprintf(&configElement('extern_program', 'import') . ' -depth 8 -window root %s', $SCREENSHOT_PATH));
    }
    my $visgrep_command = &configElement('extern_program', 'visgrep');
    my $visgrep_pattern_dir = $class->getPatternDir();
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

sub setBase {
    my ($self, $pattern_file, $pattern_coord, $not_take_shot) = @_;
    my ($x, $y) = Numpaar::Visgrep->getLocation($pattern_file, $not_take_shot);
    if(!defined($x) || !defined($y)) {
        return 0;
    }
    if(!defined($pattern_coord)) {
        $pattern_coord = {'x' => 0, 'y' => 0};
    }
    ($self->{'visgrep_base_x'}, $self->{'visgrep_base_y'}) = ($x - $pattern_coord->{'x'}, $y - $pattern_coord->{'y'});
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

sub clickFromBase {
    my ($self, $connection, $coord) = @_;
    if(!defined($self->{'visgrep_base_x'}) || !defined($self->{'visgrep_base_y'})) {
        return 0;
    }
    $connection->comMouseClick(1, $self->{'visgrep_base_x'} + $coord->{'x'}, $self->{'visgrep_base_y'} + $coord->{'y'});
    return 1;
}


1;
