use strict;
use Time::HiRes qw( usleep ualarm gettimeofday tv_interval nanosleep clock_gettime clock_getres clock_nanosleep clock stat );
use Data::Dumper;

my @stops;
my $time = 0;

my @num = ('0'..'9');
my @let = ('A'..'J');
foreach my $i (@num)
{
	foreach my $j (@let)
	{
		push @stops, {name => "$j$i" };
	}
}

my @lines;

foreach my $n (@num)
{
	my @s;
	my $tm = 1;
	foreach (@let)
	{
		push @s, ["$_$n", $tm];
		$tm += 3;
	}
	push @lines, {
		name => "$n+",
		start => 1,
		freq => 10,
		last => 1000,
		sched => \@s,
		exp => [],
	}
}
foreach my $n (@num)
{
	my @s;
	my $tm = 1;
	foreach (reverse(@let))
	{
		push @s, ["$_$n", $tm];
		$tm += 3;
	}
	push @lines, {
		name => "$n-",
		start => 1,
		freq => 10,
		last => 1000,
		sched => \@s,
		exp => [],
	}
}

foreach my $n (@let)
{
	my @s;
	my $tm = 1;
	foreach (@num)
	{
		push @s, ["$n$_", $tm];
		$tm += 3;
	}
	push @lines, {
		name => "$n+",
		start => 1,
		freq => 10,
		last => 1000,
		sched => \@s,
		exp => [],
	}
}
foreach my $n (@let)
{
	my @s;
	my $tm = 1;
	foreach (reverse(@num))
	{
		push @s, ["$n$_", $tm];
		$tm += 3;
	}
	push @lines, {
		name => "$n-",
		start => 1,
		freq => 10,
		last => 1000,
		sched => \@s,
		exp => [],
	}
}




# Memorize all direct routes for each ($station / $time) pair
my %droutes;

sub _GetAllDirectRoutesFromStation($$)
{
	my ($station, $time) = @_;
	my @r;
	foreach my $l (@lines)
	{
		foreach my $e (@{$l->{exp}})
		{
			my $boarded = -1;
			for (my $s = 0; $s < @$e; $s++)
			{
				if ($boarded != -1 and $e->[$s][0] eq $station)
				{
					last;
				}
				elsif ($boarded != -1)
				{
					push @r, { line => $l->{name}, bs => $station, bt => $boarded, gs => $e->[$s][0], gt => $e->[$s][1] };
				}
				elsif ($e->[$s][0] eq $station and $e->[$s][1] >= $time and $s != @$e - 1)
				{
					$boarded = $e->[$s][1];
				}
			}
			last if ($boarded != -1);
			
		}
	}
	return \@r;
}

sub GetAllDirectRoutesFromStation($$)
{
	my ($station, $time) = @_;
	if (exists($droutes{$station."_".$time}))
	{
		return $droutes{$station."_".$time};
	}
	else
	{
		my $ret = _GetAllDirectRoutesFromStation($station, $time);	
		$droutes{$station."_".$time} = $ret;
		return $ret;
	}
}


sub GetAllIndirectRoutesFromStation($$)
{
	my ($station, $time) = @_;
	my %r = ( $station => { line => undef, bs => $station, bt => $time, gs => $station, gt => $time} );
	my @togo = ( { line => undef, bs => undef, bt => undef, gs => $station, gt => $time} );
	while (@togo)
	{
		my $s = shift(@togo);
		my $ret = GetAllDirectRoutesFromStation($s->{gs}, $s->{gt});	
		foreach my $segment (@$ret)
		{
			if (!exists($r{$segment->{gs}}) or
				($r{$segment->{gs}}->{gt} > $segment->{gt}))# and ($segment->{line} != $r{$segment->{gs}}->{line}))
			{
				push @togo, $segment;
				$r{$segment->{gs}} = $segment;
			}
		}
	}
	return \%r;
}

foreach my $l (@lines)
{
	my $t = $l->{start};
	while ($t + $l->{freq} < $l->{last})
	{
		my @new;
		foreach my $s (@{$l->{sched}})
		{
			push @new, [$s->[0], $s->[1] + $t];
		}
		push @{$l->{exp}}, \@new;
		$t += $l->{freq};
	}
}

#my ($seconds, $microseconds) = gettimeofday;
#GetAllIndirectRoutesFromStation("A0", 0);
#my ($seconds2, $microseconds2) = gettimeofday;
#my $totus = ($seconds2 - $seconds) * 1000000 + $microseconds2 - $microseconds;

#print "$totus µs\n";
#exit 0;


sub ListAllPaths ()
{
	while ($time < 1000)
	{
		print "Time: $time\n";
		#Display
		foreach my $i (@num)
		{
			foreach my $j (@let)
			{
				print "Stop $j$i:\n";
				my $ret = GetAllIndirectRoutesFromStation("$j$i", $time);
				foreach (sort {$a cmp $b } keys(%$ret))
				{
					next if ($_ eq "$j$i");
					my $string = "";
					my $end = $_;
					while ($end ne "$j$i")
					{
						$string = " L$ret->{$end}{line} ($ret->{$end}{bs} @ $ret->{$end}{bt} -> $ret->{$end}{gs} @ $ret->{$end}{gt})".$string;
						$end = $ret->{$end}{bs};
					}
					print "$_: $string\n";
				}
			
			}
		}

		foreach my $l (@lines)
		{
			print "L $l->{name}:";
			foreach my $e (@{$l->{exp}})
			{
				next if ($e->[0][1] > $time or $e->[@$e - 1][1] < $time);
				for (my $s = 0; $s < @$e; $s++)
				{
					if ($e->[$s][1] == $time)
					{
						print " ".$e->[$s][0];
						last;
					}
					elsif ($e->[$s][1] > $time)
					{
						print " ".$e->[$s - 1][0]."->".$e->[$s][0];
						last;
					}
				}
			}
			print "\n";
		}

		<STDIN>;
		$time++;
	}
}

#ListAllPaths();

sub TransitTime($$$)
{
	my ($from, $to, $time) = @_;
	my $r = GetAllIndirectRoutesFromStation($from, $time);
	die if (!exists($r->{$to}));;
	my $arr = $r->{$to}{gt};
	return $arr;
}

sub SimPass()
{
	my ($numpass, $total) = (0, 0);
	for my $time (0..30)
	{
		print "Time $time:\n";
		my $maxp = 50;
		my $p = int(rand($maxp));
		for (0..$p)
		{
			my ($from, $to, $tt);
			$from = $let[int(rand(@let))].$num[int(rand(@num))];
			$to = $let[int(rand(@let))].$num[int(rand(@num))];
			$tt = TransitTime($from, $to, $time) - $time;
			print "$from -> $to : $tt\n";
			$numpass++;
			$total += $tt;
		}
	}
	print "$numpass pass $total total\n";
	printf "average = %f\n",($total / $numpass);
}

SimPass();

