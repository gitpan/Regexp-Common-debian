#!/usr/bin/perl
# $Id: version.t 394 2010-08-07 15:10:03Z whynot $

package main;
use strict;
use warnings;
use version 0.50; our $VERSION = qv q|0.2.1|;
use t::TestSuite   qw| RCD_process_patterns     |;
#use Regexp::Common qw| debian RE_debian_version |;
use Test::More;

my @askdebian;
if(
  $ENV{RCD_ASK_DEBIAN} &&
 ($ENV{RCD_ASK_DEBIAN} eq q|all| ||
  $ENV{RCD_ASK_DEBIAN} =~ m{\bversion\b}) ) {
    local $/ = "\n";
    @askdebian =
      qx|/usr/bin/dpkg-query --showformat '\${Version}\\n' --show|      or die
      q|(ASK_DEBIAN) was requested, however (dpkg-query) has failed; | .
      q|most probably, that's not Debian at all|;
    chomp @askdebian                         }

my %patterns = t::TestSuite::RCD_load_patterns;
plan tests =>
  4 + @{$patterns{match_version}} +
  @{$patterns{match_waversion}}   +
  @askdebian;

my $pat = q|2:345-67|;
SKIP:                                              {
    skip qq{perl of $] doesn't have C<qr/(?|)/>},
      4 + scalar @{$patterns{match_version}}          unless eval q{qr/(?|)/};
    eval { use Regexp::Common qw| debian RE_debian_version | };
    ok $pat =~ m|$RE{debian}{version}|, q|/$RE{debian}{version}/ matches|;
    ok $pat =~ RE_debian_version(), q|&RE_debian_version() .|;
    my $re = $RE{debian}{version};
    ok $pat =~ m|$re|, q|$re = $RE{debian}{version} .|;
    ok $RE{debian}{version}->matches($pat),
      q|$RE{debian}{version}->matches .|;
    diag q|finished (main::base)|                   if $t::TestSuite::Verbose;

    RCD_process_patterns(
      patterns =>        $patterns{match_version},
      re_m     =>      qr|^$RE{debian}{version}$|,
      re_g     => qr|$RE{debian}{version}{-keep}| ) }

my $wa_re = eval q|Regexp::Common::debian::R_C_d_version|;
eval { use Regexp::Common::debian };
RCD_process_patterns(
  patterns => $patterns{match_waversion},
  re_m     =>               qr|^$wa_re$|,
  re_g     =>                     $wa_re );

SKIP:                   {
    skip qq{perl of $] doesn't have C<qr/(?|)/>},
      scalar @askdebian                               unless eval q{qr/(?|)/};
    eval { use Regexp::Common qw| debian RE_debian_version | };
    my $re = $RE{debian}{version};
    ok m|^$re$|, qq|? $_|
      foreach @askdebian }

# vim: syntax=perl
