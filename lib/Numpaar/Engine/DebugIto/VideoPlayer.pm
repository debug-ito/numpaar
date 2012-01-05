package Numpaar::Engine::DebugIto::VideoPlayer;
use strict;

my @video_key_list = qw(play_pause volume_up volume_down back_normal forward_normal back_big forward_big back_small forward_small);

sub videoPlayerSetKeys {
    my ($self, %params) = @_;
    my %videokeys = ();
    foreach my $key_symbol (@video_key_list) {
        $videokeys{$key_symbol} = defined($params{$key_symbol}) ? $params{$key_symbol} : [];
    }
    $self->heap->{videoplayer_keys} = \%videokeys;
}

sub videoPlayerSend {
    my ($self, $key_symbol) = @_;
    my $keys_hash = $self->heap->{videoplayer_keys};
    return if !defined($keys_hash->{$key_symbol});
    my $keylist_ref = ref($keys_hash->{$key_symbol}) ? $keys_hash->{$key_symbol} : [$keys_hash->{$key_symbol}];
    $self->getConnection()->comKeyString(@$keylist_ref);
}

sub videoPlayerState {
    my ($self, $set_state) = @_;
    $self->heap->{videoplayer_state} = lc($set_state) if defined($set_state);
    return $self->heap->{videoplayer_state};
}

sub handlerVideo_center {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'Play/Pause' if defined($want_help);
    $self->videoPlayerSend('play_pause');
    if(defined($self->videoPlayerState)) {
        if($self->videoPlayerState eq 'play') {
            $self->videoPlayerState('pause');
        }else {
            $self->videoPlayerState('play');
        }
    }
    return 0;
}

sub handlerVideo_up {
    my ($self, $want_help) = @_;
    ## my $connection = $self->getConnection();
    return 'Vol up' if defined($want_help);
    $self->videoPlayerSend('volume_up');
    ## $connection->comKeyString(@{$self->{'volume_up'}});
    return 0;
}

sub handlerVideo_down {
    my ($self, $want_help) = @_;
    ## my $connection = $self->getConnection();
    return 'Vol down' if defined($want_help);
    $self->videoPlayerSend('volume_down');
    ## $connection->comKeyString(@{$self->{'volume_down'}});
    return 0;
}

sub handlerVideo_home {
    my ($self, $want_help) = @_;
    ## my $connection = $self->getConnection();
    return 'Back (L)' if defined($want_help);
    $self->videoPlayerSend('back_big');
    ## $connection->comKeyString(@{$self->{'back_big'}});
    return 0;
}

sub handlerVideo_left {
    my ($self, $want_help) = @_;
    ## my $connection = $self->getConnection();
    return 'Back (M)' if defined($want_help);
    $self->videoPlayerSend('back_normal');
    ## $connection->comKeyString(@{$self->{'back_normal'}});
    return 0;
}

sub handlerVideo_end {
    my ($self, $want_help) = @_;
    ## my $connection = $self->getConnection();
    return 'Back (S)' if defined($want_help);
    $self->videoPlayerSend('back_small');
    ## $connection->comKeyString(@{$self->{'back_small'}});
    return 0;
}

sub handlerVideo_page_up {
    my ($self, $want_help) = @_;
    ## my $connection = $self->getConnection();
    return 'Forward (L)' if defined($want_help);
    $self->videoPlayerSend('forward_big');
    ## $connection->comKeyString(@{$self->{'forward_big'}});
    return 0;
}

sub handlerVideo_right {
    my ($self, $want_help) = @_;
    ## my $connection = $self->getConnection();
    return 'Forward (M)' if defined($want_help);
    $self->videoPlayerSend('forward_normal');
    ## $connection->comKeyString(@{$self->{'forward_normal'}});
    return 0;
}

sub handlerVideo_page_down {
    my ($self, $want_help) = @_;
    ## my $connection = $self->getConnection();
    return 'Forward (S)' if defined($want_help);
    $self->videoPlayerSend('forward_small');
    ## $connection->comKeyString(@{$self->{'forward_small'}});
    return 0;
}


1;

__END__


=pod


=head1 NAME

Numpaar::Engine::DebugIto::VideoPlayer - generic key bindings for video players

=head1 SYNOPSIS

  package Numpaar::Engine::SamplePlayer;
  use base qw(Numpaar::Engine Numpaar::Engine::DebugIto::VideoPlayer);
  
  sub new {
      my ($class) = @_;
      my $self = $class->setupBasic(".*");
      
      ## Set keys for control
      $self->videoPlayerSetKeys(
          play_pause     => ['p'],
          volume_up      => ['Up'],
          volume_down    => ['Down'],
          back_normal    => ['Left'],
          forward_normal => ['Right'],
          back_big       => ['ctrl+Left'],
          forward_big    => ['ctrl+Right'],
          back_small     => ['shift+Left'],
          forward_small  => ['shift+Right'],
      );
      
      ## Set default player state
      $self->videoPlayerState("play");
      
      ## Get player state
      my $player_state = $self->videoPlayerState();
      
      return $self;      
  }
  
  1;


=head1 DESCRIPTION

Numpaar::Engine::DebugIto::VideoPlayer is actually not an Numpaar Engine.
It is a base class for Numpaar Engines that control videos.


=head1 ENGINE STATES

=over

=item Video

The state where control keys for the media are provided.


=back

=head1 KEYBINDINGS

=over

=item center

Play/Pause

=item up

Volume up

=item down

Volume down

=item left

Seek backward (normal)

=item right

Seek forward (normal)

=item home

Seek backward (large)

=item page_up

Seek forward (large)

=item end

Seek backward (small)

=item page_down

Seek forward (small)

=back


=head1 AUTHOR

Toshio ITO

=head1 SEE ALSO

L<Numpaar::Engine::DebugIto::Totem>, L<Numpaar::Engine::DebugIto::YouTube>


=cut

