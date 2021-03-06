
use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name => 'Lair',
    license => 'perl',
    dist_abstract => 'a small web framework',
    dist_author => 'Sebastian Knapp <SKNPP@cpan.org>',
    dist_version => '0.01002',
    requires => {
        'perl' => '5.010001',
        'Badger' => '0.08',
        'Class::Trigger' => '0.14',
        'Hash::MultiValue' => '0.10',
        'MIME::Types' => '1.34',
        'Package::Subroutine' => '>0.21.000',
        'Plack' => 0,
        'HTTP::Status' => 0
    },
    build_requires => {
        'Test::More' => 0
    },
    add_to_cleanup      => [ 'Lair-*' ],
    create_makefile_pl  => 'traditional',
    meta_add => {
        resources => {
            repository => 'git://github.com/giftnuss/p5-lair',
        }
    }
);

$builder->create_build_script();
