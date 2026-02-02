def analyze_pauses(words):
    """
    Detect pauses between spoken words.
    """
    pauses = []

    for i in range(1, len(words)):
        gap = words[i]["start"] - words[i - 1]["end"]

        if gap > 1.0:  # seconds
            pauses.append({
                "after_word": words[i - 1]["word"],
                "pause_duration": round(gap, 2)
            })

    hesitation_level = "none"

    if any(p["pause_duration"] > 2.5 for p in pauses):
        hesitation_level = "awkward"
    elif any(p["pause_duration"] > 1.2 for p in pauses):
        hesitation_level = "mild"

    return {
        "pauses": pauses,
        "hesitation": hesitation_level
    }
