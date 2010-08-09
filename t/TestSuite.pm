# $Id: TestSuite.pm 394 2010-08-07 15:10:03Z whynot $

package t::TestSuite;

use strict;
use warnings;
use version 0.50; our $VERSION = qv q|0.2.4|;
use base qw| Exporter |;
use lib   q|./blib/lib|;

use Cwd;
use Test::Differences;
use Data::Dumper;
use Module::Build;

our @EXPORT_OK = qw| RCD_process_patterns |;

$ENV{PERL5LIB} = getcwd . q(/blib/lib);

# FIXME: B<&Module::Build::runtime_params> apeared in v0.28
our $Verbose = eval { Module::Build->current->runtime_params(q|verbose|); };

our $Y_Choice;
foreach my $y_eng
( [qw| syck YAML::Syck |],
  [qw| old  YAML       |],
  [qw| tiny YAML::Tiny |]) {
    $ENV{RCD_YAML_ENGINE} && $y_eng->[0] ne $ENV{RCD_YAML_ENGINE}    and next;
    eval qq|require $y_eng->[1]|                                      or next;
    $Y_Choice = $y_eng;
    last                    }
$Y_Choice                     or die q|none known YAML reader has been found|;

sub RCD_show_y_choice ( ) {                       print qq|$Y_Choice->[1]\n| }

sub RCD_load_patterns ( )               {
    my $fn = (caller)[1];
    $fn =~ s{\.t$}{.yaml};
    if( $Y_Choice->[0] eq q|tiny| )    {
        my $yaml = YAML::Tiny->read($fn);
        return %{$yaml->[0]}            }
    elsif( $Y_Choice->[0] eq q|old| )  {
        my( $yaml, $buf );
        open my $fh, q|<|, $fn;
        read $fh, $buf, -s $fh;
        $yaml = YAML::Load( $buf );
        return %$yaml                   }
    elsif( $Y_Choice->[0] eq q|syck| ) {
        my $yaml = YAML::Syck::LoadFile( $fn );
        return %$yaml                   }}

sub RCD_save_patterns ( $\% )             {
    my($fn, $data) = ( @_ );
    if( $Y_Choice->[0] eq q|tiny| )      {
        my $yaml = YAML::Tiny->new;
        $yaml->[0] = $data;
        $yaml->write($fn)                 }
    elsif( $Y_Choice->[0] eq q|old| )    {
        open my $fh, q|>|, $fn;
        print $fh YAML::Dump( $data )     }
    elsif( $Y_Choice->[0] eq q|syck| )   {
        YAML::Syck::DumpFile( $fn, $data )}}

sub RCD_process_patterns ( % ) {
    my %args = ( @_ );

    foreach my $ptn (@{$args{patterns}})                               {
        my @in =  ( @$ptn );
        my @out = (
          $ptn->[0],
          ($ptn->[0] =~ $args{re_m} ? '+' : '-'),
          $ptn->[0] =~ $args{re_g} );
        my $dump = Data::Dumper
          ->new([ $ptn->[0] ])->Terse(1)->Useqq(1)->Indent(0)->Dump;
        $dump =~ s{^"(.+)"$}{$1};
        eq_or_diff_data \@out, \@in, sprintf q|%s %s|, $ptn->[1], $dump }

    Test::More::diag(
      sprintf q|processed patterns (%s): %i|,
        ( caller 1 )[3] || ( caller )[1], scalar @{$args{patterns}})
        if $Verbose             }

sub RCD_trial_patterns ( % ) {
    my %args = @_;
    my @rc;

    push @rc, [ $_, (m[$args{re_m}] ? '+' : '-'), m[$args{re_g}] ]
      foreach @{$args{patterns}};
    @rc                       }

sub RCD_count_patterns ( )         {
    opendir my $dh, q|t|;
    while( my $fn = readdir $dh ) {
        index( $fn, '.' ) && $fn =~ m{.yaml}                          or next;
        my %patterns;
        if( $Y_Choice->[0] eq q|tiny| )    {
            my $yaml = YAML::Tiny->read(qq|t/$fn|);
            %patterns = %{$yaml->[0]}       }
        elsif( $Y_Choice->[0] eq q|old| )  {
            my( $yaml, $buf );
            open my $fh, q|<|, qq|t/$fn|;
            read $fh, $buf, -s $fh;
            $yaml = YAML::Load( $buf );
            %patterns = %$yaml              }
        elsif( $Y_Choice->[0] eq q|syck| ) {
            my $yaml = YAML::Syck::LoadFile( qq|t/$fn| );
            %patterns = %$yaml              }
        printf qq|%23s => % 4i\n|, $_, scalar @{$patterns{$_}}
          foreach keys %patterns   }}

1;
