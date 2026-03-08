---
name: defi-analytics
description: Build blockchain analytics dashboards and DeFi protocol monitoring. Patterns for fetching on-chain data, calculating APY/TVL, and visualizing protocol metrics. Triggers on "DeFi dashboard", "on-chain data", "TVL", "APY calculation", "staking metrics", "protocol analytics", "blockchain API".
metadata:
  author: Mastering Claude Code (custom for DeFi workflows)
  version: 1.0.0
  category: defi
  source: custom
---

# DeFi Analytics

Patterns for building blockchain analytics dashboards — fetching on-chain data, calculating DeFi metrics, and presenting protocol health.

## Instructions

### Pattern 1: Multi-Source Data Fetching

DeFi dashboards typically pull from 3+ sources. Fetch in parallel:

```typescript
// lib/data/protocol-metrics.ts
interface ProtocolMetrics {
  tvl: number
  apy: number
  operatorCount: number
  linkStaked: number
  lastUpdated: string
}

export async function fetchProtocolMetrics(): Promise<ProtocolMetrics> {
  const [onChain, defiLlama, subgraph] = await Promise.allSettled([
    fetchOnChainData(),
    fetchDefiLlamaData(),
    fetchSubgraphData(),
  ])

  return {
    tvl: defiLlama.status === 'fulfilled' ? defiLlama.value.tvl : 0,
    apy: onChain.status === 'fulfilled' ? onChain.value.apy : 0,
    operatorCount: subgraph.status === 'fulfilled' ? subgraph.value.operators : 0,
    linkStaked: onChain.status === 'fulfilled' ? onChain.value.staked : 0,
    lastUpdated: new Date().toISOString(),
  }
}
```

**Rules:**
- Use `Promise.allSettled` not `Promise.all` — one API failing shouldn't kill the whole dashboard
- Cache aggressively (blockchain data doesn't change every second)
- Always include `lastUpdated` so users know data freshness

### Pattern 2: On-Chain Data via ethers.js / viem

```typescript
// lib/data/on-chain.ts
import { createPublicClient, http, formatEther } from 'viem'
import { mainnet } from 'viem/chains'

const client = createPublicClient({
  chain: mainnet,
  transport: http(process.env.RPC_URL),
})

// Read a smart contract
export async function getStakingPoolBalance(contractAddress: `0x${string}`) {
  const balance = await client.readContract({
    address: contractAddress,
    abi: STAKING_POOL_ABI,
    functionName: 'totalStaked',
  })
  
  return {
    raw: balance,
    formatted: Number(formatEther(balance)),
  }
}

// Batch multiple calls for efficiency
export async function getPoolMetrics(contractAddress: `0x${string}`) {
  const [totalStaked, rewardRate, operatorCount] = await Promise.all([
    client.readContract({ address: contractAddress, abi: STAKING_POOL_ABI, functionName: 'totalStaked' }),
    client.readContract({ address: contractAddress, abi: STAKING_POOL_ABI, functionName: 'rewardRate' }),
    client.readContract({ address: contractAddress, abi: STAKING_POOL_ABI, functionName: 'getOperatorCount' }),
  ])

  return {
    totalStaked: Number(formatEther(totalStaked)),
    rewardRate: Number(formatEther(rewardRate)),
    operatorCount: Number(operatorCount),
  }
}
```

### Pattern 3: APY Calculation

```typescript
// lib/calculations/apy.ts

/**
 * Calculate APY from reward rate and total staked
 * APY = ((1 + rewardRate/totalStaked/periodsPerYear)^periodsPerYear - 1) * 100
 */
export function calculateAPY(
  rewardRatePerSecond: number,
  totalStaked: number,
  compoundingPeriods: number = 365  // daily compounding
): number {
  if (totalStaked === 0) return 0
  
  const secondsPerYear = 365.25 * 24 * 3600
  const annualReward = rewardRatePerSecond * secondsPerYear
  const ratePerPeriod = annualReward / totalStaked / compoundingPeriods
  
  const apy = (Math.pow(1 + ratePerPeriod, compoundingPeriods) - 1) * 100
  
  // Sanity check — APYs over 1000% are usually bugs
  if (apy > 10000) {
    console.warn('Suspiciously high APY calculated:', apy)
    return 0
  }
  
  return Number(apy.toFixed(2))
}

/**
 * Calculate simple APR (no compounding)
 */
export function calculateAPR(annualRewards: number, totalStaked: number): number {
  if (totalStaked === 0) return 0
  return Number(((annualRewards / totalStaked) * 100).toFixed(2))
}
```

### Pattern 4: DeFi Llama Integration

```typescript
// lib/data/defillama.ts
const DEFILLAMA_BASE = 'https://api.llama.fi'

export async function getProtocolTVL(slug: string): Promise<number> {
  const res = await fetch(`${DEFILLAMA_BASE}/tvl/${slug}`)
  if (!res.ok) throw new Error(`DeFi Llama API error: ${res.status}`)
  return res.json() // Returns number directly
}

export async function getProtocolHistory(slug: string) {
  const res = await fetch(`${DEFILLAMA_BASE}/protocol/${slug}`)
  if (!res.ok) throw new Error(`DeFi Llama API error: ${res.status}`)
  const data = await res.json()
  
  return data.tvl.map((point: { date: number; totalLiquidityUSD: number }) => ({
    date: new Date(point.date * 1000).toISOString().split('T')[0],
    tvl: point.totalLiquidityUSD,
  }))
}
```

### Pattern 5: Data Caching Layer

```typescript
// lib/cache.ts
const cache = new Map<string, { data: unknown; expires: number }>()

export async function cached<T>(
  key: string,
  fetcher: () => Promise<T>,
  ttlSeconds: number = 300 // 5 min default
): Promise<T> {
  const existing = cache.get(key)
  if (existing && existing.expires > Date.now()) {
    return existing.data as T
  }

  const data = await fetcher()
  cache.set(key, { data, expires: Date.now() + ttlSeconds * 1000 })
  return data
}

// Usage:
// const tvl = await cached('protocol-tvl', () => getProtocolTVL('your-protocol'), 600)
```

### Number Formatting for DeFi UIs

```typescript
export function formatUSD(value: number): string {
  if (value >= 1_000_000_000) return `$${(value / 1_000_000_000).toFixed(2)}B`
  if (value >= 1_000_000) return `$${(value / 1_000_000).toFixed(2)}M`
  if (value >= 1_000) return `$${(value / 1_000).toFixed(1)}K`
  return `$${value.toFixed(2)}`
}

export function formatToken(value: number, symbol: string = 'LINK'): string {
  return `${value.toLocaleString(undefined, { maximumFractionDigits: 2 })} ${symbol}`
}

export function formatPercent(value: number): string {
  return `${value >= 0 ? '+' : ''}${value.toFixed(2)}%`
}
```

## When to Use This Skill

✅ Use defi-analytics when:
- Building protocol dashboards and analytics interfaces
- Fetching on-chain data for any blockchain project
- Calculating DeFi metrics (APY, TVL, staking ratios)
- Setting up data pipelines for protocol monitoring

❌ Don't use for:
- Smart contract development (use backend-developer agent)
- Governance content writing (use governance-writer)
- General API design (use api-design)
