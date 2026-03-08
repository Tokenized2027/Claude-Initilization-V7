# Batch Processing — Process Large Volumes at 50% Cost

> **TL;DR:** Anthropic's Message Batches API lets you process thousands of requests asynchronously at 50% off standard pricing. Perfect for large-scale evaluations, content generation, data analysis, and any non-urgent bulk processing. Combine with prompt caching for even greater savings.
>
> **Last Updated:** February 12, 2026

---

## What Is Batch Processing?

Batch processing allows you to submit multiple API requests together for asynchronous processing instead of getting immediate responses. This is ideal when:

- You're processing large volumes of data (hundreds to thousands of requests)
- Immediate responses aren't required
- You want to optimize for cost (50% discount!)
- You're running evaluations, analyses, or bulk content generation

**Key benefits:**
- **50% cost reduction** on all input and output tokens
- **Higher throughput** — process more requests in parallel
- **Simpler architecture** — no need to manage rate limits or retries yourself
- **Stack savings** — combine with prompt caching for 70-90% total cost reduction

---

## Pricing

All batch API usage is charged at **50% of standard prices**:

| Model | Batch Input | Batch Output | Standard Input | Standard Output |
|-------|-------------|--------------|----------------|-----------------|
| Claude Opus 4.6 | $2.50 / MTok | $12.50 / MTok | $5.00 / MTok | $25.00 / MTok |
| Claude Sonnet 4.5 | $1.50 / MTok | $7.50 / MTok | $3.00 / MTok | $15.00 / MTok |
| Claude Haiku 4.5 | $0.50 / MTok | $2.50 / MTok | $1.00 / MTok | $5.00 / MTok |

**Example savings:**
- 1,000 requests × 5,000 tokens each = 5M tokens
- Standard cost: 5M × $3.00 = **$15.00**
- Batch cost: 5M × $1.50 = **$7.50**
- **Savings: $7.50 (50% reduction)**

---

## When to Use Batch Processing

### ✅ Perfect Use Cases

1. **Large-scale evaluations** — Test thousands of prompts for quality, consistency, or performance
2. **Content moderation** — Analyze user-generated content at scale
3. **Data analysis** — Generate insights or summaries for large datasets
4. **Bulk content generation** — Create product descriptions, article summaries, translations
5. **Training data generation** — Create synthetic training examples for ML models
6. **A/B testing** — Test multiple prompt variations across large datasets
7. **Document processing** — Analyze, summarize, or extract from thousands of documents

### ❌ Not Suitable For

1. **Real-time chat** — User is waiting for immediate response
2. **Interactive workflows** — Need rapid iteration and feedback
3. **Small requests** — <100 requests (overhead not worth it)
4. **Time-sensitive tasks** — Must complete within minutes

---

## How Batch Processing Works

```
1. Create batch → Submit up to 100,000 requests
2. Processing → Anthropic processes asynchronously (typically <1 hour)
3. Retrieve results → Download when complete (available for 29 days)
```

### Batch Lifecycle

```
Status: in_progress → processing → ended
  ↓
Results available at results_url
  ↓
Download as .jsonl file
```

---

## Implementation Guide

### 1. Create a Batch

Submit multiple requests with unique IDs:

```python
import anthropic

client = anthropic.Anthropic()

# Create batch with 1,000 requests
requests = []
for i in range(1000):
    requests.append({
        "custom_id": f"request-{i}",
        "params": {
            "model": "claude-opus-4-6",
            "max_tokens": 1024,
            "messages": [
                {"role": "user", "content": f"Summarize document {i}"}
            ]
        }
    })

batch = client.messages.batches.create(requests=requests)
print(f"Batch created: {batch.id}")
```

**Response:**
```json
{
  "id": "msgbatch_01HkcTjaV5uDC8jWR4ZsDV8d",
  "type": "message_batch",
  "processing_status": "in_progress",
  "request_counts": {
    "processing": 1000,
    "succeeded": 0,
    "errored": 0,
    "canceled": 0,
    "expired": 0
  },
  "created_at": "2024-09-24T18:37:24.100435Z",
  "expires_at": "2024-09-25T18:37:24.100435Z",
  "results_url": null
}
```

