use v6;
use Test;
use ABC;

plan *;

{
    my $match = ABC.parse("^A,", :rule<pitch>);
    isa_ok $match, Match, '"^A," is a pitch';
    is $match<basenote>, "A", '"^A," has base note A';
    is $match<octave>, ",", '"^A," has octave ","';
    is $match<accidental>, "^", '"^A," has accidental "#"';
}

{
    my $match = ABC.parse("_B", :rule<pitch>);
    isa_ok $match, Match, '"_B" is a pitch';
    is $match<basenote>, "B", '"_B" has base note B';
    is $match<octave>, "", '"_B" has octave ""';
    is $match<accidental>, "_", '"_B" has accidental "_"';
}

{
    my $match = ABC.parse("C''", :rule<pitch>);
    isa_ok $match, Match, '"note" is a pitch';
    is $match<basenote>, "C", '"note" has base note C';
    is $match<octave>, "''", '"note" has octave two-upticks';
    is $match<accidental>, "", '"note" has accidental ""';
}

{
    my $match = ABC.parse("=d,,,", :rule<pitch>);
    isa_ok $match, Match, '"=d,,," is a pitch';
    is $match<basenote>, "d", '"=d,,," has base note d';
    is $match<octave>, ",,,", '"=d,,," has octave ",,,"';
    is $match<accidental>, "=", '"=d,,," has accidental "="';
}

{
    my $match = ABC.parse("^^e2", :rule<note>);
    isa_ok $match, Match, '"^^e2" is a note';
    is $match<pitch><basenote>, "e", '"^^e2" has base note e';
    is $match<pitch><octave>, "", '"^^e2" has octave ""';
    is $match<pitch><accidental>, "^^", '"^^e2" has accidental "^^"';
    is $match<note_length>, "2", '"^^e2" has note length 2';
}

{
    my $match = ABC.parse("__f'/", :rule<note>);
    isa_ok $match, Match, '"__f/" is a note';
    is $match<pitch><basenote>, "f", '"__f/" has base note f';
    is $match<pitch><octave>, "'", '"__f/" has octave tick';
    is $match<pitch><accidental>, "__", '"__f/" has accidental "__"';
    is $match<note_length>, "/", '"__f/" has note length /';
}

{
    my $match = ABC.parse("G,2/3", :rule<note>);
    isa_ok $match, Match, '"G,2/3" is a note';
    is $match<pitch><basenote>, "G", '"G,2/3" has base note G';
    is $match<pitch><octave>, ",", '"G,2/3" has octave ","';
    is $match<pitch><accidental>, "", '"G,2/3" has no accidental';
    is $match<note_length>, "2/3", '"G,2/3" has note length 2/3';
}

{
    my $match = ABC.parse("z2/3", :rule<rest>);
    isa_ok $match, Match, '"z2/3" is a rest';
    is $match<rest_type>, "z", '"z2/3" has base rest z';
    is $match<note_length>, "2/3", '"z2/3" has note length 2/3';
}

{
    my $match = ABC.parse("y/3", :rule<rest>);
    isa_ok $match, Match, '"y/3" is a rest';
    is $match<rest_type>, "y", '"y/3" has base rest y';
    is $match<note_length>, "/3", '"y/3" has note length 2/3';
}

{
    my $match = ABC.parse("x", :rule<rest>);
    isa_ok $match, Match, '"x" is a rest';
    is $match<rest_type>, "x", '"x" has base rest x';
    is $match<note_length>, "", '"x" has no note length';
}

{
    my $match = ABC.parse("+trill+", :rule<element>);
    isa_ok $match, Match, '"+trill+" is an element';
    is $match<gracing>, "+trill+", '"+trill+" gracing is +trill+';
}

{
    my $match = ABC.parse("~", :rule<element>);
    isa_ok $match, Match, '"~" is an element';
    is $match<gracing>, "~", '"~" gracing is ~';
}

{
    my $match = ABC.parse("z/", :rule<element>);
    isa_ok $match, Match, '"z/" is an element';
    is $match<rest><rest_type>, "z", '"z/" has base rest z';
    is $match<rest><note_length>, "/", '"z/" has length "/"';
}

