# Mojo::Promise::Merge - merge promise responses

## SYNOPSIS

    use strict;
    use warnings;

    $\ = "\n"; $, = "\t";

    use Mojo::UserAgent;
    use Mojo::JSON qw/encode_json/;
    use Mojo::Promise::Merge;
    use Mojo::Util qw/dumper/;

    my $ua = Mojo::UserAgent->new;

    my $extracts  = 'https://en.wikipedia.org/w/api.php?action=query&format=json&prop=extracts&exintro=&explaintext=&redirects=1&titles=Albert+Einstein%7CNiels+Bohr';
    my $pageprops = 'https://en.wikipedia.org/w/api.php?action=query&format=json&prop=pageprops&titles=Albert+Einstein%7CNiels+Bohr';
    my $revisions = 'https://en.wikipedia.org/w/api.php?action=query&titles=Albert+Einstein%7CNiels+Bohr&prop=revisions&rvslots=main&rvprop=timestamp&format=json';

    Mojo::Promise->all(
                   $ua->get_p($extracts),
                   $ua->get_p($pageprops),
                   $ua->get_p($revisions),
                   )
        ->with_roles('+Merge')
        ->flatten
        ->merge
        ->then(sub {
               my $merged = shift;
               print STDERR dumper $merged;
               Mojo::IOLoop->stop;
           })
        ->catch(sub {
                print STDERR @_;
           });

    Mojo::IOLoop->start;

## DESCRIPTION

Mojo::Promise::Role::Merge adds methods to flatten and merge the json responses of multiple requests using Hash::Merge's merge function.

## FUNCTIONS

### flatten

    my $all = Mojo::Promise->all(@promises)
        ->with_roles('+Merge')
        ->flatten(sub {
            my @results = @_;
        })

Flattens the results into an array (as opposed to the array of arrays normally returned by Mojo::Promise->all).

### merge

    my $all = Mojo::Promise->all(@promises)
        ->with_roles('+Merge')
        ->flatten
        ->merge;

Merges the responses. The function can be passed - as the last parameter - a callback that will be applied to each response, like this:

    my $all = Mojo::Promise->all(@promises)
        ->with_roles('+Merge')
        ->flatten
        ->merge(sub { return shift()->res->json });

Alternatively it can be passed a reference to a string that will be used by JSON::Path to process each of the results - like this:

    my $all = Mojo::Promise->all(@promises)
        ->with_roles('+Merge')
        ->flatten
        ->merge(\'$.query.pages');

Differently from Hash::Merge, Mojo::Promise::Merge can merge more than two hashes.

## Differences from JSON::Path

### Forcing results to arrayref

The presence of a `[*]` selector on the path selector will force the result to an arrayref so that

    my $json = $tx->res->json('$.entities[*]');

is equivalent to

    my $json = $tx->res->json;
    $json = JSON::Path->new($json)->values('$.entities[*]');

This is not true if using a `*` (i.e.: without brackets).

## SEE ALSO

- Hash::Merge
- Mojo::Promise
- JSON::Path

## AUTHORS

Simone Cesano

## COPYRIGHT AND LICENSE

This software is copyright (c) 2021 by Simone Cesano.

This is free software; you can redistribute it and/or modify it under the same terms as the Perl 5 programming language system itself.
