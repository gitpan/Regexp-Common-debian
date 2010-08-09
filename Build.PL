#!/usr/bin/perl
# $Id: Build.PL 395 2010-08-08 18:39:27Z whynot $

package main;
use strict;
use warnings;

use version 0.50; our $VERSION = qv q|0.2.12|;

use Module::Build 0.20;

=head1 OVERVIEW

The B<Regexp::Common::debian> is collection of REs for various strings found in
the Debian Porject E<lt>L<http:E<sol>E<sol>debian.org>E<gt>.
It's no way intended to be a validation tool.

Since B<Regexp::Common::debian> uses B<our> declaration that was introduced in
C<v5.6.0>, B<R::C::d> needs C<v5.6.0> to run.
I should admit though, I'll do my best to support perl distributed with
C<stable> release of Debian GNU/Linux
(at time of writing it is C<v5.10.0>).
And I'll try hard to support perl in C<oldstable> (C<v5.8.8>).

=head1 INSTALL

The B<R::C::d> builds with B<Module::Build>.

    $ perl Build.PL
    $ perl Build
    $ perl Build test
    $ perl Build install

Since we're about strings we need a lots of strings to test against
(B<Test::More>, unspecified version).
To access them easily (it's all about reuse, not implemented yet) I need an
apropriate storage.
Accidentally it's B<YAML::Tiny> (unspecified version).

C<v0.2.1>
Reading reports of cpantesters I've got to conclusion that B<YAML::Tiny> isn't
popular.
And avoiding installing (or unability to install (there could be reasons))
build requirements isn't that uncommon.
Although I experience a strong belief that some YAML reader happens to be
installed anyway.
And still I can't find a way to specify that I<%build_requires> B<one of> but
B<all> known to me YAML reader.
So here is a dirty trick.
B<t::TestSuite> attempts to B<require()> one of known (to me, see below) YAML
reader.
Then (upon initial C<perl Build.PL>) B<t::TestSuite> is asked what it has found
(if nothing then cosmetic C<Compilation failed in require> message will be
seen).
And one what has been found will be added to I<%build_requires>;
If nothing then fair B<YAML::Tiny> will be added.
(I think it's fair because B<YAML::Tiny> is pure-Perl, small footprint, and no
dependencies.)

B<(note)>
I'm talking about "known to me YAML readers" because I've found out that
different YAML readers treat source differently.
So I attempt to keep F<t/*.yaml> files semantically equal and sintactically
correct.
Hopefully there're no differences among versions in wild.

C<v0.2.2>
Various (all, except F<t/preferences.t> and F<t/sourceslist.t>)
test-units know a magic command
'C<$ENV{RCD_ASK_DEBIAN}>'.
Apply it this way (enabling all possible external inquiries):

    RCD_ASK_DEBIAN=all ./Build test

or this (separate keys with any non-word):

    RCD_ASK_DEBIAN=binary,architecture ./Build test

When applied a test-unit would ask Debian's commands or inspect Debian specific
files for information the test-unit is interested in.
For obvious reasons that magic will fail on non-Debian system;
So don't.
Although if used correctly that could warn of strange ('not known before')
compatibility problems.
Details:

=over

=item B<architecture> of F<t/architecture.t>

This asks C<dpkg-architecture -L> for list of known architectures
(per Section 11.1 of debian-policy).
That wouldn't find architectures dropped (had that happen ever?)
but omissions won't stay unnoted anymore.

=item B<binary> of F<t/archive.misc.t>

C<v0.2.3>
Inspects all records in F</var/lib/apt/lists/*_Packages>, extracts I<Filename:>
entries matches all of them against
C<mE<sol>^$RE{debian}{archive}{binary}$E<sol>>.
All (if any) failure will be reported at the end.

=item B<changelog> of F<t/changelog.t>

C<v0.2.8>
That will inspect F</usr/share/doc/*/changelog.Debian> files.
To do a complete scan it would take B<loads> of time (really).
You should understand, that's not enough to just run through changelogs.
It has to be verified that none entry is skipped.
The only reliable (for sake of interface, and, trivially, presence) source of
verification
is C<dpkg-parsechangelog>.
And here's the fork-mare.
C<perl> forks C<shell>, then C<perl>, then C<perl> again.
There seems to be fork of C<tail> too.
And that for B<each> entry.
(Not to count C<gunzip> to decompress the changelog.)
C<loadavg> climbs over 1.50..2.00
You've got the picture.
Although that's where choice begins.

=over

=item I<changelog>

C<v0.2.9>
That defaults to C<changelog=5>.
See below.

=item I<changelog=package>

Only one changelog will be checked.
The one that C<eq>s.
The package name is picked from directory name.

=item I<changelog=a>

Only those changelogs will be checked that C<mZ<>E<sol>^aZ<>E<sol>>.

=item I<changelog=5>

C<v0.2.9>
That will check all changelogs, although it will look no more than requested
number of entries.
(~15min for ~1200 changelogs
(and that's with I<APT::Install-Recommends> disabled).)
And that has a perfect sense.
Do you know that C<cron> once changed it's name to C<Cron>
(beware leading block) (cron_3.0pl1-46)?
C'mon, it has happened 12 (tweleve) years ago!
I can't degrade B<$RE{d}{changelog}> to accommodate that.
(And you know what?
That default is pretty fair (liblog-log4perl-perl_1.16-1).
Probably it should look for time passed but entry number.)

=item I<changelog=-5>

C<v0.2.9>
That's different.
It will check as many entries as possible (there are changelogs what
B<$RE{d}{changelog}> finds out more entries than B<dpkg-parsechangelog>
(C<dpkg_1.2.13> vs C<dpkg_0.93.79>),
but if the offending record is more than that far from top then it's reported
and otherwise ignored.
(~3h for ~1200 packages, ~45000 successful subchecks.)

=item I<changelog=0>

B<(bug)>
C<v0.2.9>
That will check all changelogs, check all possible entries and B<BAIL_OUT> off
first failure.
Shortly -- don't.
You're warned.
(Although, do it.
F<t/changelog.t> will give up pretty soon.)

=back

To slightly sweeten all that, F<tZ<>E<sol>changelog.t> attempts to filter
duplicates.
And it B<BAIL_OUT>s upon first failure.

=item B<package> of F<t/package.t>

C<v0.2.10>
Nothing special.
Output of C<dpkg-query -f '${Package}\n' -W> is matched against
B<mZ<>E<sol>^$RE{debian}{package}$E<sol>>.
Probably should parse F<*_Packagees>.

=item B<source> of F<t/archive.source.t>

C<v0.2.3>
Inspects all records in F</var/lib/apt/lists/*_Sources>, extracts I<Files:>
entries, then collects trailing filenames.
They are matched against
C<mE<sol>^$RE{debian}{archive}{source_1_0}$E<sol>>,
C<mE<sol>^$RE{debian}{archive}{patch_1_0}$E<sol>>,
C<mE<sol>^$RE{debian}{archive}{source_3_0_native}$E<sol>>,
C<mE<sol>^$RE{debian}{archive}{source_3_0_quilt}$E<sol>>,
C<mE<sol>^$RE{debian}{archive}{patch_3_0_quilt}$E<sol>>,
and
C<mE<sol>^$RE{debian}{archive}{dsc}$E<sol>>
(in fact C<E<verbar>E<verbar>>).
If none matches then it will be reported at the end.
C<mE<sol>$RE{debian}{archive}{changes}E<sol>> is missing here because there is
no source of such on build undedicated system.

=item B<version> of F<t/version.t>

C<v0.2.10>
Again nothing special.
Output of C<dpkg-query -f '${Version}\n' -W> is matched against
B<mZ<>E<sol>^$RE{debian}{version}$E<sol>>.
Probably should parse F<*_Packages> too.

=back

If any test string fails I need to know what and how.
To provide that info I've picked B<Test::Differences>
(maybe there's other option I'm not aware of?)
(I'm, B<Test::Deep>).
(Surely I could go one of fail-proof ways described in B<T::D> pod;
and what if something goes wrong?
let's no play stupid hope -- I must know what happened.)
(After looking at number of C<UNKNOWN> results from CPAN-Testers -- I think, I
should.)
That yeilds a big problem.
B<T::D> has two (actually one) open bugs --
B<[38320@rt.cpan.org]> and B<[41241@rt.cpan.org]> --
at time of writing they are still open, no maintainer responce, patch is
provided.
Some test strings of B<R::C::d> give C<undef> as predicted result.
That will provide a lots of "use of undef" warnings (really, a lots of).
And as a matter of fact, B<T::D> will be somewhat useles -- forgive me, let me
figure out version relations first.

=cut

my $engine = Module::Build->new(
  module_name       =>                 q|Regexp::Common::debian|,
  dist_author       =>       q|Eric Pozharski <whynot@cpan.org>|,
  license           =>                                   q|lgpl|,
  sign              =>                                         1,
  requires          => {
    q|perl|           => q|5.6.0|,
    q|version|        =>     0.50,
    q|Regexp::Common| =>       ''                              },
  build_requires    => {
    q|File::Temp|        => '',
    q|Test::Differences| => '',
    q|Test::More|        => ''                                 },
  PL_files          => {
    ( -f q|README.PL|  ? ( q|README.PL|  =>  q|README| ) : ()),
    ( -f q|Changes.PL| ? ( q|Changes.PL| => q|Changes| ) : ()) },
  add_to_cleanup    => [ qw| *.tmp *.bak foo.* |,
    ( -f q|README.PL|  ? q|README|  : ()),
    ( -f q|Changes.PL| ? q|Changes| : ())                      ]);

my $y_choice = qx|perl -Mt::TestSuite -we 't::TestSuite::RCD_show_y_choice'|;
chomp $y_choice;
$engine->build_requires( ($y_choice || q|YAML::Tiny|) => '' );

$engine->create_build_script();

=head1 AVAILABILITY

=over

=item pure distribution

    http://search.cpan.org/dist/Regexp-Common-debian/

=back

=head1 BUGS

=over

=item please report here

    http://rt.cpan.org/Public/Dist/Display.html?Name=Regexp-Common-debian

=back

=head1 COPYRIGHT AND LICENSING

=over

=item *

Copyright 2008--2010 Eric Pozharski E<lt>whynot@cpan.orgZ<>E<gt>

=item *

AS-IS, NO-WARRANTY, HOPE-TO-BE-USEFUL

=item *

GNU Lesser General Public License v3
E<lt>L<http:E<sol>E<sol>www.gnu.orgZ<>E<sol>licensesZ<>E<sol>lgpl.txt>E<gt>

=back