{
    my $match = ABC.parse("_D,5/4", :rule<element>);
    isa_ok $match, Match, '"_D,5/4" is an element';
    is $match<stem><note>[0]<pitch><basenote>, "D", '"_D,5/4" has base note D';
    is $match<stem><note>[0]<pitch><octave>, ",", '"_D,5/4" has octave ","';
    is $match<stem><note>[0]<pitch><accidental>, "_", '"_D,5/4" is flat';
    is $match<stem><note>[0]<note_length>, "5/4", '"_D,5/4" has note length 5/4';
}

{
    my $match = ABC.parse("A>^C'", :rule<broken_rhythm>);
    isa_ok $match, Match, '"A>^C" is a broken rhythm';
    is $match<stem>[0]<note>[0]<pitch><basenote>, "A", 'first note is A';
    is $match<stem>[0]<note>[0]<pitch><octave>, "", 'first note has no octave';
    is $match<stem>[0]<note>[0]<pitch><accidental>, "", 'first note has no accidental';
    is $match<stem>[0]<note>[0]<note_length>, "", 'first note has no length';
    is $match<broken_rhythm_bracket>, ">", 'angle is >';
    is $match<stem>[1]<note>[0]<pitch><basenote>, "C", 'second note is C';
    is $match<stem>[1]<note>[0]<pitch><octave>, "'", 'second note has octave tick';
    is $match<stem>[1]<note>[0]<pitch><accidental>, "^", 'second note is sharp';
    is $match<stem>[1]<note>[0]<note_length>, "", 'second note has no length';
}

{
    my $match = ABC.parse("d'+p+<<<+accent+_B", :rule<broken_rhythm>);
    isa_ok $match, Match, '"d+p+<<<+accent+_B" is a broken rhythm';
    given $match
    {
        is .<stem>[0]<note>[0]<pitch><basenote>, "d", 'first note is d';
        is .<stem>[0]<note>[0]<pitch><octave>, "'", 'first note has an octave tick';
        is .<stem>[0]<note>[0]<pitch><accidental>, "", 'first note has no accidental';
        is .<stem>[0]<note>[0]<note_length>, "", 'first note has no length';
        is .<g1>[0], "+p+", 'first gracing is +p+';
        is .<broken_rhythm_bracket>, "<<<", 'angle is <<<';
        is .<g2>[0], "+accent+", 'second gracing is +accent+';
        is .<stem>[1]<note>[0]<pitch><basenote>, "B", 'second note is B';
        is .<stem>[1]<note>[0]<pitch><octave>, "", 'second note has no octave';
        is .<stem>[1]<note>[0]<pitch><accidental>, "_", 'second note is flat';
        is .<stem>[1]<note>[0]<note_length>, "", 'second note has no length';
    }
}

