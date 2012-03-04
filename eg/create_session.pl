#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use Term::ReadKey qw(ReadMode ReadLine);
use WWW::Gumroad::Authentication;

print "enter your email: ";
chomp(my $email = <>);

print "enter your password: ";
ReadMode "noecho";
chomp(my $pass = ReadLine 0);
ReadMode "restore";
print "\n"x2;

my $res = WWW::Gumroad::Authentication->new->create($email, $pass);
die Dumper $res;
die Dumper +$res->error if $res->is_error;

print "successfully create session: ", $res->data->{token}, "\n";
