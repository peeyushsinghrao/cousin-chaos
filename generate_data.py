"""
Script to generate all 4 data .dart files from the remixed-40d671c6.md source.
Reads the markdown, parses each section, and writes correct Dart constants.
"""
import re
import os

MD_FILE = os.path.join(os.path.dirname(__file__), 'remixed-40d671c6.md')
OUT_DIR = os.path.join(os.path.dirname(__file__), 'lib', 'core', 'constants')

with open(MD_FILE, 'r', encoding='utf-8') as f:
    content = f.read()

# ─── helpers ────────────────────────────────────────────────────────────
def escape_dart(s):
    """Escape single quotes and backslashes for Dart string literals."""
    return s.replace('\\', '\\\\').replace("'", "\\'")

def extract_numbered_lines(block):
    """Given a text block, extract numbered items like '1. ...' or 'Q: ... A: ...'"""
    items = []
    for line in block.strip().splitlines():
        line = line.strip()
        m = re.match(r'^\d+\.\s+(.*)', line)
        if m:
            items.append(m.group(1).strip())
    return items

def section_between(text, start_marker, end_markers):
    """Extract text between start_marker and the first of end_markers found."""
    idx = text.find(start_marker)
    if idx == -1:
        return ''
    idx += len(start_marker)
    end_idx = len(text)
    for em in end_markers:
        i = text.find(em, idx)
        if i != -1 and i < end_idx:
            end_idx = i
    return text[idx:end_idx]

# ─── category map ───────────────────────────────────────────────────────
CATEGORIES = [
    ('party_starter', '🎉 PARTY STARTER'),
    ('mild_but_wild', '😜 MILD BUT WILD'),
    ('family_night', '🏠 FAMILY NIGHT'),
    ('spice_it_up', '🔥 SPICE IT UP'),
    ('girls_night_out', '💅 GIRLS NIGHT OUT'),
    ('guys_unleashed', '💪 GUYS UNLEASHED'),
]

# ─── 1. NHIE ────────────────────────────────────────────────────────────
print('Generating nhie_data.dart ...')
nhie_entries = []
for cat_key, cat_emoji in CATEGORIES:
    header = f'## {cat_emoji} — NEVER HAVE I EVER'
    block = section_between(content, header, ['## ', '# '])
    items = extract_numbered_lines(block)
    if not items:
        print(f'  WARNING: no NHIE items for {cat_key}')
    for item in items:
        nhie_entries.append(f"    {{'text': '{escape_dart(item)}', 'category': '{cat_key}'}},")
    print(f'  {cat_key}: {len(items)} items')

nhie_dart = f"""/// Never Have I Ever statement database
class NhieData {{
  static const List<Map<String, dynamic>> statements = [
    // -- PARTY STARTER --
{chr(10).join([e for e in nhie_entries if "'category': 'party_starter'" in e])}
    // -- MILD BUT WILD --
{chr(10).join([e for e in nhie_entries if "'category': 'mild_but_wild'" in e])}
    // -- FAMILY NIGHT --
{chr(10).join([e for e in nhie_entries if "'category': 'family_night'" in e])}
    // -- SPICE IT UP --
{chr(10).join([e for e in nhie_entries if "'category': 'spice_it_up'" in e])}
    // -- GIRLS NIGHT OUT --
{chr(10).join([e for e in nhie_entries if "'category': 'girls_night_out'" in e])}
    // -- GUYS UNLEASHED --
{chr(10).join([e for e in nhie_entries if "'category': 'guys_unleashed'" in e])}
  ];
}}
"""
with open(os.path.join(OUT_DIR, 'nhie_data.dart'), 'w', encoding='utf-8') as f:
    f.write(nhie_dart)
print(f'  Total NHIE entries: {len(nhie_entries)}')

# ─── 2. WYR ─────────────────────────────────────────────────────────────
print('\nGenerating wyr_data.dart ...')
wyr_entries = []
for cat_key, cat_emoji in CATEGORIES:
    header = f'## {cat_emoji} — WOULD YOU RATHER'
    block = section_between(content, header, ['## ', '# '])
    items = extract_numbered_lines(block)
    if not items:
        print(f'  WARNING: no WYR items for {cat_key}')
    for item in items:
        # Split on " OR " (case insensitive)
        parts = re.split(r'\s+OR\s+', item, maxsplit=1)
        if len(parts) == 2:
            # Remove leading "Would you rather " from optionA
            a = parts[0]
            a = re.sub(r'^Would you rather\s+', '', a, flags=re.IGNORECASE)
            b = parts[1].rstrip('?')
            wyr_entries.append(f"    {{'optionA': '{escape_dart(a)}', 'optionB': '{escape_dart(b)}', 'category': '{cat_key}'}},")
        else:
            # Fallback: store as single option
            wyr_entries.append(f"    {{'optionA': '{escape_dart(item)}', 'optionB': '', 'category': '{cat_key}'}},")
    print(f'  {cat_key}: {len(items)} items')

