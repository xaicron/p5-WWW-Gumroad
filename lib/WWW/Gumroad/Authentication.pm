package WWW::Gumroad::Authentication;

use strict;
use warnings;
use Carp qw(croak);
use LWP::UserAgent;
use HTTP::Request;

use WWW::Gumroad;
use WWW::Gumroad::Response;

sub new {
    my ($class, %args) = @_;
    $args{ua} ||= LWP::UserAgent->new(
        agent => "WWW::Gumroad / $WWW::Gumroad::VERSION",
    );

    bless {
        ua      => $args{ua},
        api_url => $args{api_url} || $WWW::Gumroad::API_BASE_URL.'/sessions',
    }, $class;
}

sub create {
    my ($self, $email, $password) = @_;
    croak 'Usage: $self->create($email, $password)' unless $email && $password;

    my $res = $self->{ua}->post(
        $WWW::Gumroad::API_BASE_URL . '/sessions',
        [ email => $email, password => $password ],
    );
    return WWW::Gumroad::Response->new($res);
}

sub delete {
    my ($self, $token) = @_;
    croak 'Usage: $self->delete($token)' unless $token;

    my $req = HTTP::Request->new(DELETE => $self->{api_url});
    $req->authorization_basic($token, '');

    my $res = $self->{ua}->request($req);
    return WWW::Gumroad::Response->new($res);
}

1;
__END__

=encoding utf-8

=for stopwords

=head1 NAME

WWW::Gumroad::Authentication - Authenticates the user's session

=head1 SYNOPSIS

  use Data::Dumper;
  use WWW::Gumroad::Authentication;

  my $authen = WWW::Gumroad::Authentication->new;
  my $res = $authen->create($email, $password);
  die Dumper $res->error if $res->is_error;
  my $token = $res->data->{token};

=head1 DESCRIPTION

WWW::Gumroad::Authentication is Authenticates the user's session for Gumroad API.

THIS MODULE IS ALPHA LEVEL INTERFACE. MAY BE CHANGED.

=head1 METHODS

=head2 new(%args)

Create a new WWW::Gumroad::Authentication instance.

  my $client = WWW::Gumroad->new;

supported options are:

=over

=item api_url : Str

Sets Gumroad Authentication API url. default is C<< $WWW::Gumroad::API_BASE_URL.'/sessions' >>.

=item ua : LWP::UserAgent

Sets HTTP Client. default is L<< LWP::UserAgent >>.

=back

=head2 $client->create($email, $password)

Authenticates the user's session. Returned value is L<< WWW::Gumroad::Response >>.

=head2 $client->delete($token)

Revokes the user's session.

=head1 AUTHOR

xaicron E<lt>xaicron {at} cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2012 - xaicron

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
