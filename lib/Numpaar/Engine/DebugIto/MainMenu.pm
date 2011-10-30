package Numpaar::Engine::DebugIto::MainMenu;
use base 'Numpaar::Engine::DebugIto::Thunar';
use Numpaar::Config ('configElement');

sub new() {
    my ($class, $winclass_winname_pattern, $window_title) = @_;
    my $self = $class->setupBasic("^$winclass_winname_pattern $window_title");
    $self->{'title'} = $window_title;
    return $self;
}

sub map0_center() {
    my ($self, $connection, $want_help) = @_;
    return '決定' if defined($want_help);
    $connection->comKeyString('Return');
    system(&configElement('extern_program', 'xdotool'), "search", '--name', $self->{'title'}, 'windowkill');
    return 0;
}

1;