### 2. Poll for Completion

Check status periodically:

```python
import time

batch_id = "msgbatch_01HkcTjaV5uDC8jWR4ZsDV8d"

while True:
    batch = client.messages.batches.retrieve(batch_id)
    
    if batch.processing_status == "ended":
        print(f"Batch complete! {batch.request_counts}")
        break
    
    print(f"Processing: {batch.request_counts.processing} remaining...")
    time.sleep(60)  # Check every minute
```

### 3. Download Results

Stream results when processing is complete:

```python
for result in client.messages.batches.results(batch_id):
    if result.result.type == "succeeded":
        message = result.result.message
        print(f"✓ {result.custom_id}: {message.content[0].text[:100]}...")
        
    elif result.result.type == "errored":
        error = result.result.error
        if error.type == "invalid_request":
            print(f"✗ {result.custom_id}: Validation error - {error.message}")
        else:
            print(f"✗ {result.custom_id}: Server error (can retry)")
            
    elif result.result.type == "expired":
        print(f"⏱ {result.custom_id}: Expired before processing")
```

---

## Combining Batch Processing + Prompt Caching

**The killer combo:** 50% batch discount + 90% caching discount = **95% total savings** on repeated context.

### Example: Analyze 1,000 documents with shared context

```python
shared_instructions = """You are analyzing financial documents.
Focus on: revenue trends, expense patterns, risk factors.
[... 3,000 tokens of detailed instructions ...]"""

requests = []
for doc_id, document in enumerate(documents):
    requests.append({
        "custom_id": f"doc-{doc_id}",
        "params": {
            "model": "claude-opus-4-6",
            "max_tokens": 2048,
            "system": [
                {
                    "type": "text",
                    "text": shared_instructions,
                    "cache_control": {"type": "ephemeral"}  # Cache this!
                }
            ],
            "messages": [
                {"role": "user", "content": f"Analyze: {document}"}
            ]
        }
    })

batch = client.messages.batches.create(requests=requests)
```

**Cost breakdown:**

Without batching or caching:
- 1,000 requests × 5,000 tokens = 5M tokens
- Cost: 5M × $3.00 = **$15.00**

With batching only (50% off):
- Cost: 5M × $1.50 = **$7.50**

With batching + caching (50% off + 90% cache hit):
- 3,000 cached tokens × 1,000 requests = 3M cached tokens
- Cache read cost: 3M × $1.50 × 0.1 = **$0.45**
- Non-cached cost: 2M × $1.50 = **$3.00**
- Total: **$3.45**

**Savings: $15.00 → $3.45 = 77% reduction**

---

## Best Practices

### Structure Your Batches

```python
# ✅ GOOD: Group similar requests for better cache hits
batch_1 = create_batch(financial_documents, "financial_analysis")
batch_2 = create_batch(legal_documents, "legal_review")

# ❌ BAD: Mix different types randomly
batch_mixed = create_batch(all_documents_random_order)
```

### Use Meaningful Custom IDs

```python
# ✅ GOOD: Track request origin
custom_id = f"user-{user_id}-doc-{doc_id}-{timestamp}"

# ❌ BAD: Generic sequential IDs
custom_id = f"request-{i}"
```

### Handle Errors Gracefully

```python
succeeded = []
failed_retryable = []
failed_invalid = []

for result in client.messages.batches.results(batch_id):
    if result.result.type == "succeeded":
        succeeded.append(result)
    elif result.result.type == "errored":
        if result.result.error.type == "invalid_request":
            failed_invalid.append(result)  # Fix before retrying
        else:
            failed_retryable.append(result)  # Retry as-is

# Retry server errors in a new batch
if failed_retryable:
    retry_batch = create_retry_batch(failed_retryable)
```

