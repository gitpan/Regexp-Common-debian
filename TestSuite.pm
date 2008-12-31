# $Id: TestSuite.pm 9 2008-12-12 03:37:21Z whyn0t $

package TestSuite;

use strict;
use warnings;
use version 0.50;

use base qw(Exporter);
use vars qw(@EXPORT_OK);
use Cwd;
use YAML::Tiny;
use Test::Differences;

our $VERSION = qv q|0.0.2|;

use lib q(./blib/lib);

@EXPORT_OK = qw| RCD_process_patterns |;

$ENV{PERL5LIB} = getcwd . q(/blib/lib);

sub RCD_do_units (\@@)       {
    my($units) = shift @_;
    unless(@_)            {
        $_->()
          foreach @$units; }
    else                  {
        eval qq|main::RCD_$_| or
          Test::More::diag($@)
          foreach @_;      }; };

sub RCD_load_patterns () {
    my $fn = (caller)[1];
    $fn =~ s{\.t$}{.yaml};
    my $yaml = YAML::Tiny->read($fn);
    return %{$yaml->[0]}; };

sub RCD_save_patterns ($\%) {
    my($fn, $data) = ( @_ );
    my $yaml = YAML::Tiny->new;
    $yaml->[0] = $data;
    $yaml->write($fn);       };

sub RCD_process_patterns (%)     {
    my %args = ( @_ );
    my(@in, @out);

    foreach my $ptn (@{$args{patterns}})         {
        my @in =  ( @$ptn );
        my @out = (
          $ptn->[0],
          ($ptn->[0] =~ $args{re_m} ? '+' : '-'),
          $ptn->[0] =~ $args{re_g} );
        eq_or_diff_data
          \@out,
          \@in,
          sprintf q|%s %s|, $ptn->[1], $ptn->[0]; };

    Test::More::diag(
      sprintf q|processed patterns (%s): %i|,
      (caller 1)[3],
      scalar @{$args{patterns}}); };

1;
