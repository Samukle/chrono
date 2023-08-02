local Chrono = {}
local ChronoMT = {}

local __THE_MODULE = (game:GetService'RunService':IsStudio() and require(game:GetService("ReplicatedStorage").MainModule) or ((game:GetService'RunService':IsServer()) and require(14292232196) or 0))

setmetatable(Chrono,ChronoMT)
return Chrono