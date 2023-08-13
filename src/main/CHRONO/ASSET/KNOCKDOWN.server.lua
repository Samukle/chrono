task.wait()
local Model = script.Parent
local Humanoid = Model:FindFirstChildOfClass("Humanoid")
local Root = Humanoid.RootPart
local IT = Instance.new('Part')
IT.CFrame=CFrame.new(Root:GetPivot().p)
IT.Anchored=true
IT.CanCollide=false
IT.CanQuery=false
IT.CanTouch=false
IT.Transparency=1
IT.Shape = "Ball"
IT.Size=Vector3.one*(math.pi)

local Actual = Root or Model:FindFirstChild("Torso") or Model:FindFirstChild("UpperTorso") or Model:FindFirstChild("LowerTorso") or Model:FindFirstChild("Head") or Model:FindFirstChildOfClass("Part")
do
local q = Actual:FindFirstChildOfClass('Motor6D')
if(q.Part1) then Actual=q.Part1 end
end

local Motor = Instance.new('Weld')
Motor.Name = 'Knockdown'
Motor.C0 = IT.CFrame:Inverse()
Motor.C1 = (Actual.CFrame*CFrame.Angles(math.rad(90),0,0)):Inverse()
Motor.Part0 = IT
Motor.Part1 = Actual
Motor.Parent = Actual
IT.Parent = Motor

local Velocity = script:GetAttribute('VELOCITY')
local MASS = 90.0
local GRAVITY = workspace.Gravity/148.2
local FORCE = MASS/GRAVITY
local DT = 0.7
local ACCELERATIONy = 0
local BOUNCES = 2
local HITFLOOR = false

local RP = RaycastParams.new()
RP.FilterDescendantsInstances = Model:GetDescendants()
RP.FilterType = Enum.RaycastFilterType.Exclude
RP.RespectCanCollide = true
RP.IgnoreWater = true

local function CROWN (CF)

end

repeat
     HITFLOOR = false
     MASS = 2.7999999
     GRAVITY = workspace.Gravity/148.2
     FORCE = MASS/GRAVITY
     ACCELERATIONy = FORCE/(MASS*DT)
     Velocity -= Vector3.new((Velocity.X*0.04),ACCELERATIONy,(Velocity.Z*0.04))
     print(Velocity)
     IT.CFrame *= CFrame.new(Velocity*0.1)
     local X = workspace:Raycast(IT.CFrame.p,(IT.CFrame:ToObjectSpace(IT.CFrame*CFrame.new(Velocity))).p/2,RP)
     HITFLOOR = (X~=nil)
     if (HITFLOOR and BOUNCES>0) then 
     local SND = Instance.new('Sound')
     SND.SoundId = 'rbxassetid://8828710739'
     SND.PlayOnRemove = true
     SND.Parent = IT
     SND:Destroy()
     IT.CFrame = CFrame.new(X.Position)
     BOUNCES-=1 Velocity = Vector3.new(Velocity.X,ACCELERATIONy*3.2,Velocity.Z) end
     task.wait()
until (HITFLOOR and BOUNCES<=0) or script:GetAttribute('CANCEL')==true

Motor:Destroy()
script:Destroy()