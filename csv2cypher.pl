use strict;

while (<STDIN>)
{
	chomp;
	my @els = split(/,/, $_);
	print "MATCH (a { name: '${els[0]}' }), (c { name: '${els[2]}' }) CREATE UNIQUE (a)-[:${els[1]}]-(c) RETURN c;\n";
}

