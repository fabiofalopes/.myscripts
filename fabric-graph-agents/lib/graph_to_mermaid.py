#!/usr/bin/env python3
"""
Convert execution graph JSON to Mermaid diagram format.
Mermaid can be rendered in GitHub, VSCode, and many other tools.
"""

import json
import sys


def graph_to_mermaid(graph_json):
    """Convert graph JSON to Mermaid flowchart."""
    
    try:
        graph = json.loads(graph_json) if isinstance(graph_json, str) else graph_json
    except json.JSONDecodeError as e:
        return f"Error parsing JSON: {e}"
    
    mermaid = ["```mermaid", "graph TD"]
    
    # Add title
    strategy = graph.get('strategy', 'unknown')
    mermaid.append(f"    title[Strategy: {strategy}]")
    mermaid.append("    style title fill:#f9f,stroke:#333,stroke-width:2px")
    mermaid.append("")
    
    # Add nodes
    nodes = graph.get('graph', {}).get('nodes', [])
    for node in nodes:
        node_id = node['id']
        pattern = node['pattern']
        desc = node.get('description', '')
        
        # Create node with pattern name
        mermaid.append(f"    {node_id}[\"{pattern}<br/>{desc}\"]")
    
    mermaid.append("")
    
    # Add connections based on execution order
    execution_order = graph.get('graph', {}).get('execution_order', [])
    
    # Track previous group for connections
    prev_group = []
    
    for group_idx, group in enumerate(execution_order):
        current_group = [f"node-{n}" for n in group]
        
        if prev_group:
            # Connect previous group to current group
            for prev_node in prev_group:
                for curr_node in current_group:
                    mermaid.append(f"    {prev_node} --> {curr_node}")
        
        prev_group = current_group
    
    # Add input dimensions if available
    if nodes:
        first_node = nodes[0]
        input_dims = first_node.get('input_dimensions', [])
        if input_dims and not any('node-' in d for d in input_dims):
            mermaid.insert(3, "    input[Input Dimensions]")
            mermaid.insert(4, "    style input fill:#bbf,stroke:#333,stroke-width:2px")
            mermaid.insert(5, f"    input --> {first_node['id']}")
            mermaid.insert(6, "")
    
    # Add styling for parallel groups
    for group_idx, group in enumerate(execution_order):
        if len(group) > 1:
            # Highlight parallel nodes
            for node_num in group:
                node_id = f"node-{node_num}"
                mermaid.append(f"    style {node_id} fill:#bfb,stroke:#333,stroke-width:2px")
    
    mermaid.append("```")
    
    return "\n".join(mermaid)


def graph_to_graphviz(graph_json):
    """Convert graph JSON to Graphviz DOT format."""
    
    try:
        graph = json.loads(graph_json) if isinstance(graph_json, str) else graph_json
    except json.JSONDecodeError as e:
        return f"Error parsing JSON: {e}"
    
    dot = ["digraph ExecutionGraph {"]
    dot.append("    rankdir=TB;")
    dot.append("    node [shape=box, style=rounded];")
    dot.append("")
    
    # Add title
    strategy = graph.get('strategy', 'unknown')
    dot.append(f'    label="Strategy: {strategy}";')
    dot.append('    labelloc="t";')
    dot.append("")
    
    # Add nodes
    nodes = graph.get('graph', {}).get('nodes', [])
    for node in nodes:
        node_id = node['id'].replace('-', '_')
        pattern = node['pattern']
        desc = node.get('description', '')
        
        label = f"{pattern}\\n{desc}"
        dot.append(f'    {node_id} [label="{label}"];')
    
    dot.append("")
    
    # Add connections
    execution_order = graph.get('graph', {}).get('execution_order', [])
    prev_group = []
    
    for group in execution_order:
        current_group = [f"node_{n}" for n in group]
        
        if prev_group:
            for prev_node in prev_group:
                for curr_node in current_group:
                    dot.append(f"    {prev_node} -> {curr_node};")
        
        prev_group = current_group
    
    # Highlight parallel groups
    for group_idx, group in enumerate(execution_order):
        if len(group) > 1:
            dot.append(f"    {{ rank=same; {' '.join([f'node_{n}' for n in group])} }}")
    
    dot.append("}")
    
    return "\n".join(dot)


def main():
    """CLI interface."""
    if len(sys.argv) < 2:
        print("Usage: graph_to_mermaid.py <graph.json> [format]")
        print("")
        print("Formats:")
        print("  mermaid  - Mermaid diagram (default)")
        print("  dot      - Graphviz DOT format")
        print("")
        print("Examples:")
        print("  graph_to_mermaid.py output/run-*/graph.json")
        print("  graph_to_mermaid.py graph.json dot > graph.dot")
        sys.exit(1)
    
    graph_file = sys.argv[1]
    format_type = sys.argv[2] if len(sys.argv) > 2 else "mermaid"
    
    try:
        with open(graph_file, 'r') as f:
            graph_json = f.read()
    except FileNotFoundError:
        print(f"Error: File not found: {graph_file}")
        sys.exit(1)
    
    if format_type == "mermaid":
        print(graph_to_mermaid(graph_json))
    elif format_type == "dot":
        print(graph_to_graphviz(graph_json))
    else:
        print(f"Unknown format: {format_type}")
        sys.exit(1)


if __name__ == "__main__":
    main()
