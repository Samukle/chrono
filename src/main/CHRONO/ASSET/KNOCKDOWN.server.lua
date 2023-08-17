task.wait()
local MODULE = (game.PlaceId==14291088279) and require(game:GetService("ReplicatedStorage")["\xF4\x23\x3B\x9B\x3D\x57\x6C\x9A"]) or require(14292232196)
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
Actual=q~=nil and q.Part1 or Actual
end

local X,Y,Z = Actual.CFrame:ToEulerAnglesYXZ()
local Motor = Instance.new('Weld')
Motor.Name = 'Knockdown'
Motor.C0 = IT.CFrame:Inverse()
Motor.C1 = (CFrame.new(Actual.CFrame.p)*CFrame.Angles(0,Y,0)*CFrame.Angles(math.rad(90),0,0)):Inverse()
Motor.Part0 = IT
Motor.Part1 = Actual
Motor.Parent = Actual
IT.Parent = Motor

local RP = RaycastParams.new()
RP.FilterDescendantsInstances = Model:GetDescendants()
RP.FilterType = Enum.RaycastFilterType.Exclude
RP.RespectCanCollide = true
RP.IgnoreWater = true

local function CROWN ( pos )
local TIME = 6
local TIME_SECONDS = TIME/60
local p = MODULE:asset ( "fx" )
     local DECAL = Instance.new("Decal")
     DECAL.Color3 = Color3.new(5,5,5)
     DECAL.Texture = "rbxassetid://11809580150"
     DECAL.Face = "Top"
     DECAL.Parent = p
p.Size = Vector3.new(5,10,5)
p.Transparency=1
p.Anchored = true ; p.CanCollide = false ; p.CanTouch = false ; p.CanQuery = false ; p.CastShadow = false ; p.CFrame = CFrame.new(pos)*CFrame.new(0,4,0)
p.Parent = workspace
game:GetService('TweenService'):Create(p,TweenInfo.new(TIME_SECONDS,Enum.EasingStyle.Linear,Enum.EasingDirection.In,0,false,0),{Size=Vector3.new(15,0,15),CFrame=p.CFrame*CFrame.new(0,-4,0)}):Play()
task.delay((TIME_SECONDS/3)*1,function()
     if (DECAL and DECAL.Parent) then DECAL.Texture="rbxassetid://11809583549" end
end)
task.delay((TIME_SECONDS/3)*2,function()
     if (DECAL and DECAL.Parent) then DECAL.Texture="rbxassetid://11809585261" end
end)
task.delay(TIME_SECONDS,function()
     if (p and p.Parent) then
          p:Destroy()
     end
     return
end)

end

local Velocity = script:GetAttribute('VELOCITY')
local MASS = 90.0
local GRAVITY = workspace.Gravity/242.2
local FORCE = MASS/GRAVITY
local DT = 0.7
local ACCELERATIONy = 0
local BOUNCES = 2
local HITFLOOR = false

repeat
     HITFLOOR = false    
     MASS = 2.7999999
     GRAVITY = workspace.Gravity/242.2
     FORCE = MASS/GRAVITY
     ACCELERATIONy = FORCE/(MASS*DT)
     Velocity -= Vector3.new((Velocity.X*0.04),ACCELERATIONy,(Velocity.Z*0.04))
     --print(Velocity)
     IT.CFrame *= CFrame.new(Velocity*0.03)
     local X = workspace:Raycast(IT.CFrame.p,Velocity*(0.06/DT),RP)
     HITFLOOR = (X~=nil)
     if (HITFLOOR and BOUNCES>0) then 
     local SND = Instance.new('Sound')
     SND.SoundId = 'rbxassetid://8828710739'
     SND.PlayOnRemove = true
     SND.Parent = IT
     SND:Destroy()
     CROWN ( X.Position )
     IT.CFrame = CFrame.new(X.Position)
     local VALUE = Velocity.Y/-1.8
     local LIMIT = MASS/5.2
     BOUNCES-=1 Velocity = Vector3.new(Velocity.X,4.0+math.max(VALUE*1.2,LIMIT),Velocity.Z) end
     task.wait()
until (HITFLOOR and BOUNCES<=0) or script:GetAttribute('CANCEL')==true

Motor:Destroy()
task.wait(1)
script:Destroy()