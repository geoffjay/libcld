#!/usr/bin/perl -w

use strict;
use IO::Select;
use IO::Socket;
use constant ECHO_PORT => 4444;

my %clients;
my $count;

my $srvr = IO::Socket::INET->new(Proto=>'tcp',
                                 LocalPort=>ECHO_PORT,
                                 Listen=>SOMAXCONN,
                                 Reuse=>1)
    or die "Error creating server socket: $!";
$srvr->autoflush(1);
my $sel = IO::Select->new($srvr);
while (1) {
    my @rdy = $sel->can_read(1);
    if (scalar @rdy == 0) {
        # remove timed out clients
        my $t = time();
        for my $cli (keys %clients) {
            if ($clients{$cli}{timeout} <= $t) {
                $sel->remove($clients{$cli}{conn});
                $clients{$cli}{conn}->close();
                delete $clients{$cli};
            }
        }
    }
    for my $cli (@rdy) {
        if ($cli == $srvr) {
            my $cli = $srvr->accept;
            unless ($cli) {
                die "Error accepting client connection: $!\n";
                next;
            }
            print "Received client connection\n";
            $clients{$cli}{conn} = $cli;
            $clients{$cli}{timeout} = time() + 10;
            $sel->add($cli);
        } else {
            my $buffer;
            if (sysread ($cli,$buffer,1024)) {
                print "Received message: $buffer";
                $buffer = $buffer . "\n";
                syswrite($cli,$buffer);
            } else {
                warn "Error reading from client: $!\n";
            }
            $sel->remove($cli);
            $cli->close();
            delete $clients{$cli};
        }
    }
}
