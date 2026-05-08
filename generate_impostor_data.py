import re
import os

MD_FILE = os.path.join(os.path.dirname(__file__), 'remixed-662bd0ea.md')
OUT_DIR = os.path.join(os.path.dirname(__file__), 'lib', 'core', 'constants')

if not os.path.exists(OUT_DIR):
    os.makedirs(OUT_DIR)

with open(MD_FILE, 'r', encoding='utf-8') as f:
    content = f.read()

def escape_dart(s):
    return s.replace('\\', '\\\\').replace("'", "\\'")

# Find all categories
category_matches = list(re.finditer(r'# .*CATEGORY \d+: (.*)', content))
categories = []

for i, match in enumerate(category_matches):
    cat_title = match.group(1).strip()
    
    start_idx = match.end()
    end_idx = category_matches[i+1].start() if i + 1 < len(category_matches) else len(content)
    
    block = content[start_idx:end_idx]
    
    # Extract numbered lines
    words = []
    for line in block.splitlines():
        line = line.strip()
        m = re.match(r'^\d+\.\s+(.*)', line)
        if m:
            words.append(m.group(1).strip())
            
    if words:
        categories.append((cat_title, words))

print(f"Found {len(categories)} categories.")

dart_code = "/// Impostor Mode word database\n"
dart_code += "class ImpostorData {\n"
dart_code += "  static const Map<String, List<String>> categories = {\n"

for cat_title, words in categories:
    dart_code += f"    '{escape_dart(cat_title)}': [\n"
    for w in words:
        dart_code += f"      '{escape_dart(w)}',\n"
    dart_code += "    ],\n"
    print(f"  {cat_title}: {len(words)} words")

dart_code += "  };\n"
dart_code += "}\n"

with open(os.path.join(OUT_DIR, 'impostor_data.dart'), 'w', encoding='utf-8') as f:
    f.write(dart_code)

print("✅ impostor_data.dart generated successfully!")
