package Numpaar::Engine::DebugIto::MainMenu;
use base 'Numpaar::Engine::DebugIto::Thunar';
use Numpaar::Config ('configElement');

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
    system(&configElement('extern_program', 'xdotool'), "search", '--name', $self->heap->{'title'}, 'windowkill');
    return 0;
}

1;

