# extract-components.jq
# Extracts potential component identifiers from the analysis JSON
# Usage: jq -r -f extract-components.jq input.json

# Function to clean and validate component strings
def clean_component:
  sub("^\\s+"; "") | sub("\\s+$"; "") |  # Trim whitespace
  sub("^['\"]"; "") | sub("['\"]$"; "") | # Remove surrounding quotes if any remain
  select(length >= 2) |                   # Too short
  select(length <= 50) |                  # Too long
  select(test("[A-Za-z0-9]")) |           # Must contain at least one alphanumeric
  select(test("^[^=<>{}]+$")) |           # Filter out likely code/json syntax
  select(test("^http") | not) |           # Filter out URLs
  select(["FILE NOT FOUND", "ERROR", "CODE", "MESSAGE", "TYPE", "NOT_FOUND_ERROR", "1 2 3 4"] | index(.) | not); # Blacklist

# Main extraction logic
. as $root |
[
  # 1. Extract from backticks (common in ocr.expert)
  (($root.ocr.expert // "") + "\n" + ($root.description // "")) | scan("`([^`]+)`")[],
  
  # 2. Extract from quotes (common in ocr.multi_scale)
  ($root.ocr.multi_scale // "") | scan("\"([^\"]+)\"")[],
  
  # 3. Extract from code blocks in description (lines that look like components)
  (
    ($root.description // "") | 
    split("\n") | 
    .[] | 
    select(test("^[A-Z0-9][A-Z0-9\\-\\.\\s]+$"))
  )
] | 
flatten | 
map(clean_component) | 
unique | 
.[]
