#!/usr/bin/env perl

use strict;
use Data::Dumper;
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
	my (@toexplore, @paths);

	return ERROR if (!exists($dic{$a}) or !exists($dic{$b}) or !exists($dic{$c}));

	push @toexplore, [$a];
	while (@toexplore)
	{
		my $p = shift(@toexplore);
		my $lastnode = $p->[scalar(@$p) - 1];
		print "Now looking at @$p, $lastnode\n";
		foreach my $t (@thr)
		{
			print "-> @$t\n";
			if ($t->[0] eq $lastnode or $t->[2] eq $lastnode)
			{
				print "*\n";
				my $alreadyinlist = 0;
				# Check if this is already in path
				for (my $i = 0; $i < scalar(@$p) - 1; $i += 4)
				{
					if (($p->[$i] eq $t->[0] and $p->[$i+1] eq '>' and $p->[$i+2] eq $t->[1] and $p->[$i+3] eq '>' and  $p->[$i+4] eq $t->[2]) or
						($p->[$i] eq $t->[2] and $p->[$i+1] eq '<' and $p->[$i+2] eq $t->[1] and $p->[$i+3] eq '<' and  $p->[$i+4] eq $t->[0]))
						{
							print "Already in list\n";
							$alreadyinlist = 1;
							last;
						}
				}
				if ($alreadyinlist == 0)
				{
					if ($t->[0] eq $lastnode)
					{
						push @$p, '>';
						push @$p, $t->[1];
						push @$p, '>';
						push @$p, $t->[2];
						if ($t->[2] eq $c)
						{
							push @paths, $p;
						}
						else
						{
							push @toexplore, $p;
						}
					}
					else
					{
						push @$p, '<';
						push @$p, $t->[1];
						push @$p, '<';
						push @$p, $t->[0];
						if ($t->[0] eq $c)
						{
							push @paths, $p;
						}
						else
						{
							push @toexplore, $p;
						}
					}
					
				}
	
			}
			
		}
	}
	print "List of paths: ".Dumper(@paths);

	# Use rules!!!
	
	foreach my $p (@paths)
	{
		print "RULES FOR PATH @$p\n";
		my @modifiedpaths;
		my $addedpaths;
		push @modifiedpaths, $p;
		do
		{
			print " Round\n";
			$addedpaths = 0;
			foreach my $r (@rul)
			{
				print "  Rule\n";
				for (my $i = 0; $i < scalar(@$p) - 1; $i += 4)
				{
					my %vars;
					print "   $i\n";
					foreach my $el (@{$r->{conditions}})
					{
						
					}
				}
				
			}
		} while ($addedpaths > 0);
	}


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
		next if (/^\#/);
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


	open RUL, "trans.txt" or die;
	while (<RUL>)
	{
		chomp;
		s/^\s+//;
		s/\s+$//;
		next if (/^$/);
		next if (/^\#/);
		if (/^(.+),(.+),(.*)$/)
		{
			my %rule;
			$rule{before} = [];
			push @{$rule{before}}, split(/(?=\>\<)|(?<=\>\<)(?! )/, $1);
			$rule{after} = [];
			push @{$rule{after}}, split(/(?=\>\<)|(?<=\>\<)(?! )/, $2);

			$rule{conditions} = [];
			foreach (split(/\s+et\s+/, $3))
			{
				if (/^(.+)\>(.+)\>(.+)$/)
				{
					push @{$rule{conditions}}, [$1, $2, $3];
				}
				else
				{
					print "Error: $_\n";
					die;
				}
			}
			print "Rule @{$rule{before}} @{$rule{after}}\n";
			push @rul, \%rule;
		}
		else
		{
			print "Error at line\n";
		}
	}
	close RUL;
}

LoadData();
#print CheckSingle("russie", "plusgrandque", "france")."\n";
#print CheckSingle("russie", "plusgrandque", "suisse")."\n";
#print CheckSingle("suisse", "pluspetitque", "france")."\n";
print CheckSingle("suisse", "pluspetitque", "russie")."\n";
