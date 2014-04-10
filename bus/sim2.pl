use strict;
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
my $numpass = 0;
for my $time (0..30)
{
	my $maxp = 50;
	my $p = int(rand($maxp));
	for (0..$p)
	{
		my ($from, $to);
		$from = $let[int(rand(@let))].$num[int(rand(@num))];
		do {
			$to = $let[int(rand(@let))].$num[int(rand(@num))];
		} while ($from eq $to);
		$numpass++;
		push @pass, { name => "P$numpass", from => $from, to => $to, time1 => $time, time2 => undef, time3 => undef, assign => undef };
	}
}

my @veh = (
	{ name => 'V1', cap => 9, status => [ { pos => 'A0', usage => [], assigned => [] } ],
	{ name => 'V2', cap => 9, status => [ { pos => 'A0', usage => [], assigned => [] } ],
);

my $time = 0;


sub AdvanceTo($)
{
	my ($newtime) = @_;

	$time = $newtime;
}


sub RandomAssign()
{
	foreach (@pass)
	{
		if ($_->{time1} > $time)
		{
			AdvanceTo($_->{time1});
		}
		$_->{assign} = int(rand(@veh));	
	}
}

RandomAssign();

print Dumper(@pass);