### Test First

```python
# Test a single request with Messages API before batching
test_response = client.messages.create(
    model="claude-opus-4-6",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Test"}]
)

# If successful, batch the full set
if test_response:
    batch = client.messages.batches.create(requests=all_requests)
```

---

## Batch Limits & Constraints

| Limit | Value |
|-------|-------|
| Max requests per batch | 100,000 |
| Max batch size | 256 MB |
| Processing timeout | 24 hours |
| Results availability | 29 days after creation |
| Cache hit rate (best effort) | 30-98% depending on traffic patterns |

**Processing time:**
- Most batches: <1 hour
- Large batches: Up to 24 hours
- If not complete within 24 hours: Requests marked as `expired`

---

## Real-World Examples

### Example 1: Content Moderation at Scale

```python
# Moderate 10,000 user comments
comments = load_comments_from_db()

moderation_prompt = """Classify this content:
- safe
- needs_review
- policy_violation

Provide reasoning."""

requests = [
    {
        "custom_id": f"comment-{comment['id']}",
        "params": {
            "model": "claude-haiku-4-5",  # Fast + cheap for classification
            "max_tokens": 256,
            "system": [
                {
                    "type": "text",
                    "text": moderation_prompt,
                    "cache_control": {"type": "ephemeral"}
                }
            ],
            "messages": [
                {"role": "user", "content": comment['text']}
            ]
        }
    }
    for comment in comments
]

batch = client.messages.batches.create(requests=requests)

# Process results
for result in client.messages.batches.results(batch.id):
    if result.result.type == "succeeded":
        classification = parse_classification(result.result.message.content[0].text)
        update_db(result.custom_id, classification)
```

### Example 2: A/B Testing Prompts

```python
# Test 3 prompt variations across 1,000 examples
variations = ["prompt_a", "prompt_b", "prompt_c"]
test_cases = load_test_cases()

requests = []
for variation in variations:
    for test_case in test_cases:
        requests.append({
            "custom_id": f"{variation}-{test_case['id']}",
            "params": {
                "model": "claude-sonnet-4-5",
                "max_tokens": 1024,
                "system": [{"type": "text", "text": PROMPTS[variation]}],
                "messages": [{"role": "user", "content": test_case['input']}]
            }
        })

batch = client.messages.batches.create(requests=requests)

# Analyze results by variation
results_by_variant = {"prompt_a": [], "prompt_b": [], "prompt_c": []}
for result in client.messages.batches.results(batch.id):
    variant = result.custom_id.split("-")[0]
    results_by_variant[variant].append(result)

# Compare quality metrics
for variant, results in results_by_variant.items():
    quality_score = calculate_quality(results)
    print(f"{variant}: {quality_score}")
```

### Example 3: Bulk Document Summarization

```python
# Summarize 5,000 research papers
papers = load_papers_from_s3()

system_prompt = """Summarize this research paper:
- Main hypothesis
- Methodology
- Key findings
- Limitations
Max 200 words."""

requests = [
    {
        "custom_id": f"paper-{paper['doi']}",
        "params": {
            "model": "claude-opus-4-6",
            "max_tokens": 512,
            "system": [
                {
                    "type": "text",
                    "text": system_prompt,
                    "cache_control": {"type": "ephemeral"}
                }
            ],
            "messages": [
                {"role": "user", "content": paper['full_text']}
            ]
        }
    }
    for paper in papers
]

batch = client.messages.batches.create(requests=requests)

# Save summaries to database
for result in client.messages.batches.results(batch.id):
    if result.result.type == "succeeded":
        doi = result.custom_id.replace("paper-", "")
        summary = result.result.message.content[0].text
        save_summary_to_db(doi, summary)
```

---

## Integration with Your Agent Workflow

### Using Batches for Agent Development

**Scenario:** You're building a new agent and want to test it across 1,000 scenarios.

