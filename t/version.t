#!/usr/bin/perl
# $Id: version.t 16 2009-01-08 19:03:31Z whyn0t $

package main;
use strict;
use warnings;
use version 0.50;
use t::TestSuite   qw| RCD_process_patterns     |;
#use Regexp::Common qw| debian RE_debian_version |;
use Test::More;

our $VERSION = qv q|0.0.7|;

my %patterns = t::TestSuite::RCD_load_patterns;
plan tests =>
  (4 + @{$patterns{match_version}}) +
  @{$patterns{match_waversion}};

sub RCD_base_version ()         {
    my $pat = q|2:345-67|;
SKIP:                                    {
    skip qq{perl of $] doesn't have C<qr/(?|)/>}, 4
      if $] <= 5.008009;
    eval { use Regexp::Common qw| debian RE_debian_version |; };
    ok
      $pat =~ m|$RE{debian}{version}|,
      q|/$RE{debian}{version}/ matches|;
    ok
      $pat =~ RE_debian_version(),
      q|&RE_debian_version() .|;
    my $re = $RE{debian}{version};
    ok
      $pat =~ m|$re|,
      q|$re = $RE{debian}{version} .|;
    ok
      $RE{debian}{version}->matches($pat),
      q|$RE{debian}{version}->matches .|; };
    diag q|finished (main::base)|
      if $t::TestSuite::Verbose; };

sub RCD_match_version ()                                {
SKIP:                                                {
    skip
      qq{perl of $] doesn't have C<qr/(?|)/>},
      scalar @{$patterns{match_version}}
      if $] <= 5.008009;
    eval { use Regexp::Common qw| debian |; };
    RCD_process_patterns(
      patterns => $patterns{match_version},
      re_m     => qr|^$RE{debian}{version}$|,
      re_g     => qr|$RE{debian}{version}{-keep}|, ); }; };

sub RCD_match_waversion ()  {
    my $wa_re = eval q|Regexp::Common::debian::R_C_d_version|;
    eval { use Regexp::Common::debian; };
    RCD_process_patterns(
      patterns => $patterns{match_waversion},
      re_m     => qr|^$wa_re$|,
      re_g     => $wa_re, ); };

my @units = (
  \&RCD_base_version,
  \&RCD_match_version,
  \&RCD_match_waversion, );

t::TestSuite::RCD_do_units @units, @ARGV;

# vim: syntax=perl
