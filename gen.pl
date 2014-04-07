use strict;
foreach ('a'..'z')
{
	print "lettre_$_,is,lettre\n";
	print "glyphe.$_,is,glyphe\n";
	print "glyphe.$_:val:$_\n";
	print "glyphe.$_,represente,lettre_$_\n";
}

foreach ('A'..'Z')
{
	print "glyphe.$_,is,glyphe\n";
	print "glyphe.$_:val:$_\n";
	print "glyphe.$_,represente,lettre_".lc($_)."\n";
}

my @dict = (
	{mot => "la", objet => "mot.la", },
	{mot => "france", objet => "mot.france", },
	{mot => "est", objet => "mot.est", },
	{mot => "plus", objet => "mot.plus", },
	{mot => "grande", objet => "mot.grande", },
	{mot => "que", objet => "mot.que", },
	{mot => "suisse", objet => "mot.suisse", },
);


foreach my $word(@dict)
{
	print "$word->{objet},is,mot\n";
	print "comb.represente.".$word->{objet}.",represente,".$word->{objet}."\n";
	print "comb.represente.".$word->{objet}.",is,combo\n";
	print "comb.represente.".$word->{objet}.":type:ordonne\n";
	print "comb.represente.".$word->{objet}.":nombre:".length($word->{mot})."\n";
	my $n = 0;
	foreach (split(//, $word->{mot}))
	{
		print "comb.represente.".$word->{objet}.",a_element$n,lettre_$_\n";
		$n++;
	}
}

