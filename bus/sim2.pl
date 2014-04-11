use strict;
use Storable 'dclone';
use Data::Dumper;

# Params
my %funcs = (
	Zero => { Assign => \&Assign_Random, NextMove =>\&NextMove_Random },
	A    => { Assign => \&Assign_LeastAssigned, NextMove =>\&NextMove_Random },
	B    => { Assign => \&Assign_LeastAssigned, NextMove =>\&NextMove_Closest },
);

my $funcset = "B";

my @num = ('0'..'9');
my @let = ('A'..'J');

my @stops;
foreach my $i (@num)
{
	foreach my $j (@let)
	{
		push @stops, {name => "$j$i"};
	}
}

my @pass;
my @passdone;
my $numpass = 0;
for my $t (0..100)
{
	my $maxp = 30;
	my $p = int(rand($maxp));
	for (0..$p)
	{
		my ($from, $to);
		$from = $let[int(rand(@let))].$num[int(rand(@num))];
		do {
			$to = $let[int(rand(@let))].$num[int(rand(@num))];
		} while ($from eq $to);
		$numpass++;
		push @pass, { name => "P$numpass", from => $from, to => $to, time1 => $t, time2 => undef, time3 => undef, assign => undef, dist=> DistanceBetween($from, $to) };
	}
}

my @veh;
for (1..10)
{
	push @veh, { name => "V$_", cap => 9, pos => 'A0', totdist => 0, carrying => [], assigned => [], nextmove => undef, togo => -1 };
}

my $time = 0;

