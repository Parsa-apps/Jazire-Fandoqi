#!/usr/bin/env python3
"""Educational voice lines for letters, numbers, colors and shapes.

Stories and lullabies are intentionally absent — do not regenerate those.
Used as the phrase book when recording the feminine teacher voice.
"""

LETTERS = {
    "l01": ("آ", "حرف آ، آ مثل آب."),
    "l02": ("ب", "حرف ب، ب مثل بابا."),
    "l03": ("پ", "حرف پ، پ مثل پروانه."),
    "l04": ("ت", "حرف ت، ت مثل توپ."),
    "l05": ("ث", "حرف ث، ث مثل ثمر."),
    "l06": ("ج", "حرف ج، ج مثل جنگل."),
    "l07": ("چ", "حرف چ، چ مثل چشم."),
    "l08": ("ح", "حرف ح، ح مثل حلوا."),
    "l09": ("خ", "حرف خ، خ مثل خرس."),
    "l10": ("د", "حرف د، د مثل درخت."),
    "l11": ("ذ", "حرف ذ، ذ مثل ذرت."),
    "l12": ("ر", "حرف ر، ر مثل رنگ."),
    "l13": ("ز", "حرف ز، ز مثل زنگ."),
    "l14": ("ژ", "حرف ژ، ژ مثل ژله."),
    "l15": ("س", "حرف س، س مثل سیب."),
    "l16": ("ش", "حرف ش، ش مثل شیر."),
    "l17": ("ص", "حرف ص، ص مثل صابون."),
    "l18": ("ض", "حرف ض، ض مثل ضربدر."),
    "l19": ("ط", "حرف ط، ط مثل طبل."),
    "l20": ("ظ", "حرف ظ، ظ مثل ظرف."),
    "l21": ("ع", "حرف ع، ع مثل عینک."),
    "l22": ("غ", "حرف غ، غ مثل غاز."),
    "l23": ("ف", "حرف ف، ف مثل فیل."),
    "l24": ("ق", "حرف ق، ق مثل قطار."),
    "l25": ("ک", "حرف ک، ک مثل کتاب."),
    "l26": ("گ", "حرف گ، گ مثل گل."),
    "l27": ("ل", "حرف ل، ل مثل لاله."),
    "l28": ("م", "حرف م، م مثل مادر."),
    "l29": ("ن", "حرف ن، ن مثل نان."),
    "l30": ("و", "حرف و، و مثل گل و بلبل."),
    "l31": ("ه", "حرف ه، ه مثل هوا."),
    "l32": ("ی", "حرف ی، ی مثل یاس."),
}

NUMBERS = {
    "n00": "عدد صفر.",
    "n01": "عدد یک.",
    "n02": "عدد دو.",
    "n03": "عدد سه.",
    "n04": "عدد چهار.",
    "n05": "عدد پنج.",
    "n06": "عدد شش.",
    "n07": "عدد هفت.",
    "n08": "عدد هشت.",
    "n09": "عدد نه.",
    "n10": "عدد ده.",
    "n11": "عدد یازده.",
    "n12": "عدد دوازده.",
    "n13": "عدد سیزده.",
    "n14": "عدد چهارده.",
    "n15": "عدد پانزده.",
    "n16": "عدد شانزده.",
    "n17": "عدد هفده.",
    "n18": "عدد هجده.",
    "n19": "عدد نوزده.",
    "n20": "عدد بیست.",
}

COLORS = {
    "c01": "رنگ قرمز.",
    "c02": "رنگ زرد.",
    "c03": "رنگ آبی.",
    "c04": "رنگ سبز.",
    "c05": "رنگ نارنجی.",
    "c06": "رنگ بنفش.",
    "c07": "رنگ صورتی.",
    "c08": "رنگ قهوه‌ای.",
    "c09": "رنگ سفید.",
    "c10": "رنگ سیاه.",
    "c11": "رنگ خاکستری.",
    "c12": "رنگ طلایی.",
}

SHAPES = {
    "s01": "شکل دایره.",
    "s02": "شکل مربع.",
    "s03": "شکل مثلث.",
    "s04": "شکل مستطیل.",
    "s05": "شکل بیضی.",
    "s06": "شکل ستاره.",
    "s07": "شکل قلب.",
    "s08": "شکل لوزی.",
    "s09": "شکل هلال.",
    "s10": "شکل پنج‌ضلعی.",
}

DONE_LETTERS = {f"l{i:02d}" for i in range(1, 33)}
DONE_NUMBERS = {f"n{i:02d}" for i in range(0, 21)}
DONE_COLORS = {f"c{i:02d}" for i in range(1, 13)}
DONE_SHAPES = {f"s{i:02d}" for i in range(1, 6)}


def remaining() -> list[tuple[str, str, str]]:
    rows: list[tuple[str, str, str]] = []
    for key, (_letter, phrase) in LETTERS.items():
        if key not in DONE_LETTERS:
            rows.append((f"assets/audio/letters/{key}.mp3", key, phrase))
    for key, phrase in NUMBERS.items():
        if key not in DONE_NUMBERS:
            rows.append((f"assets/audio/numbers/{key}.mp3", key, phrase))
    for key, phrase in COLORS.items():
        if key not in DONE_COLORS:
            rows.append((f"assets/audio/learning/colors/{key}.wav", key, phrase))
    for key, phrase in SHAPES.items():
        if key not in DONE_SHAPES:
            rows.append((f"assets/audio/learning/shapes/{key}.wav", key, phrase))
    return rows


if __name__ == "__main__":
    left = remaining()
    print(f"{len(left)} clips remaining (colors 8-12, shapes)")
    for path, key, phrase in left:
        print(f"{key:4}  {path}  {phrase}")
