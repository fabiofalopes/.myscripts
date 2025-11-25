#!/usr/bin/env python3
"""
Graph planning utilities for fabric pattern orchestration.
Determines optimal execution strategies based on dimensions.
"""

import json
import sys
from typing import Dict, List, Any


def classify_goal(goal: str) -> str:
    """
    Classify the goal type.
    
    Args:
        goal: Goal description
        
    Returns:
        Goal type: 'security-assessment', 'threat-analysis', 'research', 
                   'configuration', 'wisdom', or 'comprehensive'
    """
    goal_lower = goal.lower()
    
    if any(word in goal_lower for word in ['secure', 'safety', 'protected', 'hardened']):
        if 'how' in goal_lower or 'what' in goal_lower:
            return 'security-assessment'
        else:
            return 'configuration'
    
    elif any(word in goal_lower for word in ['threat', 'attack', 'exploit', 'vulnerability']):
        if 'research' in goal_lower or 'find' in goal_lower or 'search' in goal_lower:
            return 'research'
        else:
            return 'threat-analysis'
    
    elif any(word in goal_lower for word in ['config', 'setup', 'validate', 'check']):
        return 'configuration'
    
    elif any(word in goal_lower for word in ['learn', 'understand', 'explain', 'what is']):
        return 'wisdom'
    
    elif any(word in goal_lower for word in ['everything', 'complete', 'full', 'comprehensive']):
        return 'comprehensive'
    
    else:
        return 'wisdom'


def select_strategy(dimensions: List[Dict], goal_type: str, depth: str) -> str:
    """
    Select execution strategy based on dimensions and goal.
    
    Args:
        dimensions: List of dimension metadata
        goal_type: Type of goal
        depth: Depth level ('quick', 'normal', 'deep')
        
    Returns:
        Strategy name
    """
    dim_count = len(dimensions)
    
    # Single dimension - sequential enrichment
    if dim_count == 1:
        return 'sequential_enrichment'
    
    # Multiple similar dimensions - parallel diverge-merge
    if dim_count > 1:
        types = [d.get('type', 'cognitive') for d in dimensions]
        if len(set(types)) == 1:
            return 'parallel_diverge_merge'
    
    # Multiple different dimensions - conditional branching
    if dim_count > 1:
        types = [d.get('type', 'cognitive') for d in dimensions]
        if len(set(types)) > 1:
            return 'conditional_branching'
    
    # Deep analysis - iterative refinement
    if depth == 'deep':
        return 'iterative_refinement'
    
    # Default
    return 'sequential_enrichment'


def select_patterns(dimension: Dict, goal_type: str) -> List[str]:
    """
    Select appropriate patterns for a dimension and goal.
    
    Args:
        dimension: Dimension metadata
        goal_type: Type of goal
        
    Returns:
        List of pattern names
    """
    dim_type = dimension.get('type', 'cognitive')
    
    patterns = []
    
    # Technical dimensions
    if dim_type == 'technical':
        if goal_type == 'security-assessment':
            patterns = ['ask_secure_by_design_questions', 'analyze_risk']
        elif goal_type == 'threat-analysis':
            patterns = ['analyze_threat_report', 'create_stride_threat_model']
        elif goal_type == 'configuration':
            patterns = ['ask_secure_by_design_questions', 'analyze_risk', 'create_report_finding']
        elif goal_type == 'research':
            patterns = ['search_query_generator', 'deep_search_optimizer']
        else:
            patterns = ['extract_wisdom', 'extract_insights']
    
    # Affective dimensions
    elif dim_type == 'affective':
        patterns = ['extract_insights', 'improve_prompt']
    
    # Cognitive dimensions
    else:
        if goal_type == 'research':
            patterns = ['search_query_generator', 'search_refiner']
        else:
            patterns = ['extract_questions', 'improve_prompt']
    
    return patterns


