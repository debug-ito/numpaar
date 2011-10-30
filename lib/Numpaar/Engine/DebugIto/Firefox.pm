package Numpaar::Engine::DebugIto::Firefox;
use strict;
use base "Numpaar::Engine";

sub new() {
    my ($class) = @_;
    my $self = $class->setupBasic('^Navigator\.Firefox');
    $self->setDeferTimes();
    return $self;
}

sub setDeferTimes() {
    my ($self) = @_;
    $self->{'defer_immediate'} = 300;
    $self->{'defer_load'}      = 1500;
}

sub map0_left() {
    my ($self, $connection, $want_help) = @_;
    return '左タブへ' if defined($want_help);
    $connection->comKeyString('ctrl+Page_Up');
    $connection->comUpdateActive($self->{'defer_immediate'});
    return 0;
}

sub map0_right() {
    my ($self, $connection, $want_help) = @_;
    return '右タブへ' if defined($want_help);
    $connection->comKeyString('ctrl+Page_Down');
    $connection->comUpdateActive($self->{'defer_immediate'});
    return 0;
}

sub map0_end() {
    my ($self, $connection, $want_help) = @_;
    return 'タブを閉じる' if defined($want_help);
    $connection->comKeyString('ctrl+q', 'ctrl+w');
    $connection->comUpdateActive($self->{'defer_immediate'});
    return 0;
}

sub map0_insert() {
    my ($self, $connection, $want_help) = @_;
    return 'ブックマーク' if defined($want_help);
    $connection->comKeyString('ctrl+q', 'ctrl+b');
    $self->changeToState($connection, 'BookMark');
    return 0;
}

sub map0_center() {
    my ($self, $connection, $want_help) = @_;
    return 'リンク' if defined($want_help);
    $connection->comKeyString('ctrl+u', 'e');
    $self->changeToState($connection, 'Link');
    $self->{'doAfterLink'} = 0;
    return 0;
}

sub map0_home() {
    my ($self, $connection, $want_help) = @_;
    return '拡張モード' if defined($want_help);
    $self->changeToState($connection, 'Extended');
    return 0;
}

sub mapBookMark_center() {
    my ($self, $connection, $want_help) = @_;
    return '決定' if defined($want_help);
    $connection->comKeyString('ctrl+Return', 'ctrl+q', 'ctrl+b');
    $self->changeToState($connection, 0);
    $connection->comUpdateActive($self->{'defer_load'});
    return 0;
}

sub mapBookMark_insert() {
    my ($self, $connection, $want_help) = @_;
    return 'キャンセル' if defined($want_help);
    $connection->comKeyString('ctrl+q', 'ctrl+b');
    $self->changeToState($connection, 0);
    return 0;
}

sub mapBookMark_end() {
    my ($self, $connection, $want_help) = @_;
    return 'タブ' if defined($want_help);
    $connection->comKeyString("Tab");
    return 0;
}

sub mapBookMark_home() {
    my ($self, $connection, $want_help) = @_; return $self->mapBookMark_insert($connection, $want_help);
}

sub mapBookMark_delete() {
    my ($self, $connection, $want_help) = @_; return $self->mapBookMark_insert($connection, $want_help);
}

sub mapLink_up() {
    my ($self, $connection, $want_help) = @_;
    return '決定' if defined($want_help);
    $connection->comKeyString('Return');
    $self->changeToState($connection, 0);
    $connection->comUpdateActive($self->{'defer_load'});
    if($self->{'doAfterLink'}) {
        &{$self->{'doAfterLink'}}($self, $connection);
    }
    return 0;
}

sub mapLink_left() {
    my ($self, $connection, $want_help) = @_;
    return '4' if defined($want_help);
    $connection->comKeyString('4');
    return 0;
}

sub mapLink_center() {
    my ($self, $connection, $want_help) = @_;
    return '5' if defined($want_help);
    $connection->comKeyString('5');
    return 0;
}

sub mapLink_right() {
    my ($self, $connection, $want_help) = @_;
    return '6' if defined($want_help);
    $connection->comKeyString('6');
    return 0;
}

sub mapLink_down() {
    my ($self, $connection, $want_help) = @_;
    return 'Enter' if defined($want_help);
    $connection->comKeyString('Return');
    return 0;
}

sub mapLink_home() {
    my ($self, $connection, $want_help) = @_;
    return $self->map_delete($connection, $want_help);
}

sub mapLink_page_up() {
    my ($self, $connection, $want_help) = @_;
    return $self->map_delete($connection, $want_help);
}

sub mapLink_end() {
    my ($self, $connection, $want_help) = @_;
    return $self->map_delete($connection, $want_help);
}

sub mapLink_page_down() {
    my ($self, $connection, $want_help) = @_;
    return $self->map_delete($connection, $want_help);
}

sub mapLink_insert() {
    my ($self, $connection, $want_help) = @_;
    return $self->map_delete($connection, $want_help);
}

