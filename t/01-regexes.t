use v6;
use Test;
use ABC;

plan *;

{
    my $match = "^A," ~~ m/ <ABC::pitch> /;
    isa_ok $match, Match, '"^A," is a pitch';
    is $match<ABC::pitch><basenote>, "A", '"^A," has base note A';
    is $match<ABC::pitch><octave>, ",", '"^A," has octave ","';
    is $match<ABC::pitch><accidental>, "^", '"^A," has accidental "#"';
}

{
    my $match = "_B" ~~ m/ <ABC::pitch> /;
    isa_ok $match, Match, '"_B" is a pitch';
    is $match<ABC::pitch><basenote>, "B", '"_B" has base note B';
    is $match<ABC::pitch><octave>, "", '"_B" has octave ""';
    is $match<ABC::pitch><accidental>, "_", '"_B" has accidental "_"';
}

{
    my $match = "C''" ~~ m/ <ABC::pitch> /;
    isa_ok $match, Match, '"note" is a pitch';
    is $match<ABC::pitch><basenote>, "C", '"note" has base note C';
    is $match<ABC::pitch><octave>, "''", '"note" has octave two-upticks';
    is $match<ABC::pitch><accidental>, "", '"note" has accidental ""';
}

{
    my $match = "=d,,," ~~ m/ <ABC::pitch> /;
    isa_ok $match, Match, '"=d,,," is a pitch';
    is $match<ABC::pitch><basenote>, "d", '"=d,,," has base note d';
    is $match<ABC::pitch><octave>, ",,,", '"=d,,," has octave ",,,"';
    is $match<ABC::pitch><accidental>, "=", '"=d,,," has accidental "="';
}



done_testing;