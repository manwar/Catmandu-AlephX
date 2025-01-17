package Catmandu::AlephX::Op::ReadItem;
use Catmandu::Sane;
use Catmandu::Util qw(:check :is);
use Moo;

our $VERSION = "1.07";

with('Catmandu::AlephX::Response');

has z30 => (
  is => 'ro',
  lazy => 1,
  isa => sub{
    check_hash_ref($_[0]);
  },
  default => sub {
    {};
  }
);
sub op { 'read-item' }

sub parse {
  my($class,$str_ref) = @_;
  my $xpath = xpath($str_ref);

  my $op = op();

  my @z30;

  for my $z($xpath->find("/$op/z30")->get_nodelist()){
    push @z30,get_children($z,1);
  }

  __PACKAGE__->new(
    session_id => $xpath->findvalue("/$op/session-id"),
    errors => $class->parse_errors($xpath),
    z30 => $z30[0],
    content_ref => $str_ref
  );
}

1;
