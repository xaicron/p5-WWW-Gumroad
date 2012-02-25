package WWW::Gumroad;

use strict;
use warnings;
use 5.008_001;
our $VERSION = '0.01';

use URI;
use LWP::UserAgent;
use HTTP::Request;
use Carp qw(croak);

use WWW::Gumroad::Response;

our $API_BASE_URL = 'https://gumroad.com/api/v1';

sub new {
    my ($class, %args) = @_;
    croak 'Usage: $class->new(token => $token)' unless $args{token};

    $args{ua} ||= LWP::UserAgent->new(
        agent => "WWW::Gumroad / $WWW::Gumroad::VERSION",
    );

    bless {
        ua           => $args{ua},
        api_base_url => $args{api_base_url} || $API_BASE_URL,
        token        => $args{token},
    }, $class;
}

for my $method (qw/ua token/) {
    no strict 'refs';
    *$method = sub {
        use strict;
        return shift->{ua} unless @_ > 1;
        shift->{ua} = shift;
    };
}

sub get {
    my ($self, $endpoint) = @_;
    $self->request(method => 'GET', endpoint => $endpoint);
}

sub post {
    my ($self, $endpoint, $content) = @_;
    $self->request(method => 'POST', endpoint => $endpoint, content => $content);
}

sub put {
    my ($self, $endpoint, $content) = @_;
    $self->request(method => 'PUT', endpoint => $endpoint, content => $content);
}

sub delete {
    my ($self, $endpoint) = @_;
    $self->request(method => 'DELETE', endpoint => $endpoint);
}

sub request {
    my ($self, %args) = @_;
    croak '$self->request(method => $method, endpoint => $endpoint)'
        unless $args{method} && $args{endpoint};

    my $req = HTTP::Request->new($args{method}, $self->_endpoint($args{endpoint}));
    if (my $content = $self->_content($args{content})) {
        $req->content($content);
        $req->header('Content-Type' => 'application/x-www-form-urlencoded');
    }
    $req->authorization_basic($self->{token}, '');

    my $res = $self->{ua}->request($req);
    return WWW::Gumroad::Response->new($res);
}

sub _endpoint {
    my ($self, $endpoint) = @_;
    unless ($endpoint =~ /^https/) {
        $endpoint =~ s|^/||;
        $endpoint = $self->{api_base_url}."/$endpoint";
    };

    return $endpoint;
}

sub _content {
    my ($self, $content) = @_;
    return '' unless defined $content;
    return $content unless ref $content;

    my $uri = URI->new('http:');
    $uri->query_form(ref $content eq 'HASH' ? %$content : @$content);
    return $uri->query;
}

1;
__END__

=encoding utf-8

=for stopwords

=head1 NAME

WWW::Gumroad - HTTP Client for Gumroad API

=head1 SYNOPSIS

  use Data::Dumper;
  use WWW::Gumroad;
  use WWW::Gumroad::Authentication;

  my $authen = WWW::Gumroad::Authentication->new;
  my $res = $authen->create($email, $password);
  die Dumper $res->error if $res->is_error;
  my $token = $res->data->{token};

  my $client = WWW::Gumroad->new(token => $token);
  $res = $client->post('links', {
      name        => 'Yappo no onegai',
      url         => 'http://blog.yappo.jp/yappo/archives/yappo-onegai.png'
      price       => '100',
      description => 'Perl-users.jp創設者 大沢Yappo和宏 からの緊急のお願いをお読み下さい',
  });
  die Dumper $res->error if $res->is_error;
  my $link_id = $res->data->{link}{id};

  $res = $client->get("links/$link_id");
  die Dumper $res->error if $res->is_error;
  print Dumper $res->data;

=head1 DESCRIPTION

WWW::Gumroad is HTTP Client for Gumroad API.

THIS MODULE IS ALPHA LEVEL INTERFACE. MAY BE CHANGED.

=head1 METHODS

=head2 new(%args)

Create a new WWW::Gumroad instance.

  my $client = WWW::Gumroad->new(token => $token);

supported options are:

=over

=item token : Str

Required. Sets authenticated token. You can retrieved using L<< WWW::Gumroad::Authentication >>.

  my $authen = WWW::Gumroad::Authentication->new;
  my $res = $authen->create($email, $password);
  die Dumper $res->error if $res->is_error;

  my $token = $res->data->{token};
  my $client = WWW::Gumroad->new(token => $token);

=item api_base_url : Str

Sets Gumroad API base url. default is C<< $WWW::Gumroad::API_BASE_URL >>.

=item ua : LWP::UserAgent

Sets HTTP Client. default is L<< LWP::UserAgent >>.

=back

=head2 $client->request(%args)

Request for Gumroad API. Required value is L<< WWW::Gumroad::Response >>.

  my $res = $client->request(
      method   => 'POST',
      endpoint => '/links',
      content  => {
          name        => 'Yappo no onegai',
          url         => 'http://blog.yappo.jp/yappo/archives/yappo-onegai.png'
          price       => '100',
          description => 'Perl-users.jp創設者 大沢Yappo和宏 からの緊急のお願いをお読み下さい',
      },
  );
  die Dumper $res->error if $res->is_error;
  my $link_id = $res->data->{link}{id};

supported options are:

=over

=item method : Str

Sets HTTP method, can be specify GET or POST or PUT or DELETE.

=item endpoint : Str

Sets api path or api url.

=item content : ARRAY | HASH | Str

Sets request content. You can specify, ARRAY or HASH or Scalar content.

Currently, it will be encoded as C<< application/x-www-form-urlencoded >>

=back

=head2 $client->get($endpoint)

Alias of:

  $client->request(method => 'GET', endpoint => $endpoint);

=head2 $client->post($endpoint, $content)

Alias of:

  $client->request(method => 'POST', endpoint => $endpoint, content => $content);

=head2 $client->put($endpoint, $content)

Alias of:

  $client->request(method => 'PUT', endpoint => $endpoint, content => $content);

=head2 $client->delete($endpoint)

Alias of:

  $client->request(method => 'DELETE', endpoint => $endpoint, content => $content);

=head1 AUTHOR

xaicron E<lt>xaicron {at} cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2012 - xaicron

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
