"""Generate sprites for Rising Ball — paleta natureza_tropical.

Reads colors mirrored from lib/ds/app_colors.dart so output stays on-theme.
Produces 4 PNGs in assets/sprites/:
    ball.png       36x36   bouncy green ball with glossy highlight + face
    platform.png   100x16  grass-top platform with soil base
    spike.png      100x40  deadly accent-colored spikes
    cloud_bg.png   200x100 soft mint cloud for parallax
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "assets" / "sprites"
OUT.mkdir(parents=True, exist_ok=True)

# natureza_tropical
PRIMARY = (45, 206, 137)
SECONDARY = (255, 209, 102)
BACKGROUND = (5, 61, 42)
BACKGROUND_ALT = (10, 110, 71)
TEXT = (241, 250, 238)
ACCENT = (239, 71, 111)


def _add_shadow(sprite, blur=3, offset=(2, 3), opacity=110):
    w, h = sprite.size
    pad = blur * 4
    canvas = Image.new("RGBA", (w + pad * 2, h + pad * 2), (0, 0, 0, 0))
    alpha = sprite.split()[-1]
    shadow = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    shadow.paste((0, 0, 0, opacity),
                 (pad + offset[0], pad + offset[1]), mask=alpha)
    shadow = shadow.filter(ImageFilter.GaussianBlur(blur))
    canvas.alpha_composite(shadow)
    canvas.alpha_composite(sprite, (pad, pad))
    return canvas


def gen_ball():
    size = 96
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)

    # body
    d.ellipse([4, 4, size - 4, size - 4], fill=(*PRIMARY, 255))
    d.ellipse([10, 10, size - 10, size - 10],
              fill=(min(255, PRIMARY[0] + 35),
                    min(255, PRIMARY[1] + 35),
                    min(255, PRIMARY[2] + 35), 255))

    # bottom volume shadow
    bottom = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    bd = ImageDraw.Draw(bottom)
    bd.ellipse([14, 36, size - 14, size - 6],
               fill=(0, 50, 25, 130))
    bottom = bottom.filter(ImageFilter.GaussianBlur(5))
    img.alpha_composite(bottom)

    # specular highlight
    hi = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    hd = ImageDraw.Draw(hi)
    hd.ellipse([22, 16, 44, 36], fill=(255, 255, 255, 210))
    hi = hi.filter(ImageFilter.GaussianBlur(2))
    img.alpha_composite(hi)

    # face
    d.ellipse([34, 44, 44, 54], fill=(20, 30, 25, 255))
    d.ellipse([56, 44, 66, 54], fill=(20, 30, 25, 255))
    d.ellipse([37, 46, 41, 50], fill=(255, 255, 255, 230))
    d.ellipse([59, 46, 63, 50], fill=(255, 255, 255, 230))
    d.arc([40, 56, 60, 70], 10, 170,
          fill=(20, 30, 25, 255), width=2)

    img = img.resize((36, 36), Image.LANCZOS)
    img = _add_shadow(img, blur=2, offset=(1, 2), opacity=110)
    img.save(OUT / "ball.png")
    print(f"  ball.png         {img.size}")


def gen_platform():
    w, h = 200, 32
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)

    soil_top = (84, 56, 34)
    soil_bottom = (52, 32, 18)
    for y in range(13, h):
        t = (y - 13) / max(1, (h - 13))
        r = int(soil_top[0] + (soil_bottom[0] - soil_top[0]) * t)
        g = int(soil_top[1] + (soil_bottom[1] - soil_top[1]) * t)
        b = int(soil_top[2] + (soil_bottom[2] - soil_top[2]) * t)
        d.line([(0, y), (w, y)], fill=(r, g, b, 255))

    for y in range(0, 14):
        t = y / 14
        r = int(PRIMARY[0] * (1 - t) + BACKGROUND_ALT[0] * t)
        g = int(PRIMARY[1] * (1 - t) + BACKGROUND_ALT[1] * t)
        b = int(PRIMARY[2] * (1 - t) + BACKGROUND_ALT[2] * t)
        d.line([(0, y), (w, y)], fill=(r, g, b, 255))

    # grass blades on top edge
    blade = (PRIMARY[0], PRIMARY[1], PRIMARY[2], 255)
    for x in range(2, w, 12):
        d.polygon([(x, 6), (x + 3, 0), (x + 6, 6)], fill=blade)

    # rounded corners
    mask = Image.new("L", (w, h), 0)
    md = ImageDraw.Draw(mask)
    md.rounded_rectangle([0, 0, w, h], radius=8, fill=255)
    out = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    out.paste(img, (0, 0), mask=mask)

    out = out.resize((100, 16), Image.LANCZOS)
    out = _add_shadow(out, blur=2, offset=(0, 2), opacity=110)
    out.save(OUT / "platform.png")
    print(f"  platform.png     {out.size}")


def gen_spike():
    w, h = 200, 80
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)

    spike_count = 5
    sw = w / spike_count
    for i in range(spike_count):
        x0 = i * sw
        x1 = (i + 1) * sw
        cx = (x0 + x1) / 2
        d.polygon([(x0 + 4, h - 2), (cx, 6), (x1 - 4, h - 2)],
                  fill=(*ACCENT, 255))
        d.polygon([(cx, 6), (x1 - 4, h - 2), (cx + 2, h - 4)],
                  fill=(180, 40, 70, 255))
        d.line([(x0 + 6, h - 4), (cx, 8)],
               fill=(255, 200, 200, 220), width=2)

    d.rectangle([0, h - 8, w, h], fill=(120, 30, 50, 255))
    d.rectangle([0, h - 8, w, h - 6], fill=(180, 50, 80, 255))

    img = img.resize((100, 40), Image.LANCZOS)
    img = _add_shadow(img, blur=3, offset=(0, 2), opacity=140)
    img.save(OUT / "spike.png")
    print(f"  spike.png        {img.size}")


def gen_cloud_bg():
    w, h = 400, 200
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    cloud_color = (180, 230, 200, 200)
    blobs = [
        (40, 80, 120, 160),
        (90, 50, 200, 140),
        (160, 60, 280, 150),
        (240, 70, 360, 160),
        (140, 30, 240, 110),
    ]
    for box in blobs:
        d.ellipse(box, fill=cloud_color)

    img = img.filter(ImageFilter.GaussianBlur(8))
    bright = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    bd = ImageDraw.Draw(bright)
    for box in blobs:
        bd.ellipse((box[0] + 4, box[1] + 4, box[2] - 4, box[3] - 20),
                   fill=(220, 250, 230, 110))
    bright = bright.filter(ImageFilter.GaussianBlur(6))
    img.alpha_composite(bright)

    img = img.resize((200, 100), Image.LANCZOS)
    img.save(OUT / "cloud_bg.png")
    print(f"  cloud_bg.png     {img.size}")


def main():
    print(f"Generating sprites in {OUT}")
    gen_ball()
    gen_platform()
    gen_spike()
    gen_cloud_bg()
    print("Done.")


if __name__ == "__main__":
    main()
