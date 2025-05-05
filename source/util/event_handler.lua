import "CoreLibs/object"

class("EventHandler").extends()

function EventHandler:init()
	self.listeners = {}
end

function EventHandler:subscribe(key, bind, fn)
	local t = self.listeners[key]
	local v = {fn = fn, bind = bind}
	if not t then
		self.listeners[key] = {v}
	else
		t[#t + 1] = v
	end
end

function EventHandler:unsubscribe(key, fn)
	local t = self.listeners[key]
	if t then
		for i, v in ipairs(t) do
			if v.fn == fn then
				table.remove(t, i)
				break
			end
		end
		
		if #t == 0 then
			self.listeners[key] = nil
		end
	end
end

function EventHandler:notify(key, ...)
	local t = self.listeners[key]
	if t then
		for _, v in ipairs(t) do
			v.fn(v.bind, key, ...)
		end
	end
end