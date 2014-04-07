use strict;
my %h;

print "MATCH (n) OPTIONAL MATCH (n)-[r]-() DELETE n,r;\n";

while (<STDIN>)
{
	chomp;
	if (/.*,.*,.*/)
	{
		my @els = split(/,/, $_);
		if (!exists($h{$els[0]}))
		{
			$h{$els[0]} = 1;
			print "CREATE (a {name: '${els[0]}' }) RETURN a;\n";
		}
		if (!exists($h{$els[2]}))
		{
			$h{$els[2]} = 1;
			print "CREATE (a {name: '${els[2]}' }) RETURN a;\n";
		}
		print "MATCH (a { name: '${els[0]}' }), (c { name: '${els[2]}' }) CREATE UNIQUE (a)-[:${els[1]}]-(c) RETURN a,c;\n";
	}
	elsif (/.*:.*:.*/)
	{
		my @els = split(/:/, $_);
		if (!exists($h{$els[0]}))
		{
			print "CREATE (a {name: '${els[0]}', ${els[1]}: '${els[2]}' }) RETURN a;\n";
		}
		else
		{
			print "MATCH (a { name: '${els[0]}' }) SET a.${els[1]} = '${els[2]}' RETURN a;\n";
		}
	}
	else
	{
		die;
	}
}

