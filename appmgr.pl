#!/usr/bin/perl
use strict;
use warnings;
use Digest::SHA1 qw(sha1_hex);
use Getopt::Long;
use File::Spec::Functions;
use AppManager::DB;

my $opts;
GetOptions( 'source=s'  => \$opts->{source},
            'target=s'  => \$opts->{target},
            'init'      => \$opts->{init}, );

foreach( qw/source target/ ){
    if( ! $opts->{$_} ){
        die( "Required option $_ not defined\n" );
    }
}

my $db_mgr = AppManager::DB->new();

# Check the database files exist
my %dbh;
foreach my $name( qw/source target/ ){
    $dbh{$name} = $db_mgr->handle( { name => $name,
                                     init => $opts->{init},
                                     path => $opts->{$name},
                                 } );
}

my $digest = sha1_hex( "test" );

printf "Length: %s\n", length( $digest );

exit;
