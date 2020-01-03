cachegrand
==========

cachegrand is to be a general purpose, distributed, lock-free, on-memory and on-disk caching system.

To be able to achieve the goals, cachegrand implements a set of components specifically tailored to provide the maximum
performance and scale up almost linearly on the recent multi-core and multi-cpu servers taking advantage of the modern
hardware and modern design patterns.

While it's similar to other platforms already existing, like memcache or redis, it has two huge differences:
- it's multi-threaded, like memcache, but doesn't use locking and almost doesn't use atomic operations
- It supports on-disk storage, to be able to provide additional space with a fraction of the cost without impacting the
performance when nvme ssd(s) are used. 

The data are backed by hashtable built with performance and modern architecture in mind:
- because it's used by a network server, "the first-arrived first-served" pattern is not needed to be guaranteed
- it's lock-free and almost atomic free, it takes advantage of modern patters like memory fencing to ensure that the cpu
doesn't execute the operations in an order that would cause the algorithm to fail.
- uses the t1ha2 hashing algorithm to provide very high performances with a good distribution (less collisions)
- fully takes advantage of the L1/L2 and L3 caches to minimize accessing the main memory when searching for a key
- minimize the effects of the "false-sharing" caused by multiple threads trying to change data that are stored in
cachelines held by different hardware cores
- uses a DOD (Data Oriented Design) and a neighborhood approach when searching for the buckets and the neighborhood is
large as 2 cachelines

cachegrand is 64bit only so it will be able to run only on 64bit-based platform, the ones currently supported are the
Intel / AMD X64 architectures.

### DESIGN

TODO

### How to...

Checkout

```bash
git clone https://github.com/danielealbano/cachegrand.git
git submodule update --init --recursive
```

Build
```bash
mkdir cmake-build-debug
cd cmake-build-debug
cmake ..
make cachegrand
```

Build for testing
```bash
mkdir cmake-build-debug
cd cmake-build-debug
cmake .. -DBUILD_TESTS=1
make tests
make test
```

### TODO

cachegrand is still under heavy development, the goals for the 0.1 milestone are the following:
- implement the lock-free, fixed queue, auto-scalable threadpool
- implement the data backing layer, with per-thread sharding on-memory (using mmap with hugepages) and on-disk
    - preadv/pwritev/splice
    - append only, sharding per thread, shards map, gc data copying them into active shards, circular-shards approach
      - needs an in memory shard map for the on-memory backed storage and thhe on-disk backed storage
    - on-memory: memfd (for hugepages & sendfile), small shards, up to 16MB, copied to the on-disk storage in the
      background once the shard is full/closed.
    - on-disk: only when the data being written is +8M to maximize the IO  
- implement the network layer
    - plain epoll, read/write, sendfile, socket sharded per thread
    - threadpool to manage the network, each thread in the pool will manage it's own backlog, socket set and will have it's own
      slab allocator
    - use simple array to store the data structures, better to use more memory and spawn a new thread if really needed
      that doing atomic operations continuously 
- implement a basic support for the redis protocol for the GET and the SET operations
- improve code documentation coverage
- improve code testing coverage
- improve general documentation

### FUTURE TODO

Because it aims to be a modern platform, the goal is to have the features mentioned below by the time of it's first
stable release:
- More SSD friendly, temporary keep data in memory instead of writing directly on the disk to fill a page to avoid a RMW
  operation on the SSD that would have, in cascade, an impact on the SSD GC
- Add support for Windows and Mac OS X, the code is already being written with this goal in mind;
- Commands batching, to be able to perform multiple set of operations at the same time;
- TLS, to encrypt the data on-transit;
- Authentication and ACLs, to limit who has access and which data are accessible;
- On-memory and On-disk data encryption.

While ARM support is a nice to have, it's not currently a priority, even if there are quite some similarities between
the ARM and the X64 architectures all the data structure have been built with the latter in mind and some development
and additional research is required to be able to support ARM.
