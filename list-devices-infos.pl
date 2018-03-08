#!/usr/bin/perl -w
#
# Used to list all scsi devices, and theirs partitions and mountpoints if presented.
#

my $scsidevices=`lsscsi | awk '{print \$NF}' | grep -P 'sd[a-z]\$'`;

sub print_dev;
sub print_dev {
    my $dev = shift;
    my $output = `blkid -p -s TYPE -s PTTYPE -o export $dev`;
    my $fstype = "";
    my $pttype = "";
    for (split(/\n/, $output)) {
        my @seps = split '=', $_, 2;
        if ($seps[0] eq "PTTYPE") {
            $pttype = $seps[1];
        } elsif ($seps[0] eq "TYPE") {
            $fstype = $seps[1];
        }
    }
    if ($pttype ne "") {
        $output = `partx --show --noheadings $dev`;
        for (split(/\n/, $output)) {
            my @seps = split ' ', $_;
            print_dev($dev . $seps[0]);
        }
    } else { 
        if ($output ne "") {
            for (split(/\n/, $output)) {
                my @seps = split /\s+/, $_;
                print "$dev\t$seps[0]\t$seps[1]\t$seps[2]\t$seps[3]\n";
            }
        } else {
            print "$dev\n";
        }
    }
}

print "DEVICE\tPARTITION\tARGET\tSOURCE\tFSTYPE\tOPTIONS\n";
for my $dev (split(/\n/, $scsidevices)) {
    print_dev $dev;
}
