> *Originally designed & optimised for my personal projects*
# Luau ID Allocator

A bounded numeric ID allocator for Luau on ROBLOX. It issues fresh IDs in order, starting at `1`. Once reaches its capacity, it reuses freed IDs in last-freed-first order.

## Usage

```luau
local id_allocator = require(path.to.module);

--/* Create a pool with make_allocator */--
local pool = id_allocator.make_allocator( 2 );

--/* Create a pool manually */--
local pool: id_allocator.allocator = {
	last_id = 0,
	capacity = 2,
	free_head = 0,
	free_next = {}
};

--/* Allocate IDs */--
local first = id_allocator.alloc( pool );	-- 1
local second = id_allocator.alloc( pool );	-- 2
local err = id_allocator.alloc( pool );		-- -id_allocator.ENOSPC

local free_ok = id_allocator.free( pool, first );

if ( free_ok ) then
	local reused = id_allocator.alloc( pool ); -- 1
end 
```

## API

- `make_allocator( cap? )` - Creates an independent allocator. Capacity defaults to `255`.
- `alloc( pool )` - Returns a numeric ID from `1` through pool's capacity, or `-id_allocator.ENOSPC` when pool is full and no free IDs are available.
- `free( pool, id )` - Returns `true` when it releases an ID.