def build_execution_graph(dimensions: List[Dict], goal: str, depth: str = 'normal') -> Dict:
    """
    Build complete execution graph.
    
    Args:
        dimensions: List of dimension metadata
        goal: Goal description
        depth: Depth level
        
    Returns:
        Execution graph JSON
    """
    goal_type = classify_goal(goal)
    strategy = select_strategy(dimensions, goal_type, depth)
    
    nodes = []
    execution_order = []
    node_id = 1
    
    if strategy == 'sequential_enrichment':
        # Sequential chain
        patterns = select_patterns(dimensions[0], goal_type)
        prev_node = None
        
        for pattern in patterns:
            node = {
                'id': f'node-{node_id}',
                'pattern': pattern,
                'input_dimensions': [dimensions[0]['id']] if prev_node is None else [prev_node],
                'parallel_group': node_id,
                'description': f'Apply {pattern}'
            }
            nodes.append(node)
            execution_order.append([node_id])
            prev_node = f'node-{node_id}'
            node_id += 1
    
    elif strategy == 'parallel_diverge_merge':
        # Parallel processing with merge
        pattern = select_patterns(dimensions[0], goal_type)[0]
        parallel_group = []
        
        for dim in dimensions:
            node = {
                'id': f'node-{node_id}',
                'pattern': pattern,
                'input_dimensions': [dim['id']],
                'parallel_group': 1,
                'description': f'Process {dim["filename"]}'
            }
            nodes.append(node)
            parallel_group.append(node_id)
            node_id += 1
        
        execution_order.append(parallel_group)
        
        # Synthesis node
        synthesis_node = {
            'id': f'node-{node_id}',
            'pattern': 'extract_recommendations',
            'input_dimensions': [f'node-{i}' for i in parallel_group],
            'parallel_group': 2,
            'description': 'Synthesize results'
        }
        nodes.append(synthesis_node)
        execution_order.append([node_id])
    
    elif strategy == 'conditional_branching':
        # Different patterns per dimension type
        parallel_group = []
        
        for dim in dimensions:
            patterns = select_patterns(dim, goal_type)
            pattern = patterns[0] if patterns else 'extract_wisdom'
            
            node = {
                'id': f'node-{node_id}',
                'pattern': pattern,
                'input_dimensions': [dim['id']],
                'parallel_group': 1,
                'description': f'Process {dim["type"]} dimension'
            }
            nodes.append(node)
            parallel_group.append(node_id)
            node_id += 1
        
        execution_order.append(parallel_group)
        
        # Synthesis
        synthesis_node = {
            'id': f'node-{node_id}',
            'pattern': 'extract_recommendations',
            'input_dimensions': [f'node-{i}' for i in parallel_group],
            'parallel_group': 2,
            'description': 'Synthesize results'
        }
        nodes.append(synthesis_node)
        execution_order.append([node_id])
    
    # Estimate execution time
    estimated_time = len(nodes) * 15  # 15 seconds per node average
    if strategy in ['parallel_diverge_merge', 'conditional_branching']:
        estimated_time = estimated_time // 2  # Parallel execution
    
    return {
        'strategy': strategy,
        'reasoning': f'Selected {strategy} for {len(dimensions)} {goal_type} dimension(s)',
        'graph': {
            'nodes': nodes,
            'execution_order': execution_order
        },
        'estimated_time_seconds': estimated_time,
        'quality_gates': [
            {
                'after_node': nodes[-1]['id'],
                'threshold': 80,
                'action_if_fail': 'refine_input'
            }
        ]
    }


def main():
    """CLI interface for graph planning."""
    if len(sys.argv) < 2:
        print("Usage: graph_planner.py <command> [args...]")
        print("\nCommands:")
        print("  classify <goal>                    - Classify goal type")
        print("  strategy <dimensions_json> <goal>  - Select strategy")
        print("  plan <dimensions_json> <goal>      - Build execution graph")
        sys.exit(1)
    
    command = sys.argv[1]
    
    if command == 'classify':
        goal = sys.argv[2] if len(sys.argv) > 2 else sys.stdin.read()
        goal_type = classify_goal(goal)
        print(json.dumps({'goal_type': goal_type}, indent=2))
    
    elif command == 'strategy':
        dimensions_json = sys.argv[2] if len(sys.argv) > 2 else sys.stdin.read()
        goal = sys.argv[3] if len(sys.argv) > 3 else 'analyze'
        
        dimensions = json.loads(dimensions_json)
        goal_type = classify_goal(goal)
        strategy = select_strategy(dimensions, goal_type, 'normal')
        
        print(json.dumps({'strategy': strategy}, indent=2))
    
    elif command == 'plan':
        dimensions_json = sys.argv[2] if len(sys.argv) > 2 else sys.stdin.read()
        goal = sys.argv[3] if len(sys.argv) > 3 else 'analyze'
        depth = sys.argv[4] if len(sys.argv) > 4 else 'normal'
        
        dimensions = json.loads(dimensions_json)
        graph = build_execution_graph(dimensions, goal, depth)
        
        print(json.dumps(graph, indent=2))
    
    else:
        print(f"Unknown command: {command}")
        sys.exit(1)


if __name__ == "__main__":
    main()
