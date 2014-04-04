use strict;
use Data::Dumper;

my $haystack = "La France est plus grande que la Suisse.";
#my $haystack = "AAAAA";
my @start = split(//, $haystack);

my @dict = ("La", "France", "est", "plus", "grande", "que", "la", "Russie", ".", " ", "La France");

my @dict2;

foreach (@dict)
{
	my @tab = split(//, $_);
	push @dict2, [\@tab, "[$_]", 0];
}

push @dict2, [["[La]", "[ ]", "[France]"], "<GN:France>", 0];

my $it = 1;
my (@thisit, @nextit, @done);
push @nextit, \@start;
while (@nextit)
{
	print "Itération ".$it++."\n";
	@thisit = @nextit;
	@nextit = ();
	foreach my $inter (@thisit)
	{
		my @results = ( { table => [], pos => 0, score => 0, score2 => 0} );
		my $cursor = 0;
		while (@$inter > $cursor)
		{
		    my @newres;

		    foreach my $r (@results)
		    {
			my $found = 0;
			if ($r->{pos} > $cursor)
			{
			    push @newres, $r;
			    next;
			}
			foreach my $line (@dict2)
			{
			    my $word = $line->[0];
			    next if ($cursor + @$word > @$inter);
			    if (@$word ~~ @$inter[$cursor..$cursor + @$word - 1])
			    {
				my @table;
				push @table, @{$r->{table}};
				if ($r->{pos} < $cursor)
				{
				    #push @table, "{".join("", @$inter[$r->{pos}..$cursor-1])."}";
				    push @table, @$inter[$r->{pos}..$cursor-1];
				}
				push @table, $line->[1];
				push @newres,  { table => \@table, pos => $cursor + @$word, score => $r->{score} + @$word, score2 => $r->{score2} + 1};
				$found++;
			    }
			}
			if (!$found)
			{
			    push @newres, $r;
			}
		    }

		    $cursor++;
		    @results = @newres;
		}
		foreach my $r (@results)
		{
		    if ($r->{pos} < $cursor)
		    {
			#push @{$r->{table}}, "{".join("", @$inter[$r->{pos}..$cursor-1])."}";
			push @{$r->{table}}, @$inter[$r->{pos}..$cursor-1];
			$r->{pos} = $cursor;
		    }
		}

		@results = sort { $b->{score} <=> $a->{score} } @results;

		foreach my $r (@results)
		{
			print "@$inter => @{$r->{table}} ($r->{score}/$cursor, $r->{score2} words)\n";
			if ($r->{score2} > 0)
			{
				push @nextit, $r->{table};
			}
			else
			{
				push @done, $r->{table};
			}
		}
	}
}



