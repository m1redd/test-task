# Cache Test Task

A TypeScript coding challenge: implement a type-safe, high-performance cache for
asynchronous getters.

## The Task

Original task file (unchanged): [`src/cache.ts`](src/cache.ts)

> Implement a high-performance and type-safe cache class for a user-defined
> asynchronous getter using a limited number of simultaneous timers, without
> using any third-party modules.
>
> `get(key)` must not call the getter more than once for the same key within
> the specified period of time.

The provided stub is untyped and simply forwards every call to the getter — no
caching, no dedup, no typing. The goal is to rewrite it to meet the requirements.

## My Solution

File: [`src/typed-cache.ts`](src/typed-cache.ts)

Highlights:

- **Generic `Cache<K, V>`** — key and value types are inferred from the
  getter signature, so `cache.get(5)` and `cache.get('World')` return correctly
  typed results.
- **TTL per entry** — each cached value stores an absolute `expiresAt`
  timestamp; a hit is only returned if the entry has not expired.
- **In-flight deduplication** — while a getter call for a key is pending,
  subsequent `get(key)` calls receive the same promise instead of triggering
  another request. This matches the "not more than once within the period"
  requirement even when calls overlap.
- **Single shared timer** — at most one `setTimeout` is alive at any time,
  scheduled to fire at the nearest expiration. When it fires, it sweeps all
  expired entries in one pass and reschedules itself for the next-soonest
  expiration. This keeps the number of simultaneous timers at ≤ 1 regardless
  of how many keys are cached.
- **Error handling** — if the getter rejects, nothing is cached and the
  pending entry is cleared, so the next call can retry cleanly.
- **No third-party runtime dependencies** — only `Map` and `setTimeout`.

## Running

```bash
npm install
npm run build     # tsc --noEmit
npm run lint      # eslint
npm run format    # prettier
npm run test      # jest
```

Or run all checks at once:

```bash
./scripts/git-build.sh --local
```
