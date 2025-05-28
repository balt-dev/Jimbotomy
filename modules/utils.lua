--- Contains utilities for things like Talisman support.

function cmp(a, b)
	local ta, tb = type(a), type(b)
	if ta == "table" then
		-- BigNum
		if a.compare then return a:compare(b) end
		-- OmegaNum
		if a.compareTo then return a:compareTo(b) end
		error("unsupported number representation for " .. a .. " - must be either float, BigNum, or OmegaNum")
	end
	if tb == "table" then return -cmp(b, a) end
	local diff = (a - b)
	return (diff == 0 and 0) or (math.abs(diff) / diff)
end

if BigMeta then
	function BigMeta.__mod(b1, b2)
	    return b1:mod(b2)
	end
end

function deep_copy(value, seen)
	seen = seen or {}
    local ty = type(value)
    if ty == "table" then
    	seen[value] = true
        local t = {}
        local key, val = next(value, nil)
        while key ~= nil do
            t[key] = seen[val] and val or deep_copy(val, seen)
            key, val = next(value, key)
        end
        setmetatable(t, debug.getmetatable(value))
        return t
    end
    return value
end

function sanitize(x)
    return math.floor(x * 100) / 100
end