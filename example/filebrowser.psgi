#!/usr/bin/perl

use lib './lib';
use Lair::Ground;
use Data::Dumper;
use Badger::Filesystem;

BEGIN { 
	eval "use Template;" ;
        die "Example " . __FILE__ . " requires Template Toolkit." if $@;
    eval "use Path::Tiny;" ;
        die "Example " . __FILE__ . " requires Path::Tiny." if $@;
    eval "use MIME::Detect;" ;
        die "Example " . __FILE__ . " requires MIME::Detect." if $@;
};

package FileBrowser;
use Badger::Class
    base => 'Lair::Resource::Filesystem',
    accessors => [ 'template' ];

sub _default_template {
	Template->new
}

sub _default_get {
    sub{ 	
    	my ($self,$response) = @_;
    	my $text = '';
    	my $env = $self->context->env;
    	
    	my $base = Path::Tiny->cwd->realpath;
    	my $look = Path::Tiny::path($base, $env->{PATH_INFO});
    	
    	# Using Path::Tiny
    	#$dir = Badger::Filesystem->collapse_directory($dir);
    	#my $path = Badger::Filesystem->join_directory($base,$dir);
    	
    	# Workaround a bug? in Badger::Filesystem :(
    	#my @exists = Badger::Files	ystem->path_exists($path);
    	#pop @exists;
    	#unless(grep { !!$_ }@exists) {
			
		# even worst - this is made a deep recursion :(
		#$path = Badger::Filesystem->path($path);
		#if($path->exists()) {
		#	$text .= 'OK';
		#}
		#	$path = $base;	
		#}
		
		my $result = {'updir' => 1};
		if($look->exists) {
			$look = $look->realpath;
			unless($base->subsumes($look) or "$base" eq "$look") {
			    $look = $base;
			}
		}
		else {
			$look = $base;
		}
		
        if($look->is_file) {
			my $detect = MIME::Detect->new;
			my $type = $detect->mime_type("".$look);
			$response->header('Content-Type',$type->mime_type);
			return $look->slurp;
		}
		elsif ($look->is_dir) {
			$self->get_dir($look,$base,$result);
			return $self->display_dir($result);
		}
    }
}

sub get_dir {
	my ($self,$look,$base,$data) = @_;
	$data->{'current'} = $look->relative($base);
    $data->{'updir'} = 0 if "".$data->{'current'} eq '.';
    
    my $idx = 0;
    my $rows = $look->visit(sub {
        my ($path, $data) = @_;
        $path = Path::Tiny::path($path)->relative($base);
        $data->{$path} = [$idx++,$path];
    });
    my @rows = sort { $a->[0] <=> $b->[0] } values %$rows;
    $data->{'rows'} = \@rows;
}

sub display_dir {
	my ($self,$data) = @_;
	my $template = <<__TEMPLATE__;
[% USE dumper %]	
[% BLOCK display_row -%]
    <div><a href="/[% row.1 %]">[% row.1 %]</a></div>
[% END -%]
	
<h2>Verzeichnis	<code>[% current %]</code></h2>
<div>
  [% IF updir %][% PROCESS display_row row=[-1, '..'] %][% END %]
  [% FOREACH r = rows -%] [% r.0 %]
      [% PROCESS display_row row=r %]
  [% END -%]
</div>

END[% updir %]
__TEMPLATE__
    
    $self->template->process(\$template,$data,\my $out) || do {
        my $error = $self->template->error();
        print "error type: ", $error->type(), "\n";
        print "error info: ", $error->info(), "\n";
        print $error, "\n";
    };
    return $out;
}

package main;
use Lair;
use Lair::Controller;
use Lair::Controller::Favicon;

use Plack::Builder;

my $app = Lair->new('name' => 'a simple filesystem browser');
my $controller = Lair::Controller->new();
my $page = FileBrowser->new();

$app->add_controller(
    Lair::Controller::Favicon->new,
    $controller->add_resource($page)
);

builder { $app->handler };

