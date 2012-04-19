use v6;

use ABC::Duration;

class ABC::Tuplet does ABC::Duration {
    has $.tuple;
    has @.notes;
    
    method new($tuple, @notes) {
        die "Stem must have at least one note" if +@notes == 0;
        die "Only handle triplets so far" if $tuple != 3;
        self.bless(*, :$tuple, :@notes, :ticks(2/3 * [+] @notes>>.ticks));
    }
}
