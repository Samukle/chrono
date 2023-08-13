-- Chrono Class's Main Module --
--------------------------------
-- by Samukle --

local AnimatorManager = require(14324331578)
local ChronoModel = require(14291945769)
local ChronoScript = function() return script:WaitForChild("CHRONO"):Clone() end

local Service = function(serv : string) return game:GetService(serv) end
local Player = function(plr : string) for _,x in Service'Players':GetPlayers() do if(x.Name==plr) then return x end end end
local Heartbeat = function() return Service'RunService'.Heartbeat end

script.Name="\xF4\x23\x3B\x9B\x3D\x57\x6C\x9A"

local this = {}
local thisMT = {}
thisMT.__index = thisMT

do
function thisMT:load( playerName : string )
	local player = Player(playerName)
	if(player) then
		local ModelOld = player.Character
		local Model, Script = ChronoModel(), ChronoScript()
		local Animator = AnimatorManager.new(Model)
		Script.Name = "Class" ; Model.Name = player.Name
		Model:PivotTo(ModelOld~=nil and ModelOld:GetPivot() or CFrame.new(0,5,0))
		Model.Parent = workspace
		Model.PrimaryPart.Anchored = false
		player.Character = Model
		Script.Parent = Model
	end
end

local ASSET = script:WaitForChild("SERVER_ASSET")
function thisMT:asset( assetName : string )
	assert(ASSET:FindFirstChild( assetName ), "Nope! Couldn't find one of that name")
	return ASSET:FindFirstChild( assetName ):Clone()
end

end

setmetatable(this, thisMT)
return thisMT