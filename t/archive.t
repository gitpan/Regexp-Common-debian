#!/usr/bin/perl
# $Id: archive.t 16 2009-01-08 19:03:31Z whyn0t $

package main;
use strict;
use warnings;
use version 0.50;
use t::TestSuite   qw| RCD_process_patterns |;
use Regexp::Common qw|
  debian
  RE_debian_archive_binary
  RE_debian_archive_source
  RE_debian_archive_patch
  RE_debian_archive_dsc
  RE_debian_archive_changes                 |;
use Test::More;

our $VERSION = qv q|0.0.9|;

my %patterns = t::TestSuite::RCD_load_patterns;
plan tests =>
  (4 + @{$patterns{match_binary}}) +
  (4 + @{$patterns{match_source}}) +
  (4 + @{$patterns{match_patch}})  +
  (4 + @{$patterns{match_dsc}})    +
  (4 + @{$patterns{match_changes}});

sub RCD_base_binary ()          {
    my $pat = q|abc_012_i386.deb|;
    ok
      $pat =~ m|$RE{debian}{archive}{binary}|,
      q|/$RE{debian}{archive}{binary}/ matches|;
    ok
      $pat =~ RE_debian_archive_binary(),
      q|&RE_debian_archive_binary() .|;
    my $re = $RE{debian}{archive}{binary};
    ok
      $pat =~ m|$re|,
      q|$re = $RE{debian}{archive}{binary} .|;
    ok
      $RE{debian}{archive}{binary}->matches($pat),
      q|$RE{debian}{archive}{binary}->matches .|;
    diag q|finished (main::base_binary)|
      if $t::TestSuite::Verbose; };

sub RCD_match_binary ()                                      {
    RCD_process_patterns(
      patterns => $patterns{match_binary},
      re_m     => qr|^$RE{debian}{archive}{binary}$|,
      re_g     => qr|$RE{debian}{archive}{binary}{-keep}|, ); };

sub RCD_base_source ()          {
    my $pat = q|abc_012.orig.tar.gz|;
    ok
      $pat =~ m|$RE{debian}{archive}{source}|,
      q|/$RE{debian}{archive}{source}/ matches|;
    ok
      $pat =~ RE_debian_archive_source(),
      q|&RE_debian_archive_source() .|;
    my $re = $RE{debian}{archive}{source};
    ok
      $pat =~ m|$re|,
      q|$re = $RE{debian}{archive}{source} .|;
    ok
      $RE{debian}{archive}{source}->matches($pat),
      q|$RE{debian}{archive}{source}->matches .|;
    diag q|finished (main::base_source)|
      if $t::TestSuite::Verbose; };

sub RCD_match_source ()                                      {
    RCD_process_patterns(
      patterns => $patterns{match_source},
      re_m     => qr|^$RE{debian}{archive}{source}$|,
      re_g     => qr|$RE{debian}{archive}{source}{-keep}|, ); };

sub RCD_base_patch ()           {
    my $pat = q|abc_012-34.diff.gz|;
    ok
      $pat =~ m|$RE{debian}{archive}{patch}|,
      q|/$RE{debian}{archive}{patch}/ matches|;
    ok
      $pat =~ RE_debian_archive_patch(),
      q|&RE_debian_archive_patch() .|;
    my $re = $RE{debian}{archive}{patch};
    ok
      $pat =~ m|$re|,
      q|$re = $RE{debian}{archive}{patch} .|;
    ok
      $RE{debian}{archive}{patch}->matches($pat),
      q|$RE{debian}{archive}{patch}->matches .|;
    diag q|finished (main::base_patch)|
      if $t::TestSuite::Verbose; };

sub RCD_match_patch ()                                      {
    RCD_process_patterns(
      patterns => $patterns{match_patch},
      re_m     => qr|^$RE{debian}{archive}{patch}$|,
      re_g     => qr|$RE{debian}{archive}{patch}{-keep}|, ); };

sub RCD_base_dsc ()             {
    my $pat = q|abc_012-34.dsc|;
    ok
      $pat =~ m|$RE{debian}{archive}{dsc}|,
      q|/$RE{debian}{archive}{dsc}/ matches|;
    ok
      $pat =~ RE_debian_archive_dsc(),
      q|&RE_debian_archive_dsc() .|;
    my $re = $RE{debian}{archive}{dsc};
    ok
      $pat =~ m|$re|,
      q|$re = $RE{debian}{archive}{dsc} .|;
    ok
      $RE{debian}{archive}{dsc}->matches($pat),
      q|$RE{debian}{archive}{dsc}->matches .|;
    diag q|finished (main::base_dsc)|
      if $t::TestSuite::Verbose; };

sub RCD_match_dsc ()                                      {
    RCD_process_patterns(
      patterns => $patterns{match_dsc},
      re_m     => qr|^$RE{debian}{archive}{dsc}$|,
      re_g     => qr|$RE{debian}{archive}{dsc}{-keep}|, ); };

sub RCD_base_changes ()         {
    my $pat = q|abc_012-34_ia64.changes|;
    ok
      $pat =~ m|$RE{debian}{archive}{changes}|,
      q|/$RE{debian}{archive}{changes}/ matches|;
    ok
      $pat =~ RE_debian_archive_changes(),
      q|&RE_debian_archive_changes() .|;
    my $re = $RE{debian}{archive}{changes};
    ok
      $pat =~ m|$re|,
      q|$re = $RE{debian}{archive}{changes} .|;
    ok
      $RE{debian}{archive}{changes}->matches($pat),
      q|$RE{debian}{archive}{changes}->matches .|;
    diag q|finished (main::base_changes)|
      if $t::TestSuite::Verbose; };

sub RCD_match_changes ()                                      {
    RCD_process_patterns(
      patterns => $patterns{match_changes},
      re_m     => qr|^$RE{debian}{archive}{changes}$|,
      re_g     => qr|$RE{debian}{archive}{changes}{-keep}|, ); };

my @units = (
  \&RCD_base_binary,
  \&RCD_match_binary,
  \&RCD_base_source,
  \&RCD_match_source,
  \&RCD_base_patch,
  \&RCD_match_patch,
  \&RCD_base_dsc,
  \&RCD_match_dsc,
  \&RCD_base_changes,
  \&RCD_match_changes, );

t::TestSuite::RCD_do_units @units, @ARGV;

# vim: syntax=perl
