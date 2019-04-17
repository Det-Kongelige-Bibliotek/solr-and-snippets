#!/usr/bin/perl -w

use strict;

#
# This is so specific Grundtvigs Værker that it won't be useful for anything else
#
# In case you'd like to configure where you keep the GV
#

my $where_is_grundtvig = "../GV/";
my $where_should_it_go = "./build/text-retriever/";

if( open(my $gv, "(cd $where_is_grundtvig ;  find . -regextype sed -regex '^.*18[0-9][0-9]GV.*\$' -type f -print)|") ) {
    while(my $file = <$gv>) {
	chomp $file;
	my $uri = "";
	if($file =~ m/(18\d\d)_(\d+[a-zA-Z]?)_?(\d+)?_(com|intro|txr|txt|v0).xml$/) {
	    if($3) {
		$uri = join '/',("gv",join("_",$1,$2,$3),$4);
	    } else {
		$uri = join '/',("gv",join("_",$1,$2),$4);
	    }
	    my $path = $uri;
	    $path =~ s/[^\/]+$//;
	    $file =~ s/^\.\///;

	    my $copy = "cp  $where_is_grundtvig$file $where_should_it_go$uri.xml";
	    my $transform = "xsltproc   utilities/add-id.xsl $where_is_grundtvig$file > $where_should_it_go$uri.xml";

#	    print "mkdir -p  $where_should_it_go$path ; $copy\n";
	    print "mkdir -p  $where_should_it_go$path ; $transform\n";
	}
    }
}