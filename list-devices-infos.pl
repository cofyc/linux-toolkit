#!/usr/bin/perl -w
#
# Used to list all scsi devices, and theirs partitions and mountpoints if presented.
#
# References:
# - https://www.kernel.org/pub/linux/utils/util-linux/v2.21/libblkid-docs/libblkid-Partitions-probing.html
#

my $scsidevices=`lsscsi | awk '{print \$NF}' | grep -P 'sd[a-z]\$'`; 
sub print_dev;
sub print_dev {
    my $dev = shift;
    my $partition = shift;
    my $output = `blkid -p -s TYPE -s PTTYPE -s UUID -s PART_ENTRY_NAME -s PART_ENTRY_UUID -s PART_ENTRY_DISK -o export $partition`;
    my $fstype = "";
    my $pttype = "";
    my $fsuuid = "";
    my $pt_entry_name = "";
    my $pt_entry_uuid = "";
    my $pt_entry_disk = "";
    for (split(/\n/, $output)) {
        my @seps = split '=', $_, 2;
        if ($seps[0] eq "PTTYPE") {
            $pttype = $seps[1];
        } elsif ($seps[0] eq "TYPE") {
            $fstype = $seps[1];
        } elsif ($seps[0] eq "UUID") {
            $fsuuid = $seps[1];
        } elsif ($seps[0] eq "PART_ENTRY_NAME") {
            $pt_entry_name = $seps[1];
        } elsif ($seps[0] eq "PART_ENTRY_UUID") {
            $pt_entry_uuid = $seps[1];
        } elsif ($seps[0] eq "PART_ENTRY_DISK") {
            $pt_entry_disk = $seps[1];
        }
    }
    if ($pttype ne "") {
        $output = `partx --show --noheadings $partition`;
        for (split(/\n/, $output)) {
            my @seps = split ' ', $_;
            print_dev($dev, $dev . $seps[0]);
        }
    } elsif ($fstype ne "") { 
	$output = `findmnt --noheadings $partition`;
        if ($output ne "") {
            for (split(/\n/, $output)) {
                my @seps = split /\s+/, $_;
                print "$dev\t$partition\t$fsuuid\t$fstype\t$seps[0]\t$seps[1]\t$seps[2]\t$seps[3]\n";
            }
        } else {
            print "$dev\t$partition\t$fsuuid\t$fstype\n";
        }
    } else {
        print "error: $dev/$partition does not have parition or filesysem\n"
    }
}

print "DEVICE\tPARTITION\tUUID\tFSTYPE\tTARGET\tSOURCE\tFSTYPE\tOPTIONS\n";
for my $dev (split(/\n/, $scsidevices)) {
    print_dev($dev, $dev);
}
