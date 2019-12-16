#!perl6

use v6;
use Test;

use Crypt::Libcrypt;

my $pass = 'abcde12345';

ok my $crypted = crypt($pass, 'HJ'), "crypt for DES";

is crypt($pass, $crypted), $crypted, "and crypting the pw with the crypt-text returns the same";

if crypt-preferred-method() {
    ok my $crypted = crypt($pass), "crypt for preferred method";
    is crypt($pass, $crypted), $crypted, "and crypting the pw with the crypt-text returns the same";
}


done-testing();
# vim: expandtab shiftwidth=4 ft=perl6
