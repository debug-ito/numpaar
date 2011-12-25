package Numpaar::Engine::DebugIto::Firefox;
use strict;
use base "Numpaar::Engine";

sub new {
    my ($class) = @_;
    my $self = $class->setupBasic('^Navigator\.Firefox');
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
    $self->{'firefox_defer_immediate'} = 300;
    $self->{'firefox_defer_load'}      = 1500;
}

sub updateLoad {
    my $self = shift;
    $self->getConnection()->comUpdateActive($self->{firefox_defer_load});
}

sub updateImmediate {
    my $self = shift;
    $self->getConnection()->comUpdateActive($self->{firefox_defer_immediate});
}


sub handler0_left {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return '左タブへ' if defined($want_help);
    $connection->comKeyString('ctrl+Page_Up');
    $self->updateImmediate();
    ## $connection->comUpdateActive($self->{'firefox_defer_immediate'});
    return 0;
}

sub handler0_right {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return '右タブへ' if defined($want_help);
    $connection->comKeyString('ctrl+Page_Down');
    $self->updateImmediate();
    ## $connection->comUpdateActive($self->{'firefox_defer_immediate'});
    return 0;
}

sub handler0_end {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'タブを閉じる' if defined($want_help);
    $connection->comKeyString('ctrl+q', 'ctrl+w');
    $self->updateImmediate();
    ## $connection->comUpdateActive($self->{'firefox_defer_immediate'});
    return 0;
}

sub handler0_insert {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'ブックマーク' if defined($want_help);
    $connection->comKeyString('ctrl+q', 'ctrl+b');
    $self->setState('BookMark');
    return 0;
}

sub handler0_center {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'リンク' if defined($want_help);
    $connection->comKeyString('ctrl+u', 'e');
    $self->setState('Link');
    $self->{'doAfterLink'} = 0;
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
    $connection->comKeyString('ctrl+Return', 'ctrl+q', 'ctrl+b');
    $self->setState(0);
    $self->updateLoad();
    ## $connection->comUpdateActive($self->{'firefox_defer_load'});
    return 0;
}

sub handlerBookMark_insert {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'キャンセル' if defined($want_help);
    $connection->comKeyString('ctrl+q', 'ctrl+b');
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
    ## $connection->comUpdateActive($self->{'firefox_defer_load'});
    if($self->{'doAfterLink'}) {
        &{$self->{'doAfterLink'}}($self, $connection);
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
    $connection->comKeyString('ctrl+u', 'shift+e');
    $self->setState('Link');
    $self->{'doAfterLink'} = 0;
    return 0;
}

sub handlerExtended_left {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return '戻る' if defined($want_help);
    $connection->comKeyString('shift+b');
    $self->updateLoad();
    ## $connection->comUpdateActive($self->{'firefox_defer_load'});
    $self->setState(0);
    return 0;
}

sub handlerExtended_right {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return '進む' if defined($want_help);
    $connection->comKeyString('shift+f');
    $self->updateLoad();
    ## $connection->comUpdateActive($self->{'firefox_defer_load'});
    $self->setState(0);
    return 0;
}

sub handlerExtended_up {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return '文字大きく' if defined($want_help);
    $connection->comKeyString('ctrl+q', 'ctrl+plus');
    $self->setState("FontSize");
    return 0;
}

sub handlerExtended_down {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return '文字小さく' if defined($want_help);
    $connection->comKeyString('ctrl+q', 'ctrl+minus');
    $self->setState("FontSize");
    return 0;
}

sub handlerExtended_page_up {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'リロード' if defined($want_help);
    $connection->comKeyString('F5');
    $self->updateLoad();
    ## $connection->comUpdateActive($self->{'firefox_defer_load'});
    $self->setState(0);
    return 0;
}

sub handlerExtended_page_down {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'ホーム' if defined($want_help);
    $connection->comKeyString('alt+Home');
    $self->updateLoad();
    ## $connection->comUpdateActive($self->{'firefox_defer_load'});
    $self->setState(0);
    return 0;
}

sub handlerExtended_center {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return '文字通常' if defined($want_help);
    $connection->comKeyString('ctrl+q', 'ctrl+0');
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
    $self->{'doAfterLink'} = \&afterStringCopy;
    return 0;
}

sub handlerExtended_end {
    my ($self, $want_help) = @_;
    my $connection = $self->getConnection();
    return 'タブを戻す' if defined($want_help);
    $connection->comKeyString('ctrl+c', 'u');
    $self->updateLoad();
    ## $connection->comUpdateActive($self->{'firefox_defer_load'});
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
    ## $connection->comUpdateActive($self->{'firefox_defer_load'});
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
