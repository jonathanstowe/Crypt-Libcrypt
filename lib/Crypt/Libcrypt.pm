use v6;

module Crypt::Libcrypt:ver<0.0.9>:auth<github:jonathanstowe>:api<1.0> {

=begin pod

=begin NAME

Crypt::Libcrypt - simple binding to POSIX crypt(3)

=end NAME

=begin SYNOPSIS

=begin code

    use Crypt::Libcrypt;

    my $crypted = crypt($password, $salt );

    # Or if crypt_gensalt is available

    $crypted = crypt($password);

=end code

=end SYNOPSIS

=begin DESCRIPTION

This is a binding to the crypt() function that is typically defined in
libcrypt on most Unix-like systems or those providing a POSIX API.

There is at least a single exported subroutine crypt() that perform a one-way
encryption of the supplied plain text, with the provided "salt".
Depending on the implementation on your system, the structure of the
salt may influence the algorithm that is used to perform the encryption.
The default will probably be the DES algorithm that was traditionally
used to encrypt passwords on a Unix system, this is, however, not recommended
for new code:  see the section "Encryption mechanisms" below.

If the function C<crypt_gensalt> is provided by the C<libcrypt> then you
can call C<crypt> with a single argument which will used the preferred
encryption method with a generated random salt.

Because this is intended primarily for the encryption of passwords and
is "one way" (i.e. there is no mechanism to "decrypt" the crypt text,)
it is not suitable for general purpose encryption.

In order to check whether a password entered by a user is correct it
should be encrypted using the stored encrypted password as the "salt"
- the result will be the same as the stored crypt text if the password
is the same.

=head2 Encryption mechanisms

Depending on the particular implementation of C<crypt> on your system, there
may be more than one encryption available which is determined by the structure
of the provided C<salt>.  The default mechanism when the salt is two or
more alphanumeric characters is the DES algorithm which was the original
provided on Unix systems, it is however fairly weak and subject to brute
force attack so should be avoided where possible.

If alternative algorithms are available they are indicated by providing a
salt of the form:

=begin code

    $id$salt$encrypted

=end code

where C<id> identifies the encryption method to be used.  The actual
"salt" will be terminated with a C<$> as it may be of variable length
rather than the DES salt length of 2. The text after the third C<$>
will be ignored to allow an encrypted value to be passed as the salt in
further calls to C<crypt()>

The following values of C<id> may or may not be implemented on any given
system (or at all,) and the behaviour when using an un-implemented form is
not specified.

=item 1

The MD5 algorithm is implemented on the majority of systems as it was provided
for use in places where export regulations originally prevented the use of
DES.

=item 2

Blowfish is not implemented for C<glibc> but is available on FreeBSD

=item 3

NT-Hash is available on FreeBSD and is intended to be compatible with
Microsoft's NT scheme.  It actually ignores the salt text.

=item 5

SHA-256

=item 6

SHA-512

You can probably get a description of all available methods on
your system from the C<crypt(5)> manpage (or e,g 
L<https://manpages.debian.org/experimental/libcrypt1-dev/crypt.5.en.html> .)

If you have a reasonably modern C<libcrypt> then the subroutine
C<crypt-preferred-method> will return the prefix '$id$' as 
described above of the best and recommended encryption method.
(if the library isn't sufficiently new the function will return
a Str type object.) Bear in mind however if you need to pass the
hashed password to other software, there may be other constraints
on the methods you can use.


=end DESCRIPTION

=end pod

    use NativeCall;
    # Mac OSX uses libgcrypt to supply crypt()
    # FreeBSD always provides a non-versioned symlink AFAIK
    constant LIB = [
        $*DISTRO.name eq 'macosx' ?? 'libgcrypt.dylib' !! 'crypt',
        $*DISTRO.name eq 'freebsd' ?? Version !! v1
    ];


    sub crypt_preferred_method( --> Str) is native(LIB) { * }

    sub crypt-preferred-method(--> Str ) is export {
        (try crypt_preferred_method()) // Str
    }

    sub crypt_gensalt(Str, uint32, Str, int32 --> Str) is native(LIB) { * }

    sub crypt-generate-salt( --> Str ) is export {
        (try crypt_gensalt(Str, 0, Str, 0 ) ) // Str
    }

    sub _crypt(Str , Str  --> Str) is native(LIB) is symbol('crypt') { * }

    multi crypt(Str $password, Str $salt --> Str ) {
        _crypt($password, $salt)
    }

    multi crypt(Str $password where { crypt-preferred-method() } --> Str ) is export {
        _crypt($password, crypt-generate-salt() );
    }
}
# vim: expandtab shiftwidth=4 ft=perl6
