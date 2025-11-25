#!/usr/bin/env python3
"""
Semantic analysis utilities for fabric graph agents.
Provides text analysis, similarity scoring, and semantic clustering.
"""

import json
import re
import sys
from typing import Dict, List, Set, Tuple
from collections import Counter


def extract_keywords(text: str, top_n: int = 10) -> List[str]:
    """
    Extract top keywords from text using frequency analysis.
    
    Args:
        text: Input text
        top_n: Number of top keywords to return
        
    Returns:
        List of top keywords
    """
    # Remove common stop words
    stop_words = {
        'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for',
        'of', 'with', 'by', 'from', 'as', 'is', 'was', 'are', 'were', 'be',
        'been', 'being', 'have', 'has', 'had', 'do', 'does', 'did', 'will',
        'would', 'should', 'could', 'may', 'might', 'must', 'can', 'this',
        'that', 'these', 'those', 'i', 'you', 'he', 'she', 'it', 'we', 'they'
    }
    
    # Tokenize and clean
    words = re.findall(r'\b[a-z]{3,}\b', text.lower())
    words = [w for w in words if w not in stop_words]
    
    # Count frequencies
    counter = Counter(words)
    
    return [word for word, _ in counter.most_common(top_n)]


def calculate_similarity(text1: str, text2: str) -> float:
    """
    Calculate semantic similarity between two texts using word overlap.
    
    Args:
        text1: First text
        text2: Second text
        
    Returns:
        Similarity score (0-100)
    """
    # Extract keywords from both texts
    keywords1 = set(extract_keywords(text1, 20))
    keywords2 = set(extract_keywords(text2, 20))
    
    if not keywords1 or not keywords2:
        return 0.0
    
    # Calculate Jaccard similarity
    intersection = len(keywords1 & keywords2)
    union = len(keywords1 | keywords2)
    
    similarity = (intersection / union) * 100 if union > 0 else 0.0
    
    return round(similarity, 2)


def detect_semantic_type(text: str) -> str:
    """
    Detect semantic type of text (technical, affective, cognitive).
    
    Args:
        text: Input text
        
    Returns:
        Semantic type: 'technical', 'affective', or 'cognitive'
    """
    text_lower = text.lower()
    
    # Technical indicators
    technical_patterns = [
        r'\b(configure|install|setup|command|script|code|api|protocol)\b',
        r'\b(wpa[23]|ssh|firewall|vlan|802\.11|ip|port)\b',
        r'\b(uci|opkg|iptables|wireless|network)\b',
        r'`[^`]+`',  # Code blocks
    ]
    
    # Affective indicators
    affective_patterns = [
        r'\b(worried|concerned|anxious|frustrated|confused|uncertain)\b',
        r'\b(hope|wish|want|need|fear|worry)\b',
        r'\b(difficult|hard|easy|simple|complex|complicated)\b',
        r'\b(feel|think|believe|wonder|question)\b',
    ]
    
    # Cognitive indicators
    cognitive_patterns = [
        r'\b(understand|learn|know|figure out|determine|decide)\b',
        r'\b(why|how|what|when|where|which)\b',
        r'\b(problem|solution|approach|strategy|method)\b',
        r'\b(consider|evaluate|analyze|assess|review)\b',
    ]
    
    # Count matches
    technical_score = sum(len(re.findall(p, text_lower)) for p in technical_patterns)
    affective_score = sum(len(re.findall(p, text_lower)) for p in affective_patterns)
    cognitive_score = sum(len(re.findall(p, text_lower)) for p in cognitive_patterns)
    
    # Determine type
    scores = {
        'technical': technical_score,
        'affective': affective_score,
        'cognitive': cognitive_score
    }
    
    return max(scores, key=scores.get) if max(scores.values()) > 0 else 'cognitive'


def cluster_by_similarity(texts: List[str], threshold: float = 50.0) -> List[List[int]]:
    """
    Cluster texts by semantic similarity.
    
    Args:
        texts: List of texts to cluster
        threshold: Similarity threshold for clustering (0-100)
        
    Returns:
        List of clusters (each cluster is a list of text indices)
    """
    n = len(texts)
    clusters = []
    assigned = set()
    
    for i in range(n):
        if i in assigned:
            continue
            
        cluster = [i]
        assigned.add(i)
        
        for j in range(i + 1, n):
            if j in assigned:
                continue
                
            similarity = calculate_similarity(texts[i], texts[j])
            if similarity >= threshold:
                cluster.append(j)
                assigned.add(j)
        
        clusters.append(cluster)
    
    return clusters


