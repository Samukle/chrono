local Util = {}
local Selection = game:GetService("Selection")
local CH = function() local queue = Selection:Get() [1] if(queue:IsA("KeyframeSequence")) then return queue else error "ＫｅｙｆｒａｍｅＳｅｑｕｅｎｃｅではりません" end end

function Util:ANIMATION()
     end

return Util