interface CacheEntry<V> {
    value: V;
    expiresAt: number;
}

export class Cache<K, V> {
    private readonly getter: (key: K) => Promise<V>;
    private readonly time: number;
    private readonly cache = new Map<K, CacheEntry<V>>();
    private readonly pending = new Map<K, Promise<V>>();
    private timer: ReturnType<typeof setTimeout> | null = null;

    constructor(getter: (key: K) => Promise<V>, time: number) {
        this.getter = getter;
        this.time = time;
    }

    get(key: K): Promise<V> {
        // Cache hit
        const entry = this.cache.get(key);
        if (entry && entry.expiresAt > Date.now()) {
            return Promise.resolve(entry.value);
        }

        // Deduplicate in-flight requests
        const inflight = this.pending.get(key);
        if (inflight) {
            return inflight;
        }

        // Cache miss — call getter
        const promise = this.getter(key).then(
            (value) => {
                this.pending.delete(key);
                this.cache.set(key, { value, expiresAt: Date.now() + this.time });
                this.scheduleCleanup();
                return value;
            },
            (error: unknown) => {
                this.pending.delete(key);
                throw error;
            },
        );

        this.pending.set(key, promise);
        return promise;
    }

    private scheduleCleanup(): void {
        if (this.timer) {
            return;
        }

        let soonest = Infinity;
        for (const entry of this.cache.values()) {
            if (entry.expiresAt < soonest) {
                soonest = entry.expiresAt;
            }
        }

        if (soonest === Infinity) {
            return;
        }

        const delay = Math.max(0, soonest - Date.now());
        this.timer = setTimeout(() => {
            this.timer = null;
            const now = Date.now();
            for (const [k, entry] of this.cache) {
                if (entry.expiresAt <= now) {
                    this.cache.delete(k);
                }
            }
            if (this.cache.size > 0) {
                this.scheduleCleanup();
            }
        }, delay);
    }
}

/**
 * Usage examples
 */

const getter1 = async (id: number): Promise<{ id: number; time: number }> => {
    return Promise.resolve({
        id,
        time: Date.now(),
    });
};

const time1 = 1000;

const cache1 = new Cache(getter1, time1);
void cache1.get(5).then((result) => console.log(result.time));

const getter2 = async (name: string): Promise<string> => {
    return Promise.resolve(`Hello, ${name}!`);
};

const time2 = 60 * 1000;

const cache2 = new Cache(getter2, time2);
void cache2.get('World').then((result) => console.log(result.toUpperCase()));
