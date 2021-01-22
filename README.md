# Crypt::Libcrypt

Provide a simple Raku binding to POSIX crypt(3) function

## Synopsis

        use Crypt::Libcrypt;

        my $crypted = crypt($password, $salt );

        # Or if crypt_gensalt is available

        $crypted = crypt($password);

## Description


This is a binding to the crypt() function that is typically defined in libcrypt on most Unix-like systems or those providing a POSIX API.

There is at least a single exported subroutine crypt() that perform a one-way encryption of the supplied plain text, with the provided "salt". Depending on the implementation on your system, the structure of the salt may influence the algorithm that is used to perform the encryption. The default will probably be the DES algorithm that was traditionally used to encrypt passwords on a Unix system, this is, however, not recommended for new code: see the section "Encryption mechanisms" below.

If the function `crypt_gensalt` is provided by the `libcrypt` then you can call `crypt` with a single argument which will used the preferred encryption method with a generated random salt.

Because this is intended primarily for the encryption of passwords and is "one way" (i.e. there is no mechanism to "decrypt" the crypt text,) it is not suitable for general purpose encryption.

In order to check whether a password entered by a user is correct it should be encrypted using the stored encrypted password as the "salt" - the result will be the same as the stored crypt text if the password is the same.

Encryption mechanisms
---------------------

Depending on the particular implementation of `crypt` on your system, there may be more than one encryption available which is determined by the structure of the provided `salt`. The default mechanism when the salt is two or more alphanumeric characters is the DES algorithm which was the original provided on Unix systems, it is however fairly weak and subject to brute force attack so should be avoided where possible.

If alternative algorithms are available they are indicated by providing a salt of the form:

        $id$salt$encrypted

where `id` identifies the encryption method to be used. The actual "salt" will be terminated with a `$` as it may be of variable length rather than the DES salt length of 2. The text after the third `$` will be ignored to allow an encrypted value to be passed as the salt in further calls to `crypt()`

The following values of `id` may or may not be implemented on any given system (or at all,) and the behaviour when using an un-implemented form is not specified.

  * 1

The MD5 algorithm is implemented on the majority of systems as it was provided for use in places where export regulations originally prevented the use of DES.

  * 2

Blowfish is not implemented for `glibc` but is available on FreeBSD

  * 3

NT-Hash is available on FreeBSD and is intended to be compatible with Microsoft's NT scheme. It actually ignores the salt text.

  * 5

SHA-256

  * 6

SHA-512

You can probably get a description of all available methods on your system from the `crypt(5)` manpage (or e,g [https://manpages.debian.org/experimental/libcrypt1-dev/crypt.5.en.html](https://manpages.debian.org/experimental/libcrypt1-dev/crypt.5.en.html) .)

If you have a reasonably modern `libcrypt` then the subroutine `crypt-preferred-method` will return the prefix '$id$' as described above of the best and recommended encryption method. (if the library isn't sufficiently new the function will return a Str type object.) Bear in mind however if you need to pass the hashed password to other software, there may be other constraints on the methods you can use.

## Installation

Currently there is no dedicated test to determine whether your platform is supported, the unit tests may simply fail horribly.

Assuming you have a working Rakudo installation you should be able to install this with *zef* :

    # From the source directory
   
    zef install .

    # Remote installation

    zef install Crypt::Libcrypt

*Notes for OSX* this can be used with libgcrypt on OSX (if you use brew, you can `brew install libgcrypt`)

## Support

Suggestions/patches are welcomed via github at:

https://github.com/jonathanstowe/Crypt-Libcrypt/issues

I'm not able to test on a wide variety of platforms so any help there would be 
appreciated. Also help with the documentation of which platforms support
which encryption algorithms is probably required.

## Licence

This is free software.

Please see the [LICENCE](LICENCE) file in the distribution

© Jonathan Stowe 2015 - 2021
