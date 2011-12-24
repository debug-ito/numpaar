package Numpaar::Engine::DebugIto::Firefox;
use strict;
use base "Numpaar::Engine";

sub new {
    my ($class) = @_;
    my $self = $class->setupBasic('^Navigator\.Firefox');
    ## $self->setDeferTimes();
    return $self;
}

sub setupBasic {
    my ($class, $pattern) = @_;
    my $self = $class->SUPER::setupBasic($pattern);
    $self->setDeferTimes();
    return $self;
}
    

sub setDeferTimes {
    my ($self) = @_;
    $self->{'defer_immediate'} = 300;
    $self->{'defer_load'}      = 1500;
}

sub handler0_left {
    my ($self, $connection, $want_help) = @_;
    return '左タブへ' if defined($want_help);
    $connection->comKeyString('ctrl+Page_Up');
    $connection->comUpdateActive($self->{'defer_immediate'});
    return 0;
}

sub handler0_right {
    my ($self, $connection, $want_help) = @_;
    return '右タブへ' if defined($want_help);
    $connection->comKeyString('ctrl+Page_Down');
    $connection->comUpdateActive($self->{'defer_immediate'});
    return 0;
}

sub handler0_end {
    my ($self, $connection, $want_help) = @_;
    return 'タブを閉じる' if defined($want_help);
    $connection->comKeyString('ctrl+q', 'ctrl+w');
    $connection->comUpdateActive($self->{'defer_immediate'});
    return 0;
}

sub handler0_insert {
    my ($self, $connection, $want_help) = @_;
    return 'ブックマーク' if defined($want_help);
    $connection->comKeyString('ctrl+q', 'ctrl+b');
    $self->setState('BookMark', $connection);
    return 0;
}

sub handler0_center {
    my ($self, $connection, $want_help) = @_;
    return 'リンク' if defined($want_help);
    $connection->comKeyString('ctrl+u', 'e');
    $self->setState('Link', $connection);
    $self->{'doAfterLink'} = 0;
    return 0;
}

sub handler0_home {
    my ($self, $connection, $want_help) = @_;
    return '拡張モード' if defined($want_help);
    $self->setState('Extended', $connection);
    return 0;
}

sub handlerBookMark_center {
    my ($self, $connection, $want_help) = @_;
    return '決定' if defined($want_help);
    $connection->comKeyString('ctrl+Return', 'ctrl+q', 'ctrl+b');
    $self->setState(0, $connection);
    $connection->comUpdateActive($self->{'defer_load'});
    return 0;
}

sub handlerBookMark_insert {
    my ($self, $connection, $want_help) = @_;
    return 'キャンセル' if defined($want_help);
    $connection->comKeyString('ctrl+q', 'ctrl+b');
    $self->setState(0, $connection);
    return 0;
}

sub handlerBookMark_end {
    my ($self, $connection, $want_help) = @_;
    return 'タブ' if defined($want_help);
    $connection->comKeyString("Tab");
    return 0;
}

sub handlerBookMark_home {
    my ($self, $connection, $want_help) = @_; return $self->handlerBookMark_insert($connection, $want_help);
}

sub handlerBookMark_delete {
    my ($self, $connection, $want_help) = @_; return $self->handlerBookMark_insert($connection, $want_help);
}

sub handlerLink_up {
    my ($self, $connection, $want_help) = @_;
    return '決定' if defined($want_help);
    $connection->comKeyString('Return');
    $self->setState(0, $connection);
    $connection->comUpdateActive($self->{'defer_load'});
    if($self->{'doAfterLink'}) {
        &{$self->{'doAfterLink'}}($self, $connection);
    }
    return 0;
}

sub handlerLink_left {
    my ($self, $connection, $want_help) = @_;
    return '4' if defined($want_help);
    $connection->comKeyString('4');
    return 0;
}

sub handlerLink_center {
    my ($self, $connection, $want_help) = @_;
    return '5' if defined($want_help);
    $connection->comKeyString('5');
    return 0;
}

sub handlerLink_right {
    my ($self, $connection, $want_help) = @_;
    return '6' if defined($want_help);
    $connection->comKeyString('6');
    return 0;
}

sub handlerLink_down {
    my ($self, $connection, $want_help) = @_;
    return 'Enter' if defined($want_help);
    $connection->comKeyString('Return');
    return 0;
}

sub handlerLink_home {
    my ($self, $connection, $want_help) = @_;
    return $self->handler_delete($connection, $want_help);
}

sub handlerLink_page_up {
    my ($self, $connection, $want_help) = @_;
    return $self->handler_delete($connection, $want_help);
}

sub handlerLink_end {
    my ($self, $connection, $want_help) = @_;
    return $self->handler_delete($connection, $want_help);
}

sub handlerLink_page_down {
    my ($self, $connection, $want_help) = @_;
    return $self->handler_delete($connection, $want_help);
}

sub handlerLink_insert {
    my ($self, $connection, $want_help) = @_;
    return $self->handler_delete($connection, $want_help);
}