sub DistanceBetween($$)
{
    my ($a, $b) = @_;
    my $dist = 0;
    my ($x1, $y1) = split(//, $a);
    my ($x2, $y2) = split(//, $b);
    $dist += abs(ord($x2) - ord($x1));
    $dist += abs(ord($y2) - ord($y1));
    return $dist;
}

sub NextMove_Random($)
{
	my ($v) = @_;
	if (!defined($v->{nextmove}) and (@{$v->{carrying}} > 0 or @{$v->{assigned}} > 0))
        {
            my @candidates;
            foreach (@{$v->{carrying}})
            {
                push @candidates, $_->{to};
            }
            foreach (@{$v->{assigned}})
            {
                push @candidates, $_->{from};
            }
            $v->{nextmove} = $candidates[0];
            $v->{togo} = DistanceBetween($v->{pos}, $v->{nextmove});
        }
}

sub NextMove_Closest($)
{
	my ($v) = @_;
	if (!defined($v->{nextmove}) and (@{$v->{carrying}} > 0 or @{$v->{assigned}} > 0))
        {
		my %best = (num => undef, id => undef);
		foreach (@{$v->{carrying}})
		{
			my $d = DistanceBetween($v->{pos}, $_->{to});
			if (!defined($best{id}) or $best{num} > DistanceBetween($v->{pos}, $d))
			{
				$best{id} = $_->{to};
				$best{num} = $d;
			}
		}
		if (@{$v->{carrying}} < $v->{cap})
		{
			foreach (@{$v->{assigned}})
			{
				my $d = DistanceBetween($v->{pos}, $_->{from});
				if (!defined($best{id}) or $best{num} > DistanceBetween($v->{pos}, $d))
				{
					$best{id} = $_->{from};
					$best{num} = $d;
				}
			}
		}
		$v->{nextmove} = $best{id};
		$v->{togo} = $best{num};
        }
}

sub NextMove($)
{
	my ($v) = @_;
	$funcs{$funcset}->{NextMove}($v);
}

sub Advance()
{
    foreach my $v (@veh)
    {
	# Where we on the move
	if ($v->{togo} > 0)
	{
		$v->{togo}--;
		$v->{totdist}++;
		$v->{eeos}--;
	}
	# Have we reached destination (or were we not moving but at the right position)
	if ($v->{togo} == 0)
	{
		$v->{pos} = $v->{nextmove};
		$v->{nextmove} = undef;
		$v->{togo} = -1;
	}
	if ($v->{togo} == 0 or $v->{togo} == -1)
            {
                # Passengers get off
                my @newc;
                foreach (@{$v->{carrying}})
                {
                    if ($_->{to} eq $v->{pos})
                    {
                        $_->{time3} = $time + 1;
                        print "$_->{time3}: pass $_->{name} ($_->{from} -> $_->{to}) GETS OFF $v->{name}\n";
                        push @passdone, $_;
                    }
                    else
                    {
                        push @newc, $_;
                    }
                }
                @{$v->{carrying}} = @newc;
                
                # Others get on
                my @newa;
                foreach (@{$v->{assigned}})
                {
                    if ($_->{from} eq $v->{pos} and @{$v->{carrying}} < $v->{cap})
                    {
                        $_->{time2} = $time + 1;
                        print "$_->{time2}: pass $_->{name} ($_->{from} -> $_->{to}) GETS ON $v->{name}\n";
                        push @{$v->{carrying}}, $_;
                    }
                    else
                    {
                        push @newa, $_;
                    }
                }
                @{$v->{assigned}} = @newa;
            }

        # Where to go next ?
        NextMove($v);

    }


	print ($time+1).":";
	foreach my $v (@veh)
	{
		print " $v->{name}($v->{pos}";
		print " -> $v->{nextmove} [$v->{togo}]" if defined($v->{nextmove});
		print " ".scalar(@{$v->{carrying}})."/".$v->{cap}." +".scalar(@{$v->{assigned}}).")";
		print "*$v->{eeos}*";
	}
	print "\n";
	$time++;
}

sub EstimatedEndOfService($)
{
	my ($v) = @_;
	my ($dist, $last);
	if (defined($v->{nextmove}))
	{
		$dist = $v->{togo};
		$last = $v->{nextmove};
	}
	else
	{
		$dist = 0;
		$last = $v->{pos}
	}
	my @dst;
	my $nodst = 0;
	foreach (@{$v->{assigned}})
	{
		push @dst, { from => $_->{from}, to => $_->{to}, st => 'a' };
		$nodst += 2;
	}
	foreach (@{$v->{carrying}})
	{
		push @dst, { from => $_->{from}, to => $_->{to}, st => 'c' };
		$nodst++;
	}
	while ($nodst > 0)
	{
		my %best = ( id => undef, num => undef, pos => undef );
		for (0..(@dst - 1))
		{
			my ($el, $pos);
			if ($dst[$_]->{st} eq 'a')
			{
				$pos =  $dst[$_]->{from}; 				
			}
			elsif ($dst[$_]->{st} eq 'c')
			{
				$pos =  $dst[$_]->{to};
			}
			else
			{
				next;
			}
			$el = DistanceBetween($last, $pos);
			if (!defined($best{id}) or $el < $best{num})
			{
				$best{id} = $_;
				$best{num} = $el;
				$best{pos} = $pos;
			}
		}

		$dist += $best{num};
		$nodst--;
		if ($dst[$best{id}]->{st} eq 'a')
		{
			$dst[$best{id}]->{st} = 'c';
		}
		elsif ($dst[$best{id}]->{st} eq 'c')
		{
			$dst[$best{id}]->{st} = 'd';
		}
		elsif ($dst[$best{id}]->{st} ne 'd')
		{
			die;
		}
		$last = $best{pos};
	}
	return $dist;
}

sub Assign_Random($)
{
	my ($p) = @_;
	$p->{assign} = int(rand(@veh));
}

sub Assign_LeastAssigned($)
{
	my ($p) = @_;
	my %best = (num => undef, id => undef);
	for (0..scalar(@veh) - 1)
	{
		if (!defined($best{id}) or $best{num} > scalar(@{$veh[$_]->{assigned}}))
		{
			$best{id} = $_;
			$best{num} = scalar(@{$veh[$_]->{assigned}});
		}
	}
	$p->{assign} = $best{id};
}

sub Assign($)
{
	my ($p) = @_;
	$funcs{$funcset}->{Assign}($p);
}

sub ShowStats()
{
	my ($wait, $board, $totdist) = (0, 0, 0);
	foreach (@passdone)
	{
		$wait += $_->{time2} - $_->{time1};
		$board += $_->{time3} - $_->{time2};
		$totdist += $_->{dist};
	}
	printf "Num pass %d, Avg time %.2f, (Avg wait %.2f, Avg board %.2f) time/dist ratio %.2f\n", scalar(@passdone), ($wait + $board) / scalar(@passdone), $wait / scalar(@passdone), $board / scalar(@passdone), ($wait + $board) / $totdist;

	my ($totdistveh) = (0);
	foreach (@veh)
	{
		$totdistveh += $_->{totdist};
	}
	printf "Ratio pass/veh %.2f\n", $totdist / $totdistveh;
}

sub Main()
{
	my $turn = 0;
	while (1)
	{
		while (@pass > 0 and $pass[0]->{time1} <= $turn)
		{
			my $p = shift(@pass);
			Assign($p);
			print "$p->{time1}: pass $p->{name} ($p->{from} -> $p->{to}) ASSIGNED TO ".$veh[$p->{assign}]->{name}."\n";
			$veh[$p->{assign}]->{eeos} = EstimatedEndOfService($veh[$p->{assign}]);
			push @{$veh[$p->{assign}]->{assigned}}, $p;
		}
		Advance();
		if (@pass == 0)
		{
			my $stop = 1;
			foreach (@veh)
			{
				if (@{$_->{assigned}} > 0 or @{$_->{carrying}} > 0)
				{
					$stop = 0;
					last;
				}
			}
			last if ($stop);
		}
		$turn++;
	}
	ShowStats();
}

Main();
#print Dumper(@passdone);



