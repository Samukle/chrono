local Model = script.Parent
local Humanoid = Model:FindFirstChildOfClass("Humanoid")
local Root = Humanoid.RootPart
local IT = Instance.new('Part')
IT.CFrame=Root:GetPivot()
IT.Anchored=true
IT.CanCollide=false
IT.CanQuery=false
IT.CanTouch=false
IT.Transparency=1
IT.Size=Vector3.zero

local Actual = Root
do
local q = Actual:FindFirstChildOfClass('Motor6D')
if(q.Part1) then Actual=q.Part1 end
end

local Motor = Instance.new('Weld')
Motor.Name = 'Hit shake'
Motor.C0 = IT.CFrame:Inverse()
Motor.C1 = Actual.CFrame:Inverse()
local C1 = Motor.C1
Motor.Part0 = IT
Motor.Part1 = Actual
Motor.Parent = Actual
IT.Parent = Motor

local Shake=script:GetAttribute('HITSTOP')
local x=1
for i=1,Shake do
     Motor.C1=C1*CFrame.new(x*0.2,0,0)
     x=(x==0) and 1 or (x==1) and -1 or (x==-1) and 0 or 0
     task.wait()
     end

Motor:Destroy()
script:Destroy()