```python
# 1. Define test scenarios
test_scenarios = load_scenarios("test_suite.json")

# 2. Load agent prompt from your agent system
agent_prompt = open("~/ai-dev-team/05-frontend-developer.md").read()

# 3. Create batch with agent prompt + scenarios
requests = [
    {
        "custom_id": f"scenario-{scenario['id']}",
        "params": {
            "model": "claude-opus-4-6",
            "max_tokens": 4096,
            "system": [
                {
                    "type": "text",
                    "text": agent_prompt,
                    "cache_control": {"type": "ephemeral"}
                }
            ],
            "messages": [
                {"role": "user", "content": scenario['input']}
            ]
        }
    }
    for scenario in test_scenarios
]

batch = client.messages.batches.create(requests=requests)

# 4. Analyze results for quality
pass_rate = 0
for result in client.messages.batches.results(batch.id):
    if result.result.type == "succeeded":
        output = result.result.message.content[0].text
        expected = get_expected_output(result.custom_id)
        if matches_expected(output, expected):
            pass_rate += 1

print(f"Agent pass rate: {pass_rate / len(test_scenarios) * 100}%")
```

---

## Monitoring and Management

### List All Batches

```python
# View all batches in your workspace
for batch in client.messages.batches.list(limit=20):
    print(f"{batch.id}: {batch.processing_status} - {batch.request_counts}")
```

### Cancel a Running Batch

```python
# Cancel if you realize there's an error
batch = client.messages.batches.cancel(batch_id)
print(f"Cancellation initiated: {batch.cancel_initiated_at}")

# Wait for cancellation to complete
while batch.processing_status == "canceling":
    time.sleep(10)
    batch = client.messages.batches.retrieve(batch_id)

print(f"Canceled. Partial results: {batch.request_counts.succeeded}")
```

---

## Troubleshooting

### Common Issues

**Issue: "413 request_too_large"**
- **Cause:** Batch exceeds 256 MB
- **Fix:** Split into multiple smaller batches

**Issue: High expiration rate (requests timing out)**
- **Cause:** System under high load or request complexity too high
- **Fix:** Use faster model (Haiku vs Opus), reduce max_tokens, split batch

**Issue: Results not matching request order**
- **Cause:** This is expected — batch processes concurrently
- **Fix:** Always use `custom_id` to match results to requests

**Issue: Low cache hit rate**
- **Cause:** Requests processed too far apart in time
- **Fix:** Ensure consistent `cache_control` blocks, submit batches closer together

**Issue: Results expired (>29 days)**
- **Cause:** Didn't download results within 29 days of batch creation
- **Fix:** Set up automated result retrieval immediately after batch completion

---

## Cost Optimization Strategies

### 1. Model Selection

```python
# Use cheapest model that meets quality bar
TASK_MODELS = {
    "classification": "claude-haiku-4-5",      # $0.50/$2.50 batch
    "summarization": "claude-sonnet-4-5",     # $1.50/$7.50 batch
    "analysis": "claude-opus-4-6",            # $2.50/$12.50 batch
}
```

### 2. Batch + Cache Together

```python
# ALWAYS cache shared context in batches
system_prompt = load_shared_context()

requests = [
    {
        "custom_id": f"req-{i}",
        "params": {
            "system": [
                {
                    "type": "text",
                    "text": system_prompt,
                    "cache_control": {"type": "ephemeral"}  # ← CRITICAL
                }
            ],
            # ... rest of params
        }
    }
    for i in range(10000)
]
```

### 3. Minimize Output Tokens

```python
# Be specific about output format to avoid verbose responses
system_prompt = """Respond with ONLY a JSON object:
{
  "classification": "spam|ham",
  "confidence": 0.0-1.0
}
No explanations."""
```

---

## See Also

- `advanced/guides/PROMPT_CACHING.md` — Combine with batching for maximum savings
- `essential/guides/COSTS.md` — Overall cost breakdown
- Anthropic Docs: https://docs.anthropic.com/en/docs/build-with-claude/message-batches
