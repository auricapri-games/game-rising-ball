"""Generate sprites for Rising Ball using the natureza_tropical palette.

Sprites:
- ball.png      36x36   bouncing ball (yellow/gold w/ shine + shadow)
- platform.png  100x16  grass-topped platform (green w/ tropical leaves)
- spike.png     100x40  hazard spikes (coral/red w/ jagged tops)
- mascot.png    180x180 hero ball mascot (used on splash/home)
- background.png 360x640 vertical tropical gradient with subtle leaves

Run from repo root:
    python3 scripts/gen_sprites.py
"""
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

OUT = Path(__file__).resolve().parent.parent / "assets" / "sprites"
OUT.mkdir(parents=True, exist_ok=True)

# natureza_tropical (mirrors lib/ds/app_colors.dart)
PRIMARY = (45, 206, 137)     # #2DCE89 emerald green
SECONDARY = (255, 209, 102)  # #FFD166 sun gold
BG_DARK = (5, 61, 42)        # #053D2A deep forest
BG_ALT = (10, 110, 71)       # #0A6E47 leaf green
TEXT = (241, 250, 238)       # #F1FAEE off-white
ACCENT = (239, 71, 111)      # #EF476F coral red


def _radial_shade(size, light, dark, light_pos=(0.35, 0.30)):
    """Render a circular sprite with a radial light to dark gradient."""
    img = Image.new("RGBA", (size * 2, size * 2), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    cx = int(size * 2 * light_pos[0])
    cy = int(size * 2 * light_pos[1])
    max_r = int((size * 2) * 0.95)
    for r in range(max_r, 0, -1):
        t = 1 - (r / max_r)
        c = (
            int(dark[0] + (light[0] - dark[0]) * t),
            int(dark[1] + (light[1] - dark[1]) * t),
            int(dark[2] + (light[2] - dark[2]) * t),
            255,
        )
        draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=c)
    mask = Image.new("L", (size * 2, size * 2), 0)
    ImageDraw.Draw(mask).ellipse([0, 0, size * 2, size * 2], fill=255)
    out = Image.new("RGBA", (size * 2, size * 2), (0, 0, 0, 0))
    out.paste(img, (0, 0), mask)
    return out.resize((size, size), Image.LANCZOS)


def make_ball(path):
    size = 144
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))

    shadow = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    sdraw = ImageDraw.Draw(shadow)
    sdraw.ellipse([14, size - 26, size - 14, size - 8], fill=(0, 0, 0, 110))
    shadow = shadow.filter(ImageFilter.GaussianBlur(4))
    canvas = Image.alpha_composite(canvas, shadow)

    body = _radial_shade(size, light=(255, 235, 180), dark=(220, 150, 30))
    canvas = Image.alpha_composite(canvas, body)

    rim = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    ImageDraw.Draw(rim).ellipse(
        [4, 4, size - 4, size - 4], outline=(160, 100, 20, 220), width=4,
    )
    canvas = Image.alpha_composite(canvas, rim)

    hl = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    ImageDraw.Draw(hl).ellipse(
        [int(size * 0.22), int(size * 0.18), int(size * 0.50), int(size * 0.42)],
        fill=(255, 255, 240, 230),
    )
    hl = hl.filter(ImageFilter.GaussianBlur(2))
    canvas = Image.alpha_composite(canvas, hl)

    canvas.resize((36, 36), Image.LANCZOS).save(path)


