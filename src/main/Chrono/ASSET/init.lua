local ASSET = {}
local ASSETMT = {}

ASSET.list = script:GetChildren()

do

ASSETMT.__index = ASSETMT
ASSETMT.exists = function(self, WHAT) for _,x in self.list do if(x.Name==WHAT) then return true end end return false end
ASSETMT.__call = function(self, INPUT)
     for _,i in self.list do
          if(i.Name==INPUT) then return i:Clone() end
          end
     end

end

setmetatable(ASSET,ASSETMT)
return ASSET