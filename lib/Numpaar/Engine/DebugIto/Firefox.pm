package Numpaar::Engine::DebugIto::Firefox;
use strict;
use base "Numpaar::Engine";

our $keys_link = ['ctrl+u', 'e'];
our $keys_link_newtab = ['ctrl+u', 'shift+e'];
our $keys_left_tab = ['ctrl+Page_Up'];
our $keys_right_tab = ['ctrl+Page_Down'];
our $keys_close_tab = ['ctrl+q', 'ctrl+w'];
our $keys_restore_tab = ['ctrl+c', 'u'];

our $keys_back = ['shift+b'];
our $keys_forward = ['shift+f'];
our $keys_bookmark  = ['ctrl+q', 'ctrl+b'];
our $keys_bookmark_finish = ['ctrl+Return', 'ctrl+q', 'ctrl+b'];
our $keys_bookmark_cancel = ['ctrl+q', 'ctrl+b'];
our $keys_fontsize_increase = ['ctrl+q', 'ctrl+plus'];
our $keys_fontsize_decrease = ['ctrl+q', 'ctrl+minus'];
our $keys_fontsize_normal   = ['ctrl+q', 'ctrl+0'];
our $keys_reload = ['F5'];
our $keys_home = ['alt+Home'];
our $defer_immediate = 300;
our $defer_load = 1500;

sub new {
    my ($class) = @_;
    my $self = $class->setupBasic('^Navigator\.Firefox');
    return $self;
}

sub setupBasic {
    my ($class, $pattern) = @_;
    my $self = $class->SUPER::setupBasic($pattern);
    return $self;
}

sub updateLoad {
    my $self = shift;
    $self->getConnection()->comUpdateActive($defer_load);
}

sub updateImmediate {
    my $self = shift;
    $self->getConnection()->comUpdateActive($defer_immediate);
}


sub handler0_left {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return '左タブへ' if defined($want_help);
    $connection->comKeyString(@$keys_left_tab);
    $self->updateImmediate();
    return 0;
}

sub handler0_right {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return '右タブへ' if defined($want_help);
    $connection->comKeyString(@$keys_right_tab);
    $self->updateImmediate();
    return 0;
}

sub handler0_end {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'タブを閉じる' if defined($want_help);
    $connection->comKeyString(@$keys_close_tab);
    $self->updateImmediate();
    return 0;
}

sub handler0_insert {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'ブックマーク' if defined($want_help);
    $connection->comKeyString(@$keys_bookmark);
    $self->setState('BookMark');
    return 0;
}

sub handler0_center {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'リンク' if defined($want_help);
    $connection->comKeyString(@$keys_link);
    $self->setState('Link');
    $self->heap->{'doAfterLink'} = 0;
    return 0;
}

sub handler0_home {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return '拡張モード' if defined($want_help);
    $self->setState('Extended');
    return 0;
}

sub handlerBookMark_center {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return '決定' if defined($want_help);
    $connection->comKeyString(@$keys_bookmark_finish);
    $self->setState(0);
    $self->updateLoad();
    return 0;
}

sub handlerBookMark_insert {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'キャンセル' if defined($want_help);
    $connection->comKeyString(@$keys_bookmark_cancel);
    $self->setState(0);
    return 0;
}

sub handlerBookMark_end {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'タブ' if defined($want_help);
    $connection->comKeyString("Tab");
    return 0;
}

sub handlerBookMark_home {
    my ($self, $want_help) = @_; return $self->handlerBookMark_insert($want_help);
}

sub handlerBookMark_delete {
    my ($self, $want_help) = @_; return $self->handlerBookMark_insert($want_help);
}

sub handlerLink_up {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return '決定' if defined($want_help);
    $connection->comKeyString('Return');
    $self->setState(0);
    $self->updateLoad();
    if($self->heap->{'doAfterLink'}) {
        &{$self->heap->{'doAfterLink'}}($self, $connection);
    }
    return 0;
}

sub handlerLink_left {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return '4' if defined($want_help);
    $connection->comKeyString('4');
    return 0;
}

sub handlerLink_center {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return '5' if defined($want_help);
    $connection->comKeyString('5');
    return 0;
}

sub handlerLink_right {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return '6' if defined($want_help);
    $connection->comKeyString('6');
    return 0;
}

sub handlerLink_down {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'Enter' if defined($want_help);
    $connection->comKeyString('Return');
    return 0;
}

sub handlerLink_home {
    my ($self, $want_help) = @_;
    return $self->handler_delete($want_help);
}

sub handlerLink_page_up {
    my ($self, $want_help) = @_;
    return $self->handler_delete($want_help);
}

sub handlerLink_end {
    my ($self, $want_help) = @_;
    return $self->handler_delete($want_help);
}

