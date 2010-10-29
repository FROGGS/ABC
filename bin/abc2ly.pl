use v6;
use ABC::Header;
use ABC::Tune;
use ABC::Grammar;
use ABC::Actions;
use ABC::Duration;
use ABC::Note;

my %accidental-map = ( ''  => "",
                       '='  => "",
                       '^'  => "is",
                       '^^' => "isis",
                       '_'  => "es",
                       '__' => "eses" );

my %octave-map = ( 0  => "'",
                   1  => "''" );

class Context {
    has %.key;
    has $.meter;
    
    method new(%key, $meter) {
        self.bless(*, :%key, :$meter);
    }
    
    method get-real-pitch($nominal-pitch) {
        my $match = ABC::Grammar.parse($nominal-pitch, :rule<pitch>);
        if $match<accidental> {
            $nominal-pitch;
        } else {
            ($.key{$match<basenote>.uc} // "") ~ $match<basenote> ~ $match<octave>;
        }
    }
    
    method get-Lilypond-pitch($abc-pitch) {
        # say :$abc-pitch.perl;
        my $real-pitch = self.get-real-pitch($abc-pitch);
        # say :$real-pitch.perl;
        my $match = ABC::Grammar.parse($real-pitch, :rule<pitch>);
        
        my $octave = +((~$match<basenote>) ~~ 'a'..'z');
        # SHOULD: factor in $match<octave> too
        
        $match<basenote>.lc ~ %accidental-map{~$match<accidental>} ~ %octave-map{$octave};
    }

    my %cheat-length-map = ( '/' => "16",
                             "" => "8",
                             "1" => "8",
                             "3/2" => "8.",
                             "2" => "4",
                             "3" => "4."
        );
    
    method get-Lilypond-duration(ABC::Duration $abc-duration) {
        %cheat-length-map{$abc-duration.duration-to-str};
    }
    
    method write-meter() {
        print "\\time $.meter ";
    }
}

sub HeaderToLilypond(ABC::Header $header) {
    say "\\header \{";
    
    my @titles = $header.get("T")>>.value;
    say "    piece = \"{ @titles[0] }\"";
    my @composers = $header.get("C")>>.value;
    say "    composer = \"{ @composers[0] }\"" if ?@composers;
    
    say "}";
}

class TuneConvertor {
    has $.context;

    method new($key, $meter) {
        self.bless(*, :context(Context.new(key_signature($key), $meter)));
    }

    # MUST: this is context dependent too
    method Duration($element) {
        $element.value ~~ ABC::Duration ?? $element.value.ticks !! 0;
    }
    
    method StemToLilypond($stem, $suffix = "") {
        if $stem ~~ ABC::Note {
            print " { $.context.get-Lilypond-pitch($stem.pitch) }";
            print "{ $.context.get-Lilypond-duration($stem) }$suffix ";
        }
    }
    
    method SectionToLilypond(@elements) {
        say "\{";
    
        my $suffix = "";
        for @elements -> $element {
            given $element.key {
                when "stem" { self.StemToLilypond($element.value, $suffix); }
                when "rest" { print " r{ $.context.get-Lilypond-duration($element.value) } " }
                when "barline" { say " |"; }
                when "tuplet" { 
                    print " \\times 2/3 \{"; 
                    for $element.value.notes -> $stem {
                        self.StemToLilypond($stem);
                    }
                    print " } ";  
                }
                when "broken_rhythm" {
                    self.StemToLilypond($element.value.effective-stem1, $suffix);
                    # MUST: handle interior graciings
                    self.StemToLilypond($element.value.effective-stem2);
                }
                when "gracing" {
                    given $element.value {
                        when "~" { $suffix ~= "\\turn"; next; }
                        when "." { $suffix ~= "\\staccato"; next; }
                    }
                }
            }
    
            $suffix = "";
        }
    
        say "\}";
    }
    
    method BodyToLilypond($key, @elements) {
        say "\{";
        say "\\key $key \\major";
        $.context.write-meter;
    
        my $start-of-section = 0;
        my $duration-in-section = 0;
        for @elements.keys -> $i {
            if $i > $start-of-section 
               && @elements[$i].key eq "barline" 
               && @elements[$i].value ne "|" {
                if $duration-in-section % 8 != 0 {
                    print "\\partial 8*{ $duration-in-section % 8 } ";
                }
    
                if @elements[$i].value eq ':|:' | ':|' | '::' {
                    print "\\repeat volta 2 "; # 2 is abitrarily chosen here!
                }
                self.SectionToLilypond(@elements[$start-of-section ..^ $i]);
                $start-of-section = $i + 1;
                $duration-in-section = 0;
            }
            $duration-in-section += self.Duration(@elements[$i]);
        }
    
        if $start-of-section + 1 < @elements.elems {
            if $duration-in-section % 8 != 0 {
                print "\\partial 8*{ $duration-in-section % 8 } ";
            }
    
            if @elements[*-1].value eq ':|:' | ':|' | '::' {
                print "\\repeat volta 2 "; # 2 is abitrarily chosen here!
            }
            self.SectionToLilypond(@elements[$start-of-section ..^ +@elements]);
        }
    
        say "\}";
    }
    
}

my $match = ABC::Grammar.parse($*IN.slurp, :rule<tune_file>, :actions(ABC::Actions.new));

say '\\version "2.12.3"';

for @( $match.ast ) -> $tune {
    say "\\score \{";

    my $key = $tune.header.get("K")[0].value;
    my $meter = $tune.header.get("M")[0].value;

    my $convertor = TuneConvertor.new($key, $meter);
    $convertor.BodyToLilypond($key.comb(/./)[0].lc, $tune.music);
    HeaderToLilypond($tune.header);

    say "}";    
}

