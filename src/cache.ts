/**
 * Implement a high-performance and type-safe cache class
 * for a user-defined asynchronous getter
 * using limited number of simultaneous timers
 * without using any third-party modules
 */
class Cache {
    getter;

    constructor(getter, time) {
        this.getter = getter;
    }

    get(key) {
        /**
         * This method must not call the getter more than once
         * for the same key within the specified period of time
         */
        return this.getter(key);
    }
}

/**
 * Usage examples
 */

const getter1 = async (id: number) => {
    return Promise.resolve({
        id,
        time: Date.now(),
    });
};

const time1 = 1000; // 1000 milliseconds = 1 second

const cache1 = new Cache(getter1, time1);
console.log(cache1.get(5).time);

const getter2 = async (name: string) => {
    return Promise.resolve(`Hello, ${name}!`);
};

const time2 = 60 * 1000; // 1 minute

const cache2 = new Cache(getter2, time2);
console.log(cache2.get('World').toUpperCase());