def extract_entities(text: str) -> Dict[str, List[str]]:
    """
    Extract named entities from text (hardware, software, protocols).
    
    Args:
        text: Input text
        
    Returns:
        Dictionary of entity types and their values
    """
    entities = {
        'hardware': [],
        'software': [],
        'protocols': [],
        'ip_addresses': [],
        'commands': []
    }
    
    # Hardware patterns
    hardware_patterns = [
        r'\b(atheros|ar\d+|broadcom|bcm\d+|qualcomm|qca\d+)\b',
        r'\b(ubiquiti|tp-link|netgear|asus|linksys)\b',
        r'\b(router|ap|access point|switch|modem)\b',
    ]
    
    # Software patterns
    software_patterns = [
        r'\b(openwrt|dd-wrt|tomato|lede)\b',
        r'\b(dropbear|openssh|dnsmasq|hostapd)\b',
        r'\b(suricata|zeek|snort)\b',
    ]
    
    # Protocol patterns
    protocol_patterns = [
        r'\b(wpa[23]?|wep|802\.11[a-z]*)\b',
        r'\b(ssh|http|https|ftp|telnet|smtp)\b',
        r'\b(tcp|udp|icmp|arp)\b',
    ]
    
    # IP addresses
    ip_pattern = r'\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b'
    
    # Commands (in backticks or after $)
    command_pattern = r'`([^`]+)`|\$\s*([^\n]+)'
    
    text_lower = text.lower()
    
    # Extract entities
    for pattern in hardware_patterns:
        entities['hardware'].extend(re.findall(pattern, text_lower, re.IGNORECASE))
    
    for pattern in software_patterns:
        entities['software'].extend(re.findall(pattern, text_lower, re.IGNORECASE))
    
    for pattern in protocol_patterns:
        entities['protocols'].extend(re.findall(pattern, text_lower, re.IGNORECASE))
    
    entities['ip_addresses'] = re.findall(ip_pattern, text)
    
    commands = re.findall(command_pattern, text)
    entities['commands'] = [c[0] or c[1] for c in commands if c[0] or c[1]]
    
    # Remove duplicates and empty strings
    for key in entities:
        entities[key] = list(set(filter(None, entities[key])))
    
    return entities


def analyze_text_structure(text: str) -> Dict[str, any]:
    """
    Analyze text structure (sections, lists, code blocks).
    
    Args:
        text: Input text
        
    Returns:
        Dictionary with structure analysis
    """
    return {
        'word_count': len(text.split()),
        'line_count': len(text.split('\n')),
        'header_count': text.count('#'),
        'list_item_count': text.count('-') + text.count('*'),
        'code_block_count': text.count('```') // 2,
        'has_questions': '?' in text,
        'has_commands': '`' in text or '$' in text,
        'avg_sentence_length': len(text.split()) / max(1, text.count('.') + text.count('!') + text.count('?'))
    }


def main():
    """CLI interface for semantic analysis."""
    if len(sys.argv) < 2:
        print("Usage: semantic.py <command> [args...]")
        print("\nCommands:")
        print("  keywords <text>              - Extract keywords")
        print("  similarity <text1> <text2>   - Calculate similarity")
        print("  type <text>                  - Detect semantic type")
        print("  entities <text>              - Extract entities")
        print("  structure <text>             - Analyze structure")
        sys.exit(1)
    
    command = sys.argv[1]
    
    if command == 'keywords':
        text = sys.argv[2] if len(sys.argv) > 2 else sys.stdin.read()
        keywords = extract_keywords(text)
        print(json.dumps(keywords, indent=2))
    
    elif command == 'similarity':
        text1 = sys.argv[2] if len(sys.argv) > 2 else ""
        text2 = sys.argv[3] if len(sys.argv) > 3 else ""
        similarity = calculate_similarity(text1, text2)
        print(json.dumps({"similarity": similarity}, indent=2))
    
    elif command == 'type':
        text = sys.argv[2] if len(sys.argv) > 2 else sys.stdin.read()
        semantic_type = detect_semantic_type(text)
        print(json.dumps({"type": semantic_type}, indent=2))
    
    elif command == 'entities':
        text = sys.argv[2] if len(sys.argv) > 2 else sys.stdin.read()
        entities = extract_entities(text)
        print(json.dumps(entities, indent=2))
    
    elif command == 'structure':
        text = sys.argv[2] if len(sys.argv) > 2 else sys.stdin.read()
        structure = analyze_text_structure(text)
        print(json.dumps(structure, indent=2))
    
    else:
        print(f"Unknown command: {command}")
        sys.exit(1)


if __name__ == "__main__":
    main()
