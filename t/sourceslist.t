#!/usr/bin/perl
# $Id: sourceslist.t 20 2009-02-07 21:10:39Z whyn0t $

package main;
use strict;
use warnings;
use version 0.50;
use t::TestSuite   qw| RCD_process_patterns         |;
use Regexp::Common qw| debian RE_debian_sourceslist |;
use Test::More;

our $VERSION = qv q|0.0.1|;

my %patterns = t::TestSuite::RCD_load_patterns;
plan tests => 4 + @{$patterns{match_sourceslist}};

sub RCD_base_sourceslist ()         {
    my $pat = q|deb file:/var/spool/repo stable main contrib|;
    ok
      $pat =~ m|$RE{debian}{sourceslist}|,
      q|/$RE{debian}{sourceslist}/ matches|;
    ok
      $pat =~ RE_debian_sourceslist(),
      q|&RE_debian_sourceslist() .|;
    my $re = $RE{debian}{sourceslist};
    ok
      $pat =~ m|$re|,
      q|$re = $RE{debian}{sourceslist} .|;
    ok
      $RE{debian}{sourceslist}->matches($pat),
      q|$RE{debian}{sourceslist}->matches .|;
    diag q|finished (main::base)|
      if $t::TestSuite::Verbose; };

sub RCD_match_sourceslist ()                             {
    RCD_process_patterns(
      patterns => $patterns{match_sourceslist},
      re_m     => qr|^$RE{debian}{sourceslist}$|,
      re_g     => qr|$RE{debian}{sourceslist}{-keep}|, ); };

my @units = (
  \&RCD_base_sourceslist,
  \&RCD_match_sourceslist, );

t::TestSuite::RCD_do_units @units, @ARGV;

# vim: syntax=perl
