#!/usr/bin/env perl

my %dic;
my @thr;
my @rul;

use constant {
	FALSE => 0,
	TRUE => 1,
	UNKNOWN => 2,
	ERROR => 3,
};

sub CheckSingle($$$)
{
	my ($a, $b, $c) = @_;

	# Case 1
	return ERROR if (!exists($dic{$a}) or !exists($dic{$b}) or !exists($dic{$c}));

	# Case 2
	foreach (@thr)
	{
		return TRUE if ($_->[0] == $a and $_->[1] == $b and $_->[2] == $c);
	}


	# Case 3

	return UNKNOWN;
}

sub LoadData()
{
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
				print "New word : '$1'\n";
			}
			if (!exists($dic{$2}))
			{
				$dic{$2} = 1;
				print "New word : '$2'\n";
			}
			if (!exists($dic{$3}))
			{
				$dic{$3} = 1;
				print "New word : '$3'\n";
			}
			push @thr, [$1, $2, $3];
			print "'$1' > '$2' > '$3'\n";
		}
		else
		{
			print "Error at line\n";
		}
	}
	close THR;
}

LoadData();

