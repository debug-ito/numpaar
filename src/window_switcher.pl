#!/usr/bin/perl -w

use strict;
use Encode;
use Gtk2 -init;
use Gtk2::SimpleList;

my $XDOTOOL;
my $gtk_window;
my $gtk_list;
my @winlist = ();


sub main() {
    if(@ARGV < 1) {
        die "Please provide the path to xdotool as the argument.";
    }
    $XDOTOOL = $ARGV[0];
    &initGtk();

    while(my $line = <STDIN>) {
        chomp $line;
        next if $line !~ /^(\d+) (.+)$/;
        my ($wid, $name) = ($1, $2);
        ## next if &isInBlackList($name);
        $name = decode('utf8', $name);
        push(@winlist, {'wid' => $wid, 'name' => $name});
        push(@{$gtk_list->{'data'}}, $name);
    }
    close(STDIN);

    if(!@winlist) {
        exit 0;
    }

    $gtk_list->select(1);
    $gtk_window->show_all();
    Gtk2->main;
}

sub escape() {
    my ($str) = @_;
    $str =~ s/([\\\"\$\`])/\\$1/g;
    return $str;
}

sub initGtk() {
    $gtk_window = Gtk2::Window->new('toplevel');
    $gtk_window->signal_connect(delete_event => sub {Gtk2->main_quit;});
    $gtk_window->set_title("Numpaar Switcher");
    $gtk_list = Gtk2::SimpleList->new('Window Name' => 'text');
    $gtk_list->signal_connect(row_activated => \&selected);
    $gtk_window->add($gtk_list);
}

sub selected() {
    my ($treeview, $treepath, $treecol) = @_;
    system($XDOTOOL, 'windowactivate', '--sync', $winlist[$treepath->get_indices()]->{'wid'});
    Gtk2->main_quit;
    exit;
}

&main();



## my $height_cand = 150 + 20 * int(@winlist);
## my $max_height  = 500;
## my $height = ($height_cand > $max_height ? $max_height : $height_cand);



## my $zenity_com = sprintf('%s --list --width 400 --height %d --title "Numpaar Switcher" --text "Window list"'.
##                          ' --hide-column 1 --column index --column Name ', $ZENITY, $height);
## for(my $i = 0 ; $i < @winlist ; $i++) {
##    $zenity_com .= sprintf(' %d "%s"', $i, &escape($winlist[$i]->{'name'}));
## }

## my $selection = `$zenity_com`;
## chomp $selection;
## if($selection eq "") {
##    exit 0;
## }
## printf STDERR ("Switcher Selection: WID:%d NAME:%s\n", $winlist[$selection]->{'wid'}, $winlist[$selection]->{'name'});
## system($XDOTOOL, 'windowactivate', '--sync', $winlist[$selection]->{'wid'});