sub handlerLink_page_down {
    my ($self, $want_help) = @_;
    return $self->handler_delete($want_help);
}

sub handlerLink_insert {
    my ($self, $want_help) = @_;
    return $self->handler_delete($want_help);
}

sub handlerExtended_home {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'リンク(新タブ)' if defined($want_help);
    $connection->comKeyString(@$keys_link_newtab);
    $self->setState('Link');
    $self->heap->{'doAfterLink'} = 0;
    return 0;
}

sub handlerExtended_left {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return '戻る' if defined($want_help);
    $connection->comKeyString(@$keys_back);
    $self->updateLoad();
    $self->setState(0);
    return 0;
}

sub handlerExtended_right {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return '進む' if defined($want_help);
    $connection->comKeyString(@$keys_forward);
    $self->updateLoad();
    $self->setState(0);
    return 0;
}

sub handlerExtended_up {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return '文字大きく' if defined($want_help);
    $connection->comKeyString(@$keys_fontsize_increase);
    $self->setState("FontSize");
    return 0;
}

sub handlerExtended_down {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return '文字小さく' if defined($want_help);
    $connection->comKeyString(@$keys_fontsize_decrease);
    $self->setState("FontSize");
    return 0;
}

sub handlerExtended_page_up {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'リロード' if defined($want_help);
    $connection->comKeyString(@$keys_reload);
    $self->updateLoad();
    $self->setState(0);
    return 0;
}

sub handlerExtended_page_down {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'ホーム' if defined($want_help);
    $connection->comKeyString(@$keys_home);
    $self->updateLoad();
    $self->setState(0);
    return 0;
}

sub handlerExtended_center {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return '文字通常' if defined($want_help);
    $connection->comKeyString(@$keys_fontsize_normal);
    $self->setState(0);
    return 0;
}

sub afterStringCopy {
    my ($self, $connection) = @_;
    $connection->comKeyString('ctrl+x', "g", "ctrl+a", "space", "Left");
    $self->setState("Search");
}

sub handlerExtended_insert {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return '文字列コピー' if defined($want_help);
    $connection->comKeyType(';Y');
    $self->setState('Link');
    $self->heap->{'doAfterLink'} = \&afterStringCopy;
    return 0;
}

sub handlerExtended_end {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'タブを戻す' if defined($want_help);
    $connection->comKeyString(@$keys_restore_tab);
    $self->updateLoad();
    $self->setState(0);
    return 0;
}

sub handlerFontSize_center {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return '終了' if defined($want_help);
    $self->setState(0);
    return 0;
}

sub handlerFontSize_up   { my ($self, $want_help) = @_; return $self->handlerExtended_up  ($want_help); }
sub handlerFontSize_down { my ($self, $want_help) = @_; return $self->handlerExtended_down($want_help); }
sub handlerFontSize_home { my ($self, $want_help) = @_; return $self->handlerFontSize_center($want_help); }
sub handlerFontSize_end { my ($self, $want_help) = @_; return $self->handlerFontSize_center($want_help); }
sub handlerFontSize_left { my ($self, $want_help) = @_; return $self->handlerFontSize_center($want_help); }
sub handlerFontSize_right { my ($self, $want_help) = @_; return $self->handlerFontSize_center($want_help); }
sub handlerFontSize_page_up { my ($self, $want_help) = @_; return $self->handlerFontSize_center($want_help); }
sub handlerFontSize_page_down { my ($self, $want_help) = @_; return $self->handlerFontSize_center($want_help); }
sub handlerFontSize_insert { my ($self, $want_help) = @_; return $self->handlerFontSize_center($want_help); }

sub handlerSearch_page_up {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return '前の検索エンジン' if defined($want_help);
    $connection->comKeyString('ctrl+Up');
    return 0;
}

sub handlerSearch_page_down {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return '次の検索エンジン' if defined($want_help);
    $connection->comKeyString('ctrl+Down');
    return 0;
}

sub handlerSearch_up {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'Backspace' if defined($want_help);
    $connection->comKeyString('BackSpace');
    return 0;
}

sub handlerSearch_home {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'クリアして貼り付け' if defined($want_help);
    $connection->comKeyString('ctrl+a', 'ctrl+k', 'ctrl+y', 'alt+y');
    return 0;
}

sub handlerSearch_end {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return '貼り付け' if defined($want_help);
    $connection->comKeyString('ctrl+y');
    return 0;
}

sub handlerSearch_center {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return '検索' if defined($want_help);
    $connection->comKeyString('Return');
    $self->updateLoad();
    $self->setState(0);
    return 0;
}

sub handler_delete {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'キャンセル' if defined($want_help);
    $connection->comKeyString('ctrl+g');
    $self->setState(0);
    return 0;
}

1;
