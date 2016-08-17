#!/usr/bin/env perl

use strict;
use warnings;
use v5.014;

use FindBin;
use local::lib "$FindBin::Bin/local";

use IO::Socket::INET;


my $sock = IO::Socket::INET->new(
  PeerAddr => 'localhost',
  PeerPort => 31337,
  Proto => 'tcp'
) or die "Couldn't create crawler socket: $!";

while (1) {
  $sock->print("head\nbody\n");
  sleep 2;
}

$sock->close;
