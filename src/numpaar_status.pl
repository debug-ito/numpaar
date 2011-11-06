#!/usr/bin/perl -w

use strict;
use warnings;
use IO::Handle;
use Gtk2 -init;
use Pango;
use FindBin;
use Encode;

my $BUTTON_WIDTH  = 70;
my $BUTTON_HEIGHT = 45;
my $SCRIPT_DIR = $FindBin::Bin;
my $ICON_DIR = $SCRIPT_DIR . "/../resources/";
my %ICON_MAP = ('normal' => "normal.icon.svg", 'busy' => "busy.icon.svg");
my $WIN_X = 0;
my $WIN_Y = 0;
my $LABEL_FONT = "sans 12";
my $READ_LENGTH = 256;

my $window;
my $is_window_shown = 0;
my $status_icon;
my %remote_buttons = ();

my $input_handle;
my $command_read_data = '';

sub setupInput {
    $input_handle = IO::Handle->new();
    my $input_fileno = fileno(STDIN);
    $input_handle->fdopen($input_fileno, "r");
    $input_handle->blocking(0);
    Glib::IO->add_watch($input_fileno, 'G_IO_IN', \&readInput);
    Glib::IO->add_watch($input_fileno, 'G_IO_HUP', \&shutdown);
    Glib::IO->add_watch($input_fileno, 'G_IO_ERR', \&shutdown);
}

sub shutdown {
    Gtk2->main_quit();
    return 1;
}

sub processCommandLine {
    my ($line) = @_;
    chomp $line;
    my @fields = split(/ +/, $line);
    my $key = shift(@fields);
    if($key eq 'toggle') {
        &toggleWindowShow();
    }elsif($key eq 'icon' && @fields) {
        &changeIcon($fields[0]);
    }elsif(defined($remote_buttons{$key})) {
        &setButtonLabel($remote_buttons{$key}, join(' ', @fields));
    }
}

sub readInput {
    my $temp_read_data;
    ## print STDERR "Enter readInput\n";
    while($input_handle->sysread($temp_read_data, $READ_LENGTH)) {
        ## print STDERR "READ:$temp_read_data\n";
        $command_read_data .= $temp_read_data;
        while($command_read_data =~ s/^(.+?)[\r\n]+//) {
            my $line = $1;
            &processCommandLine($line);
        }
    }
    return 1;
}

sub changeIcon {
    my ($icon_id) = @_;
    if(!defined($ICON_MAP{$icon_id})) {
        print STDERR "Status: No such icon ID as $icon_id\n";
        return;
    }
    $status_icon->set_from_file($ICON_DIR . $ICON_MAP{$icon_id});
}

sub setButtonLabel {
    my ($button, $label) = @_;
    $button->get_child()->set_label(decode('utf8', $label));
}

sub toggleWindowShow {
    if($is_window_shown) {
        $is_window_shown = 0;
        $window->hide();
    }else {
        $is_window_shown = 1;
        $window->show_all();
    }
}

sub addButton {
    my ($table, $left, $right, $top, $bottom, $keystr, $default_label) = @_;
    my $newbutton = Gtk2::Button->new();
    my $newlabel = Gtk2::Label->new(decode('utf8', $default_label));
    $newlabel->set_line_wrap(1);
    $newlabel->set_alignment(0, 0.5);
    $newlabel->set_justify('GTK_JUSTIFY_LEFT');
    $newlabel->modify_font(Gtk2::Pango::FontDescription->from_string($LABEL_FONT));
    $newbutton->set_alignment(0, 0.5);
    $newbutton->add($newlabel);
    $table->attach_defaults($newbutton, $left, $right, $top, $bottom);
    $newlabel->set_size_request($BUTTON_WIDTH * ($right - $left), $BUTTON_HEIGHT * ($bottom - $top));
    $remote_buttons{$keystr} = $newbutton;
}

sub setupButtons {
    my ($table) = @_;
    &addButton($table, 0, 1, 0, 1, "numlock",  "NumLock");
    &addButton($table, 1, 2, 0, 1, "divide",   "/");
    &addButton($table, 2, 3, 0, 1, "multiply", "*");
    &addButton($table, 3, 4, 0, 1, "minus",    "-");
    &addButton($table, 0, 1, 1, 2, "home",     "7");
    &addButton($table, 1, 2, 1, 2, "up",       "8");
    &addButton($table, 2, 3, 1, 2, "page_up",  "9");
    &addButton($table, 3, 4, 1, 3, "plus",     "+");
    &addButton($table, 0, 1, 2, 3, "left",     "4");
    &addButton($table, 1, 2, 2, 3, "center",   "5");
    &addButton($table, 2, 3, 2, 3, "right",    "6");
    &addButton($table, 0, 1, 3, 4, "end",      "1");
    &addButton($table, 1, 2, 3, 4, "down",     "2");
    &addButton($table, 2, 3, 3, 4, "page_down","3");
    &addButton($table, 3, 4, 3, 5, "enter",    "Enter");
    &addButton($table, 0, 2, 4, 5, "insert",   "0");
    &addButton($table, 2, 3, 4, 5, "delete",   ".");
}

sub setupGtk {
    $window = Gtk2::Window->new();
    $window->signal_connect('delete_event' => sub { print STDERR "Status: delete.\n"; Gtk2->main_quit()} );
    $window->signal_connect('destroy' => sub {print STDERR "Status: destroy.\n"; } );
    $window->set_keep_above(1);
    $window->set_skip_pager_hint(1);
    $window->set_skip_taskbar_hint(1);
    $window->set_accept_focus(0);
    my $maintable = Gtk2::Table->new(5, 4, 0);
    &setupButtons($maintable);
    $window->add($maintable);
    $window->set_title("Numpaar Status");
    $window->move($WIN_X, $WIN_Y);
    $status_icon = Gtk2::StatusIcon->new_from_file($ICON_DIR . $ICON_MAP{normal});
}

sub main {
    &setupGtk();
    &setupInput();
    Gtk2->main();
}

&main();


