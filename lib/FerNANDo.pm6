unit class FerNANDo;

has UInt %!loop;
has Bool %.vars is default(False);
has UInt $!line = 0;
has Bool $.debug;

method parse(Str $code) {
    $code.lines>>.words>>.List.grep: so *;
}

multi method compile(@code) {
    do for @code -> @line {
        NEXT $!line++;
        self.compile: |@line
    }
}
multi method compile() { -> { } }
multi method compile($var) {
    my $loop = %!loop{ $var };
    LEAVE %!loop{ $var } = $!line;
    do if %!loop{ $var }:exists {
        -> {
            self.debug: [$var], "loop $var => back to $loop";
            if $.var($var) {
                $!line = $loop
            } else {
                $!line++
            }
        }
    } else {
        -> {
            self.debug: [$var], "pass the loop";
            $!line++
        }
    }
}
multi method compile($var1, $var2) {
    -> {
        LEAVE $!line++;
        my $v1 = $.var($var1);
        my $v2 = $.var($var2);
        $.var($var1) = !($v1 && $v2);
        self.debug: [$var1, $var2], "$v1 NAND $v2 => { $.var($var1) }"
    }
}
multi method compile($var1, $var2, $var3) {
    -> {
        LEAVE $!line++;
        my $v2 = $.var($var2);
        my $v3 = $.var($var3);
        $.var($var1) = !($v2 && $v3);
        self.debug: [$var1, $var2, $var3], "$v2 NAND $v3 => { $.var($var1) }"
    }
}
multi method compile(|v ($, $, $, $, $, $, $, $)) {
    -> {
        LEAVE $!line++;
        my $to-print = v.Array.map({ $.var($_) ?? 1 !! 0 }).join.parse-base(2).chr;
        if $!debug {
            say "\e[32;1mPRINTED: \e[1m$to-print\e[m"
        } else {
            print $to-print
        }
        self.debug: v.Array, v.Array.map({ "{ $_ }({ $.var($_) ?? 1 !! 0 })" })
    }
}
multi method compile(|v ($, $, $, $, $, $, $, $, $)) {
    -> {
        LEAVE $!line++;
        my $val = prompt;
        self.var(v.Array, [ $val.chars == 1 ?? 1 !! 0, |$val.ord.fmt("%08b").comb ])
    }
}
multi method var(@names, @values) {
    self.var(.[0]) = so .[1].Int for @names Z @values
}
multi method var(Str $name)  is rw { %!vars{ $name } }
multi method var("?")              { Bool.pick }
method run(@code) {
    $!line = 0;
    while $!line.defined && @code[ $!line ] -> &run-line {
        run-line;
        self.dump-vars;
    }
}
method dump-vars {
    return unless $!debug;
    say do for %!vars.kv -> $name, $val {
        $val ?? "\e[32;2m$name\e[m" !! "\e[31;2m$name\e[m"
    }.join(" - ")
}
method debug(@vars, $msg) {
    return unless $!debug;
    say "\e[1m$!line: {@vars}: $msg\e[m"
}
