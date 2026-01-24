#!/usr/bin/env python3
import sys
import json
import difflib


def load_data(filepath):
    with open(filepath, "r") as f:
        return json.load(f)


def normalize(text):
    return text.strip().upper()


def is_similar(a, b, threshold=0.85):
    return difflib.SequenceMatcher(None, a, b).ratio() >= threshold


def group_components(items):
    # items is a list of {"text": "...", "source": "..."}

    # First count frequencies of exact matches
    counts = {}
    for item in items:
        txt = normalize(item["text"])
        counts[txt] = counts.get(txt, 0) + 1

    # Sort unique texts by frequency (descending)
    # This ensures the most common spelling becomes the "canonical" seed for the cluster
    unique_texts = sorted(counts.keys(), key=lambda x: counts[x], reverse=True)

    clusters = []
    # List of dicts: {'canonical': str, 'variants': set(), 'sources': [], 'count': 0}

    for text in unique_texts:
        matched = False
        for cluster in clusters:
            # Check similarity against the canonical representative of the cluster
            if is_similar(text, cluster["canonical"]):
                cluster["variants"].add(text)
                matched = True
                break

        if not matched:
            clusters.append(
                {"canonical": text, "variants": {text}, "sources": [], "count": 0}
            )

    # Now populate sources and counts based on the clusters we built
    for item in items:
        text = normalize(item["text"])
        for cluster in clusters:
            if text in cluster["variants"]:
                cluster["sources"].append(item["source"])
                cluster["count"] += 1
                break

    # Format output
    result = []
    for cluster in clusters:
        result.append(
            {
                "canonical_candidate": cluster["canonical"],
                "variants": sorted(list(cluster["variants"])),
                "frequency": cluster["count"],
                "confidence": min(
                    1.0, cluster["count"] / 5.0
                ),  # Simple heuristic: 5 occurrences = 100% confidence
                "sources": sorted(list(set(cluster["sources"]))),
            }
        )

    # Sort results by frequency
    result.sort(key=lambda x: x["frequency"], reverse=True)

    return result


if __name__ == "__main__":
    try:
        if len(sys.argv) > 1:
            input_file = sys.argv[1]
            data = load_data(input_file)
        else:
            data = json.load(sys.stdin)

        groups = group_components(data)
        print(json.dumps({"component_groups": groups}, indent=2))
    except Exception as e:
        sys.stderr.write(f"Error: {str(e)}\n")
        sys.exit(1)
