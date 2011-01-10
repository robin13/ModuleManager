package AppManager::DB;
use strict;
use warnings;
use Digest::SHA1 qw/sha1_hex/;
use FindBin::Real qw/RealBin/;
use DBI;
use File::Spec::Functions;
use constant MANIFEST_FILENAME => 'manifest.db';


sub new{
    my $class = shift;
    my $self = {};

    $self->{sql_script} = catfile( RealBin(), 'create_db.sql' );

    bless $self, $class;
    return $self;
}


sub handle{
    my( $self, $args ) = @_;

    if( ! $args->{name} ){
        die( "Cannot get a handle without a name" );
    }

    if( ! $self->{handles}->{ $args->{name} } ){
        if( ! $args->{path} ){
            die( "Path for handle $args->{name} not defined" );
        }
        if( ! -d $args->{path} ){
            die( "Path for handle $args->{name} does not exist: $args->{path}" );
        }

        my $db_path = catfile( $args->{path}, MANIFEST_FILENAME );
        if( ! -f $db_path ){
            if( $args->{init} ){
                $self->{handles}->{$args->{name}} = $self->init_db( $db_path );
            }else{
                die( "No init set, and database file does not exist at $db_path\n" );
            }
        }else{
            $self->{handles}->{$args->{name}} = DBI->connect("dbi:SQLite:dbname=$db_path","","");
        }
    }
    return $self->{handles}->{$args->{name}};
}

sub init_db{
    my( $self, $path ) = @_;

    if( ! -f $self->{sql_script} ){
        die( "Create script $self->{sql_script} does not exist...\n" );
    }

    my $dbh = DBI->connect("dbi:SQLite:dbname=" . $path,"","");
    if( ! $dbh ){
        die( "Could not connect to DB during init_db: $!" );
    }

    if( ! open( FH, '<' . $self->{sql_script} ) ){
        die( "Could not open create db script ($self->{sql_script}): $!" );
    }
    my $line;
    my $sql;
  LINE:
    while( $line = readline( FH ) ){
        if( $line =~ m/^\s*$/ || $line =~ m/^\-\-/ || $line =~ m/^\#/ ){
            next LINE;
        }
        chomp( $line );
        $sql .= $line;
    }
    close FH;

    my @commands = split( /;/, $sql );
    foreach( @commands ){
        $dbh->do( $_ );
    }
    return $dbh;
}

1;
