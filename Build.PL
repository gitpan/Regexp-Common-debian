#!/usr/bin/perl
# $Id: Build.PL 13 2008-12-31 10:34:06Z whyn0t $

package main;
use strict;
use warnings;

use version 0.50; our $VERSION = qv q|0.0.4|;

use Module::Build 0.20;

=head1 OVERVIEW

The B<Regexp::Common::debian> is collection of REs for various strings found in
the Debian Porject E<lt>L<http:E<sol>E<sol>debian.org>E<gt>.
It's no way intended to be a validation tool.

Right now (before first release) I can't decide what version of Perl is needed.
I should admit though, I'll do my best to support perl distributed with
C<stable> release of Debian GNU/Linux
(at time of writing it is C<v5.8.8>).
And I'll try hard to support perl in C<oldstable> (C<v5.8.4>).

=head1 INSTALL

The B<R::C::d> is distributed with B<Module::Build>.

    $ perl Build.PL
    $ perl Build
    $ perl Build test
    $ perl Build install

Since we're about strings we need a lots of strings to test against
(B<Test::More>, unspecified version).
To access them easily (it's all about reuse, not implemented yet) I need an
apropriate storage.
Accidentally it's B<YAML::Tiny> (unspecified version).

If any test string fails I need to know what and how.
To provide that info I've picked B<Test::Differences>
(maybe there's other option I'm not aware of?).
(Surely I could go one of fail-proof ways described in B<T::D> pod;
and what if something goes wrong?
let's no play stupid hope -- I must know what happened.)
That yeilds a big problem.
B<T::D> has two (actually one) open bugs --
E<lt>L<http:E<sol>E<sol>rt.cpan.orgZ<>E<sol>PublicZ<>E<sol>BugZ<>E<sol>Display.html?id=38320|[#38320]>E<gt>
and
E<lt>L<http:E<sol>E<sol>rt.cpan.orgZ<>E<sol>PublicZ<>E<sol>BugZ<>E<sol>Display.html?id=41241|[#41241]>E<gt>
--
at time of writing they are still open, no maintainer responce, patch is
provided.
Some test strings of B<R::C::d> give C<undef> as predicted result.
That will provide a lots of "use of undef" warnings (really, a lots of).
And as a matter of fact, B<T::D> will be somewhat useles -- forgive me, let me
figure out version relations first.

=cut

my $engine = Module::Build->new(
  module_name       => q|Regexp::Common::debian|,
  dist_author       => q|Eric Pozharski <whynot@cpan.org>|,
  license           => q|lgpl|,
  sign              => 1,
  requires          => {
    q|version|        => 0.50,
    q|Regexp::Common| => '', },
  build_requires    => {
    q|Test::Differences| => '',
    q|YAML::Tiny|        => '',
    q|Test::More|        => '', },
  PL_files          => {
    ( -f q|README.PL|  ? ( q|README.PL|  => q|README|  ) : ()),
    ( -f q|CHANGES.PL| ? ( q|CHANGES.PL| => q|Changes| ) : ()), },
  add_to_cleanup    => [ qw| *.tmp *.bak foo.* |,
    ( -f q|README.PL|  ? q|README|  : ()),
    ( -f q|CHANGES.PL| ? q|Changes| : ()), ],);

$engine->create_build_script();

=head1 AVAILABILITY

#FIXME: think http:E<sol>E<sol>cpan.org

#FIXME: think http:E<sol>E<sol>sourceforge.net

=head1 BUGS

#FIXME: think http:E<sol>E<sol>rt.cpan.org

=head1 COPYRIGHT AND LICENSING

=over

=item *

Copyright 2008 Eric Pozharski <whynot@cpan.org>

=item *

AS-IS, NO-WARRANTY, HOPE-TO-BE-USEFUL

=item *

Lesser General Public License v3
E<lt>L<http:E<sol>E<sol>www.gnu.orgZ<>E<sol>licensesZ<>E<sol>lgpl.txt>E<gt>

=back
