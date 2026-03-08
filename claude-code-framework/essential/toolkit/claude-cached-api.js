#!/usr/bin/env node
/**
 * Claude API Wrapper with Prompt Caching
 * 
 * This script demonstrates how to call Claude's API with prompt caching enabled.
 * Use this as a template for building your own cached API wrappers.
 * 
 * Usage:
 *   node claude-cached-api.js "Your prompt here"
 *   node claude-cached-api.js "Your prompt" --agent frontend
 * 
 * Requirements:
 *   npm install @anthropic-ai/sdk
 *   export ANTHROPIC_API_KEY=your_key_here
 */

import Anthropic from '@anthropic-ai/sdk';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

// ============================================================================
// Configuration
// ============================================================================

const AGENT_PROMPTS = {
  shared: '~/ai-dev-team/01-shared-context.md',
  architect: '~/ai-dev-team/03-system-architect.md',
  pm: '~/ai-dev-team/04-product-manager.md',
  designer: '~/ai-dev-team/05-designer.md',
  'api-architect': '~/ai-dev-team/06-api-architect.md',
  frontend: '~/ai-dev-team/07-frontend-developer.md',
  backend: '~/ai-dev-team/08-backend-developer.md',
  security: '~/ai-dev-team/09-security-auditor.md',
  tester: '~/ai-dev-team/10-system-tester.md',
  devops: '~/ai-dev-team/11-devops-engineer.md',
  writer: '~/ai-dev-team/12-technical-writer.md'
};

const PROJECT_BRIEF = '~/ai-dev-team/project-briefs/current-project.md';

// ============================================================================
// Helper Functions
// ============================================================================

/**
 * Load file content with tilde expansion
 */
function loadFile(filePath) {
  const expandedPath = filePath.replace(/^~/, process.env.HOME);
  try {
    return fs.readFileSync(expandedPath, 'utf-8');
  } catch (error) {
    console.error(`Error loading file ${filePath}:`, error.message);
    return null;
  }
}

/**
 * Build system prompt with caching markers
 */
function buildSystemPrompt(agentType) {
  const sharedContext = loadFile(AGENT_PROMPTS.shared);
  
  if (!sharedContext) {
    throw new Error('Failed to load shared context');
  }

  const systemBlocks = [
    {
      type: "text",
      text: sharedContext
    }
  ];

  // Add agent-specific prompt if specified
  if (agentType && AGENT_PROMPTS[agentType]) {
    const agentPrompt = loadFile(AGENT_PROMPTS[agentType]);
    if (agentPrompt) {
      systemBlocks.push({
        type: "text",
        text: agentPrompt,
        cache_control: { type: "ephemeral" } // Cache the full system prompt
      });
    }
  } else {
    // If no agent specified, just cache the shared context
    systemBlocks[0].cache_control = { type: "ephemeral" };
  }

  return systemBlocks;
}

/**
 * Build user message with optional project brief caching
 */
function buildUserMessage(userPrompt, includeProjectBrief = true) {
  const messageBlocks = [];

  if (includeProjectBrief) {
    const projectBrief = loadFile(PROJECT_BRIEF);
    if (projectBrief) {
      messageBlocks.push({
        type: "text",
        text: projectBrief,
        cache_control: { type: "ephemeral" } // Cache the project brief
      });
    }
  }

  messageBlocks.push({
    type: "text",
    text: userPrompt
  });

  return messageBlocks;
}

/**
 * Call Claude API with caching
 */
async function callClaude(userPrompt, options = {}) {
  const {
    agent = null,
    includeProjectBrief = true,
    model = 'claude-opus-4-6',
    maxTokens = 4096
  } = options;

  const client = new Anthropic({
    apiKey: process.env.ANTHROPIC_API_KEY
  });

  const systemPrompt = buildSystemPrompt(agent);
  const userMessage = buildUserMessage(userPrompt, includeProjectBrief);

  console.log('\n🔄 Calling Claude API with caching...\n');

  const response = await client.messages.create({
    model,
    max_tokens: maxTokens,
    system: systemPrompt,
    messages: [
      {
        role: 'user',
        content: userMessage
      }
    ]
  });

  // Log cache usage statistics
  const usage = response.usage;
  console.log('📊 Token Usage:');
  console.log(`   Input tokens: ${usage.input_tokens}`);
  console.log(`   Cache write tokens: ${usage.cache_creation_input_tokens || 0}`);
  console.log(`   Cache read tokens: ${usage.cache_read_input_tokens || 0}`);
  console.log(`   Output tokens: ${usage.output_tokens}`);
  
  if (usage.cache_read_input_tokens > 0) {
    const savings = ((usage.cache_read_input_tokens * 0.9) / 1000000 * 3).toFixed(4);
    console.log(`   💰 Estimated savings from cache: $${savings}`);
  }
  console.log('');

  return response.content[0].text;
}

// ============================================================================
// CLI Interface
// ============================================================================

async function main() {
  const args = process.argv.slice(2);
  
  if (args.length === 0) {
    console.log(`
Usage: node claude-cached-api.js "Your prompt here" [options]

Options:
  --agent <type>     Agent type: architect, pm, designer, api-architect, frontend, backend, security, tester, devops, writer
  --no-brief         Don't include project brief
  --model <model>    Claude model (default: claude-opus-4-6)
  --max <tokens>     Max output tokens (default: 4096)

Examples:
  node claude-cached-api.js "Create a user profile component"
  node claude-cached-api.js "Debug the API" --agent backend
  node claude-cached-api.js "Design the dashboard" --agent designer
  node claude-cached-api.js "Review security" --agent security --no-brief
`);
    process.exit(0);
  }

  const userPrompt = args[0];
  const options = {};

  // Parse options
  for (let i = 1; i < args.length; i++) {
    if (args[i] === '--agent' && args[i + 1]) {
      options.agent = args[i + 1];
      i++;
    } else if (args[i] === '--no-brief') {
      options.includeProjectBrief = false;
    } else if (args[i] === '--model' && args[i + 1]) {
      options.model = args[i + 1];
      i++;
    } else if (args[i] === '--max' && args[i + 1]) {
      options.maxTokens = parseInt(args[i + 1]);
      i++;
    }
  }

  try {
    const response = await callClaude(userPrompt, options);
    console.log('🤖 Claude Response:\n');
    console.log(response);
  } catch (error) {
    console.error('❌ Error:', error.message);
    if (error.response) {
      console.error('API Response:', error.response);
    }
    process.exit(1);
  }
}

main();
