#!/usr/bin/env perl

use strict;
use warnings;
use v5.014;

use FindBin;
use local::lib "$FindBin::Bin/local";

use forks;

use IO::Socket::INET;
use Thread::Queue;

my $q = Thread::Queue->new();


my $spark_socket = IO::Socket::INET->new(
  LocalAddr => 'localhost',
  LocalPort => 1337,
  Listen => 1,
  Proto => 'tcp',
  ReuseAddr => 1
) or die "Can't open spark socket: $!";

my $client_socket = IO::Socket::INET->new(
  LocalAddr => 'localhost',
  LocalPort => 31337,
  Listen => 10,
  Proto => 'tcp',
  ReuseAddr => 1
) or die "Can't open client socket: $!";


my $broker_thread;
my @threads;


while (my $sp = $spark_socket->accept()) {
  say 'got new spark client';
  $broker_thread = threads->create(sub {
    while (defined (my $data = $q->dequeue())) {
      $sp->print("$data\n");
      say 'sent data';
    }

    $sp->close();
  });
  last;
}

while (my $cl = $client_socket->accept()) {
  say 'got new client ' . $cl->peerport;
  push @threads, threads->create(sub {
    my $head;
    my $body;
    my $has_read_all = 0;
    while (<$cl>) {
      chomp;
      say "data: [$_]";
      $q->enqueue($_);
    }

    $cl->close();
  })
}

for my $thr (@threads) {
  $thr->join();
}
$q->end();
$broker_thread->join();
