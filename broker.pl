#!/usr/bin/env perl

use strict;
use warnings;
use v5.014;

use IO::Socket::INET;
use FindBin;


my $sock = IO::Socket::INET->new(
  LocalAddr => 'localhost',
  LocalPort => 1337,
  Listen => 1,
  Proto => 'tcp',
  ReuseAddr => 1
) or die "Can't open socket: $!";

while (my $client = $sock->accept()) {
  open (my $data, '<', "$FindBin::Bin/data.txt")
    or die "Can't open data: $!";
  say "got client: " . $client->sockport;

  REWIND:
  while (<$data>) {
    chomp;
    $client->print($_ . "\n")
      or die "print err; $!";
  }
  seek $data, 0, 0;
  sleep 1;
  goto "REWIND";

  close $data;
}
