#!/usr/bin/perl
# $Id: package.t 16 2009-01-08 19:03:31Z whyn0t $

package main;
use strict;
use warnings;
use version 0.50;
use t::TestSuite   qw| RCD_process_patterns     |;
use Regexp::Common qw| debian RE_debian_package |;
use Test::More;

our $VERSION = qv q|0.0.4|;

my %patterns = t::TestSuite::RCD_load_patterns;
plan tests => 4 + @{$patterns{match_package}};

sub RCD_base_package ()         {
    my $pat = q|xyz|;
    ok
      $pat =~ m|$RE{debian}{package}|,
      q|/$RE{debian}{package}/ matches|;
    ok
      $pat =~ RE_debian_package(),
      q|&RE_debian_package() .|;
    my $re = $RE{debian}{package};
    ok
      $pat =~ m|$re|,
      q|$re = $RE{debian}{package} .|;
    ok
      $RE{debian}{package}->matches($pat),
      q|$RE{debian}{package}->matches .|;
    diag q|finished (main::base)|
      if $t::TestSuite::Verbose; };

sub RCD_match_package ()                             {
    RCD_process_patterns(
      patterns => $patterns{match_package},
      re_m     => qr|^$RE{debian}{package}$|,
      re_g     => qr|$RE{debian}{package}{-keep}|, ); };

my @units = (
  \&RCD_base_package,
  \&RCD_match_package, );

t::TestSuite::RCD_do_units @units, @ARGV;

# vim: syntax=perl
