"""
Cache management for video processing state

This module provides intelligent caching to:
- Prevent duplicate processing of the same video
- Enable incremental pattern additions
- Track processing history and token usage
- Provide foundation for bulk processing
"""

from pathlib import Path
import json
from datetime import datetime
from typing import Optional, Dict, List, Any
from dataclasses import dataclass, asdict


@dataclass
class ProcessingEvent:
    """Single processing event in history"""
    timestamp: str
    mode: str
    patterns_run: List[str]
    chunks_created: int
    api_calls: int
    tokens_used: int
    processing_time_seconds: float
    success: bool
    error: Optional[str] = None


@dataclass
class CacheEntry:
    """Complete cache entry for a video"""
    video_id: str
    video_url: str
    title: str
    upload_date: str
    duration_seconds: int
    transcript_word_count: int
    markdown_path: str
    last_updated: str
    patterns_run: List[str]
    processing_history: List[Dict[str, Any]]
    chunks: Optional[List[Dict[str, Any]]] = None  # Cached chunk info
    phase1_metadata: Optional[Dict[str, Any]] = None  # Global context
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'CacheEntry':
        """Create CacheEntry from dict"""
        return cls(**data)
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dict for JSON serialization"""
        return asdict(self)


class CacheManager:
    """Manages video processing cache"""
    
    def __init__(self, cache_dir: Path):
        """Initialize cache manager
        
        Args:
            cache_dir: Directory for cache files (e.g., $OBSVAULT/youtube/.cache)
        """
        self.cache_dir = Path(cache_dir).expanduser()
        self.cache_dir.mkdir(parents=True, exist_ok=True)
        self.index_file = self.cache_dir / "index.json"
        self._load_index()
    
    def exists(self, video_id: str) -> bool:
        """Check if video already processed
        
        Args:
            video_id: YouTube video ID
            
        Returns:
            True if cache entry exists
        """
        return video_id in self.index.get('videos', {})
    
    def get_cache(self, video_id: str) -> Optional[CacheEntry]:
        """Load cache entry for video
        
        Args:
            video_id: YouTube video ID
            
        Returns:
            CacheEntry if exists, None otherwise
        """
        if not self.exists(video_id):
            return None
        
        cache_file = self.cache_dir / f"{video_id}.json"
        try:
            with open(cache_file) as f:
                data = json.load(f)
            return CacheEntry.from_dict(data)
        except (FileNotFoundError, json.JSONDecodeError) as e:
            print(f"⚠️  Warning: Failed to load cache for {video_id}: {e}")
            # Invalidate corrupt cache
            self.invalidate(video_id)
            return None
    
    def save_cache(self, video_id: str, entry: CacheEntry) -> None:
        """Save cache entry
        
        Args:
            video_id: YouTube video ID
            entry: CacheEntry to save
        """
        cache_file = self.cache_dir / f"{video_id}.json"
        
        # Save individual cache file
        with open(cache_file, 'w') as f:
            json.dump(entry.to_dict(), f, indent=2)
        
        # Update index
        if 'videos' not in self.index:
            self.index['videos'] = {}
        
        self.index['videos'][video_id] = {
            'title': entry.title,
            'markdown_path': entry.markdown_path,
            'last_processed': entry.last_updated,
            'patterns_count': len(entry.patterns_run)
        }
        self._save_index()
    
    def get_note_path(self, video_id: str) -> Optional[str]:
        """Get markdown note path for video
        
        Args:
            video_id: YouTube video ID
            
        Returns:
            Path to markdown note, or None if not found
        """
        cache = self.get_cache(video_id)
        return cache.markdown_path if cache else None
    
    def get_patterns_run(self, video_id: str) -> List[str]:
        """Get patterns already run on video
        
        Args:
            video_id: YouTube video ID
            
        Returns:
            List of pattern names
        """
        cache = self.get_cache(video_id)
        return cache.patterns_run if cache else []
    
    def append_patterns(self, video_id: str, new_patterns: List[str]) -> None:
        """Append new patterns to cache
        
        Args:
            video_id: YouTube video ID
            new_patterns: List of new pattern names
        """
        cache = self.get_cache(video_id)
        if not cache:
            return
        
        # Add new patterns
        cache.patterns_run.extend(new_patterns)
        cache.last_updated = datetime.now().isoformat()
        
        # Add to processing history
        cache.processing_history.append({
            'timestamp': cache.last_updated,
            'mode': 'append',
            'patterns_appended': new_patterns,
            'success': True
        })
        
        self.save_cache(video_id, cache)
    
    def invalidate(self, video_id: str) -> None:
        """Delete cache for video
        
        Args:
            video_id: YouTube video ID
        """
        cache_file = self.cache_dir / f"{video_id}.json"
        if cache_file.exists():
            cache_file.unlink()
        
        if video_id in self.index.get('videos', {}):
            del self.index['videos'][video_id]
            self._save_index()
    
    def list_all(self) -> List[Dict[str, Any]]:
        """List all cached videos
        
        Returns:
            List of video info dicts
        """
        return list(self.index.get('videos', {}).items())
    
    def get_statistics(self) -> Dict[str, Any]:
        """Get cache statistics
        
        Returns:
            Dict with total videos, patterns, tokens, etc.
        """
        total_videos = len(self.index.get('videos', {}))
        total_patterns = 0
        total_tokens = 0
        
        for video_id in self.index.get('videos', {}).keys():
            cache = self.get_cache(video_id)
            if cache:
                total_patterns += len(cache.patterns_run)
                for event in cache.processing_history:
                    total_tokens += event.get('tokens_used', 0)
        
        return {
            'total_videos': total_videos,
            'total_patterns': total_patterns,
            'total_tokens_used': total_tokens,
            'cache_directory': str(self.cache_dir)
        }
    
    def _load_index(self) -> None:
        """Load index file"""
        if self.index_file.exists():
            try:
                with open(self.index_file) as f:
                    self.index = json.load(f)
            except json.JSONDecodeError:
                print("⚠️  Warning: Corrupt index file, creating new one")
                self._create_new_index()
        else:
            self._create_new_index()
    
    def _create_new_index(self) -> None:
        """Create new index"""
        self.index = {
            'version': '3.0',
            'created': datetime.now().isoformat(),
            'last_updated': datetime.now().isoformat(),
            'videos': {}
        }
    
    def _save_index(self) -> None:
        """Save index file"""
        self.index['last_updated'] = datetime.now().isoformat()
        with open(self.index_file, 'w') as f:
            json.dump(self.index, f, indent=2)
