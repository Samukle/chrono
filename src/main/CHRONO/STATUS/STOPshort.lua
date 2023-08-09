local STATUS = require(script.Parent)

function TICKStart ( self, Ocurrance )
Ocurrance.Variables.paused = {}
local p = Instance.new("Part")
p.Anchored = true
p.CanCollide = false ; p.CanQuery = false ; p.CanTouch = false
p.CFrame = Ocurrance.Subject:GetPivot()
p.Size = Vector3.zero
p.Transparency = 1
p.Parent = Ocurrance.UI
local SND = Instance.new('Sound')
SND.SoundId = 'rbxassetid://6920047468'
SND.PlayOnRemove = true
SND.Parent = p
SND:Destroy()
local function doweld(x)
local q = Instance.new('Weld')
q.C0 = p.CFrame:Inverse()
q.C1 = x.CFrame:Inverse()
q.Part0 = p
q.Part1 = x
q.Parent = p
Ocurrance.Variables.paused [#Ocurrance.Variables.paused+1] = q
end
if (Ocurrance.Subject:IsA('BasePart')) then doweld(Ocurrance.Subject) end
for k,x in Ocurrance.Subject:GetDescendants() do
     if (x:IsA('BasePart')) then
          doweld(x)
     end
end

Ocurrance.Variables.part = p
Ocurrance.Variables.CFrame = p.CFrame
end
function TICKAdd ( self, Ocurrance )
Ocurrance.Duration += 1.0
Ocurrance.Time = Ocurrance.Duration
end
function TICKWhile ( self, Ocurrance )
Ocurrance.Variables.part.CFrame = Ocurrance.Variables.CFrame
end
function TICKEnd ( self, Ocurrance )
local p = Ocurrance.Variables.part
if (p and p.Parent) then p:Destroy() end
end

return STATUS:Index( 'STOPshort', { Duration=1.0, Color=Color3.new(0,1,0), Display='STOPPED', TICKStart=TICKStart, TICKWhile=TICKWhile, TICKAdd=TICKAdd, TICKEnd=TICKEnd } )