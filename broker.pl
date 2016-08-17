#!/usr/bin/env perl

use strict;
use warnings;
use v5.014;

use forks;

use IO::Socket::INET;
use FindBin;
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
      $sp->print($data->{head});
      $sp->print($data->{body});
      say 'sent data';
    }

    $sp->close();
  });
  last;
}

while (my $cl = $client_socket->accept()) {
  say 'got new client';
  push @threads, threads->create(sub {
    my $head;
    my $body;
    my $has_read_all = 0;
    while (<$cl>) {
      chomp;
      if (!$head) {
        say 'read head';
        $head = "$_\n";
      } elsif (!$body) {
        say 'read body';
        $body = "$_\n";
        $has_read_all = 1;
      } else {
        warn "Head and body full but no has_read_all";
      }

      if ($has_read_all) {
        say "enqueue $head with $body";
        $q->enqueue({ head => $head, body => $body });
        $has_read_all = 0;
        $head = undef;
        $body = undef;
      }
    }

    $cl->close();
  })
}

for my $thr (@threads) {
  $thr->join();
}
$q->end();
$broker_thread->join();
