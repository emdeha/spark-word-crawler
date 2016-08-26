#!/usr/bin/env perl

use strict;
use warnings;
use v5.014;

use FindBin;
use local::lib "$FindBin::Bin/local";

use IO::Socket::INET;


sub usage {
  "Usage: ./simulate-training.pl <training_data_file>";
}

die usage
  if !defined($ARGV[0]) || !-f $ARGV[0];

open(my $training_data_file, '<', $ARGV[0])
  or die ("couldn't open training data; $!");

my $spark_socket = IO::Socket::INET->new(
  LocalAddr => 'localhost',
  LocalPort => 1336,
  Listen => 1,
  Proto => 'tcp',
  ReuseAddr => 1
) or die "Can't open spark socket: $!";


while (my $sp = $spark_socket->accept()) {
  say 'got new spark client';

REWIND:
  while (<$training_data_file>) {
    chomp;
    my $data = $_;

    my $comma_count = () = $data =~ /,/g;
    while ($comma_count > 10) {
      say "chops data";
      $data =~ s/,[^,]*$//;
      $comma_count = () = $data =~ /,/g;
    }
    $sp->print("$data\n");
    say "sent data";
  }
  sleep 1;
  seek $training_data_file, 0, 0;
  goto REWIND;

  $sp->close();
}
