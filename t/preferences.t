#!/usr/bin/perl
# $Id: preferences.t 19 2009-01-24 01:38:13Z whyn0t $

package main;
use strict;
use warnings;
use version 0.50;
use t::TestSuite   qw| RCD_process_patterns         |;
use Regexp::Common qw| debian RE_debian_preferences |;
use Test::More;

our $VERSION = qv q|0.1.1|;

my %patterns = t::TestSuite::RCD_load_patterns;
plan tests => 4 + @{$patterns{match_preferences}};

sub RCD_base_preferences ()    {
    my $pat = <<'END_OF_PREFERENCES';
Package: perl
Pin: version 6*
Pin-Priority: 100000
END_OF_PREFERENCES
    ok
      $pat =~ m|$RE{debian}{preferences}|,
      q|/$RE{debian}{preferences}/ matches|;
    ok
      $pat =~ RE_debian_preferences(),
      q|&RE_debian_preferences() .|;
    my $re = $RE{debian}{preferences};
    ok
      $pat =~ m|$re|,
      q|$re = $RE{debian}{preferences} .|;
    ok
      $RE{debian}{preferences}->matches($pat),
      q|$RE{debian}{preferences}->matches .|;
    diag q|finished (main::RCD_base)|
      if $t::TestSuite::Verbose; };

sub RCD_match_preferences ()                             {
    RCD_process_patterns(
      patterns => $patterns{match_preferences},
      re_m     => qr|^$RE{debian}{preferences}$|,
      re_g     => qr|$RE{debian}{preferences}{-keep}|, ); };

my @units = (
  \&RCD_base_preferences,
  \&RCD_match_preferences, );

t::TestSuite::RCD_do_units @units, @ARGV;

# vim: syntax=perl
