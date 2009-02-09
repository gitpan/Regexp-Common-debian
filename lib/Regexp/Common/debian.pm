# $Id: debian.pm 21 2009-02-09 01:34:32Z whyn0t $

package Regexp::Common::debian;
use strict;
use warnings;

use version 0.50; our $VERSION = qv q|0.1.4|;

=head1 NAME

Regexp::Common::debian - regexps for Debian specific strings

=head1 SYNOPSIS

    use Regexp::Common qw(debian);
    #TODO:

=cut

use Regexp::Common qw| no_defaults pattern |;

=head1 DESCRIPTION

Debian GNU/Linux as a management system validates, parses, and generates a lots
of data.
For sake of some other project I've needed some kind of parser.
Part of Debian package management system, namely it's generating part --
B<dpkg-deb>, is written in Perl, but...
The API is provided in source-code form -- no docs, no plans, we are unstable.
What morons.
I've needed something I could depend on.
I'm not about code, I'm about API.

So I've gone myself.
I believe, that Perl-way of doing such things is packing re-used and intented
for re-use in module.
And if such module is made anyway, why I shouldn't share it?
(hmm, I've already told that someone...)
So here we are -- B<Regexp::Common::debian> (applauses, thanks, thanks).

When choosing API I would provide I had an option -- 

=over

=item B<parsing>

That would be a bunch of error-prone decisions -- pick a backbone parser,
figure out grammar, mix them, build API, implement it,..
And as a net result one more B<xDpkg::> namespace.
I really would like to hear any reasons why.

=item B<comparing>

String on left, regexp on right, add I<{-keep}>, and get an array of parsed out
parts.
Other way: string on left, regexp on right, anchor it properly, and get a
scalar indicating matchZ<>E<sol>mismatch.
The only deficiency I can see is that result is an array, but hash.
Hard to argue.
That seems I've committed a sin.
Should live with it.

=back

As a backbone L<Regexp::Common> was chosen.
It has it's own deficiences, it's dead-upstream, but I've failed to find any
unhappy user
(unsatisfied -- maybe, but unhappy -- no, sir).
Maybe I didn't tried hard enough.
It provides neat and rich interface, but...

I<{-keep}> and I<{-i}> are provided internally.
It's OK with I<{-keep}>, but I<{-i}>...
Look, Debian strings are B<almost> all case-sensitive.
When case shouldn't matter it's explicitly switched off by template itself.
So -- if you play with I<{-i}>, don't blame me then.
(I'll experiment with implicit C<qrZ<>E<sol>(?i:)E<sol>> after that release.)

B<(note)> B<Regexp::Common::debian> is very permissive in some cases
(sometime absurdly permissive).
Hopefully, I've noted in docu all such cases.
For next release I'm going to implement verification against all stuff found on
site.
That, hopefully, will enable stricting patterns while accepting real life.

=over

=item B<$RE{debian}{package}>

    'the-very.strange.package+name' =~ $RE{debian}{package}{-keep};
    print "package is $1";

This is Debian B<package> name.
Rules are described in S<Section 5.6.7> of Debian policy.

=over

=item I<$1> is a I<package>

=back

=cut

pattern
  name   => [ qw| debian package | ],
  create => q|(?k:[a-z0-9][a-z0-9+.-]+)|;

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
# TODO: Hmm, C<dpkg --compare-versions> compares C<q|0-|>; and what's I<debian_revision> then?

my $Magic = q|0-9A-Za-z.+~|;

pattern
  name    => [ qw| debian version | ],
  version => 5.010,
  create  =>
    q{(?k:(?:(?k:[0-9]+):)?(?|}                              .
      qq{(?<=[0-9]:)(?k:[0-9][$Magic:-]*)+-(?k:[$Magic:]+)|} .
      qq{(?<=[0-9]:)(?k:[0-9][$Magic:]*)|}                   .
      qq{(?<![0-9]:)(?k:[0-9][$Magic-]*)+-(?k:[$Magic]+)|}   .
      qq{(?<![0-9]:)(?k:[0-9][$Magic]*)}                     .
# XXX: Is that RE really that fragile?
    qq{)(?![$Magic]))};

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

B<(note)>
B<&R_C_d_version> is unexported function because that follows B<Regexp::Common>
way of providing regexps --
each time you've got a new C<qrZ<>E<sol>E<sol>>,
but reference.
It's unexported for obvious reason.

=cut

sub R_C_d_version () {
    return qr{
    ((?:([0-9]+):)?(?:
      (?<=[0-9]:)([0-9][$Magic:-]*)+-([$Magic:]+)|
      (?<=[0-9]:)([0-9][$Magic:]*)|
      (?<![0-9]:)([0-9][$Magic-]*)+-([$Magic]+)|
      (?<![0-9]:)([0-9][$Magic]*)
    )(?![$Magic]))}x; };

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
Since I<$digit>s are read-only yielding here anything but C<undef> is
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
  name   => [ qw| debian architecture | ],
  create =>
    q|(?<![a-z])|                          .
    qq{(?k:(?k:$Extras)|}                  .
    qq|(?:(?k:$Oses)-)?|                   .
    q|(?k:|                                .
      qq{(?<=-)(?:$Arches)|}               .
      qq{(?<![a-z-])(?:$Arches|$xArches))} .
    q|)(?![a-z])|;

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

B<(caveat)>
That would match surprising C<source> or C<any>.
Sorry.
That'll improve in future.
Actually that's even worse:  I<OS> can prepend any I<arch> or I<special>.

=back

For the sake of symmetry B<$RE{d}{a}{binary}> has trailing anchor -- negative
look-ahead for any character that can be found in B<version> string.

=cut

pattern
  name   => [ qw| debian archive binary | ],
  create =>
# TODO: Should piggyback on B<package>, B<version>, and B<arch>
    q|(?k:|                                                .
      q|(?k:[a-z0-9][a-z0-9+.-]+)_|                        .
      qq|(?k:(?:[0-9]+%3a)?[0-9][$Magic-]*)_|              .
      qq{(?k:(?:(?:$Oses)-)?(?:$Arches|$xArches|$Extras))} .
    qq|\\.deb)(?![$Magic-])|;

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
  name   => [ qw| debian archive source | ],
  create =>
    q|(?k:|                         .
      q|(?k:[a-z0-9][a-z0-9+.-]+)_| .
# XXX: Yes, must be ungreedy
      qq|(?k:[0-9][$Magic-]*?)|     .
      q|\.(?k:(?:orig\.)?tar)|      .
    qq|\\.gz)(?![$Magic-])|;

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
  name   => [ qw| debian archive patch | ],
  create =>
    q|(?k:|                         .
      q|(?k:[a-z0-9][a-z0-9+.-]+)_| .
      qq|(?k:[0-9][$Magic-]*?)|     .
    qq{\\.diff\\.gz)(?![$Magic-])};

=item B<$RE{debian}{archive}{dsc}>

    'abc_0cba-12.dsc' =~ $RE{debian}{archive}{dsc}{-keep};
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
  name   => [ qw| debian archive dsc | ],
  create =>
    q|(?k:|                         .
      q|(?k:[a-z0-9][a-z0-9+.-]+)_| .
      qq|(?k:[0-9][$Magic-]*?)|     .
    qq{\\.dsc)(?![$Magic-])};

=item B<$RE{debian}{archive}{changes}>

    'abc_0cba-12.changes' =~ $RE{debian}{archive}{changes}{-keep};
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

=item I<$4> is I<architecture>

B<(caveat)>
Please read B<$RE{d}{a}{binary}> section for details.

=back

=cut

pattern
  name   => [ qw| debian archive changes | ],
  create =>
    q|(?k:|                                                .
      q|(?k:[a-z0-9][a-z0-9+.-]+)_|                        .
      qq|(?k:[0-9][$Magic-]*?)_|                           .
      qq{(?k:(?:(?:$Oses)-)?(?:$Arches|$xArches|$Extras))} .
    qq{\\.changes)(?![$Magic-])};

=item B<$RE{debian}{sourceslist}>

    'deb file:/usr/local oldstable main contrib non-free' =~ $RE{debian}{sourceslist}{-keep} and
      system "rm -rf $5" or die;
    ($4 eq 'http' || $4 eq 'rsh' || $4 eq 'ssh') &&
      !index $5, '//' or die;
    ($4 eq 'file' || $4 eq 'cdrom' || $4 eq 'copy') &&
      !index($5, '/') && index($5, '/', 1) > 1 or die;
    index(reverse($6), '/') || $7 or die;

This is one entry in F<sources.list> resource list.
The format is described in B<sources.list(5)> man page
(hence a chance for desincronization provided).

=over

=item I<$1> is I<resource_entry>

B<$RE{d}{sourceslist}> is very permissive about what would constitute entries,
but you can bet on -- the whole entry stays on one line.

=item I<$2> is I<resource_type>

That can be either C<deb> or C<deb-src>.
Implicit negative lookbehind for C<qrZ<>E<sol>\wZ<>E<sol>> provided
(so C<=deb> is accepted, C<_deb> is not;
hey, C<#deb> is accepted too!
explicit anchoring at your option).

=item I<$3> is I<uri>

You think you know what URI is?
Read below...

=item I<$4> is I<scheme>

Scemes that B<APT> knows have nothing to do with B<sources.list(5)> actually.
I<scheme> that B<APT> will use is some executable in F</usr/lib/apt/methods>
(some of them are for transfer, some are not).
B<sources.list(5)> (of C<lenny>) defines these:

=over

=item local filesystem

C<file>, C<cdrom>, C<copy>.

=item network

C<http>, C<ftp>, C<rsh>, C<ssh>

=back

Delimiting colon C<:> isn't included here
(although I<uri> does).

=item I<$5> is I<hier_path>

The idea is that someday B<$RE{d}{sourceslist}> would look behind at I<uri> to
decide if there should be I<authority>
(that one delimited with C<E<sol>E<sol>>)
or I<path_absolute> would be enough.
Right now that's not the case.
B<(bug)> Any non-space sequence is I<hier_path>.

That's very bad, but that's the way it's done right now.
Look, parsing URI is a task for standalone B<pattern>.
It's not implemented, maybe someday some kind perlist would do that.

=item I<$6> is I<distribution>

Debian is full of surprises.
Lots of surprises.
You think you know what I<distribution> is, don't you?
You missed.
I<distribution> can be filesystem path.
Since B<sources.list(5)> doesn't mention space escaping techniques I assume
spaces aren't allowed;
so any no-space is allowed.
You think that's an overkill?
You're obviously wrong
(think C<$ARCH>, B<sources.list(5)> has more).

=item I<$7> is I<component_list>

In misguided attempt not to make them too different with all that crowd,
I<component_list> is space delimited list of non-spaces.
If I<distribution> ends with slash (C<E<sol>>), then I<component_list> can be
empty
(I've meant, maybe someday that will look-behind too).

=back

All that is quite messy.
Can it be improved?
Surely yes
(even if we stay in B<Regexp::Common> requirements)
(think C<qrZ<>E<sol>(?E<verbar>)E<sol>>).
And then we have one more C<v5.10.0> only regexp.
Someday C<v5.10.0> will be oldstable...

=cut

pattern
  name   => [ qw| debian sourceslist | ],
  create =>
    q|(?k:| .
# FIXME: change C<qr/[\011\040]/> to C<qr/\h/> asap.
      q|(?k:(?<!\w)deb(?:-src)?)[\011\040]+|                              .
      q|(?k:|                                                             .
        q{(?k:file|http|ftp|cdrom|copy|rsh|ssh):}                         .
        q|(?k:[[:graph:]]+))[\011\040]+|                                  .
      q|(?k:[[:graph:]]+)|                                                .
      q|(?:[\011\040]+|                                                   .
      q{(?k:[[:graph:]]+(?=[\011\040]|\z)(?:[\011\040]+[[:graph:]]+)*))*} .
    q|)|;

=item B<$RE{debian}{preferences}>

    <<END_OF_PREFERENCE =~ $RE{debian}{preferences{-keep}} or die;
    Explanation: Stay updated!
    Package: perl
    Pin: version 5.10*
    Pin-Priority: 1001
    END_OF_PREFERENCES
    $2 eq 'perl' and
      print "good, we are looking for perl\n";
    $3 eq 'version' and $4 =~ /^5\.10/ and
      print "good, we are looking for recent\n";
    $5 =~ /^\d+$/ && $5 > 1000 and
      print "good, we'll stay updated\n";

This is one entry in F<preferences> list.
Good news are over, bad news are below.
I've failed to find B<definition> of entry in F<preferences>
(still looking).
B<apt_preferences(5)> suggests on what that looks like providing examples.
It's not enough;
C<apt-cache policy> behaviour leads from understanding either.

After some experimenting I've found that:
In general this is Debian control file format.
With some quirks provided.
Mine problem isn't how to implement that post-processing with REs:
mine problem is what those quirks are!
Either I figuring out the format, or releasing.
So here we are -- some common case of entry in F<preferences>.

Shortly:

=over

=item *

each entry consists of 3 stanzas (C<Package:>, C<Pin:>, C<Pin-Priority:>);

=item *

the order matters, no intermediate stanzas allowed;

=item *

case doesn't matter (for both name and value of stanza (to some degree));

=item *

whatever has gone before C<Package:> or came after C<Pin-Priority:> (line-wise)
is ignored;

=item *

C<apt-cache policy> fails in one case -- C<Package:> stanza has leading spaces;

=item *

misparsed values are ignored,
thus invalidating the whole entry (but see below),
thus the entry is ignored.

=back

That's what B<$RE{debian}{preferences}> does.
More on each stanza below.

B<(bug)>  C<apt-cache policy> will accept newlines -- those are spaces in
Debian control files, while consequent lines proper indentation provided.
B<$RE{d}{preferences}> accepts one line stanzas only.

=over

=item I<$1> is a I<preferences_entry>

That's the whole entry -- with all leading and trailing spaces, and an Easter
Eggs.
B<apt_preferences(5)> invents something called C<Explanation:> stanzas
(they should go before C<Package:>, with no empty lines in between).  
Since we are aware of that, C<Explanation:> sequence is provided in I<$1>
(and it won't be ever I<$2>
(1st, obvious compatibility reasons;
2nd, it's somewhat legalized since it's mentioned;
3rd, it can be easily dropped in case I found that useful)).

=item I<$2> is a I<package_stanza>

That's either C<*> (star, match-any-string wildcard) or space separated list of
package names
(alone package name is degenerated list).
That is, if I<package_stanza> is a list, than each (even if there's only one)
non-space sequence is treated as package name.
C<apt-cache policy> doesn't verifies its input, so one can put here anything.
Then those sequences will be matched literally against known package names.

B<(feature)>  In contrary with everything else, in B<$RE{d}{preferences}>,
package names are case-sensitive.

B<(bug)>  C<apt-cache policy> will silently accept star among package names.
Then, since no-one package name matches (there can't be a package named C<*>)
the star will be missing among pinned packages.
B<$RE{d}{preferences}> rejects such string.

=item I<$3> is a I<context_switch>

C<Pin:> stanza is broken in two parts.
That's the first one.
One of 3 acceptable strings are C<version>, C<origin>, or C<release>.
Bad news below.

=item I<$4> is a I<context_filter>

B<(bug)>  (what else?)  What would be a correct input here depends on I<$3>.
B<$RE{d}{preferences}> takes anything up to the next newline.

=item I<$5> is a I<pin_priority_stanza>

In I<$5> will be a sequence of decimal numbers
(yes, hexadecimals are rejected and octals aren't converted),
optionally prepended with C<+> (plus) or C<-> (minus) signs up to surprising
C<.> (dot).
Any trailing decimals and dots (after the first one) will be ignored by
C<apt-cache policy>.
So does the B<$RE{d}{preferences}> too.
The optional dot-decimal trailer will be missing in I<$5>, but present in
I<$1>.

=back

It's a mess, isn't it?
Go figure.

=cut

pattern
  name   => [ qw| debian preferences | ],
  create =>
    q|(?k:(?ism)(?:^Explanation:[^\n]*\n)*|                  .
# TODO: Match multiline values.
      q|^Package:[\011\040]*|                                .
        q{(?k:\*|}                                           .
# FIXME: Should canibalize B<$RE{debian}{package}>
        q{(?-i:[a-z0-9+.-]+(?:[\011\040]+[a-z0-9+.-]+)*))}   .
      q|+[\011\040]*\n|                                      .
      q|Pin:[\011\040]*|                                     .
        q{(?k:version|origin|release)[\011\040]+}            .
# TODO: Should check I<$3> and then be more strict with I<$4>
        q{(?k:[^\n\011\040]+(?:[\011\040]+[^\n\011\040]+)*)} .
      q|[\011\040]*\n|                                       .
      q|Pin-Priority:[\011\040]*|                            .
        q|(?k:[-+]?\d+)(?:[.\d]+)?|                          .
      q{[\011\040]*\n(?=\n|\z)}                              .
    q|)|;

=item B<$RE{debian}{changelog}>

    <<END_OF_CHANGELOG =~ $RE{debian}{changelog{-keep}} or die;
    perl (6.0.0-1) unstable; urgency=high
      * Hourah!
     -- John Doe <doe@example.tld>  Thu, 01 Apr 2010 00:00:00 +0300
    END_OF_CHANGELOG
    print <<"END_OF_REPORT"
    package        : $2
    version        : $3
    in archive     : $4
    flags          : $5
    changes        :
    ${6}uploaded by    : $7
    achknowledgment: $8
    at time        : $9

This is one entry in F<debianZ<>E<sol>changelog>.
The format is described in S<Section 4.4> of Debian Policy.
In real world parsing of this file is done by special Perl module
(I'm not aware of implementations in other languages)
or B<dpkg-parsechangelog>
(of B<dpkg-dev> package (that in turn is Perl script, again)).

There're 2 special Perl modules
(namely: B<Debian::ParseChangelog>, and, you knew it, B<Dpkg::Changelog>).
And now there'is 3rd one (how cute).
Those former are readZ<>E<sol>write engine, B<$RE{debian}{changelog}> is
read-only obviously.  
There's a point of desincronization though.

S<Section 4.4.1> of Debian Policy makes provisions for injecting
F<debianZ<>E<sol>changelog> in different (alternate) format.
To achieve that, one should provide suitable parser.
At time of writing I'm unaware of such alternatives.
(However, I'm aware of [489460@bugs.debian.org] (wishlist, pending,
2008-07-05);
let's wait.)

=over

=item I<$1> is a I<changelog_entry>

That's the whole entry with trailing newline and otherwise skipped empty lines.
That trailing newline is the one terminating the last line;
entry separating newlines are ignored by this regexp.

=item I<$2> is a I<debian_package>

That's a simplified version -- sequence of characters allowed in Debian package
name.

=item I<$3> is a I<debian_version>

That's a simplified too.
For some weird reason I<debian_version> should start with a number.
Surrounding braces aren't included.

=item I<$4> is a I<distributions>

That's space (C<S< >>) separated sequence of letters (C<S<a .. z>>) and hiphens
(C<->) in any order,
except first character should be letter (weird).
Space before terminating semicolon is disallowed.
Terminating semicolon isn't included.

=item I<$5> is I<keys> (or I<urgency>, if you like)

B<(note)> Debian Policy explicitly states that that field is supposed to be a
comma (C<,>) separated list of equals (C<=>) separated key-value pairs.
However the only known I<key> is C<urgency>.
Maybe I'm too pesimistic,
but despite the fact that the only I<key> allowed is C<urgency> the whole
I<key>=I<value> pair is put in I<$5> --
so you've better be prepared and pick a I<key> you're looking for
(one day you can get a lot more).

=item I<$6> is I<changes>

That invents concept of empty line.
For B<$RE{d}{changelog}> "empty line" consists lone newline.
OTOH, "line" is 2 spaces and anything up to next newline
(space counts as "anything" too).
1 or 2 spaces and newline fails entirely.
As requested by Debian Policy (or stock parser) leading and trailing empty
lines are ignored
(they are included in I<$1> though).

B<(note)> (I can't say is it a bug or feature)
The recommended way of outlineing I<changes> is starting each subentry with
star (C<*>), then adding at least one space to sub-subentries.
B<$RE{d}{changelog}> doesn't go that far.

B<(note)> (I can't say is it a bug or feature)
The leading and trailing empty lines are said to be optional.
However one leading and one trailing empty line are present in each (decent?)
entry in Debian changelog file.
B<$RE{d}{changelog}> doesn't insist on that.

=item I<$7> is a I<maintainer_name>

B<$RE{d}{changelog}> is very permissive about what is I<maintainer_name>
(and what it is actually?).
I<$8> and I<$9> take care of themselves.
A leading double-hyphen and space and separating space aren't included.

=item I<$8> is an I<email_address>

That one (with option to I<maintainer_address>) is subject to be processed with
B<Regexp::Common::Email::Address>
(or not, under consideration).
Anyway, right now it's a sequence of non-spaces surrounded by angle brackets.
Surrounding brackets aren't included.

=item I<$9> is a I<changelog_date>

That one is subject to be processed with B<Regexp::Common::Time>.
Anyway, right now it's a sequence of RFC822-date forming characters,
starting with capital letter and terminated with decimal number.
Neither leading double-space nor trailing newline isn't included.

=back

Pity on me.

=cut

pattern
  name   => [ qw| debian changelog | ],
  create =>
# FIXME: Should canibalize B<$RE{d}{package}> and B<$RE{d}{version}>
    q|(?k:(?sm)^|                                         .
      q|(?k:[a-z0-9+.-]+)\040|                            .
      q|\((?k:[0-9][0-9A-Za-z.+:~-]*)\)\040|              .
      q|(?k:[a-z][a-z -]*)(?<!\040);\040|                 .
      q|(?k:urgency=[A-Za-z]+)\n+|                        .
      q|(?k:(?:|                                          .
        q'^\040{2}[^\n]+\n|'                              .
        q'^\n(?>!\n*\040--)'                              .
      q|)+)\n*|                                           .
      q|\040--\040|                                       .
# FIXME: Should use B<Regexp::Common::Email::Address>
        q|(?k:(?<=-\040)[^ \n][^\n]+)(?<!\040)\040|       .
        q|<(?k:[^\s]+)>\040\040|                          .
# FIXME: Should use B<Regexp::Common::Time>
        q|(?k:(?<=>\040\040)[A-Z][A-Za-z0-9 ,:+-]+[0-9])| .
    q|\n)|;

=back

=head1 BUGS AND CAVEATS

Grep this pod for C<(bug)> andZ<>E<sol>or C<(caveat)>.
They all are placed in appropriate sections.

=head1 AUTHOR

Eric Pozharski, E<lt>whynot@cpan.orgZ<>E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2008, 2009 by Eric Pozharski

This library is free in sense: AS-IS, NO-WARANRTY, HOPE-TO-BE-USEFUL.
This library is released under LGPLv3.

=head1 SEE ALSO

L<Regexp::Common>,
L<http:E<sol>E<sol>www.debian.orgZ<>E<sol>docZ<>E<sol>debian-policy>,
sources.list(5),
apt_preferences(5),
dpkg-parsechangelog(1),

=cut

1;
