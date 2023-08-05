local AnimatorManager = {}
local Animator = script:WaitForChild('Animator')

function AnimatorManager.new(OBJ)
     local __QUERY = Animator:Clone()
     __QUERY.Parent = OBJ
     return __QUERY
     end

return AnimatorManager