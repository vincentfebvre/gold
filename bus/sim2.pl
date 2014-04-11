use strict;
use Storable 'dclone';
use Data::Dumper;

# Params
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
for my $t (0..30)
{
	my $maxp = 3;
	my $p = int(rand($maxp));
	for (0..$p)
	{
		my ($from, $to);
		$from = $let[int(rand(@let))].$num[int(rand(@num))];
		do {
			$to = $let[int(rand(@let))].$num[int(rand(@num))];
		} while ($from eq $to);
		$numpass++;
		push @pass, { name => "P$numpass", from => $from, to => $to, time1 => $t, time2 => undef, time3 => undef, assign => undef };
	}
}

my @veh = (
{ name => 'V1', cap => 9, pos => 'A0', carrying => [], assigned => [], nextmove => undef, togo => -1 },
{ name => 'V2', cap => 9, pos => 'A0', carrying => [], assigned => [], nextmove => undef, togo => -1 },
);

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

sub Advance()
{
    foreach my $v (@veh)
    {
        # Where we on the move
        if ($v->{togo} > 0)
        {
            $v->{togo}--;

            # Have we reached destination
            if ($v->{togo} == 0)
            {
                $v->{pos} = $v->{nextmove};
                $v->{nextmove} = undef;
                $v->{togo} = -1;

                # Passengers get off
                my @newc;
                foreach (@{$v->{carrying}})
                {
                    if ($_->{to} eq $v->{pos})
                    {
                        $_->{time3} = $time + 1;
                        print "$_->{time3}: passenger $_->{name} ($_->{from} -> $_->{to}) GETS OFF $_->{assign}\n";
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
                        print "$_->{time2}: passenger $_->{name} ($_->{from} -> $_->{to}) GETS ON $_->{assign}\n";
                        push @{$v->{carrying}}, $_;
                    }
                    else
                    {
                        push @newa, $_;
                    }
                }
                @{$v->{assigned}} = @newa;
            }
        }

        # Where to go next ?
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
	$time++;
}


sub RandomAssign()
{
	while (@pass)
	{
        my $p = shift(@pass);
		while ($p->{time1} > $time)
		{
			Advance();
		}
		$p->{assign} = int(rand(@veh));
        print "$p->{time1}: passenger $p->{name} ($p->{from} -> $p->{to}) ASSIGNED TO $p->{assign}\n";
        push @{$veh[$p->{assign}]->{assigned}}, $p;
	}
}

RandomAssign();
#print Dumper(@passdone);