def make_platform(path):
    w, h = 400, 64
    canvas = Image.new("RGBA", (w, h), (0, 0, 0, 0))

    soil = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    sdraw = ImageDraw.Draw(soil)
    sdraw.rounded_rectangle([0, 18, w, h - 6], radius=14, fill=(8, 70, 45, 255))
    canvas = Image.alpha_composite(canvas, soil)

    grass = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    gdraw = ImageDraw.Draw(grass)
    for y in range(28):
        t = y / 28
        c = (
            int(PRIMARY[0] * (1 - t) + 30 * t),
            int(PRIMARY[1] * (1 - t) + 130 * t),
            int(PRIMARY[2] * (1 - t) + 70 * t),
            255,
        )
        gdraw.rectangle([0, y, w, y + 1], fill=c)
    mask = Image.new("L", (w, h), 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        [0, 0, w, 36], radius=14, fill=255,
    )
    grass.putalpha(mask)
    canvas = Image.alpha_composite(canvas, grass)

    bdraw = ImageDraw.Draw(canvas)
    for x in range(8, w - 8, 22):
        bdraw.polygon(
            [(x, 6), (x + 6, 0), (x + 12, 6)], fill=(230, 255, 210, 200),
        )
        bdraw.polygon(
            [(x + 12, 8), (x + 18, 2), (x + 24, 8)], fill=(60, 200, 130, 220),
        )

    hdraw = ImageDraw.Draw(canvas)
    hdraw.rectangle([20, 12, w - 20, 14], fill=(255, 255, 255, 70))

    shadow = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle(
        [10, h - 8, w - 10, h - 2], radius=4, fill=(0, 0, 0, 100),
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(3))
    canvas = Image.alpha_composite(shadow, canvas)

    canvas.resize((100, 16), Image.LANCZOS).save(path)


def make_spike(path):
    w, h = 400, 160
    canvas = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(canvas)

    draw.rounded_rectangle([0, h - 24, w, h - 4], radius=10, fill=(120, 30, 50, 255))

    spike_w = 50
    base_y = h - 24
    tip_y = 14
    for i in range(w // spike_w):
        x0 = i * spike_w
        x1 = x0 + spike_w
        mid = (x0 + x1) // 2
        draw.polygon(
            [(x0, base_y), (mid, tip_y + 4), (x1, base_y)],
            fill=(170, 40, 70, 255),
        )
        draw.polygon(
            [(x0 + 4, base_y - 2), (mid, tip_y + 8), (mid, base_y - 4)],
            fill=ACCENT + (255,),
        )

    glow = canvas.filter(ImageFilter.GaussianBlur(5))
    glow.putalpha(glow.getchannel("A").point(lambda a: int(a * 0.5)))
    canvas = Image.alpha_composite(glow, canvas)

    shadow = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle(
        [10, h - 8, w - 10, h - 2], radius=4, fill=(0, 0, 0, 130),
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(4))
    canvas = Image.alpha_composite(shadow, canvas)

    canvas.resize((100, 40), Image.LANCZOS).save(path)


def make_mascot(path):
    """Larger version of the ball with a face."""
    size = 360
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))

    shadow = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).ellipse(
        [40, size - 70, size - 40, size - 30], fill=(0, 0, 0, 130),
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(8))
    canvas = Image.alpha_composite(canvas, shadow)

    body = _radial_shade(size, light=(255, 240, 200), dark=(210, 140, 30))
    canvas = Image.alpha_composite(canvas, body)

    rim = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    ImageDraw.Draw(rim).ellipse(
        [10, 10, size - 10, size - 10],
        outline=(160, 100, 20, 240), width=8,
    )
    canvas = Image.alpha_composite(canvas, rim)

    fdraw = ImageDraw.Draw(canvas)
    eye_y = int(size * 0.46)
    eye_off = int(size * 0.16)
    cx = size // 2
    eye_r_outer = 36
    eye_r_inner = 18
    fdraw.ellipse(
        [cx - eye_off - eye_r_outer, eye_y - eye_r_outer,
         cx - eye_off + eye_r_outer, eye_y + eye_r_outer],
        fill=(255, 255, 255, 255),
    )
    fdraw.ellipse(
        [cx + eye_off - eye_r_outer, eye_y - eye_r_outer,
         cx + eye_off + eye_r_outer, eye_y + eye_r_outer],
        fill=(255, 255, 255, 255),
    )
    fdraw.ellipse(
        [cx - eye_off - eye_r_inner + 4, eye_y - eye_r_inner + 4,
         cx - eye_off + eye_r_inner + 4, eye_y + eye_r_inner + 4],
        fill=(20, 30, 40, 255),
    )
    fdraw.ellipse(
        [cx + eye_off - eye_r_inner + 4, eye_y - eye_r_inner + 4,
         cx + eye_off + eye_r_inner + 4, eye_y + eye_r_inner + 4],
        fill=(20, 30, 40, 255),
    )
    fdraw.ellipse(
        [cx - eye_off + 6, eye_y - 8, cx - eye_off + 14, eye_y],
        fill=(255, 255, 255, 240),
    )
    fdraw.ellipse(
        [cx + eye_off + 6, eye_y - 8, cx + eye_off + 14, eye_y],
        fill=(255, 255, 255, 240),
    )

    smile_y = int(size * 0.66)
    fdraw.arc(
        [cx - 60, smile_y - 30, cx + 60, smile_y + 30],
        start=20, end=160, fill=(70, 30, 10, 240), width=10,
    )

    blush = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    bdraw = ImageDraw.Draw(blush)
    bdraw.ellipse(
        [cx - eye_off - 38, eye_y + 22, cx - eye_off + 2, eye_y + 50],
        fill=(255, 120, 140, 130),
    )
    bdraw.ellipse(
        [cx + eye_off - 2, eye_y + 22, cx + eye_off + 38, eye_y + 50],
        fill=(255, 120, 140, 130),
    )
    blush = blush.filter(ImageFilter.GaussianBlur(4))
    canvas = Image.alpha_composite(canvas, blush)

    hl = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    ImageDraw.Draw(hl).ellipse(
        [int(size * 0.22), int(size * 0.16), int(size * 0.46), int(size * 0.36)],
        fill=(255, 255, 245, 220),
    )
    hl = hl.filter(ImageFilter.GaussianBlur(5))
    canvas = Image.alpha_composite(canvas, hl)

    canvas.resize((180, 180), Image.LANCZOS).save(path)


