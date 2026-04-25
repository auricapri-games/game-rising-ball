# Rising Ball — sprite brief

**Strategy**: generated
**Palette**: natureza_tropical

## Sprites required

- ball.png 36x36 ball
- platform.png 100x16 grass platform
- spike.png 100x40 spikes

## How to generate

1. Implement `scripts/gen_sprites.py` to draw each sprite via PIL.
2. Use AppColors.primary / secondary / accent / background / text — derive
   the actual hex by reading `lib/ds/app_colors.dart` (already generated
   from palette `natureza_tropical`).
3. Output PNGs to `assets/sprites/` matching the names above.
4. Run `python3 scripts/gen_sprites.py` from the repo root.

## Composition rules

- Every sprite must be ON-THEME (`natureza_tropical`). No alien colors.
- Use gradients + soft shadows where appropriate (not flat fill).
- Transparent background (RGBA) on every PNG.
- Anti-aliased edges (PIL's `draw.ellipse` etc handle this).
- Keep filesizes small (each sprite < 30KB).
