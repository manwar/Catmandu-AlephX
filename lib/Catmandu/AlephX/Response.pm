package Catmandu::AlephX::Response;
use Catmandu::AlephX::Sane;
use Moo::Role;
use Data::Util qw(:validate :check);

sub BUILD {
  my $self = $_[0];
  $self->error($self->data()->{error}->[0]);
  $self->session_id($self->data()->{'session-id'}->[0]);
}

=head1 NAME

  Catmandu::AlephX::Response - base class for xml-responses from the AlephX-server

=head1 SYNOPSIS
  
  All responses from the AlephX-server share the same functionality and keys:
    - expressed in XML
    - name of the parent element is equal to the parameter 'op', except when
      the value in 'op' is not recognized. Then it is set to 'login'.
    - when an internal error occurred, the error is reported in the key 'error'
    - session-id is reported in the key 'session-id'
    - al the other subkeys are be treated as 'data'

  All public methods from Catmandu::AlephX return an object of a subclass of Catmandu::AlepX::Response.
  In case of connection errors, or xml parsing problems, exceptions are thrown.

=head1 methods

=head2 op

  type of 'op'.

=head2 error

  internal error that was reported in the xml response.
  These errors only apply to values in your parameters.
  Other errors, like connection errors or problems while parsing the xml response are thrown as exceptions.

=head2 session_id

  session-id of the current request

=head2 is_success

  This method only checks if there was an internal error in the AlephX-response.
  So it simply tests if the key 'error' was undefined.   

  As said before, other errors are thrown as exceptions  

=cut

requires 'op';
has error => (is => 'rw');
has session_id => (is => 'rw');
has data => (
  is => 'ro',
  required => 1,
  isa => sub { hash_ref($_[0]); }
);
sub is_success { return !defined($_[0]->error); }

1;
