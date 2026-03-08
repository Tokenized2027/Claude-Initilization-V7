#!/usr/bin/env python3
"""
Claude API Wrapper with Prompt Caching (Python)

This script demonstrates how to call Claude's API with prompt caching enabled.
Use this as a template for building your own cached API wrappers.

Usage:
    python claude_cached_api.py "Your prompt here"
    python claude_cached_api.py "Your prompt" --agent frontend
    python claude_cached_api.py "Debug API" --agent backend --no-brief

Requirements:
    pip install anthropic
    export ANTHROPIC_API_KEY=your_key_here
"""

import os
import sys
import argparse
from pathlib import Path
from anthropic import Anthropic

# ============================================================================
# Configuration
# ============================================================================

AGENT_PROMPTS = {
    'shared': '~/ai-dev-team/01-shared-context.md',
    'architect': '~/ai-dev-team/03-system-architect.md',
    'pm': '~/ai-dev-team/04-product-manager.md',
    'designer': '~/ai-dev-team/05-designer.md',
    'api-architect': '~/ai-dev-team/06-api-architect.md',
    'frontend': '~/ai-dev-team/07-frontend-developer.md',
    'backend': '~/ai-dev-team/08-backend-developer.md',
    'security': '~/ai-dev-team/09-security-auditor.md',
    'tester': '~/ai-dev-team/10-system-tester.md',
    'devops': '~/ai-dev-team/11-devops-engineer.md',
    'writer': '~/ai-dev-team/12-technical-writer.md'
}

PROJECT_BRIEF = '~/ai-dev-team/project-briefs/current-project.md'

# ============================================================================
# Helper Functions
# ============================================================================

def load_file(file_path: str) -> str:
    """Load file content with tilde expansion."""
    expanded_path = Path(file_path).expanduser()
    try:
        return expanded_path.read_text(encoding='utf-8')
    except FileNotFoundError:
        print(f"Error: File not found: {file_path}", file=sys.stderr)
        return None
    except Exception as e:
        print(f"Error loading file {file_path}: {e}", file=sys.stderr)
        return None


def build_system_prompt(agent_type: str = None) -> list:
    """Build system prompt with caching markers."""
    shared_context = load_file(AGENT_PROMPTS['shared'])
    
    if not shared_context:
        raise ValueError('Failed to load shared context')

    system_blocks = [
        {
            "type": "text",
            "text": shared_context
        }
    ]

    # Add agent-specific prompt if specified
    if agent_type and agent_type in AGENT_PROMPTS:
        agent_prompt = load_file(AGENT_PROMPTS[agent_type])
        if agent_prompt:
            system_blocks.append({
                "type": "text",
                "text": agent_prompt,
                "cache_control": {"type": "ephemeral"}  # Cache the full system prompt
            })
    else:
        # If no agent specified, just cache the shared context
        system_blocks[0]["cache_control"] = {"type": "ephemeral"}

    return system_blocks


def build_user_message(user_prompt: str, include_project_brief: bool = True) -> list:
    """Build user message with optional project brief caching."""
    message_blocks = []

    if include_project_brief:
        project_brief = load_file(PROJECT_BRIEF)
        if project_brief:
            message_blocks.append({
                "type": "text",
                "text": project_brief,
                "cache_control": {"type": "ephemeral"}  # Cache the project brief
            })

    message_blocks.append({
        "type": "text",
        "text": user_prompt
    })

    return message_blocks


def call_claude(
    user_prompt: str,
    agent: str = None,
    include_project_brief: bool = True,
    model: str = 'claude-opus-4-6',
    max_tokens: int = 4096
) -> str:
    """Call Claude API with caching."""
    
    if not os.getenv('ANTHROPIC_API_KEY'):
        raise ValueError('ANTHROPIC_API_KEY environment variable not set')

    client = Anthropic(api_key=os.getenv('ANTHROPIC_API_KEY'))

    system_prompt = build_system_prompt(agent)
    user_message = build_user_message(user_prompt, include_project_brief)

    print('\n🔄 Calling Claude API with caching...\n')

    response = client.messages.create(
        model=model,
        max_tokens=max_tokens,
        system=system_prompt,
        messages=[
            {
                "role": "user",
                "content": user_message
            }
        ]
    )

    # Log cache usage statistics
    usage = response.usage
    print('📊 Token Usage:')
    print(f'   Input tokens: {usage.input_tokens}')
    print(f'   Cache write tokens: {getattr(usage, "cache_creation_input_tokens", 0)}')
    print(f'   Cache read tokens: {getattr(usage, "cache_read_input_tokens", 0)}')
    print(f'   Output tokens: {usage.output_tokens}')
    
    cache_read_tokens = getattr(usage, 'cache_read_input_tokens', 0)
    if cache_read_tokens > 0:
        savings = (cache_read_tokens * 0.9) / 1_000_000 * 3
        print(f'   💰 Estimated savings from cache: ${savings:.4f}')
    print()

    return response.content[0].text


# ============================================================================
# CLI Interface
# ============================================================================

def main():
    parser = argparse.ArgumentParser(
        description='Claude API wrapper with prompt caching',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s "Create a user profile component"
  %(prog)s "Debug the API" --agent backend
  %(prog)s "Design the dashboard" --agent designer
  %(prog)s "Review security" --agent security --no-brief
        """
    )
    
    parser.add_argument('prompt', help='Your prompt to Claude')
    parser.add_argument('--agent', choices=['architect', 'pm', 'designer', 'api-architect', 'frontend', 'backend', 'security', 'tester', 'devops', 'writer'],
                        help='Agent type to use')
    parser.add_argument('--no-brief', action='store_true',
                        help="Don't include project brief")
    parser.add_argument('--model', default='claude-opus-4-6',
                        help='Claude model to use (default: claude-opus-4-6)')
    parser.add_argument('--max-tokens', type=int, default=4096,
                        help='Max output tokens (default: 4096)')

    args = parser.parse_args()

    try:
        response = call_claude(
            user_prompt=args.prompt,
            agent=args.agent,
            include_project_brief=not args.no_brief,
            model=args.model,
            max_tokens=args.max_tokens
        )
        
        print('🤖 Claude Response:\n')
        print(response)
        
    except Exception as e:
        print(f'❌ Error: {e}', file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