def make_background(path):
    w, h = 360, 640
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    for y in range(h):
        t = y / h
        c = (
            int(BG_DARK[0] * (1 - t) + BG_ALT[0] * t),
            int(BG_DARK[1] * (1 - t) + BG_ALT[1] * t),
            int(BG_DARK[2] * (1 - t) + BG_ALT[2] * t),
            255,
        )
        draw.rectangle([0, y, w, y + 1], fill=c)

    leaves = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    spots = [
        (40, 90, 110, 18),
        (240, 40, 80, 22),
        (300, 200, 90, 15),
        (60, 320, 130, 20),
        (260, 470, 100, 18),
        (40, 560, 80, 22),
    ]
    for x, y, w_, rot in spots:
        leaf = Image.new("RGBA", (w_, w_), (0, 0, 0, 0))
        ImageDraw.Draw(leaf).ellipse(
            [0, int(w_ * 0.35), w_, int(w_ * 0.65)], fill=(45, 200, 130, 70),
        )
        leaf = leaf.rotate(rot, resample=Image.BICUBIC, expand=True)
        leaf = leaf.filter(ImageFilter.GaussianBlur(2))
        leaves.alpha_composite(leaf, (x, y))
    img = Image.alpha_composite(img, leaves)

    vign = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    vdraw = ImageDraw.Draw(vign)
    for r in range(0, 200, 6):
        a = int(120 * (r / 200))
        vdraw.rectangle([0, h - r, w, h - r + 6], fill=(0, 0, 0, a))
    vign = vign.filter(ImageFilter.GaussianBlur(20))
    img = Image.alpha_composite(img, vign)

    img.save(path)


def main():
    make_ball(OUT / "ball.png")
    print(f"Wrote {OUT/'ball.png'}")
    make_platform(OUT / "platform.png")
    print(f"Wrote {OUT/'platform.png'}")
    make_spike(OUT / "spike.png")
    print(f"Wrote {OUT/'spike.png'}")
    make_mascot(OUT / "mascot.png")
    print(f"Wrote {OUT/'mascot.png'}")
    make_background(OUT / "background.png")
    print(f"Wrote {OUT/'background.png'}")


if __name__ == "__main__":
    main()
