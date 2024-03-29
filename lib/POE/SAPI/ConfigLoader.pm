package POE::SAPI::ConfigLoader;

use 5.010001;
use strict;
use warnings;

use POE;

our $VERSION = '0.03';

my $config = 'config.db';

sub new {
        my $package = shift;
        my %opts    = %{$_[0]} if ($_[0]);
        $opts{ lc $_ } = delete $opts{$_} for keys %opts;       # convert opts to lower case
        my $self = bless \%opts, $package;

        $self->{start} = time;
        $self->{cycles} = 0;

        $self->{me} = POE::Session->create(
                object_states => [
                        $self => {
                                _start          =>      'initLauncher',
                                loop            =>      'keepAlive',
                                _stop           =>      'killLauncher',
				initConfig	=>	'initConfig',
                        },
                        $self => [ qw (   ) ],
                ],
        );
}

sub keepAlive {
        my ($kernel,$session)   = @_[KERNEL,SESSION];
        my $self = shift;
        $kernel->delay('loop' => 1);
        $self->{cycles}++;
}
sub killLauncher { warn "Session halting"; }
sub initLauncher {
	my ($self,$kernel) = @_[OBJECT,KERNEL];
	$kernel->yield('loop'); 
	$kernel->alias_set('ConfigLoader');
	$kernel->post($self->{parent},'register',{ name=>'ConfigLoader', type=>'local' });
}
sub initConfig {
        my ($kernel,$self) = @_[KERNEL,OBJECT];

        my $dbfile = 'config.db';

        if (-e $self->{base}.$dbfile) {
                $kernel->post($self->{parent},"passback",{ type=>"debug", msg=>"DB PATH: ".$self->{base}.$dbfile." EXISTS - loading", src=>"ConfigLoader" });
                $kernel->post('DBIO',"initConfig");
		
        } else {
                $kernel->post($self->{parent},"passback",{ type=>"debug", msg=>"DB PATH: ".$self->{base}.$dbfile." NONEXISTANT", src=>"ConfigLoader" });
		$kernel->post('DBIO',"newDB",{ 
			'port'	=> 'auto',
			'host'	=> 'auto',
			'admin'	=> 'AdminPass',
		});
        }
}


1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

POE::SAPI::ConfigLoader - Perl extension for blah blah blah

=head1 SYNOPSIS

  use POE::SAPI::ConfigLoader;

=head1 DESCRIPTION

This is a CORE module of L<POE::SAPI> and should not be called directly.

=head2 EXPORT

None by default.

=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Paul G Webster, E<lt>paul@daemonrage.netE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Paul G Webster

All rights reserved.

Redistribution and use in source and binary forms are permitted
provided that the above copyright notice and this paragraph are
duplicated in all such forms and that any documentation,
advertising materials, and other materials related to such
distribution and use acknowledge that the software was developed
by the 'blank files'.  The name of the
University may not be used to endorse or promote products derived
from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.


=cut
