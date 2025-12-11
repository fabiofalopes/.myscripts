"""Enriched packet builder for context-aware Fabric processing.

This module creates "enriched packets" - chunks of content wrapped with
contextual metadata that helps AI models understand position and broader
context when processing segments of longer content.
"""

from dataclasses import dataclass
from typing import Tuple, Optional


@dataclass
class EnrichedPacket:
    """Context-enriched chunk for Fabric AI processing.
    
    An enriched packet contains a chunk of transcript plus metadata about:
    - Global context (video title, summary, key topics)
    - Position in sequence (beginning/middle/end)
    - Temporal context (timestamp range)
    
    The packet can generate a Fabric-compatible input string that includes
    a preamble with this context, followed by the actual content.
    
    Attributes:
        video_title: Title of the video/content
        video_summary: 1-2 sentence overview of full content
        key_topics: Comma-separated list of main topics/entities
        chunk_id: Unique identifier (e.g., "chunk_001")
        chunk_index: Zero-based index in sequence
        total_chunks: Total number of chunks in sequence
        position: Position category ("single", "beginning", "middle", "end")
        timestamp_range: Tuple of (start_time, end_time) as HH:MM:SS strings
        transcript_segment: The actual chunk text content
        token_count: Number of tokens in transcript_segment
    """
    
    # Global context metadata
    video_title: str
    video_summary: str
    key_topics: str
    
    # Chunk metadata
    chunk_id: str
    chunk_index: int
    total_chunks: int
    position: str
    timestamp_range: Tuple[str, str]
    
    # Content
    transcript_segment: str
    token_count: int = 0
    
    def to_fabric_input(self) -> str:
        """Format packet as Fabric-compatible input.
        
        Generates a complete input string with:
        1. Contextual preamble (metadata)
        2. Content separator
        3. Actual transcript segment
        
        This string is meant to be passed to fabric-ai via stdin after
        the pattern's system prompt.
        
        Returns:
            str: Complete input string ready for Fabric processing
        """
        preamble = self._generate_preamble()
        return f"{preamble}\n\n{self.transcript_segment}"
    
    def _generate_preamble(self) -> str:
        """Generate contextual preamble header.
        
        Creates a structured metadata block that provides:
        - CONTENT CONTEXT: Overall video information
        - CHUNK INFORMATION: Position and temporal details
        
        Returns:
            str: Markdown-formatted preamble
        """
        position_note = self._get_position_note()
        
        # Format chunk position display
        chunk_display = f"chunk {self.chunk_index + 1} of {self.total_chunks}"
        
        return f"""---
CONTENT CONTEXT:
- Source: {self.video_title}
- Overview: {self.video_summary}
- Key Topics: {self.key_topics}

CHUNK INFORMATION:
- Position: {self.position} ({chunk_display})
- Timestamp Range: {self.timestamp_range[0]} - {self.timestamp_range[1]}
- Processing Note: {position_note}

---"""
    
    def _get_position_note(self) -> str:
        """Generate position-specific processing instruction.
        
        Provides guidance to the AI model on how to approach this chunk
        based on its position in the sequence.
        
        Returns:
            str: Position-appropriate processing note
        """
        notes = {
            "single": (
                "This is the complete content. Analyze comprehensively."
            ),
            
            "beginning": (
                "This is the opening segment. Focus on introductions, setup, "
                "and initial themes. Establish context for what follows."
            ),
            
            "middle": (
                "This is a middle segment continuing from previous content. "
                "Focus on development, details, and progression of established themes."
            ),
            
            "end": (
                "This is the final segment concluding previous content. "
                "Focus on conclusions, resolutions, and final takeaways."
            )
        }
        
        return notes.get(self.position, notes["middle"])


def determine_position(chunk_index: int, total_chunks: int) -> str:
    """Determine position category for a chunk.
    
    Logic:
    - If only 1 chunk total: "single"
    - First chunk of multi-chunk: "beginning"
    - Last chunk of multi-chunk: "end"
    - Any middle chunk: "middle"
    
    Args:
        chunk_index: Zero-based index of current chunk
        total_chunks: Total number of chunks
    
    Returns:
        str: Position category ("single", "beginning", "middle", "end")
    
    Examples:
        >>> determine_position(0, 1)
        'single'
        >>> determine_position(0, 3)
        'beginning'
        >>> determine_position(1, 3)
        'middle'
        >>> determine_position(2, 3)
        'end'
    """
    if total_chunks == 1:
        return "single"
    elif chunk_index == 0:
        return "beginning"
    elif chunk_index == total_chunks - 1:
        return "end"
    else:
        return "middle"


def create_packet(
    video_title: str,
    video_summary: str,
    key_topics: str,
    chunk_id: str,
    chunk_index: int,
    total_chunks: int,
    timestamp_range: Tuple[str, str],
    transcript_segment: str,
    token_count: Optional[int] = None
) -> EnrichedPacket:
    """Factory function to create an enriched packet.
    
    Convenience function that handles position determination and
    provides a clean interface for packet creation.
    
    Args:
        video_title: Title of video/content
        video_summary: Brief 1-2 sentence overview
        key_topics: Comma-separated topics
        chunk_id: Unique identifier (e.g., "chunk_001")
        chunk_index: Zero-based chunk index
        total_chunks: Total chunk count
        timestamp_range: (start, end) timestamps as HH:MM:SS
        transcript_segment: Actual text content
        token_count: Optional pre-calculated token count
    
    Returns:
        EnrichedPacket: Configured packet ready for Fabric processing
    """
    position = determine_position(chunk_index, total_chunks)
    
    # Use provided token count or default to 0
    # (token counting will be done by chunker module)
    final_token_count = token_count if token_count is not None else 0
    
    return EnrichedPacket(
        video_title=video_title,
        video_summary=video_summary,
        key_topics=key_topics,
        chunk_id=chunk_id,
        chunk_index=chunk_index,
        total_chunks=total_chunks,
        position=position,
        timestamp_range=timestamp_range,
        transcript_segment=transcript_segment,
        token_count=final_token_count
    )
