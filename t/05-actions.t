use v6;
use Test;
use ABC::Header;
use ABC::Grammar;
use ABC::Actions;

plan *;

{
    my $music = q«X:64
T:Cuckold Come Out o' the Amrey
S:Northumbrian Minstrelsy
M:4/4
L:1/8
K:D
»;
    my $match = ABC::Grammar.parse($music, :rule<header>, :actions(ABC::Actions.new));
    isa_ok $match, Match, 'tune recognized';
    isa_ok $match.ast, ABC::Header, '$match.ast is an ABC::Header';
    is $match.ast.get("T").elems, 1, "One T field found";
    is $match.ast.get("T")[0].value, "Cuckold Come Out o' the Amrey", "And it's correct";
    ok $match.ast.is-valid, "ABC::Header is valid";
}

{
    my $match = ABC::Grammar.parse("e3", :rule<element>, :actions(ABC::Actions.new));
    isa_ok $match, Match, 'element recognized';
    isa_ok $match.ast, Pair, '$match.ast is a Pair';
    is $match.ast.key, "stem", "Stem found";
    is $match.ast.value, "e3", "Value e3";
}

{
    my $match = ABC::Grammar.parse("G2g gdc|", :rule<bar>, :actions(ABC::Actions.new));
    isa_ok $match, Match, 'element recognized';
    isa_ok $match.ast.elems, 7, '$match.ast has seven elements';
    is $match.ast[3].key, "stem", "Fourth is stem";
    is $match.ast[*-1].key, "barline", "Last is barline";
}

{
    my $match = ABC::Grammar.parse("G2g gdc", :rule<bar>, :actions(ABC::Actions.new));
    isa_ok $match, Match, 'element recognized';
    isa_ok $match.ast.elems, 6, '$match.ast has seven elements';
    is $match.ast[3].key, "stem", "Fourth is stem";
    is $match.ast[*-1].key, "stem", "Last is stem";
}


done_testing;