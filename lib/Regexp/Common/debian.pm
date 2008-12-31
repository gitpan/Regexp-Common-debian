# $Id: debian.pm 13 2008-12-31 10:34:06Z whyn0t $

package Regexp::Common::debian;
use strict;
use warnings;

use version 0.50; our $VERSION = qv q|0.0.10|;

use Carp;

=head1 NAME

Regexp::Common - regexps for Debian specific strings

=head1 SYNOPSIS

    use Regexp::Common qw(debian);
    #TODO:

=cut

use Regexp::Common qw| no_defaults pattern |;

=head1 DESCRIPTION

#TODO:

=over

=item B<$RE{debian}{package}>

    'the-very.strange.package+name' =~ $RE{debian}{package}{-keep};
    print "package is $1";

This is Debian B<package> name.
Rules are described in S<Section 5.6.7> of Debian policy.

=over

=item I<$1> is a package

=back

=cut

pattern
  name   => [ qw| debian package -policy=real | ],
  create => sub                                          {
      my($self, $flags) = ( @_ );
      $flags->{-policy} eq q|strict| ||
      $flags->{-policy} eq q|real|   and
        return q|(?k:[a-z0-9][a-z0-9+.-]+)|;
      $flags->{-policy} eq q|loose|  ||
      $flags->{-policy} eq q|looser| ||
      $flags->{-policy} eq q|lost|   and
        return q|(?k:[^_/]+)|;
      croak qq|unknown I<-policy>: C<$flags->{-policy}>|; }, ;

=item B<$RE{debian}{version}>

    '10:1+abc~rc.2-ALPHA-rc25+w~t.f' =~ $RE{debian}{version}{-keep};
    $2 eq '10'               &&
    $3 eq '1+abc~rc.2-ALPHA' &&
    $4 eq 'rc25+w~t.f'       or die;

This is Debian B<version>.
Rules are described in S<Section 5.6.12> of Debian policy.

=over

=item I<$1> is a I<debian_version>

=item I<$2> is an I<epoch>

if any.
Oterwise -- C<undef>.

=item I<$3> is an I<upstream_version>

