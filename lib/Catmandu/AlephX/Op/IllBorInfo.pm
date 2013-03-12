package Catmandu::AlephX::Op::IllBorInfo;
use Catmandu::AlephX::Sane;
use Data::Util qw(:check :validate);
use Moo;
use Catmandu::AlephX::XPath::Helper qw(:all);

extends('Catmandu::AlephX::Op::BorAuth');
with('Catmandu::AlephX::Response');

has z308 => (
  is => 'ro',
  lazy => 1,
  isa => sub {
    array_ref($_[0]);
  },
  default => sub {
    [];
  }
);

sub op { 'ill-bor-info' } 

sub parse {
  my($class,$xpath)=@_;

  my @keys = qw(z303 z304 z305 z308);
  my %args = ();

  for my $key(@keys){
    my $data = get_children(
      $xpath->find("/ill-bor-info/$key")->get_nodelist()
    );
    $args{$key} = $data;

  }

  __PACKAGE__->new(
    %args,
    session_id => $xpath->findvalue('/ill-bor-info/session-id')->value(),
    error => $xpath->findvalue('/ill-bor-info/error')->value()
  );
  
}

1;
