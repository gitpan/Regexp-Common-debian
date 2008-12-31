#!/usr/bin/perl
# $Id: package.t 13 2008-12-31 10:34:06Z whyn0t $

package main;
use strict;
use warnings;
use version 0.50;
use TestSuite      qw| RCD_process_patterns     |;
use Regexp::Common qw| debian RE_debian_package |;
use Test::More tests => 73;

our $VERSION = qv q|0.0.3|;

my %patterns = TestSuite::RCD_load_patterns;

sub RCD_base_package ()           {
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
    diag q|finished (main::base)|; };

sub RCD_match_package ()                             {
    RCD_process_patterns(
      patterns => $patterns{match_package},
      re_m     => qr|^$RE{debian}{package}$|,
      re_g     => qr|$RE{debian}{package}{-keep}|, ); };

my @units = (
  \&RCD_base_package,
  \&RCD_match_package, );

TestSuite::RCD_do_units @units, @ARGV;

# vim: syntax=perl