B<(caveat)>
A string like C<0--1> will end up with I<$3> set to weird C<0->
(hopefully, Debian won't degrade to such versions; though YMMV).

=item I<$4> is a I<debian_revision>

B<(bug)>
C<0-1-> will end up with I<$3> set to C<0> and I<$4> set to C<1> (such trailing
hyphens will be missing in I<$1>).
C<0-> will end up with I<$4> C<undef>ed.

=back

B<(bug)>
Either I don't perlre or I didn't tried hard enough.
Anyway, I didn't find a way to parse Debian version the way B<R::C> requires in
context of B<perl5.8.8> (perl in stable, going to be oldstable).
C<qrZ<>E<sol>(?E<verbar>)E<sol>> saved B<perl5.10.0> (but see
B<"R_C_d_version">).

B<(caveat)>
The I<debian_revision> is allowed to start with non-digit.
This's solely my reading of Debian Policy.

=cut

# XXX: perl5.8.8 misses C<qr/(?|)/>.
# XXX: perl5.10.0 misses C<qr/(?=[$magic-]+)/>.
# XXX: qr/(?{ m,[$magic-]+, })/ segfaults.
# XXX: implicit anchoring must be avoided (as if it would help).
# XXX: C<do { my $x; qr/?{ local $x; }/; }> is weird.
# XXX: C<qr/(??{})/> requires C<use re qw eval ;> inside(?) R::C.
# FIXME: C<q|0-1-|> should fail, but C<(q|0-1-|, undef, 0, 1)>.
# FIXME: C<q|0-|> should fail, but C<(q|0-|, undef, 0, undef)>.

my $Magic = q|0-9A-Za-z.+|;

pattern
  name   => [ qw| debian version -policy=real | ],
  create => sub            {
      my($self, $flags) = ( @_ );
      my $magic = $Magic;
      if($flags->{-policy} eq q|strict|)                     {}
      elsif(
        $flags->{-policy} eq q|real| ||
        $flags->{-policy} eq q|loose|)                       {
          $magic .= q|~|;                                     }
      elsif($flags->{-policy} eq q|looser|)                  {
# TODO: Denote lack of C<%>.
          return qq|(?k:[:~$Magic-]+)|;                       }
      elsif($flags->{-policy} eq q|lost|)                    {
          return q|(?k:[^_/]+)|;                              }
      else                                                   {
          croak qq|unknown I<-policy>: C<$flags->{-policy}>|; };
      return 
        q{(?k:(?:(?k:[0-9]+):)?(?|}                              .
          qq{(?<=[0-9]:)(?k:[0-9][$magic:-]*)+-(?k:[$magic:]+)|} .
          qq{(?<=[0-9]:)(?k:[0-9][$magic:]*)|}                   .
          qq{(?<![0-9]:)(?k:[0-9][$magic-]*)+-(?k:[$magic]+)|}   .
          qq{(?<![0-9]:)(?k:[0-9][$magic]*)}                     .
# XXX: Is that RE really that fragile?
        qq{)(?![$magic]))}; }, ;

=item B<R_C_d_version>

    use Regexp::Common qw(debian);
    # though that works too
    # use Regexp::Common::debian;
    my $re = Regexp::Common::debian::R_C_d_version;
    $version =~ /^$re$/;
    $2                   and print "has epoch\n";
    $3 || $5 || $6 || $8 and print "has upstream_version\n";
    $4 || $7             and print "has debian_revision\n";
    $3 && !$4 || !$3 && $4 or die;
    $6 && !$7 || !$6 && $7 or die;
    $3 && !$5 && !$6 && !$8 or die;
           $5 && !$6 && !$8 or die;
                  $6 && !$8 or die;

That's a workaround for B<perl5.8.8>
(read L<"$RE{debian}{version}"> (look for B<(bug)>)).
Look for B<(caveat)> in L<"$RE{debian}{version}"> -- those apply here too.

=over

=item I<$1> is I<debian_version> again

=item I<$2> is I<epoch> always

=item Either I<$3>, or I<$5>, or I<$6>, or I<$8> is I<upstream_version>

=item Either I<$4> or I<$7> is I<debian_revision>

=back

That's the best what can be done with RE
(in real world it's done functional way).
Sorry.

B<(bug)>
It always grabs (should be configurable with setting like I<-keep>).
OTOH, look, within 2year
(or so)
(as soon as B<perl5.10.0> would be oldstable)
that dirty piece will be dropped anyway.

=cut

sub R_C_d_version (;$) {
    my $policy = shift @_;
    my $magic = $Magic;
    unless($policy)                              {
        $magic .= q|~|;                           }
    elsif($policy eq q|strict|)                  {}
    elsif(
      $policy eq q|real| ||
      $policy eq q|loose|)                       {
        $magic .= q|~|;                           }
    elsif($policy eq q|looser|)                  {
# TODO: Denote lack of C<%>.
        return qr|([:~$Magic-]+)|;                }
    elsif($policy eq q|lost|)                    {
        return qr|([^_/]+)|;                      }
    else                                         {
        croak qq|unknown I<-policy>: C<$policy>|; };
    return qr{
    ((?:([0-9]+):)?(?:
      (?<=[0-9]:)([0-9][$magic:-]*)+-([$magic:]+)|
      (?<=[0-9]:)([0-9][$magic:]*)|
      (?<![0-9]:)([0-9][$magic-]*)+-([$magic]+)|
      (?<![0-9]:)([0-9][$magic]*)
    )(?![$magic]))}x;   };

=item B<$RE{debian}{architecture}>

    $arch =~ $RE{debian}{architecture}{-keep};
    $2 && ($3 ||  $4)           and die;
           $3 && !$4            and die;
           $3 &&  $4 eq 'armel' and die;
    $2 and print "that's special: $2";
    $3 and print "OS is: $3";
    $4 and print "arch is: $4";

This is Debian B<architecture>.
Rules are described in I<Section 5.6.8> of Debian policy.

=over

=item I<$1> is some of Debian's I<architecture>s

=item I<$2> is any I<special>

Distinguishing special architectures (C<all>, C<any>, and C<source>) and
I<os>-I<arch> pairs is arguable.
But I've decided that would be good to separate C<all> and e.g. C<i386>
(what in turn is actually C<linux-i386>).

=item I<$3> is I<os>

When C<!$3 && $4> is true then unZ<>B<defined> I<$3> actually means C<linux>.
Since I<$I<digit>>s are read-only yielding here anything but C<undef> is
impossible.
More on that in I<Section 11.1> of Debian policy.

=item I<$4> is I<arch>

Please note that there are architectures which are present only for C<linux>
I<os>
(namely C<armel> and C<lpia>, at time of writing).

=back

B<(caveat)>
Debian policy by itself doesn't specify what I<os>-I<arch> pairs are valid
(only I<special>s are mentioned).
In turn it relies on C<qxZ<>E<sol>dpkg-architecture -LZ<>E<sol>>.
In effect B<R::C::d> can desinchronize;
Hopefully, that wouldn't stay unnoticed too long.

=cut

my $Arches  = 
  q{alpha|amd64|armeb|arm|hppa|i386|ia64|m32r|m68k|mipsel|mips|powerpc|} .
  q{ppc64|s390x|s390|sh3eb|sh3|sh4eb|sh4|sparc};
my $xArches = q{armel|lpia};
my $Oses    =
  q{darwin|freebsd|hurd|kfreebsd|knetbsd|netbsd|openbsd|solaris};
my $Extras  = q{all|any|source};

pattern
  name   => [ qw| debian architecture -policy=real | ],
  create => sub                                                         {
      my($self, $flags) = ( @_ );
      if(
        $flags->{-policy} eq q|strict| ||
        $flags->{-policy} eq q|real|    )                            {
          return
            q|(?<![a-z])|                          .
            qq{(?k:(?k:$Extras)|}                  .
            qq|(?:(?k:$Oses)-)?|                   .
            q|(?k:|                                .
              qq{(?<=-)(?:$Arches)|}               .
              qq{(?<![a-z-])(?:$Arches|$xArches))} .
            q|)(?![a-z])|;                                            }
      elsif($flags->{-policy} eq q|loose|)                           {
          return
            q|(?<![a-z])|                      .
            q|(?k:|                            .
            qq|(?:(?k:$Oses)-)?|               .
            qq{(?k:$Arches|$xArches|$Extras))} .
            q|(?![a-z])|;                                             }
      elsif($flags->{-policy} eq q|looser|)                          {
          return
            qq{(?<![a-z])(?k:(?:(?k:[a-z]+)-)?(?k:[a-z]+))(?![a-z])}; }
      elsif($flags->{-policy} eq q|lost|)                            {
          return
            qq|(?<![a-z])(?k:(?:(?:[a-z]+)-)?[a-z]+)(?![a-z])|;       }
      else                                                           {
          croak qq|unknown I<-policy>: C<$flags->{-policy}>|;         }; }, ;

=item B<$RE{debian}{archive}{binary}>

    'abc_1.2.3-512_all.deb' =~ $RE{debian}{archive}{binary}{-keep};
    print "     package is -> $2";
    print "     version is -> $3";
    print "architecture is -> $4";

This is Debian binary archive (even if there's no binary file (in B<-B> sense)
inside it's called "binary" anyway).
The naming convention isn't described in Debian policy;
Instead it refers to format understood by B<dpkg> (Preface of S<Chapter 3>).
(Hopefully, someday here will be references to code inside B<dpkg> and B<dpkg-deb>
codebase that does those nasty things with I<package>, I<version>, and I<arch>
composing in and decomposing out of filenames.)

=over

=item I<$1> is I<deb-filename>

That's the whole archive filename with C<.deb> suffix included

=item I<$2> is I<package>

=item I<$3> is I<version>

There's a big deal of WTF.
I<Filename:> in F<*_Packages> miss I<epoch> at all.
Archives in F<poolZ<>E<sol>> miss them too.
Archives in F<E<sol>varZ<>E<sol>cacheZ<>E<sol>aptZ<>E<sol>archives> ...
That seems to be C<apt-get> specific (I don't have reference to code though).
As a feature B<$RE{d}{a}{binary}> provides an I<epoch> hack in filenames.

=item I<$4> is I<architecture>

That would match surprising C<source> or C<any>.
Sorry.
That'll improve in future.
Actually that's even worse:  I<OS> can prepend any I<arch> or I<special>.

=back

For the sake of symmetry B<$RE{d}{a}{binary}> has trailing anchor -- negative
look-ahead for any character that can be found in B<version> string.

=cut

pattern
  name   => [ qw| debian archive binary -policy=real | ],
  create => sub                   {
      my($self, $flags) = ( @_ );
      $flags->{-policy} eq q|lost|                                 and
        return q|(?k:(?k:[^_/]+)_(?k:[^_/]+)_(?k:[^_/]+).deb)|;
      grep $flags->{-policy} eq $_, qw| strict real loose looser | or
        croak qq|unknown I<-policy>: C<$flags->{-policy}>|;
# TODO: Should piggyback on B<package>, B<version>, and B<arch>
      return
        q|(?k:|                                                .
          q|(?k:[a-z0-9][a-z0-9+.-]+)_|                        .
          qq|(?k:(?:[0-9]+%3a)?[0-9][~$Magic-]*)_|             .
          qq{(?k:(?:(?:$Oses)-)?(?:$Arches|$xArches|$Extras))} .
        qq|\\.deb)(?![~$Magic-])|; }, ;

=item B<$RE{debian}{archive}{source}>

    'xyz_1-ab.25~6.orig.tar.gz' =~ $RE{debian}{archive}{source}{-keep};
    print "package is $2";
    index($3, '-') && $4 eq 'tar' and die;
    $4 eq 'orig.tar'              and "print there should be patch";

This is Debian upstream (or Debian-native) source tarball.
Naming source archives is outside Debian policy;
although

=over

=item *

S<Section 5.6.21> mentions that "the exact forms of the filenames are described
in" S<Section C.3>.

=item *

S<Section C.3> points that source archive must be in form
F<B<package>_B<upstream-version>.orig.tar.gz>.

=item *

Naming Debian-native packages is left completely.

=item *

B<dpkg-source(1)> (B<1.14.23>) in Section S<B<SOURCE PACKAGE FORMATS>> mentions
some bits of naming (Debian-native packages are left too).

=back

Welcome to the real life.
B<$RE{d}{a}{source}> knows only B<Format: 1.0> naming.

=over

=item I<$1> is I<tarball-filename>

Since there's no other suffix, but F<.gz> it's present only in I<$1>

=item I<$2> is I<package>

=item I<$3> is I<version>

=item I<$4> is I<type>

This can hold one of 2 strings (C<orig.tar> (regular package) or C<tar>
(Debian-native package)).

=back

Since dot (C<.>) is used as separator and can be in I<version> the whole thing
is implicitly anchored (negative-lookahead for I<version>-forming character)
(The idea is that C<0.orig.tar.gz> can be a very strange version)
and I<version> itself is stressed to be as short as possible.

=cut

pattern
  name   => [ qw| debian archive source -policy=real | ],
  create => sub                  {
      my($self, $flags) = ( @_ );
      $flags->{-policy} eq q|lost|                                 and
        return
          q|(?k:(?k:[^_/]+)_| .
          q|(?k:[^_/]+?)\.|   .
          q|(?k:(?:orig\.)?tar\.gz(?![_/])))|;
      grep $flags->{-policy} eq $_, qw| strict real loose looser | or
        croak qq|unknown I<-policy>: C<$flags->{-policy}>|;
      return
        q|(?k:|                         .
          q|(?k:[a-z0-9][a-z0-9+.-]+)_| .
# XXX: Yes, must be ungreedy
          qq|(?k:[0-9][~$Magic-]*?)|    .
          q|\.(?k:(?:orig\.)?tar)|      .
        qq|\\.gz)(?![~$Magic-])|; }, ;

=item B<$RE{debian}{archive}{patch}>

    'abc_0cba-12.diff.gz' =~ $RE{debian}{archive}{patch}{-keep};
    print "package is $2";
    -1 == index $3, '-' and die;
    print "debian revision is ", (split /-/, $3)[-1];

This is "debianization diff" (S<Section C.3> of Debian policy).
Naming patches is outside Debian policy;
So we're back to guessing.
There're rumors (or maybe trends) that B<S<Format 1.0>> will be deprecated (or
maybe obsolete).

=over

=item I<$1> is I<patch-filename>

Since there's no other suffix, but F<.diff.gz> it's present only in I<$1>

=item I<$2> is I<package>

=item I<$3> is I<version>

B<(caveat)>  Consider this.
A Debian-native package misses a patch and hyphen in I<version>.
A regular package has a patch and must have hyphen in I<version>.
B<$RE{d}{a}{patch}> is absolutely ignorant about that
(we are about matching but verifying after all).

=back

The very same considerations covered in discussion trailing
B<$RE{d}{a}{source}> entry apply to B<$RE{d}{a}{patch}> as well
(consider: C<0.diff.gz> can be a I<version>).

=cut

pattern
  name   => [ qw| debian archive patch -policy=real | ],
  create => sub                         {
      my($self, $flags) = ( @_ );
      $flags->{-policy} eq q|lost|                                 and
        return q|(?k:(?k:[^_/]+)_(?k:[^_/]+?)\.(?k:diff\.gz(?![_/])))|;
      grep $flags->{-policy} eq $_, qw| strict real loose looser | or
        croak qq|unknown I<-policy>: C<$flags->{-policy}>|;
      return
        q|(?k:|                         .
          q|(?k:[a-z0-9][a-z0-9+.-]+)_| .
          qq|(?k:[0-9][~$Magic-]*?)|    .
        qq{\\.diff\\.gz)(?![~$Magic-])}; }, ;

=item B<$RE{debian}{archive}{dsc}>

    'abc_0cba-12.dsc' =~ $RE{debian}{archive}{dsc}{-policy=real};
    print "package is $2";
    print "version is $3";

This is "Debian source control" (S<Section 5.4> describes its contents but
naming).
Statistically based guessing, you know
(once I'll elaborate to point exact lines in B<dpkg-dev> bundle where it's in
use (creating and parsing)).

=over

=item I<$1> is I<dsc-filename>

As usual, since the only suffix can be F<.dsc> it's present in I<$1> only.

=item I<$2> is I<package>

=item I<$3> is I<version>

=back

blah-blah refering to B<$RE{d}{a}{source}>
(consider: C<0.dsc> can be I<version>).

=cut

pattern
  name   => [ qw| debian archive dsc -policy=real | ],
  create => sub                   {
      my($self, $flags) = ( @_ );
      $flags->{-policy} eq q|lost|                                 and
        return q|(?k:(?k:[^_/]+)_(?k:[^_/]+?)\.(?k:dsc(?![_/])))|;
      grep $flags->{-policy} eq $_, qw| strict real loose looser | or
        croak qq|unknown I<-policy>: C<$flags->{-policy}>|;
      return
        q|(?k:|                         .
          q|(?k:[a-z0-9][a-z0-9+.-]+)_| .
          qq|(?k:[0-9][~$Magic-]*?)|    .
        qq{\\.dsc)(?![~$Magic-])}; }, ;

=item B<$RE{debian}{archive}{changes}>

    'abc_0cba-12.changes' =~ $RE{debian}{archive}{changes}{-policy=real};
    print "package is $2";
    print "version is $3";

This is "Debian changes file" (S<Section 5.5> describes its contents but
naming).
Statistically based guessing, you know
(once I'll elaborate to point exact lines in B<dpkg-dev> bundle where it's in
use (creating and parsing)) (should be a template).

=over

=item I<$1> is I<changes-filename>

As usual, since the only suffix can be F<.changes> it's present in I<$1> only.

=item I<$2> is I<package>

=item I<$3> is I<version>

=back

blah-blah refering to B<$RE{d}{a}{source}>
(consider: C<0.changes> can be I<version>).

=cut

pattern
  name   => [ qw| debian archive changes -policy=real | ],
  create => sub                       {
      my($self, $flags) = ( @_ );
      $flags->{-policy} eq q|lost|                                 and
        return q|(?k:(?k:[^_/]+)_(?k:[^_/]+?)\.(?k:changes(?![_/])))|;
      grep $flags->{-policy} eq $_, qw| strict real loose looser | or
        croak qq|unknown I<-policy>: C<$flags->{-policy}>|;
      return
        q|(?k:|                         .
          q|(?k:[a-z0-9][a-z0-9+.-]+)_| .
          qq|(?k:[0-9][~$Magic-]*?)|    .
        qq{\\.changes)(?![~$Magic-])}; }, ;

=back

=head1 BUGS AND CAVEATS

Grep this pod for C<(bug)> andZ<>E<sol>or C<(caveat)>.
They all are placed in appropriate sections.

=head1 AUTHOR

Eric Pozharski, E<lt>whynot@cpan.orgZ<>E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2008 by Eric Pozharski

This library is free in sense: AS-IS, NO-WARANRTY, HOPE-TO-BE-USEFUL.
This library is released under LGPLv3.

=head1 SEE ALSO

L<Regexp::Common>,
L<http:E<sol>E<sol>www.debian.orgZ<>E<sol>docZ<>E<sol>debian-policy>,

=cut

1;
