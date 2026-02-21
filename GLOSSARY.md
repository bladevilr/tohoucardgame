# TouhouBazaar Glossary

## Core Battle Terms
- `Showdown`: Real-time battle phase where both boards auto-serve by cooldown.
- `Flavor`: Main scoring stat for each serve.
- `Presentation`: Creates pressure over time against lower presentation side.
- `Technique Multiplier`: Final multiplier from total technique stat.
- `Aroma Reduction`: Cooldown acceleration from total aroma stat.
- `DoT` (Damage over Time): Continuous score gain from presentation gap each tick.

## Trigger and Keyword Terms
- `on_activate`: Effects that run when an item serves.
- `on_tick`: Effects that run periodically while showdown is active.
- `score_bonus`: Runtime additive score payload used by triggers/effects.
- `Environment Keyword`: Shared battlefield keyword (for example `greasy`, `messy`).
- `Buff Keyword`: Player-side stack keyword that modifies item output.

## Synergy and Clash Terms
- `Synergy`: Activated set bonus from cuisine/tag/board conditions.
- `keyword_trigger`: Synergy branch that grants/consumes keywords on matching serve events.
- `Cuisine Clash`: Shared-cuisine settlement at showdown end.
- `CLASH_LOSER_SCORE_MULT`: Multiplier kept by clash loser; remainder is deducted.

## Result Analysis Terms
- `item_contributions`: Per-slot cumulative serve score contribution.
- `dot_totals`: Total score earned through presentation DoT.
- `clash_penalties`: Post-battle deduction records from cuisine clash.
- `showdown_analysis`: MatchState meta payload consumed by `ResultScreen`.
