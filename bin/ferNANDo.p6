#!env perl6

use FerNANDo;

multi MAIN(Str :$e!, Bool :$debug) {
    my $nando = FerNANDo.new: :$debug;
    my @code  = $nando.parse: $e;
    my @ccode = $nando.compile: @code;
    $nando.run: @ccode
}

subset File of Str where .IO.f;

multi MAIN(File $file, Bool :$debug) {
    my $nando = FerNANDo.new: :$debug;
    my @code  = $nando.parse: $file.IO.slurp;
    my @ccode = $nando.compile: @code;
    $nando.run: @ccode
}
