# Mojo::Promise::Role::Merge

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
        ->then(sub {
               print dumper Mojo::Promise::Merge::merge(@_);
               Mojo::IOLoop->stop;
           })
        ->catch(sub {
                print STDERR @_;
           });

    Mojo::IOLoop->start;

## DESCRIPTION

Mojo::Promise::Merge merges the json responses of multiple requests via Hash::Merge's merge function.

## FUNCTIONS

### merge

    Mojo::Promise::Merge::merge(@_);

Merges the responses. The function can be passed - as the last parameter - a callback that will be applied to each response, like this:

    Mojo::Promise::Merge::merge(@_, sub { return shift()->res->json });

Alternatively it can be passed a reference to a string that will be used by JSON::Path to process each of the results - like this:

    Mojo::Promise::Merge::merge(@_, \'$.query.pages');

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
