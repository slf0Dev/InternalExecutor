local ObjectPool = {}

function ObjectPool.new(Object, InitialAmount)
	
	local Pool = {
		Object		= Object;
		Available	= {};
	}
	
	for i=1, InitialAmount or 1 do
		Pool.Available[i] = Object:Clone()
	end
	
	function Pool:Get()
		
		local o = self.Available[1]
		if o then
			table.remove(self.Available,1)
			
			--print("get: pool")
			return o
		else
			
			--print("get: new")
			return self.Object:Clone()
		end
		
	end
	
	function Pool:Return(o)
		--print("return")
		
		o.Parent = nil
		self.Available[#self.Available+1] = o
	end
	
	
	return Pool
	
end

return ObjectPool
