#!/usr/bin/perl
# $Id: changelog.t 20 2009-02-07 21:10:39Z whyn0t $

package main;
use strict;
use warnings;
use version 0.50;
use t::TestSuite   qw| RCD_process_patterns       |;
use Regexp::Common qw| debian RE_debian_changelog |;
use Test::More;

our $VERSION = qv q|0.1.1|;

my %patterns = t::TestSuite::RCD_load_patterns;
plan tests => 4 + @{$patterns{match_changelog}};

sub RCD_base_changelog ()       {
    my $pat = <<'END_OF_CHANGELOG';
perl (6.0.0-1) unstable; urgency=high
  * At last!
 -- Eric Pozharski <whynot@cpan.org>  Thu, 01 Apr 2010 00:00:00 +0300
END_OF_CHANGELOG
    ok
      $pat =~ m|$RE{debian}{changelog}|,
      q|/$RE{debian}{changelog}/ matches|;
    ok
      $pat =~ RE_debian_changelog(),
      q|&RE_debian_changelog() .|;
    my $re = $RE{debian}{changelog};
    ok
      $pat =~ m|$re|,
      q|$re = $RE{debian}{changelog} .|;
    ok
      $RE{debian}{changelog}->matches($pat),
      q|$RE{debian}{changelog}->matches .|;
    diag q|finished (main::RCD_base)|
      if $t::TestSuite::Verbose; };

sub RCD_match_changelog ()                             {
    RCD_process_patterns(
      patterns => $patterns{match_changelog},
      re_m     => qr|^$RE{debian}{changelog}$|,
      re_g     => qr|$RE{debian}{changelog}{-keep}|, ); };

my @units = (
  \&RCD_base_changelog,
  \&RCD_match_changelog, );

t::TestSuite::RCD_do_units @units, @ARGV;

# vim: syntax=perl