sub mapExtended_home() {
    my ($self, $connection, $want_help) = @_;
    return 'リンク(新タブ)' if defined($want_help);
    $connection->comKeyString('ctrl+u', 'shift+e');
    $self->changeToState($connection, 'Link');
    $self->{'doAfterLink'} = 0;
    return 0;
}

sub mapExtended_left() {
    my ($self, $connection, $want_help) = @_;
    return '戻る' if defined($want_help);
    $connection->comKeyString('shift+b');
    $connection->comUpdateActive($self->{'defer_load'});
    $self->changeToState($connection, 0);
    return 0;
}

sub mapExtended_right() {
    my ($self, $connection, $want_help) = @_;
    return '進む' if defined($want_help);
    $connection->comKeyString('shift+f');
    $connection->comUpdateActive($self->{'defer_load'});
    $self->changeToState($connection, 0);
    return 0;
}

sub mapExtended_up() {
    my ($self, $connection, $want_help) = @_;
    return '文字大きく' if defined($want_help);
    $connection->comKeyString('ctrl+q', 'ctrl+plus');
    $self->changeToState($connection, "FontSize");
    return 0;
}

sub mapExtended_down() {
    my ($self, $connection, $want_help) = @_;
    return '文字小さく' if defined($want_help);
    $connection->comKeyString('ctrl+q', 'ctrl+minus');
    $self->changeToState($connection, "FontSize");
    return 0;
}

sub mapExtended_page_up() {
    my ($self, $connection, $want_help) = @_;
    return 'リロード' if defined($want_help);
    $connection->comKeyString('F5');
    $connection->comUpdateActive($self->{'defer_load'});
    $self->changeToState($connection, 0);
    return 0;
}

sub mapExtended_page_down() {
    my ($self, $connection, $want_help) = @_;
    return 'ホーム' if defined($want_help);
    $connection->comKeyString('alt+Home');
    $connection->comUpdateActive($self->{'defer_load'});
    $self->changeToState($connection, 0);
    return 0;
}

sub mapExtended_center() {
    my ($self, $connection, $want_help) = @_;
    return '文字通常' if defined($want_help);
    $connection->comKeyString('ctrl+q', 'ctrl+0');
    $self->changeToState($connection, 0);
    return 0;
}

sub afterStringCopy() {
    my ($self, $connection) = @_;
    $connection->comKeyString('ctrl+x', "g", "ctrl+a", "space", "Left");
    $self->changeToState($connection, "Search");
}

sub mapExtended_insert() {
    my ($self, $connection, $want_help) = @_;
    return '文字列コピー' if defined($want_help);
    $connection->comKeyType(';Y');
    $self->changeToState($connection, 'Link');
    $self->{'doAfterLink'} = \&afterStringCopy;
    return 0;
}

sub mapExtended_end() {
    my ($self, $connection, $want_help) = @_;
    return 'タブを戻す' if defined($want_help);
    $connection->comKeyString('ctrl+c', 'u');
    $connection->comUpdateActive($self->{'defer_load'});
    $self->changeToState($connection, 0);
    return 0;
}

sub mapFontSize_center() {
    my ($self, $connection, $want_help) = @_;
    return '終了' if defined($want_help);
    $self->changeToState($connection, 0);
    return 0;
}

sub mapFontSize_up()   { my ($self, $connection, $want_help) = @_; return $self->mapExtended_up($connection, $want_help); }
sub mapFontSize_down() { my ($self, $connection, $want_help) = @_; return $self->mapExtended_down($connection, $want_help); }

sub mapSearch_page_up() {
    my ($self, $connection, $want_help) = @_;
    return '前の検索エンジン' if defined($want_help);
    $connection->comKeyString('ctrl+Up');
    return 0;
}

sub mapSearch_page_down() {
    my ($self, $connection, $want_help) = @_;
    return '次の検索エンジン' if defined($want_help);
    $connection->comKeyString('ctrl+Down');
    return 0;
}

sub mapSearch_up() {
    my ($self, $connection, $want_help) = @_;
    return 'Backspace' if defined($want_help);
    $connection->comKeyString('BackSpace');
    return 0;
}

sub mapSearch_home() {
    my ($self, $connection, $want_help) = @_;
    return 'クリアして貼り付け' if defined($want_help);
    $connection->comKeyString('ctrl+a', 'ctrl+k', 'ctrl+y', 'alt+y');
    return 0;
}

sub mapSearch_end() {
    my ($self, $connection, $want_help) = @_;
    return '貼り付け' if defined($want_help);
    $connection->comKeyString('ctrl+y');
    return 0;
}

sub mapSearch_center() {
    my ($self, $connection, $want_help) = @_;
    return '検索' if defined($want_help);
    $connection->comKeyString('Return');
    $connection->comUpdateActive($self->{'defer_load'});
    $self->changeToState($connection, 0);
    return 0;
}

sub map_delete() {
    my ($self, $connection, $want_help) = @_;
    return 'キャンセル' if defined($want_help);
    $connection->comKeyString('ctrl+g');
    $self->changeToState($connection, 0);
    return 0;
}

1;
