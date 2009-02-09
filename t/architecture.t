#!/usr/bin/perl
# $Id: architecture.t 16 2009-01-08 19:03:31Z whyn0t $

package main;
use strict;
use warnings;
use version 0.50;
use t::TestSuite   qw| RCD_process_patterns          |;
use Regexp::Common qw| debian RE_debian_architecture |;
use Test::More;

our $VERSION = qv q|0.0.4|;

my %patterns = t::TestSuite::RCD_load_patterns;
plan tests => 4 + @{$patterns{match_architecture}};

sub RCD_base_architecture ()    {
    my $pat = q|openbsd-arm|;
    ok
      $pat =~ m|$RE{debian}{architecture}|,
      q|/$RE{debian}{architecture}/ matches|;
    ok
      $pat =~ RE_debian_architecture(),
      q|&RE_debian_architecture() .|;
    my $re = $RE{debian}{architecture};
    ok
      $pat =~ m|$re|,
      q|$re = $RE{debian}{architecture} .|;
    ok
      $RE{debian}{architecture}->matches($pat),
      q|$RE{debian}{architecture}->matches .|;
    diag q|finished (main::RCD_base)|
      if $t::TestSuite::Verbose; };

sub RCD_match_architecture ()                             {
    RCD_process_patterns(
      patterns => $patterns{match_architecture},
      re_m     => qr|^$RE{debian}{architecture}$|,
      re_g     => qr|$RE{debian}{architecture}{-keep}|, ); };

my @units = (
  \&RCD_base_architecture,
  \&RCD_match_architecture, );

t::TestSuite::RCD_do_units @units, @ARGV;

# vim: syntax=perl
