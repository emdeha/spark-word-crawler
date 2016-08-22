#!/usr/bin/env perl

use strict;
use warnings;
use v5.014;

use FindBin;
use local::lib "$FindBin::Bin/local";

use IO::Socket::INET;
use WWW::Crawler::Lite;
use HTML::TreeBuilder;
use URI;

my $sock = IO::Socket::INET->new(
  PeerAddr => 'localhost',
  PeerPort => 31337,
  Proto => 'tcp'
) or die "Couldn't create crawler socket: $!";

my %pages = ();
my %links = ();

my $tree = HTML::TreeBuilder->new();

my $crawler; $crawler = WWW::Crawler::Lite->new(
  agent => 'SparkWordCrawler/1.0',
  http_accept => [qw(text/html application/xhtml+xml)],
  link_parser => 'default',
  delay_seconds => 1,
  on_response => sub {
    my ($url, $res) = @_;

    warn "fetched response for $url";
    $tree->parse($res->content);
    my $single_line = '';
    for my $p ($tree->find("p")) {
      $single_line .= join ' ', split "\n", $p->as_text;
    }
    my $host = URI->new($url)->host;
    my $line = "$host\n$single_line\n";
    warn "Sending [" . substr($line, 0, 60) . "]";
    $sock->print($line);
  },
  follow_ok => sub {
    my ($url) = @_;
    return 1;
  },
  on_link => sub {
    my ($from, $to, $text) = @_;

    return if exists($pages{$to});

    $links{$to} ||= [];
    push @{$links{$to}}, { from => $from, text => $text };
  },
  on_bad_url => sub {
    my ($url) = @_;

    $pages{$url} = 'BAD';
  }
);

$crawler->crawl( url => 'http://neuralnetworksanddeeplearning.com/about.html' );

$sock->close;
