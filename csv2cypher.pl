use strict;
my %h;

while (<STDIN>)
{
	chomp;
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

