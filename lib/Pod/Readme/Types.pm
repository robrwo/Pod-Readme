package Pod::Readme::Types;

use v5.10.1;

use strict;
use warnings;

use Exporter qw/ import /;
use IO qw/ Handle /;
use Path::Class;
use Scalar::Util qw/ blessed /;
use Type::Tiny;
use Types::Standard qw/ GlobRef FileHandle Str /;

use version 0.77; our $VERSION = version->declare('v1.0.1_01');

our @EXPORT_OK =
  qw/ Dir File Indentation IO ReadIO WriteIO HeadingLevel TargetName /;

=head1 NAME

Pod::Readme::Types - types used by Pod::Readme

=head1 SYNOPSIS

  use Pod::Readme::Types qw/ Indentation /;

  has verbatim_indent => (
    is      => 'ro',
    isa     => Indentation,
    default => 2,
  );

=head1 DESCRIPTION

This module provides types for use with the modules in L<Pod::Readme>.

It is intended for internal use, although some of these may be useful
for writing plugins (see L<Pod::Readme::Plugin>).

=head1 EXPORTS

None by default. All functions must be explicitly exported.

=head2 C<Indentation>

The indentation level used for verbatim text. Must be an integer
greater than or equal to 2.

=cut

sub Indentation {
    state $type = Type::Tiny->new(
        name       => 'Indentation',
        constraint => sub { $_ =~ /^\d+$/ && $_ >= 2 },
        message => sub { 'must be an integer >= 2' },
    );
    return $type;
}

=head2 C<HeadingLevel>

A heading level, used for plugin headings.

Must be either 1, 2 or 3. (Note that C<=head4> is not allowed, since
some plugins use subheadings.)

=cut

sub HeadingLevel {
    state $type = Type::Tiny->new(
        name       => 'HeadingLevel',
        constraint => sub { $_ =~ /^[123]$/ },
        message    => sub { 'must be an integer between 1 and 3' },
    );
    return $type;
}

=head2 C<TargetName>

A name of a target, e.g. "readme".

=cut

sub TargetName {
    state $type = Type::Tiny->new(
        name       => 'TargetName',
        constraint => sub { $_ =~ /^\w+$/ },
        message    => sub { 'must be an alphanumeric string' },
    );
    return $type;
}

=head2 C<Dir>

A directory. Can be a string or L<Path::Class::Dir> object.

=cut

sub Dir {
    state $type = Type::Tiny->new(
        name       => 'Dir',
        constraint => sub {
            blessed($_)
              && $_->isa('Path::Class::Dir')
              && -d $_;
        },
        message => sub { 'must be be a directory' },
    );
    return $type->plus_coercions( Str, sub { dir($_) }, );
}

=head2 C<File>

A file. Can be a string or L<Path::Class::File> object.

=cut

sub File {
    state $type = Type::Tiny->new(
        name       => 'File',
        constraint => sub {
            blessed($_)
              && $_->isa('Path::Class::File');
        },
        message => sub { 'must be be a file' },
    );
    return $type->plus_coercions( Str, sub { file($_) }, );
}

sub IO {
    state $type = Type::Tiny->new(
        name       => 'IO',
        constraint => sub {
            blessed($_)
              && ( $_->isa('IO::Handle') || $_->isa('IO::String') );
        },
        message => sub { 'must be be an IO::Handle or IO::String' },
    );
    return $type;
}

sub ReadIO {
    state $type = IO->plus_coercions(    #
        FileHandle, sub { IO::Handle->new_from_fd( $_, 'r' ) },
        GlobRef,    sub { IO::Handle->new_from_fd( $_, 'w' ) },
    );
    return $type;
}

sub WriteIO {
    state $type = IO->plus_coercions(    #
        FileHandle, sub { IO::Handle->new_from_fd( $_, 'w' ) },
        GlobRef,    sub { IO::Handle->new_from_fd( $_, 'w' ) },
    );
    return $type;
}

1;