wyr_dart = f"""/// Would You Rather question database
class WyrData {{
  static const List<Map<String, dynamic>> questions = [
    // -- PARTY STARTER --
{chr(10).join([e for e in wyr_entries if "'category': 'party_starter'" in e])}
    // -- MILD BUT WILD --
{chr(10).join([e for e in wyr_entries if "'category': 'mild_but_wild'" in e])}
    // -- FAMILY NIGHT --
{chr(10).join([e for e in wyr_entries if "'category': 'family_night'" in e])}
    // -- SPICE IT UP --
{chr(10).join([e for e in wyr_entries if "'category': 'spice_it_up'" in e])}
    // -- GIRLS NIGHT OUT --
{chr(10).join([e for e in wyr_entries if "'category': 'girls_night_out'" in e])}
    // -- GUYS UNLEASHED --
{chr(10).join([e for e in wyr_entries if "'category': 'guys_unleashed'" in e])}
  ];
}}
"""
with open(os.path.join(OUT_DIR, 'wyr_data.dart'), 'w', encoding='utf-8') as f:
    f.write(wyr_dart)
print(f'  Total WYR entries: {len(wyr_entries)}')

# ─── 3. TRIVIA ──────────────────────────────────────────────────────────
print('\nGenerating trivia_data.dart ...')
trivia_entries = []
for cat_key, cat_emoji in CATEGORIES:
    header = f'## {cat_emoji} — TRIVIA'
    block = section_between(content, header, ['## ', '# '])
    items = extract_numbered_lines(block)
    if not items:
        print(f'  WARNING: no TRIVIA items for {cat_key}')
    for item in items:
        # Parse "Q: ... A: ..."
        m = re.match(r'Q:\s*(.*?)\s*A:\s*(.*)', item)
        if m:
            q = m.group(1).strip().rstrip('?') + '?'
            q = q.replace('??', '?')
            a = m.group(2).strip()
            trivia_entries.append(f"    {{'q': '{escape_dart(q)}', 'a': '{escape_dart(a)}', 'category': '{cat_key}'}},")
        else:
            print(f'  WARNING: could not parse trivia: {item[:60]}')
    print(f'  {cat_key}: {len(items)} items')

trivia_dart = f"""/// Trivia question database
class TriviaData {{
  static const List<Map<String, String>> questions = [
    // -- PARTY STARTER --
{chr(10).join([e for e in trivia_entries if "'category': 'party_starter'" in e])}
    // -- MILD BUT WILD --
{chr(10).join([e for e in trivia_entries if "'category': 'mild_but_wild'" in e])}
    // -- FAMILY NIGHT --
{chr(10).join([e for e in trivia_entries if "'category': 'family_night'" in e])}
    // -- SPICE IT UP --
{chr(10).join([e for e in trivia_entries if "'category': 'spice_it_up'" in e])}
    // -- GIRLS NIGHT OUT --
{chr(10).join([e for e in trivia_entries if "'category': 'girls_night_out'" in e])}
    // -- GUYS UNLEASHED --
{chr(10).join([e for e in trivia_entries if "'category': 'guys_unleashed'" in e])}
  ];
}}
"""
with open(os.path.join(OUT_DIR, 'trivia_data.dart'), 'w', encoding='utf-8') as f:
    f.write(trivia_dart)
print(f'  Total TRIVIA entries: {len(trivia_entries)}')

# ─── 4. RANDOM ──────────────────────────────────────────────────────────
print('\nGenerating random_data.dart ...')
header = '# 📋 SECTION 5: RANDOM CHALLENGES'
block = section_between(content, header, ['# ', '---\n\n*End'])
items = extract_numbered_lines(block)
print(f'  Random challenges: {len(items)} items')

random_lines = []
for item in items:
    random_lines.append(f'    "{escape_dart(item)}",')

random_dart = f"""class RandomData {{
  static const List<String> challenges = [
{chr(10).join(random_lines)}
  ];
}}
"""
with open(os.path.join(OUT_DIR, 'random_data.dart'), 'w', encoding='utf-8') as f:
    f.write(random_dart)

print('\n✅ All 4 data files generated successfully!')
