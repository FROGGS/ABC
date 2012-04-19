use v6;

use ABC::Header;
use ABC::Tune;
use ABC::Duration;
use ABC::Note;
use ABC::Rest;
use ABC::Tuplet;
use ABC::BrokenRhythm;
use ABC::Chord;
use ABC::LongRest;

class ABC::Actions {
    method header_field($/) {
        make ~$<header_field_name> => ~$<header_field_data>;
    }
    
    method header($/) { 
        my $header = ABC::Header.new;
        for @( $<header_field> ) -> $field {
            $header.add-line($field.ast.key, $field.ast.value);
        }
        make $header;
    }
    
    method note_length($/) {
        if $<note_length_denominator> {
            make duration-from-parse($<top>, $<note_length_denominator>[0]<bottom>);
        } else {
            make duration-from-parse($<top>);
        }
    }
    
    method mnote($/) {
        make ABC::Note.new(~$<pitch>, 
                           $<note_length>.ast, 
                           ?$<tie>);
    }
    
    method stem($/) {
        if @( $<mnote> ) == 1 {
            make $<mnote>[0].ast;
        } else {
            make ABC::Stem.new(@( $<mnote> )>>.ast);
        }
    }
    
    method rest($/) {
        make ABC::Rest.new(~$<rest_type>, $<note_length>.ast);
    }

    method multi_measure_rest($/) {
        make ABC::LongRest.new(~$<number>);
    }
    
    method tuplet($/) {
        make ABC::Tuplet.new(3, @( $<stem> )>>.ast);
    }
    
    method broken_rhythm($/) {
        make ABC::BrokenRhythm.new($<stem>[0].ast, 
                                   ~$<g1>, 
                                   ~$<broken_rhythm_bracket>, 
                                   ~$<g2>,
                                   $<stem>[1].ast);
    }

    method inline_field($/) {
        make ~$/<alpha> => ~$/<value>;
    }
    
    method long_gracing($/) {
        make ~$/<long_gracing_text>;
    }

    method gracing($/) {
        make $/<long_gracing> ?? $/<long_gracing>.ast !! ~$/;
    }
    
    method slur_begin($/) {
        make ~$/;
    }
    
    method slur_end($/) {
        make ~$/;
    }
    
    method chord($/) {
        # say "hello?";
        # say $/<chord_accidental>[0].WHAT;
        # say $/<chord_accidental>[0].perl;
        make ABC::Chord.new(~$/<mainnote>, ~($/<mainaccidental> // ""), ~($/<maintype> // ""), 
                            ~($/<bassnote> // ""), ~($/<bass_accidental> // ""));
    }
    
    method chord_or_text($/) {
        my @chords = $/<chord>.map({ $_.ast });
        my @texts = $/<text_expression>.map({ ~$_ });
        make (@chords, @texts).flat;
    }
    
    method element($/) {
        my $type;
        for <broken_rhythm stem rest slur_begin slur_end multi_measure_rest gracing grace_notes nth_repeat end_nth_repeat spacing tuplet inline_field chord_or_text> {
            $type = $_ if $/{$_};
        }
        # say $type ~ " => " ~ $/{$type}.ast.WHAT;
        
        my $ast = $type => ~$/{$type};
        # say :$ast.perl;
        # say $/{$type}.ast.perl;
        # say $/{$type}.ast.WHAT;
        if $/{$type}.ast ~~ ABC::Duration | ABC::LongRest | Pair | Str | List {
            $ast = $type => $/{$type}.ast;
        }
        make $ast;
    }
    
    method barline($/) { 
        make "barline" => ~$/;
    }
    
    method bar($/) {
        my @bar = @( $<element> )>>.ast;
        if $<barline> {
            @bar.push($<barline>>>.ast);
        }
        make @bar;
    }
    
    method line_of_music($/) {
        my @line;
        if $<barline> {
            @line.push($<barline>>>.ast);
        }
        my @bars = @( $<bar> )>>.ast;
        for @bars -> $bar {
            for $bar.list {
                @line.push($_);
            }
        }
        @line.push("endline" => "");
        make @line;
    }
    
    method music($/) {
        my @music;
        for @( $<line_of_music> )>>.ast -> $line {
            for $line.list {
                @music.push($_);
            }
        }
        make @music;
    }
    
    method tune($/) {
        make ABC::Tune.new($<header>.ast, $<music>.ast);
    }
    
    method tune_file($/) {
        make @( $<tune> )>>.ast;
    }
}