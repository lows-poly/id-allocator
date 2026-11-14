--[[
 * id_allocator.luau
 *
 * Bounded numeric ID allocator with free-list reuse.
 *
 * Fresh IDs are issued in order from 1 through the allocator's
 * capacity. After that, freed IDs are reused in last-freed-first
 * order.
 *
 * Allocation returns -ENOSPC when no IDs are available.
 --]]

type int = number;

local DEFAULT_CAP = 0xFF;
local ENOSPC = 1;

export type allocator = {
	last_id: int,
	capacity: int,
	free_head: int,
	free_next: { [int]: int }
};

local id_allocator = {};
id_allocator.ENOSPC = ENOSPC;

function id_allocator.make_allocator( cap )
	assert( cap >= 1 and cap % 1 == 0, "CAPACITY MUST BE A POSITIVE INTEGER" );
	return {
		last_id = 0,
		capacity = cap or DEFAULT_CAP,
		free_head = 0,
		free_next = {}
	};
end

function id_allocator.alloc( allocator )
	local id;

	assert( allocator, "CANNOT ALLOCATE ID WITHOUT AN ALLOCATOR" );

	if ( allocator.last_id < allocator.capacity ) then
		allocator.last_id += 1;
		return allocator.last_id;
	end

	id = allocator.free_head;

	if ( id == 0 ) then
		return -ENOSPC;
	end

	allocator.free_head = allocator.free_next[id];
	allocator.free_next[id] = nil;
	return id;
end

function id_allocator.free( allocator, id )
	assert( allocator, "CANNOT FREE ID WITHOUT AN ALLOCATOR" );

	if ( id < 1 or id > allocator.last_id or id % 1 ~= 0 ) then
		return false;
	end

	if ( allocator.free_next[id] ~= nil ) then
		return false;
	end

	allocator.free_next[id] = allocator.free_head;
	allocator.free_head = id;
	return true;
end

return id_allocator;
