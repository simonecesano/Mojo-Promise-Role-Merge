package Mojo::Promise::Role::Merge;

use Mojo::Base -role;
use Mojo::Util qw/dumper/;

use Hash::Merge;
use JSON::Path;
use List::Util qw/reduce/;

sub flatten {
    my $self = shift;
    $self->then(sub {
		    Mojo::Promise->resolve(map { $_->[0] } @_)
		  })
}

sub merge {
    my $self = shift;
    my $cb = _make_cb( shift() );

    $self->then(sub {
		    my $r = reduce { Hash::Merge::merge($a, $b) } map { $cb->($_) } @_;
		    Mojo::Promise->resolve($r)
		  })
}

sub _make_cb {
    my $cb;

    if (ref $_[-1] eq 'CODE') {
	$cb = pop;
    } elsif (ref $_[-1] eq 'SCALAR') {
	my $query = ${pop()};
	my $jpath = JSON::Path->new($query);

	if ($query =~ /\[\*\]/) {
	    $cb = sub { [ $jpath->values(shift()->res->json) ] };
	} else {
	    $cb = sub { $jpath->value(shift()->res->json) };
	}
    } else {
	$cb = sub { return shift()->res->json }
    }
    return $cb;
};


1;