sub handlerExtended_home {
    my ($self, $connection, $want_help) = @_;
    return 'リンク(新タブ)' if defined($want_help);
    $connection->comKeyString('ctrl+u', 'shift+e');
    $self->setState('Link', $connection);
    $self->{'doAfterLink'} = 0;
    return 0;
}

sub handlerExtended_left {
    my ($self, $connection, $want_help) = @_;
    return '戻る' if defined($want_help);
    $connection->comKeyString('shift+b');
    $connection->comUpdateActive($self->{'defer_load'});
    $self->setState(0, $connection);
    return 0;
}

sub handlerExtended_right {
    my ($self, $connection, $want_help) = @_;
    return '進む' if defined($want_help);
    $connection->comKeyString('shift+f');
    $connection->comUpdateActive($self->{'defer_load'});
    $self->setState(0, $connection);
    return 0;
}

sub handlerExtended_up {
    my ($self, $connection, $want_help) = @_;
    return '文字大きく' if defined($want_help);
    $connection->comKeyString('ctrl+q', 'ctrl+plus');
    $self->setState("FontSize", $connection);
    return 0;
}

sub handlerExtended_down {
    my ($self, $connection, $want_help) = @_;
    return '文字小さく' if defined($want_help);
    $connection->comKeyString('ctrl+q', 'ctrl+minus');
    $self->setState("FontSize", $connection);
    return 0;
}

sub handlerExtended_page_up {
    my ($self, $connection, $want_help) = @_;
    return 'リロード' if defined($want_help);
    $connection->comKeyString('F5');
    $connection->comUpdateActive($self->{'defer_load'});
    $self->setState(0, $connection);
    return 0;
}

sub handlerExtended_page_down {
    my ($self, $connection, $want_help) = @_;
    return 'ホーム' if defined($want_help);
    $connection->comKeyString('alt+Home');
    $connection->comUpdateActive($self->{'defer_load'});
    $self->setState(0, $connection);
    return 0;
}

sub handlerExtended_center {
    my ($self, $connection, $want_help) = @_;
    return '文字通常' if defined($want_help);
    $connection->comKeyString('ctrl+q', 'ctrl+0');
    $self->setState(0, $connection);
    return 0;
}

sub afterStringCopy {
    my ($self, $connection) = @_;
    $connection->comKeyString('ctrl+x', "g", "ctrl+a", "space", "Left");
    $self->setState("Search", $connection);
}

sub handlerExtended_insert {
    my ($self, $connection, $want_help) = @_;
    return '文字列コピー' if defined($want_help);
    $connection->comKeyType(';Y');
    $self->setState('Link', $connection);
    $self->{'doAfterLink'} = \&afterStringCopy;
    return 0;
}

sub handlerExtended_end {
    my ($self, $connection, $want_help) = @_;
    return 'タブを戻す' if defined($want_help);
    $connection->comKeyString('ctrl+c', 'u');
    $connection->comUpdateActive($self->{'defer_load'});
    $self->setState(0, $connection);
    return 0;
}

sub handlerFontSize_center {
    my ($self, $connection, $want_help) = @_;
    return '終了' if defined($want_help);
    $self->setState(0, $connection);
    return 0;
}

sub handlerFontSize_up   { my ($self, $connection, $want_help) = @_; return $self->handlerExtended_up($connection, $want_help); }
sub handlerFontSize_down { my ($self, $connection, $want_help) = @_; return $self->handlerExtended_down($connection, $want_help); }

sub handlerSearch_page_up {
    my ($self, $connection, $want_help) = @_;
    return '前の検索エンジン' if defined($want_help);
    $connection->comKeyString('ctrl+Up');
    return 0;
}

sub handlerSearch_page_down {
    my ($self, $connection, $want_help) = @_;
    return '次の検索エンジン' if defined($want_help);
    $connection->comKeyString('ctrl+Down');
    return 0;
}

sub handlerSearch_up {
    my ($self, $connection, $want_help) = @_;
    return 'Backspace' if defined($want_help);
    $connection->comKeyString('BackSpace');
    return 0;
}

sub handlerSearch_home {
    my ($self, $connection, $want_help) = @_;
    return 'クリアして貼り付け' if defined($want_help);
    $connection->comKeyString('ctrl+a', 'ctrl+k', 'ctrl+y', 'alt+y');
    return 0;
}

sub handlerSearch_end {
    my ($self, $connection, $want_help) = @_;
    return '貼り付け' if defined($want_help);
    $connection->comKeyString('ctrl+y');
    return 0;
}

sub handlerSearch_center {
    my ($self, $connection, $want_help) = @_;
    return '検索' if defined($want_help);
    $connection->comKeyString('Return');
    $connection->comUpdateActive($self->{'defer_load'});
    $self->setState(0, $connection);
    return 0;
}

sub handler_delete {
    my ($self, $connection, $want_help) = @_;
    return 'キャンセル' if defined($want_help);
    $connection->comKeyString('ctrl+g');
    $self->setState(0, $connection);
    return 0;
}

1;
