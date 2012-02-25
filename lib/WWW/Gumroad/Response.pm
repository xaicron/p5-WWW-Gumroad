package WWW::Gumroad::Response;

use strict;
use warnings;
use JSON qw(decode_json);

sub new {
    my ($class, $res) = @_;

    my $is_success = 0;
    my ($data, $error);

    local $@;
    if ($res->is_success) {
        $data = eval { decode_json $res->content };
        if (my $e = $@) {
            $error = {
                type    => '__json_parse_error',
                message => $e,
            };
        }
        elsif ($data->{success}) {
            $is_success = 1;
        }
        else {
            $error = $data->{error} || $data;
        }
    }
    else {
        $error = {
            type    => '__response_code_is_error',
            message => $res->status_line,
        };
    }

    bless {
        is_success    => $is_success,
        error         => $error,
        data          => $data,
        http_response => $res,
    }, $class;
}

sub is_success {
    shift->{is_success} ? 1 : 0;
}

sub is_error {
    !shift->{is_success};
}

sub http_response {
    shift->{http_response};
}

sub error {
    shift->{error},
}

sub data {
    shift->{data};
}

1;
__END__

=encoding utf-8

=for stopwords

=head1 NAME

WWW::Gumroad::Response - Response class

=head1 SYNOPSIS

  use Data::Dumper;
  use WWW::Gumroad::Response;

  my $res = WWW::Gumroad::Response->new($http_response);
  die Dumper $res->error if $res->is_error;
  my $data = $res->data;

=head1 DESCRIPTION

WWW::Gumroad::Response is Gumroad API's response class.

THIS MODULE IS ALPHA LEVEL INTERFACE. MAY BE CHANGED.

=head1 METHODS

=head2 new($http_response)

Create a new WWW::Gumroad::Response instance.

=head2 $res->is_success

=head2 $res->is_error

=head2 $res->http_response

=head2 $res->error

API error response data. Returned values is HASHREF.

=head2 $res->data

API response data. Returned values is HASHREF.

=head1 AUTHOR

xaicron E<lt>xaicron {at} cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2012 - xaicron

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
