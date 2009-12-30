use v6;

grammar ABC
{
    regex header_field_name { \w }
    regex header_field_data { \N* }
    regex header_field { ^^ <header_field_name> ':' \s* <header_field_data> $$ }
    regex header { [<header_field> \v]+ }

    regex basenote { <[a..g]+[A..G]> }
    regex octave { \'+ | \,+ }
    regex accidental { '^' | '^^' | '_' | '__' | '=' }
    regex pitch { <accidental>? <basenote> <octave>? }

    regex tie { '-' }
    regex note_length { [\d* ['/' \d*]? ] | '/' }
    regex note { <pitch> <note_length>? <tie>? }
    
    regex rest_type { <[x..z]> }
    regex rest { <rest_type> <note_length>? }
    
    regex gracing { '+' <alpha>+ '+' }
    
    regex spacing { \h+ }
    
    regex broken_rhythm_bracket { ['<'+ | '>'+] }
    regex broken_rhythm { <note> <g1=gracing>* <broken_rhythm_bracket> <g2=gracing>* <note> }
    
    regex element { <broken_rhythm> | <note> | <rest> | <gracing> | <spacing> }
    
    regex barline { ':|:' | '|:' | '|' | ':|' | '::' }
    
    regex bar { <element>+ <barline>? }
        
    regex line_of_music { <barline>? <bar>+ }
    
    regex music { [<line_of_music> \s*\v?]+ }
    
    regex tune { <header> <music> }
}

sub header_hash($header_match)
{
    gather for $header_match<header_field>
    {
        take $_.<header_field_name>.Str => $_.<header_field_data>.Str;
    }
}

sub key_signature($key_signature_name)
{
    my %keys = (
        'C' => 0,
        'G' => 1,
        'D' => 2,
        'A' => 3,
        'E' => 4,
        'B' => 5,
        'F#' => 6,
        'C#' => 7,
        'F' => -1,
        'Bb' => -2,
        'Eb' => -3,
        'Ab' => -4,
        'Db' => -5,
        'Gb' => -6,
        'Cb' => -7
    );
    
    my $match = $key_signature_name ~~ m/ <ABC::basenote> ('#' | 'b')? \h* (\w*) /;
    die "Illegal key signature\n" unless $match ~~ Match;
    my $lookup = [~] $match<ABC::basenote>.uc, $match[0];
    my $sharps = %keys{$lookup};
    
    if ($match[1].defined) {
        given ~($match[1]) {
            when ""     { }
            when /^maj/ { }
            when /^ion/ { }
            when /^mix/ { $sharps -= 1; }
            when /^dor/ { $sharps -= 2; }
            when /^m/   { $sharps -= 3; }
            when /^aeo/ { $sharps -= 3; }
            when /^phr/ { $sharps -= 4; }
            when /^loc/ { $sharps -= 5; }
            when /^lyd/ { $sharps += 1; }
            default     { die "Unknown mode {$match[1]} requested"; }
        }
    }
    
    my @sharp_notes = <F C G D A E B>;
    my %hash;
    
    given $sharps {
        when 1..7   { for ^$sharps -> $i { %hash{@sharp_notes[$i]} = "^"; } }
        when -7..-1 { for ^(-$sharps) -> $i { %hash{@sharp_notes[6-$i]} = "_"; } }
    }

    return %hash;
}

class ABCHeader
{
    
}

class ABCBody
{
    
}

class ABCTune
{
    has $.header;
    has $.body;
    
}