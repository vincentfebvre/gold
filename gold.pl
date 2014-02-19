#!/usr/bin/env perl

my %dic;
my @thr;
my @rul;

open THR, "thr.txt" or die;
while (<THR>)
{
	chomp;
	s/^\s+//;
	s/\s+$//;
	next if (/^$/);
	if (/^(\w+)>(\w+)>(\w+)$/)
	{
		if (!exists($dic{$1}))
		{
			$dic{$1} = 1;
			print "Added : '$1'\n";
		}
		if (!exists($dic{$2}))
		{
			$dic{$2} = 1;
			print "Added : '$2'\n";
		}
		if (!exists($dic{$3}))
		{
			$dic{$3} = 1;
			print "Added : '$3'\n";
		}
		push @thr, [$1, $2, $3];
	}
	else
	{
		print "Error at line\n";
	}
}
close THR;

if (

