#!/bin/bash
#
# claude-cached.sh - Simple bash wrapper for cached Claude API calls
#
# Usage:
#   ./claude-cached.sh "Your prompt here"
#   ./claude-cached.sh "Debug API" frontend
#
# Requirements:
#   - jq (for JSON parsing)
#   - ANTHROPIC_API_KEY environment variable
#
# This script uses prompt caching to save 90% on repeated contexts.
# Perfect for quick one-off commands with the same agent prompts.

set -euo pipefail

# ============================================================================
# Configuration
# ============================================================================

AGENT_DIR="${HOME}/ai-dev-team"
SHARED_CONTEXT="${AGENT_DIR}/01-shared-context.md"
PROJECT_BRIEF="${AGENT_DIR}/project-briefs/current-project.md"
MODEL="claude-opus-4-6"
MAX_TOKENS=4096

# Agent prompt files - v3.0 structure (10 agents)
declare -A AGENTS=(
    [architect]="${AGENT_DIR}/03-system-architect.md"
    [pm]="${AGENT_DIR}/04-product-manager.md"
    [designer]="${AGENT_DIR}/05-designer.md"
    [api-architect]="${AGENT_DIR}/06-api-architect.md"
    [frontend]="${AGENT_DIR}/07-frontend-developer.md"
    [backend]="${AGENT_DIR}/08-backend-developer.md"
    [security]="${AGENT_DIR}/09-security-auditor.md"
    [tester]="${AGENT_DIR}/10-system-tester.md"
    [devops]="${AGENT_DIR}/11-devops-engineer.md"
    [writer]="${AGENT_DIR}/12-technical-writer.md"
)

# ============================================================================
# Helper Functions
# ============================================================================

check_requirements() {
    if ! command -v jq &> /dev/null; then
        echo "❌ Error: jq is required but not installed."
        echo "   Install with: brew install jq (macOS) or apt-get install jq (Linux)"
        exit 1
    fi

    if [ -z "${ANTHROPIC_API_KEY:-}" ]; then
        echo "❌ Error: ANTHROPIC_API_KEY environment variable not set"
        exit 1
    fi
}

load_file() {
    local file="$1"
    if [ ! -f "$file" ]; then
        echo "❌ Error: File not found: $file" >&2
        return 1
    fi
    cat "$file"
}

escape_json() {
    python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))'
}

# ============================================================================
# Build API Payload
# ============================================================================

build_payload() {
    local user_prompt="$1"
    local agent_type="${2:-}"
    
    # Load shared context
    local shared_context
    shared_context=$(load_file "$SHARED_CONTEXT" | escape_json)
    
    # Build system prompt
    local system_prompt='[{"type":"text","text":'"$shared_context"'}'
    
    # Add agent-specific prompt if specified
    if [ -n "$agent_type" ] && [ -n "${AGENTS[$agent_type]:-}" ]; then
        local agent_prompt
        agent_prompt=$(load_file "${AGENTS[$agent_type]}" | escape_json)
        system_prompt+=',{"type":"text","text":'"$agent_prompt"',"cache_control":{"type":"ephemeral"}}'
    else
        # Cache just the shared context if no agent specified
        system_prompt='[{"type":"text","text":'"$shared_context"',"cache_control":{"type":"ephemeral"}}'
    fi
    
    system_prompt+=']'
    
    # Build user message with project brief
    local user_content='['
    
    if [ -f "$PROJECT_BRIEF" ]; then
        local project_brief
        project_brief=$(load_file "$PROJECT_BRIEF" | escape_json)
        user_content+='{"type":"text","text":'"$project_brief"',"cache_control":{"type":"ephemeral"}},'
    fi
    
    local escaped_prompt
    escaped_prompt=$(echo "$user_prompt" | escape_json)
    user_content+='{"type":"text","text":'"$escaped_prompt"'}'
    user_content+=']'
    
    # Build complete payload
    cat <<EOF
{
  "model": "$MODEL",
  "max_tokens": $MAX_TOKENS,
  "system": $system_prompt,
  "messages": [
    {
      "role": "user",
      "content": $user_content
    }
  ]
}
EOF
}

# ============================================================================
# Call API
# ============================================================================

call_claude() {
    local payload="$1"
    
    echo "🔄 Calling Claude API with caching..." >&2
    echo "" >&2
    
    local response
    response=$(curl -s https://api.anthropic.com/v1/messages \
        -H "content-type: application/json" \
        -H "x-api-key: $ANTHROPIC_API_KEY" \
        -H "anthropic-version: 2023-06-01" \
        -d "$payload")
    
    # Check for API errors
    if echo "$response" | jq -e '.error' > /dev/null 2>&1; then
        echo "❌ API Error:" >&2
        echo "$response" | jq '.error' >&2
        exit 1
    fi
    
    # Display usage statistics
    echo "📊 Token Usage:" >&2
    local input_tokens cache_write cache_read output_tokens
    input_tokens=$(echo "$response" | jq -r '.usage.input_tokens // 0')
    cache_write=$(echo "$response" | jq -r '.usage.cache_creation_input_tokens // 0')
    cache_read=$(echo "$response" | jq -r '.usage.cache_read_input_tokens // 0')
    output_tokens=$(echo "$response" | jq -r '.usage.output_tokens // 0')
    
    echo "   Input tokens: $input_tokens" >&2
    echo "   Cache write tokens: $cache_write" >&2
    echo "   Cache read tokens: $cache_read" >&2
    echo "   Output tokens: $output_tokens" >&2
    
    # Calculate savings
    if [ "$cache_read" -gt 0 ]; then
        local savings
        savings=$(echo "scale=4; ($cache_read * 0.9) / 1000000 * 3" | bc)
        echo "   💰 Estimated savings from cache: \$$savings" >&2
    fi
    echo "" >&2
    
    # Extract and return the response text
    echo "$response" | jq -r '.content[0].text'
}

# ============================================================================
# Main
# ============================================================================

main() {
    check_requirements
    
    if [ $# -lt 1 ]; then
        cat <<EOF
Usage: $0 "Your prompt here" [agent_type]

Agent types: architect, pm, designer, api-architect, frontend, backend, security, tester, devops, writer

Examples:
  $0 "Create a user profile component"
  $0 "Debug the API errors" backend
  $0 "Review security vulnerabilities" security
  $0 "Design the dashboard layout" designer

This script uses prompt caching to save 90% on repeated contexts.
EOF
        exit 0
    fi
    
    local user_prompt="$1"
    local agent_type="${2:-}"
    
    if [ -n "$agent_type" ] && [ -z "${AGENTS[$agent_type]:-}" ]; then
        echo "❌ Error: Invalid agent type '$agent_type'" >&2
        echo "   Valid types: architect, pm, designer, api-architect, frontend, backend, security, tester, devops, writer" >&2
        exit 1
    fi
    
    local payload
    payload=$(build_payload "$user_prompt" "$agent_type")
    
    local response
    response=$(call_claude "$payload")
    
    echo "🤖 Claude Response:"
    echo ""
    echo "$response"
}

main "$@"
