#!/bin/bash

# Check if a URL was provided as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 [--comments-only] <reddit_thread_url>"
  exit 1
fi

COMMENTS_ONLY="false"
if [ "$1" == "--comments-only" ] || [ "$1" == "-c" ]; then
  COMMENTS_ONLY="true"
  shift
fi

if [ -z "$1" ]; then
  echo "Usage: $0 [--comments-only] <reddit_thread_url>"
  exit 1
fi

URL=$1

# Strip query parameters (anything after ?)
URL_NO_QUERY="${URL%%\?*}"

# Strip trailing slash if present
URL_NO_SLASH="${URL_NO_QUERY%/}"

# Ensure the URL ends with .json for the API endpoint
JSON_URL="${URL_NO_SLASH}.json"

export COMMENTS_ONLY

# Create a temporary Python script to avoid quote escaping issues
cat > /tmp/reddit_parser.py << 'EOF'
import json
import sys
import datetime

def format_comment(comment, level=0):
    data = comment.get('data', {})
    if not data:
        return ''
    body = data.get('body', '[deleted]')
    author = data.get('author', '[deleted]')
    score = data.get('score', 0)
    indent = '    ' * level 
    md = f'{indent}- **{author}** (*Score: {score}*):\n'
    md += f'{indent}  > {body.replace(chr(10), chr(10) + indent + "  > ")}\n\n'
    replies = data.get('replies')
    if replies and isinstance(replies, dict) and 'data' in replies:
        for reply in replies['data']['children']:
            if reply['kind'] == 't1':
                md += format_comment(reply, level + 1)
    return md

try:
    full_data = json.load(sys.stdin)
    post_data = full_data[0]['data']['children'][0]['data']
    comments_data = full_data[1]['data']['children']
    
    import os
    comments_only = os.getenv('COMMENTS_ONLY', 'false') == 'true'
    
    if comments_only:
        markdown_output = '## Comments\n\n'
        for comment in comments_data:
            if comment['kind'] == 't1':
                markdown_output += format_comment(comment)
    else:
        # Format creation date from UTC timestamp
        created_utc = post_data.get('created_utc', 0)
        if created_utc:
            created_date = datetime.datetime.fromtimestamp(created_utc).strftime('%Y-%m-%d %H:%M:%S UTC')
        else:
            created_date = 'Unknown'
        
        # Get current date for scraping timestamp
        scraped_date = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC')
        
        # Build metadata header
        subreddit_name = post_data.get('subreddit', '')
        title = post_data.get('title', '').replace('|', '\\|')
        
        metadata = f"""---
title: {title}
source: Reddit
url: {post_data.get('url', '')}
subreddit: r/{subreddit_name}
author: /u/{post_data.get('author', '')}
score: {post_data.get('score', 0)}
comments: {post_data.get('num_comments', 0)}
created_utc: {created_utc}
date_created: {created_date}
scraped_date: {scraped_date}
tags: ["reddit", "{subreddit_name}"]
---

"""
        
        markdown_output = metadata
        markdown_output += f'# {post_data["title"]}\n'
        markdown_output += f'**Author:** /u/{post_data["author"]} | **Subreddit:** r/{post_data["subreddit"]} | **Score:** {post_data["score"]} | **Comments:** {post_data["num_comments"]}\n\n'
        if post_data.get('selftext'):
            markdown_output += f'{post_data["selftext"]}\n\n'
        markdown_output += '---\n## Comments\n\n'
        for comment in comments_data:
            if comment['kind'] == 't1':
                markdown_output += format_comment(comment)
    print(markdown_output)
except (json.JSONDecodeError, IndexError) as e:
    sys.stderr.write(f'Error: Failed to parse Reddit JSON data. {e}\n')
EOF

# Fetch the JSON data using curl with a custom User-Agent
# The output is piped directly to the Python script for processing
curl -s -A "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" "$JSON_URL" | python3 /tmp/reddit_parser.py

# Clean up temporary file
rm -f /tmp/reddit_parser.py