# for ':|:', '|:', '|', ':|', '::'  
# {
#     my $match = $_ ~~ m/ <ABC::barline> /;
#     isa_ok $match, Match, "barline $_ recognized";
#     is $match<ABC::barline>, $_, "barline $_ is correct";
# }
# 
# {
#     my $match = "g>ecgece/f/g/e/|" ~~ m/ <ABC::bar> /;
#     isa_ok $match, Match, 'bar recognized';
#     is $match<ABC::bar>, "g>ecgece/f/g/e/|", "Entire bar was matched";
#     is $match<ABC::bar><element>.map(~*), "g>e c g e c e/ f/ g/ e/", "Each element was matched";
#     is $match<ABC::bar><barline>, "|", "Barline was matched";
# }
# 
# {
#     my $match = "g>ecg ec e/f/g/e/ |" ~~ m/ <ABC::bar> /;
#     isa_ok $match, Match, 'bar recognized';
#     is $match<ABC::bar>, "g>ecg ec e/f/g/e/ |", "Entire bar was matched";
#     is $match<ABC::bar><element>.map(~*), "g>e c g   e c   e/ f/ g/ e/  ", "Each element was matched";
#     is $match<ABC::bar><barline>, "|", "Barline was matched";
# }
# 
# {
#     my $line = "g>ecg ec e/f/g/e/ | d/c/B/A/ Gd BG B/c/d/B/ |";
#     my $match = $line ~~ m/ <ABC::line_of_music> /;
#     isa_ok $match, Match, 'line of music recognized';
#     is $match<ABC::line_of_music>, $line, "Entire line was matched";
#     is $match<ABC::line_of_music><bar>[0], "g>ecg ec e/f/g/e/ |", "First bar is correct";
#     is $match<ABC::line_of_music><bar>[1], " d/c/B/A/ Gd BG B/c/d/B/ |", "Second bar is correct";
#     # say $match<ABC::line_of_music>.perl;
# }
# 
# {
#     my $line = "|A/B/c/A/ c>d e>deg | dB/A/ gB +trill+A2 +trill+e2 ::";
#     my $match = $line ~~ m/ <ABC::line_of_music> /;
#     isa_ok $match, Match, 'line of music recognized';
#     is $match<ABC::line_of_music>, $line, "Entire line was matched";
#     is $match<ABC::line_of_music><bar>[0], "A/B/c/A/ c>d e>deg |", "First bar is correct";
#     is $match<ABC::line_of_music><bar>[1], " dB/A/ gB +trill+A2 +trill+e2 ::", "Second bar is correct";
#     is $match<ABC::line_of_music><barline>, "|", "Initial barline matched";
#     # say $match<ABC::line_of_music>.perl;
# }
# 
# {
#     my $line = 'g>ecg ec e/f/g/e/ |[2-3 d/c/B/A/ {Gd} BG B/c/d/B/ |';
#     my $match = $line ~~ m/ <ABC::line_of_music> /;
#     isa_ok $match, Match, 'line of music recognized';
#     is $match<ABC::line_of_music>, $line, "Entire line was matched";
#     is $match<ABC::line_of_music><bar>[0], "g>ecg ec e/f/g/e/ |", "First bar is correct";
#     is $match<ABC::line_of_music><bar>[1], '[2-3 d/c/B/A/ {Gd} BG B/c/d/B/ |', "Second bar is correct";
#     # say $match<ABC::line_of_music>.perl;
# }
# 
# {
#     my $music = q«A/B/c/A/ +trill+c>d e>deg | GG +trill+B>c d/B/A/G/ B/c/d/B/ |
#     A/B/c/A/ c>d e>deg | dB/A/ gB +trill+A2 +trill+e2 ::
#     g>ecg ec e/f/g/e/ | d/c/B/A/ Gd BG B/c/d/B/ | 
#     g/f/e/d/ c/d/e/f/ gc e/f/g/e/ | dB/A/ gB +trill+A2 +trill+e2 :|»;
#     my $match = $music ~~ m/ <ABC::music> /;
#     isa_ok $match, Match, 'music recognized';
#     is $match<ABC::music><line_of_music>.elems, 4, "Four lines matched";
# }
# 
# {
#     my $music = q«X:64
# T:Cuckold Come Out o' the Amrey
# S:Northumbrian Minstrelsy
# M:4/4
# L:1/8
# K:D
# »;
#     my $match = $music ~~ m/ <ABC::header> /;
#     isa_ok $match, Match, 'header recognized';
#     is $match<ABC::header><header_field>.elems, 6, "Six fields matched";
#     is $match<ABC::header><header_field>.map(*.<header_field_name>), "X T S M L K", "Got the right field names";
# }
# 
# {
#     my $music = q«X:64
# T:Cuckold Come Out o' the Amrey
# S:Northumbrian Minstrelsy
# M:4/4
# L:1/8
# K:D
# A/B/c/A/ +trill+c>d e>deg | GG +trill+B>c d/B/A/G/ B/c/d/B/ |
# A/B/c/A/ c>d e>deg | dB/A/ gB +trill+A2 +trill+e2 ::
# g>ecg ec e/f/g/e/ | d/c/B/A/ Gd BG B/c/d/B/ | 
# g/f/e/d/ c/d/e/f/ gc e/f/g/e/ | dB/A/ gB +trill+A2 +trill+e2 :|
# »;
#     my $match = $music ~~ m/ <ABC::tune> /;
#     isa_ok $match, Match, 'tune recognized';
#     given $match<ABC::tune><header>
#     {
#         is .<header_field>.elems, 6, "Six fields matched";
#         is .<header_field>.map(*.<header_field_name>), "X T S M L K", "Got the right field names";
#     }
#     is $match<ABC::tune><music><line_of_music>.elems, 4, "Four lines matched";
#     say $match;
# }

done_testing;