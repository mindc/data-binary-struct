use 5.008005;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME           => 'Data::Binary::Struct',
    VERSION_FROM   => 'lib/Data/Binary/Struct.pm',
    PREREQ_PM      => { 
		'Test::More' => 0, 
		'Exporter'  => '5.57',
	},
);
