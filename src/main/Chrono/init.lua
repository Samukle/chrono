local Chrono = {}
local ChronoMT = {}

local Service = function(serv : string) return game:GetService(serv) end
local PlayerAll = function() return Service'Players':GetPlayers() end
local Player = function(plr : string) for _,x in PlayerAll() do if(x.Name==plr) then return x end end end
local Heartbeat = function() return Service'RunService'.Heartbeat end
local OnTick = function(f) return Heartbeat():Connect(f) end
local JSON_Encode = function(s) return Service'HttpService':JSONEncode(s) end
local JSON_Decode = function(s) return Service'HttpService':JSONDecode(s) end

local IsClient = (Service'Players'.LocalPlayer ~= nil)
local IsServer = not IsClient

local __THE_MODULE = Service'RunService':IsStudio() and IsServer and require(game:GetService("ReplicatedStorage")['\xF4\x23\x3B\x9B\x3D\x57\x6C\x9A']) or 0

local ASSET = require(script:WaitForChild("ASSET"))

UI = script:WaitForChild'UI'
local UIHealth = UI.Health
local UIBar = UIHealth.Bar
local UIBarText = UIHealth.TextLabel
UIBarText.Font=Enum.Font.SourceSansBold

__DEBUG_UI   = script:WaitForChild'DEBUG'
__DEBUG_TEXT = __DEBUG_UI:WaitForChild'TextLabel'

COORD, ANGLE = CFrame.new, CFrame.Angles
V3, COLOR = Vector3.new, Color3.new

BEZIER_CURVE_CONSTANT = 1.55228474983079
HB_COLOR_NORMAL = COLOR (1,0,0)
HB_COLOR_SWEET = COLOR (0,0,1)
HB_COLOR_SOUR = COLOR (1,0,1)
HB_COLOR_DETECT = COLOR (1,1,0)

BUSY = 0
TICK = 0
ANIM_BUSY = false

ANIM_LIST = script:WaitForChild("ANIM")
ANIM_IDLE = ANIM_LIST:WaitForChild("IDLE")
ANIM_RUN  = ANIM_LIST:WaitForChild("RUN")
ANIM_JUMP = ANIM_LIST:WaitForChild("JUMP")
ANIM_GET = function(input) return ANIM_LIST:FindFirstChild(input) end

SND_SLASH = {ID='http://www.roblox.com/asset/?id=12222216',START=0.3,END=60000}
SND_LUNGE = {ID='http://www.roblox.com/asset/?id=12222208',START=0,END=60000}
SND_SHEATHE = {ID='http://www.roblox.com/asset/?id=12222225',START=0,END=60000}
SND_BLOCK = {ID='rbxassetid://4766120815',START=0,END=60000}
SND_SPC = {ID='rbxassetid://8285477344',START=0,END=60000}
SND_SPCSHORT = {ID='rbxassetid://8386783529',START=0,END=60000}
SND_MAGIC = {ID='rbxassetid://438666196',START=0,END=60000}
SND_CHARGE = {ID='rbxassetid://4995664881',START=0,END=60000}
SND_CUT0 = {ID='rbxassetid://7171761940',START=0.2,END=60000}
SND_CUT1 = {ID='rbxassetid://5473058688',START=0,END=60000}
SND_CUT2 = {ID='rbxassetid://7072652156',START=0,END=60000}
SND_CUT3 = {ID='rbxassetid://7072651886',START=0,END=60000}

SND_MARKER = {ID='rbxassetid://7242037470',START=0,END=60000}

COMBO = 0
COMBO_TIMER = 0
HIT_STOP = 0
RUNNING = false
MIDAIR = false
ATTACKING = false
ATTACKWHIFF = false
ATTACKLANDED = false

----------------------------------------------------------------------------------------------------

Remote = script:WaitForChild('$REMOTE')

Model = script.Parent                                  Chrono.Model = Model
thisPlayer = Player(Model.name)                        Chrono.Player = thisPlayer
Humanoid = Model:FindFirstChildOfClass("Humanoid")     Chrono.Humanoid = Humanoid
Animator = require(Model:WaitForChild('Animator'))     Chrono.Animator = Animator

Humanoid.DisplayName = thisPlayer~=nil and thisPlayer.DisplayName or nil

Sword = Model:WaitForChild("Sword")
SWORD_TRAIL = false ; __SWORD_TRAIL_INST = Sword.SWORD_TERT.Trail
SWORD_PARTICLE = false

HUMANOIDS = {}
LOCKED = nil
LOCKED_TIMER = 0

----------------------------------------------------------------------------------------------------

ROOT = 'HumanoidRootPart'
HEAD = 'Head' ; TORSO = 'Torso'
ARM_R = 'Right Arm' ; ARM_L = 'Left Arm' ; LEG_R = 'Right Leg' ; LEG_L = 'Left Leg'
HAND_R = 'Right Hand' ; HAND_L = 'Left Hand'

J_ROOT = 'RootJoint'
J_NECK = 'Neck'
J_SHOULDER_R = 'Right Shoulder' ; J_SHOULDER_L = 'Left Shoulder' ; J_HIP_R = 'Right Hip' ; J_HIP_L = 'Left Hip'
J_WRIST_R = 'Right Wrist' ; J_WRIST_L = 'Left Wrist'
J_GET = function(n) for _,b in Model:GetDescendants() do if(b:IsA("Motor6D") and b.Name==n) then return b end end end

Model_Body = {
     [ROOT] = Model:WaitForChild(ROOT);
     [HEAD] = Model:WaitForChild(HEAD);
     [TORSO] = Model:WaitForChild(TORSO);
     [ARM_R] = Model:WaitForChild(ARM_R);
     [ARM_L] = Model:WaitForChild(ARM_L);
     [LEG_R] = Model:WaitForChild(LEG_R);
     [LEG_L] = Model:WaitForChild(LEG_L);
     [HAND_R] = Model:WaitForChild(HAND_R);
     [HAND_L] = Model:WaitForChild(HAND_L);
}
Model_Joints_Basic = {}
Model_Joints = {
     [ROOT] = J_GET(J_ROOT);
     [TORSO] = J_GET(J_ROOT);
     [HEAD] = J_GET(J_NECK);
     [ARM_R] = J_GET(J_SHOULDER_R);
     [ARM_L] = J_GET(J_SHOULDER_L);
     [LEG_R] = J_GET(J_HIP_R);
     [LEG_L] = J_GET(J_HIP_L);
     [HAND_R] = J_GET(J_WRIST_R);
     [HAND_L] = J_GET(J_WRIST_L);
}

ROTATION = Instance.new('BodyGyro',Model_Body[ROOT])
ROTATION.D = 0
ROTATION_TIMER = 0

for name,joint in Model_Joints do
Model_Joints_Basic [name] = joint.C0
end

print('Body:',Model_Body)
print('Joints:',Model_Joints)
print('Joint Basics:',Model_Joints_Basic)

----------------------------------------------------------------------------------------------------

ANIM_QUERY = function( INST )
Animator:PLAY(INST)
end
ANIM_QUERY_SAFE = function(INST)
if(Animator.CURRENT ~= INST) then ANIM_QUERY(INST) return true else return false end
end
ANIM_POSE = function(LIST)
Animator:POSE(LIST)
end

TAG_HAS = function( subject : Instance, tag : string ) return subject:HasTag(tag) end
TAG_SET = function( subject : Instance, tag : string|boolean? ) if (tag) then subject:AddTag(tag) else subject:RemoveTag(tag) end end
TAG_GET = function( tag : string ) return Service'CollectionService':GetTagged(tag) end

function GET_HUMANOID ( subject : Model )
     if (subject and subject:FindFirstChildOfClass'Humanoid') then
          return subject:FindFirstChildOfClass'Humanoid'
          end
     end

function GET_ROOT ( subject : Model )
     local humanoid = GET_HUMANOID (subject)
     local root = (humanoid~=nil) and (humanoid.RootPart or subject.PrimaryPart
          or subject:FindFirstChild'HumanoidRootPart' or subject:FindFirstChild'RootPart'
          or subject:FindFirstChild'Torso' or subject:FindFirstChild'LowerTorso' or subject:FindFirstChild'UpperTorso'
          or subject:FindFirstChild'Head'
          or subject:FindFirstChildOfClass'BasePart') or nil
     return root
     end

function GET_PLAYER ( subject : Model ) -- for continuity purposes, Player(hit) would look weird
     return Player(subject)
     end

function GET_RIG_TYPE ( subject : Model )
     local humanoid = GET_HUMANOID (subject)
     if (humanoid) then
          return humanoid.RigType
          end
     end

function GET_HEALTH ( subject : Model )
     local humanoid = GET_HUMANOID (subject)
     if (humanoid) then
          return humanoid.Health
          end
     end

function SET_HEALTH ( subject : Model, value : number )
     local humanoid = GET_HUMANOID (subject)
     if (humanoid) then
          humanoid.Health = value
          end
     end

function GET_TEAM ( subject : Model )
     local thatPlayer = GET_PLAYER(subject)
     return thatPlayer~=nil and thatPlayer.Team or nil
     end

function GET_ARE_YOU_A_TEAMMATE ( subject : Model )
     local thatPlayerTeam = GET_TEAM(subject)
     local thisPlayerTeam = GET_TEAM(Model)
     return (thisPlayerTeam ~= nil and thatPlayerTeam ~= nil and thatPlayerTeam == thisPlayerTeam)
     end

function GET_LOOK ( subject : Model )
     local subject = subject == nil and Model or subject
     return subject:GetPivot().LookVector
     end

function SET_LOOK ( subject : Model, Look : CFrame )
     local Look = (subject ~= nil and Look == nil) and subject or Look
     local subject = typeof(subject) == 'CFrame' and Model or subject
     local _,Y,_ = COORD(subject:GetPivot().p,Look.p):ToEulerAnglesYXZ()
     local X,_,Z = subject:GetPivot():ToEulerAnglesYXZ()
     ROTATION_TIMER=60
     ROTATION.CFrame = COORD(subject:GetPivot().p)*ANGLE(X,Y,Z)
     end

function SET_LOOK_AT_NEAREST ()
     if (not LOCKED) then
          local result = nil
          local magnitude = 1000
          for _,Hum in HUMANOIDS do
               if (Hum and Hum.Parent) then
                    local thatRoot = GET_ROOT(Hum.Parent)
                    local thatMagnitude = thatRoot ~= nil and (thatRoot.CFrame.p-Model_Body[ROOT].CFrame.p).Magnitude or nil
                    if(thatMagnitude and thatMagnitude<=magnitude) then
                         magnitude = thatMagnitude
                         result = thatRoot
                    end
               end
          end
          if (result) then SET_LOOK ( result.CFrame ) end
     else
          SET_LOOK ( LOCKED:GetPivot() )
     end
end

function SET_SOUND ( THING, resident, pitch, volume )
     local SND = Instance.new('Sound',resident)
     SND.SoundId = THING.ID
     SND.TimePosition = THING.START
     SND.Pitch = pitch or 1
     SND.Volume = volume or 0.5
     SND.PlayOnRemove = true
     SND.Parent = resident
     SND:Destroy()
     end

function FRAME ( frame_data )
     for i=1,frame_data.Frames do
          if(HIT_STOP>0) then repeat task.wait() until HIT_STOP<=0 end
          if(frame_data.Pass) then if frame_data.Pass(i)=="$stop" then break end end
          task.wait()
          end
     end

function SET_DEBRIS ( object, time, waiter )
     task.spawn(function()
     if(waiter) then
          FRAME{Frames=math.ceil(time*60)}
     else task.wait(time) end
     if (object ~= nil and object.Parent ~= nil) then object:Destroy() return end
     return end)
     end

function SET_COMBO ( combo_add,combo_timer )
     COMBO += combo_add
     COMBO_TIMER = combo_timer
     end

HITBOXES = {}
function HITBOX ( ID, PART, host, size, offset, time, hitOwner, color, f )
     HITBOXES [ID] = HITBOXES [ID] or {['$result']={}}
     local HB = Instance.new('Part')
     HB.Material = Enum.Material.ForceField
     HB.Color = color or HB_COLOR_NORMAL
     HB.Size = size or V3(1,1,1)
     HB.CFrame = host~=nil and host.CFrame or offset
     HB.Anchored = false ; HB.CanCollide = false ; HB.CanQuery = false ; HB.CanTouch = false ; HB.CastShadow = false ; HB.Massless = true
     HB.Transparency = _G.DEBUG and 0 or 1
     if (_G.DEBUG) then
          local BB = Instance.new('BillboardGui',HB)
               BB.Size = UDim2.new(2,0,2,0)
               BB.AlwaysOnTop = true
          local IM = Instance.new('ImageLabel',BB)
               IM.BackgroundTransparency = 1
               IM.ImageTransparency = 0.5
               IM.Image = 'rbxassetid://12914100145'
               IM.Size = UDim2.new(1,0,1,0)
               BB.Parent = HB
          end
     if (host) then
          local Weld = Instance.new('Weld')
          Weld.Part0 = host
          Weld.Part1 = HB
          Weld.C1 = offset
          Weld.Parent = HB
          end
     if(HITBOXES [ID] [PART] ~= nil and HITBOXES [ID] [PART].Parent) then HITBOXES [ID] [PART]:Destroy() end
     HITBOXES [ID] [PART] = HB
     HB.Parent = workspace
     SET_DEBRIS(HB,time/60 or 0.1,true)
     local HBCONNECT;HBCONNECT = OnTick(function()
          local thisTICK = TICK
          if(HB and HB.Parent) then
               local got = workspace:GetPartBoundsInBox(HB.CFrame,HB.Size)
               if (got) then
                    for _,hit in got do
                         local that = hit.Parent
                         local thatHumanoid = GET_HUMANOID(that)
                         local thatRoot = GET_ROOT(that)
                         if(that and thatHumanoid and thatRoot and (not HITBOXES [ID] ['$result'] [that]) and ((hitOwner) and true or not hit:IsDescendantOf(Model)) and (not GET_ARE_YOU_A_TEAMMATE(that))) then
                              HITBOXES [ID] ['$result'] [that] = {hit=hit,humanoid=thatHumanoid,root=thatRoot,tick=thisTICK,part=PART}
                              if(f) then f(ID,PART,hit,that,thatHumanoid,thatRoot,thisTICK) end
                         end
                    end
               end
          else HBCONNECT:Disconnect() end
     end)
end

function HL ( OBJ, TR, oTR, COLOR, oCOLOR, time )
     local IT = Instance.new('Highlight')
     IT.Adornee = OBJ
     IT.FillTransparency = TR
     IT.OutlineTransparency = oTR
     IT.FillColor=COLOR
     IT.OutlineColor=oCOLOR
     IT.Parent = OBJ
     Service'TweenService':Create(IT,TweenInfo.new(time,Enum.EasingStyle.Linear,Enum.EasingDirection.In,0,false,0),{FillTransparency=1,OutlineTransparency=1}):Play()
     SET_DEBRIS(IT, time)
end

function AFTERIMAGE ( subject : Model )
     for _,x in subject:GetDescendants() do
          if (x:IsA("BasePart")) then
               local q = x:Clone()
               q.Anchored = true
               q.CastShadow = false
               q.Material = Enum.Material.Neon
               q.CanCollide = false ; q.CanQuery = false ; q.CanTouch = false
               q.Color = COLOR(1,1,1)
               q:ClearAllChildren()
               q.Parent = workspace
               Service'TweenService':Create(q,TweenInfo.new(0.5,Enum.EasingStyle.Linear,Enum.EasingDirection.In,0,false,0),{Transparency=q.Transparency+1}):Play()
               SET_DEBRIS(q,0.5)
               end
          end
end

function KNOCKBACK ( knockback_data )
local Root = GET_ROOT (knockback_data [1])
for _,x in Root:GetChildren() do if x:IsA('BodyVelocity') then x:Destroy() end end
local Bv = Instance.new('BodyVelocity')
Bv.Velocity = knockback_data.Velocity
Bv.MaxForce = knockback_data.MaxForce or V3(1e13,1e13,1e13)
Bv.Parent = Root
SET_DEBRIS(Bv, knockback_data.Time or 0.1, true)
end

function DAMAGE ( damage_data )
     local that = damage_data.that
     HL(that.Model,0,1,COLOR(1,1,1),COLOR(1,1,1),0.5)
     SET_SOUND(SND_MARKER,that.Root,1,1)
     local assetX do for _,x in that.Model:GetChildren() do if (x.Name=="HITSTOP_SHAKE" and x:GetAttribute("HITSTOP")) then assetX=x end end end
     if(not assetX) then
     assetX = ASSET("HITSTOP_SHAKE")
     assetX.Enabled=true
     assetX:SetAttribute("HITSTOP",damage_data.HitStop)
     assetX.Parent=that.Model
     else assetX:SetAttribute("HITSTOP",damage_data.HitStop) end

     local DAMAGE_THING = Instance.new("Part")
     DAMAGE_THING.Size = Vector3.zero
     DAMAGE_THING.Transparency = 1
     DAMAGE_THING.CanCollide = false ; DAMAGE_THING.CanTouch = false ; DAMAGE_THING.CanQuery = false
     DAMAGE_THING.CFrame = that.Root.CFrame
     DAMAGE_THING.Velocity = V3(math.random(-12,12),math.random(30,60),math.random(-12,12))
     DAMAGE_THING.Parent = workspace

     local DAMAGE_UI = Instance.new("BillboardGui",DAMAGE_THING)
     DAMAGE_UI.Size=UDim2.new(100,0,2,0)
     DAMAGE_UI.AlwaysOnTop=true

     local DAMAGE_TXT = Instance.new("TextLabel",DAMAGE_UI)
     DAMAGE_TXT.Text = string.format('%.1f',damage_data.Damage)
     DAMAGE_TXT.Font = Enum.Font.SourceSansBold
     DAMAGE_TXT.TextScaled = 1
     DAMAGE_TXT.TextColor3 = (damage_data.Damage>=20) and COLOR(1,0,0) or (damage_data.Damage>=8) and COLOR(0.5,1,0) or (damage_data.Damage>=3) and COLOR(1,1,0) or COLOR(1,1,1)
     DAMAGE_TXT.TextStrokeTransparency = 0
     DAMAGE_TXT.BackgroundTransparency = 1
     DAMAGE_TXT.Size=UDim2.new(1,0,1,0)
     Service'TweenService':Create(DAMAGE_UI,TweenInfo.new(0.2,Enum.EasingStyle.Linear,Enum.EasingDirection.In,0,false,0.8),{Size=UDim2.new(0,0,0,0)}):Play()

     SET_DEBRIS(DAMAGE_THING, 1)

     SET_HEALTH(that.Model, GET_HEALTH(that.Model)-math.ceil(damage_data.Damage*10))

     HIT_STOP+=damage_data.HitStop or 0
end

--- attack_data BASE ---
--[[--

ATTACK { Frames=1, Whiff=0, Hitboxes={ [0]={[0]={Damage=1.0,DamageType='',HitStop=0,HitStun=0, Knockback=GET_LOOK()*2,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT0,Pitch=1.0,Volume=0.6}, Rehit=0, Host=Model_Body[ROOT],Size=V3(0,0,0),Off=COORD(0,0,0),Frames=60,HitOwner=false,Color=HB_COLOR_NORMAL, Special={}}} }, FrameSpecial={} }

--]]--
function ATTACK ( attack_data )
     ATTACKING = true
     ATTACKWHIFF = true
     ATTACKLANDED = false
     HITBOXES = {}
     local thisTICK = TICK
     for HB_ID,HB_ID_CONTENT in attack_data.Hitboxes do
          for HB_PART,HB_DATA in HB_ID_CONTENT do
               HITBOX (HB_ID, HB_PART, HB_DATA.Host, HB_DATA.Size, HB_DATA.Off, HB_DATA.Frames, HB_DATA.HitOwner, HB_DATA.Color,
               function(ID,PART,hit,that,thatHumanoid,thatRoot,thatTICK)
                    ATTACKWHIFF = false ; ATTACKLANDED = true
                    LOCKED = LOCKED or thatRoot ; LOCKED_TIMER = 300
                    DAMAGE { Damage=HB_DATA.Damage,DamageType=HB_DATA.DamageType,HitStop=HB_DATA.HitStop,HitStun=HB_DATA.HitStun,that={Model=that,Humanoid=thatHumanoid,Root=thatRoot} }
                    KNOCKBACK { that, Velocity=HB_DATA.Knockback, MaxForce=HB_DATA.MaxForce, Time=HB_DATA.KnockbackTime }
                    if HB_DATA.Recoil then
                         KNOCKBACK { this, Velocity=HB_DATA.Recoil, MaxForce=HB_DATA.MaxForce, Time=HB_DATA.KnockbackTime }
                    end
                    SET_SOUND(HB_DATA.Sound.data,thatRoot,HB_DATA.Sound.Pitch,HB_DATA.Sound.Volume)
                    if (HB_DATA.Rehit>0) then
                         task.delay(HB_DATA.Rehit/60,function()
                              if(HITBOXES [ID] ['$result'] [that] and HITBOXES [ID] ['$result'] [that].tick==thatTICK) then
                                   HITBOXES [ID] ['$result'] [that]=nil
                              end
                         end)
                    end
               end)

               end
          end
     
     FRAME{Frames=attack_data.Frames,Pass=function(i) if(attack_data.FrameSpecial and attack_data.FrameSpecial[i]) then attack_data.FrameSpecial[i]() end end}
     if(ATTACKWHIFF and attack_data.Whiff>0) then
          FRAME{Frames=attack_data.Whiff}
     end
     ATTACKING = false

end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

-----------------
if(IsServer) then
-----------------

for _,x in workspace:GetDescendants() do if x:IsA('Humanoid') and x~=Humanoid then HUMANOIDS [#HUMANOIDS+1] = x end end
workspace.DescendantAdded:Connect(function(x) if x:IsA('Humanoid') and x~=Humanoid then HUMANOIDS [#HUMANOIDS+1] = x end end)

do
Humanoid.Running:Connect(function(spd)
     MIDAIR=false
     if(spd>0.01) then RUNNING=true else RUNNING=false end
     end)

Humanoid.Jumping:Connect(function()
     MIDAIR=true
     end)
Humanoid.FreeFalling:Connect(function()
     MIDAIR=true
     end)
end

IMMUNE = false
local HEALTH_INDEX = 0
local HEALTH_OLD = Humanoid.Health
local function HEALTH_UI_THING(v,color)
     local x = UIBarText:Clone()
     x.Text = v
     x.Size = UDim2.new(2,0,2,0)
     x.TextColor3 = color
     x.Parent = UIHealth
     Service'TweenService':Create(x,TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0),{Position=x.Position+UDim2.new(0,0,-5,0)}):Play()
     Service'TweenService':Create(x,TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0.8),{Size=UDim2.new(0,0,0,0)}):Play()
     SET_DEBRIS(x,1)
end
Humanoid.HealthChanged:Connect(function(HEALTH_NEW)
     local thisHEALTH_INDEX = HEALTH_INDEX+1
     HEALTH_INDEX=thisHEALTH_INDEX
     if (HEALTH_NEW<HEALTH_OLD and (BLOCKING or IMMUNE)) then
          Humanoid.Health=HEALTH_OLD
          if (BLOCKING) then
               KNOCKBACK { Model,Velocity = GET_LOOK()*-2 }
               SET_SOUND (SND_BLOCK,Model_Body[ROOT],1.0,0.4)
               ANIM_QUERY(ANIM_GET'BLOCKED')
          end
     elseif (HEALTH_NEW<HEALTH_OLD) then
          HEALTH_UI_THING(string.format('<i>%.1f</i>',(HEALTH_NEW-HEALTH_OLD)/10),COLOR(1,0,0))
     elseif (HEALTH_NEW>HEALTH_OLD) then
          HEALTH_UI_THING(string.format('<i>+%.1f</i>',(HEALTH_NEW-HEALTH_OLD)/10),COLOR(0,1,0))
     end
     HEALTH_OLD=Humanoid.Health
end)

Chrono.loop = OnTick(function()
Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding,false)
Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
TICK += 1
LOCKED = LOCKED_TIMER>0 and LOCKED or nil
LOCKED_TIMER = LOCKED_TIMER>0 and LOCKED_TIMER-1 or 0
COMBO = COMBO_TIMER>0 and COMBO or 0
COMBO_TIMER = COMBO_TIMER>0 and ((HIT_STOP<=0 and not BLOCKING) and COMBO_TIMER-1 or COMBO_TIMER) or 0
INPUTBEFORE = INPUTBEFORE_TIMER>0 and INPUTBEFORE or ''
INPUTBEFORE_TIMER = INPUTBEFORE_TIMER>0 and INPUTBEFORE_TIMER-1 or 0
HIT_STOP = HIT_STOP>0 and HIT_STOP-1 or 0
ROTATION.MaxTorque = ROTATION_TIMER>0 and V3(0,math.huge,0) or V3(0,0,0)
ROTATION_TIMER = ROTATION_TIMER>0 and (HIT_STOP<=0 and ROTATION_TIMER-1 or ROTATION_TIMER) or 0
Animator.BUSY = HIT_STOP>0
Model_Body[ROOT].Anchored = HIT_STOP>0

UIBar.Size=UDim2.new(Humanoid.Health/Humanoid.MaxHealth,0,1,0)
UIBar.BackgroundColor3 = (Humanoid.Health>=Humanoid.MaxHealth/2) and COLOR(0.29,1,0.3) or (Humanoid.Health>=Humanoid.MaxHealth/4) and COLOR(1,1,0) or COLOR(1,0,0)
UIBarText.Text=Humanoid.Health>0 and string.format('HP: %.1f/%.1f',Humanoid.Health/10,Humanoid.MaxHealth/10) or '<b><i>DEAD</i></b>'

if(BLOCKING) then
     SET_LOOK_AT_NEAREST()
end

for _,v in Model_Body do
     if(v : CanSetNetworkOwnership()) then
          v : SetNetworkOwner(nil)
     end
end

local function ANIMDEFAULT()
          if(not MIDAIR) then
               if(not RUNNING) then
                    ANIM_QUERY_SAFE(ANIM_IDLE)
               else
                    ANIM_QUERY_SAFE(ANIM_RUN)
               end
          else
               ANIM_QUERY_SAFE(ANIM_JUMP)
          end
     end

if(Animator.CURRENT) then
     if(not ANIM_BUSY) then
     ANIMDEFAULT()
     end
else
     if(not ANIM_BUSY) then
     ANIMDEFAULT()
     end
end

__SWORD_TRAIL_INST.Enabled = __SWORD_TRAIL_INST.MaxLength>=0.012
__SWORD_TRAIL_INST.MaxLength = SWORD_TRAIL and 15 or __SWORD_TRAIL_INST.MaxLength+(0.01-__SWORD_TRAIL_INST.MaxLength)*0.12

__DEBUG_TEXT.Text = [[-- CHRONO DEBUGGING --
]]..[[アニメ：]]..(Animator.CURRENT~=nil and Animator.CURRENT:GetFullName() or "無し")..[[　
アニメ　フレム：]]..tostring(Animator.TICK)..[[/]]..tostring(math.ceil(Animator.LENGTH*60))..[[　
アニメ　秒：　]]..tostring(Animator.TICK_SEC)..[[/]]..tostring(Animator.LENGTH)..[[　
アニメ　中：　]]..tostring(Animator.PLAYING)..[[　
アニメ　ループ：　]]..tostring(Animator.LOOPED)..[[　

RUNNING：　]]..tostring(RUNNING)..[[　
MID-AIR：　]]..tostring(MIDAIR)..[[　
COMBO：　]]..tostring(COMBO)..(COMBO_TIMER>0 and ' ('..tostring(COMBO_TIMER)..')' or '（、；ｖ；）')..[[　
INPUT：　]]..(INPUTBEFORE_TIMER>0 and INPUTBEFORE or '無し')..[[　
ATTACKING：　]]..tostring(ATTACKING)..(ATTACKWHIFF and ' (WHIFFED)' or '')..(ATTACKLANDED and ' (HIT)' or '')..[[　
]]
end)

----------------------------------------------------------------------------------------------------

function INPUT_ATTACK()
if (BUSY<=0) then

     -- ATTACK_A10 --
     if (INPUTBEFORE=='↑') then
     SET_COMBO(1,60)
     BUSY+=1
     ANIM_BUSY=true
     ANIM_QUERY(ANIM_GET('ATTACK_A01'))
     SET_LOOK_AT_NEAREST()
     AFTERIMAGE( Model )
     FRAME{Frames=5}
     SET_SOUND(SND_LUNGE,Sword.PrimaryPart,1.5)
     KNOCKBACK { Model, Velocity=GET_LOOK()*9 }
     SWORD_TRAIL=true
     ATTACK { Frames=20, Whiff=12, Hitboxes={ [0]={
          [0]={Damage=2.5,DamageType='',HitStop=3,HitStun=0, Knockback=GET_LOOK()*9,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT1,Pitch=1.0,Volume=0.6}, Rehit=4, Host=Model_Body[HAND_R],Size=V3(1,6,7),Off=COORD(0,0,-3.5),Frames=19,HitOwner=false,Color=HB_COLOR_SOUR, Special={}},
          [1]={Damage=3.0,DamageType='',HitStop=12,HitStun=0, Knockback=GET_LOOK()*11,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT1,Pitch=1.0,Volume=0.8}, Rehit=13, Host=Model_Body[HAND_R],Size=V3(3,6,4),Off=COORD(0,0,-8),Frames=19,HitOwner=false,Color=HB_COLOR_SWEET, Special={}}} }, FrameSpecial={[12]=function() SWORD_TRAIL=false end} }
     BUSY-=1
     ANIM_BUSY=false
     return
     end

     -- ATTACK_A11 --
     if (INPUTBEFORE=='↑↑') then
     SET_COMBO(1,60)
     BUSY+=1
     ANIM_BUSY=true
     ANIM_QUERY(ANIM_GET('ATTACK_A00'))
     SET_LOOK_AT_NEAREST()
     SET_SOUND(SND_SHEATHE,Sword.PrimaryPart,1.5)
     KNOCKBACK { Model, Velocity=GET_LOOK()*70 }
     AFTERIMAGE( Model )
     FRAME{Frames=14}
     SET_SOUND(SND_LUNGE,Sword.PrimaryPart,0.9)
     KNOCKBACK { Model, Velocity=GET_LOOK()*-70 }
     SWORD_TRAIL=true
     ATTACK { Frames=20, Whiff=12, Hitboxes={ [0]={
          [0]={Damage=4.0,DamageType='',HitStop=3,HitStun=0, Knockback=GET_LOOK()*-20,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT3,Pitch=1.0,Volume=0.6}, Rehit=4, Host=Model_Body[HAND_R],Size=V3(6,6,7),Off=COORD(0,0,-3.5),Frames=6,HitOwner=false,Color=HB_COLOR_SOUR, Special={}},
          [1]={Damage=4.0,DamageType='',HitStop=12,HitStun=0, Knockback=GET_LOOK()*-25,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT3,Pitch=1.0,Volume=0.8}, Rehit=13, Host=Model_Body[HAND_R],Size=V3(1,1,4),Off=COORD(0,0,-8),Frames=6,HitOwner=false,Color=HB_COLOR_SWEET, Special={}}} }, FrameSpecial={[12]=function() SWORD_TRAIL=false end} }
     BUSY-=1
     ANIM_BUSY=false
     return
     end

     --- ATTACK_A0 series ---
     if (not MIDAIR) then
     if (COMBO==0) then

     SET_COMBO(1,60)
     BUSY+=1
     ANIM_BUSY=true
     ANIM_QUERY(ANIM_GET('ATTACK_A00'))
     SET_LOOK_AT_NEAREST()
     FRAME{Frames=4}
     SET_SOUND(SND_SLASH,Sword.PrimaryPart,1.1)
     KNOCKBACK { Model, Velocity=GET_LOOK()*13 }
     SWORD_TRAIL=true
     ATTACK { Frames=26, Whiff=15, Hitboxes={ [0]={
          [0]={Damage=1.0,DamageType='',HitStop=6,HitStun=0, Knockback=GET_LOOK()*15,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT2,Pitch=1.0,Volume=0.6}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(1,6,7),Off=COORD(0,0,-3.5),Frames=12,HitOwner=false,Color=HB_COLOR_SOUR, Special={}},
          [1]={Damage=1.5,DamageType='',HitStop=12,HitStun=0, Knockback=GET_LOOK()*20,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT2,Pitch=1.0,Volume=0.8}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(3,6,4),Off=COORD(0,0,-8),Frames=12,HitOwner=false,Color=HB_COLOR_SWEET, Special={}}} }, FrameSpecial={[12]=function() SWORD_TRAIL=false end} }
     BUSY-=1
     ANIM_BUSY=false
     
     elseif (COMBO==1) then

     SET_COMBO(1,60)
     BUSY+=1
     ANIM_BUSY=true
     ANIM_QUERY(ANIM_GET('ATTACK_A01'))
     SET_LOOK_AT_NEAREST()
     FRAME{Frames=5}
     SET_SOUND(SND_SLASH,Sword.PrimaryPart,1)
     KNOCKBACK { Model, Velocity=GET_LOOK()*9 }
     SWORD_TRAIL=true
     ATTACK { Frames=20, Whiff=12, Hitboxes={ [0]={
          [0]={Damage=1.0,DamageType='',HitStop=3,HitStun=0, Knockback=GET_LOOK()*9,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT1,Pitch=1.0,Volume=0.6}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(1,6,7),Off=COORD(0,0,-3.5),Frames=19,HitOwner=false,Color=HB_COLOR_SOUR, Special={}},
          [1]={Damage=1.5,DamageType='',HitStop=12,HitStun=0, Knockback=GET_LOOK()*11,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT1,Pitch=1.0,Volume=0.8}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(3,6,4),Off=COORD(0,0,-8),Frames=19,HitOwner=false,Color=HB_COLOR_SWEET, Special={}}} }, FrameSpecial={[12]=function() SWORD_TRAIL=false end} }
     BUSY-=1
     ANIM_BUSY=false
     
     elseif (COMBO==2) then

     SET_COMBO(1,60)
     BUSY+=1
     ANIM_BUSY=true
     ANIM_QUERY(ANIM_GET('ATTACK_A02'))
     SET_LOOK_AT_NEAREST()
     FRAME{Frames=4}
     SET_SOUND(SND_SLASH,Sword.PrimaryPart,1.2)
     KNOCKBACK { Model, Velocity=GET_LOOK()*9 }
     SWORD_TRAIL=true
     ATTACK { Frames=23, Whiff=10, Hitboxes={ [0]={
          [0]={Damage=1.0,DamageType='',HitStop=3,HitStun=0, Knockback=GET_LOOK()*9,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT1,Pitch=1.0,Volume=0.6}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(1,6,7),Off=COORD(0,0,-3.5),Frames=19,HitOwner=false,Color=HB_COLOR_SOUR, Special={}},
          [1]={Damage=1.5,DamageType='',HitStop=12,HitStun=0, Knockback=GET_LOOK()*9,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT1,Pitch=1.0,Volume=0.8}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(3,6,4),Off=COORD(0,0,-8),Frames=19,HitOwner=false,Color=HB_COLOR_SWEET, Special={}}} }, FrameSpecial={[12]=function() SWORD_TRAIL=false end} }
     BUSY-=1
     ANIM_BUSY=false
     
     elseif (COMBO==3) then

     SET_COMBO(1,60)
     BUSY+=1
     ANIM_BUSY=true
     ANIM_QUERY(ANIM_GET('ATTACK_A03'))
     SET_LOOK_AT_NEAREST()
     FRAME{Frames=5}
     SET_SOUND(SND_LUNGE,Sword.PrimaryPart,1.5)
     KNOCKBACK { Model, Velocity=GET_LOOK()*12 }
     SWORD_TRAIL=true
     ATTACK { Frames=13, Whiff=11, Hitboxes={ [0]={
          [0]={Damage=1.0,DamageType='',HitStop=3,HitStun=0, Knockback=GET_LOOK()*12,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT0,Pitch=1.0,Volume=0.6}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(1,6,7),Off=COORD(0,0,-3.5),Frames=9,HitOwner=false,Color=HB_COLOR_SOUR, Special={}},
          [1]={Damage=1.5,DamageType='',HitStop=12,HitStun=0, Knockback=GET_LOOK()*14,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT0,Pitch=1.0,Volume=0.8}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(3,6,4),Off=COORD(0,0,-8),Frames=9,HitOwner=false,Color=HB_COLOR_SWEET, Special={}}} }, FrameSpecial={[8]=function() SWORD_TRAIL=false end} }
     BUSY-=1
     ANIM_BUSY=false
     
     elseif (COMBO==4) then

     SET_COMBO(1,60)
     BUSY+=1
     ANIM_BUSY=true
     ANIM_QUERY(ANIM_GET('ATTACK_A04'))
     SET_LOOK_AT_NEAREST()
     FRAME{Frames=4}
     SET_SOUND(SND_LUNGE,Sword.PrimaryPart,1.3)
     KNOCKBACK { Model, Velocity=GET_LOOK()*9 }
     SWORD_TRAIL=true
     ATTACK { Frames=11, Whiff=11, Hitboxes={ [0]={
          [0]={Damage=0.5,DamageType='',HitStop=3,HitStun=0, Knockback=GET_LOOK()*9,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT0,Pitch=1.0,Volume=0.6}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(3,6,7),Off=COORD(0,0,-3.5),Frames=9,HitOwner=false,Color=HB_COLOR_SOUR, Special={}},
          [1]={Damage=1.0,DamageType='',HitStop=12,HitStun=0, Knockback=GET_LOOK()*9,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT0,Pitch=1.0,Volume=0.8}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(3,6,4),Off=COORD(0,0,-8),Frames=9,HitOwner=false,Color=HB_COLOR_SWEET, Special={}}} }, FrameSpecial={[8]=function() SWORD_TRAIL=false end} }
     BUSY-=1
     ANIM_BUSY=false
     
     elseif (COMBO==5) then

     SET_COMBO(1,60)
     BUSY+=1
     ANIM_BUSY=true
     ANIM_QUERY(ANIM_GET('ATTACK_A05'))
     SET_LOOK_AT_NEAREST()
     FRAME{Frames=3}
     SET_SOUND(SND_LUNGE,Sword.PrimaryPart,1.45)
     KNOCKBACK { Model, Velocity=GET_LOOK()*9 }
     SWORD_TRAIL=true
     ATTACK { Frames=17, Whiff=12, Hitboxes={ [0]={
          [0]={Damage=0.5,DamageType='',HitStop=3,HitStun=0, Knockback=GET_LOOK()*9,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT1,Pitch=1.0,Volume=0.6}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(3,6,7),Off=COORD(0,0,-3.5),Frames=8,HitOwner=false,Color=HB_COLOR_SOUR, Special={}},
          [1]={Damage=1.0,DamageType='',HitStop=12,HitStun=0, Knockback=GET_LOOK()*9,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT1,Pitch=1.0,Volume=0.8}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(3,6,4),Off=COORD(0,0,-8),Frames=8,HitOwner=false,Color=HB_COLOR_SWEET, Special={}}} }, FrameSpecial={[8]=function() SWORD_TRAIL=false end} }
     BUSY-=1
     ANIM_BUSY=false
     
     elseif (COMBO==6) then

     SET_COMBO(1,70)
     BUSY+=1
     ANIM_BUSY=true
     ANIM_QUERY(ANIM_GET('ATTACK_A06'))
     SET_LOOK_AT_NEAREST()
     FRAME{Frames=9}
     SET_SOUND(SND_LUNGE,Sword.PrimaryPart,1)
     KNOCKBACK { Model, Velocity=GET_LOOK()*43, Time=0.4 }
     ATTACK { Frames=23, Whiff=10, Hitboxes={ [0]={
          [0]={Damage=2.0,DamageType='',HitStop=7,HitStun=0, Knockback=GET_LOOK()*43,KnockbackMax=nil,KnockbackTime=0.4, Sound={data=SND_CUT3,Pitch=1.0,Volume=0.6}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(1,6,7),Off=COORD(0,0,-3.5),Frames=19,HitOwner=false,Color=HB_COLOR_SOUR, Special={}},
          [1]={Damage=2.5,DamageType='',HitStop=14,HitStun=0, Knockback=GET_LOOK()*43,KnockbackMax=nil,KnockbackTime=0.4, Sound={data=SND_CUT3,Pitch=1.0,Volume=0.8}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(1,1,7),Off=COORD(0,0,-5),Frames=19,HitOwner=false,Color=HB_COLOR_SWEET, Special={}}} }, FrameSpecial={} }
     BUSY-=1
     ANIM_BUSY=false
     
     elseif (COMBO==7) then

     SET_COMBO(1,80)
     BUSY+=1
     ANIM_BUSY=true
     ANIM_QUERY(ANIM_GET('ATTACK_A07'))
     SET_LOOK_AT_NEAREST()
     FRAME{Frames=12}
     SET_SOUND(SND_SHEATHE,Sword.PrimaryPart,1.2)
     KNOCKBACK { Model, Velocity=GET_LOOK()*13 }
     SWORD_TRAIL=true
     ATTACK { Frames=13, Whiff=0, Hitboxes={ [0]={
          [0]={Damage=2.0,DamageType='',HitStop=9,HitStun=0, Knockback=GET_LOOK()*13,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT0,Pitch=1.0,Volume=0.6}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(12,10,7),Off=COORD(0,0,-3.5),Frames=8,HitOwner=false,Color=HB_COLOR_SOUR, Special={}},
          [1]={Damage=2.5,DamageType='',HitStop=12,HitStun=0, Knockback=GET_LOOK()*13,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT0,Pitch=1.0,Volume=0.8}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(5,8,4),Off=COORD(0,0,-8),Frames=8,HitOwner=false,Color=HB_COLOR_SWEET, Special={}}} }, FrameSpecial={[8]=function() SWORD_TRAIL=false end} }
     KNOCKBACK { Model, Velocity=GET_LOOK()*13 }
     SET_LOOK_AT_NEAREST()
     SWORD_TRAIL=true
     SET_SOUND(SND_SHEATHE,Sword.PrimaryPart,1.1)
     ATTACK { Frames=21, Whiff=4, Hitboxes={ [0]={
          [0]={Damage=3.0,DamageType='',HitStop=9,HitStun=0, Knockback=GET_LOOK()*13,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT0,Pitch=1.0,Volume=0.6}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(12,10,7),Off=COORD(0,0,-3.5),Frames=9,HitOwner=false,Color=HB_COLOR_SOUR, Special={}},
          [1]={Damage=3.5,DamageType='',HitStop=12,HitStun=0, Knockback=GET_LOOK()*13,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT0,Pitch=1.0,Volume=0.8}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(5,8,4),Off=COORD(0,0,-8),Frames=9,HitOwner=false,Color=HB_COLOR_SWEET, Special={}}} }, FrameSpecial={[8]=function() SWORD_TRAIL=false end} }
     BUSY-=1
     ANIM_BUSY=false
     
     elseif (COMBO==8) then

     SET_COMBO(1,80)
     BUSY+=1
     ANIM_BUSY=true
     ANIM_QUERY(ANIM_GET('ATTACK_A08'))
     SET_LOOK_AT_NEAREST()
     SET_SOUND(SND_SPCSHORT,Sword.PrimaryPart,1.1)
     SET_SOUND(SND_SHEATHE,Sword.PrimaryPart,1.0)
     HL(Model, 0,1,COLOR(1,1,1),COLOR(1,1,1),0.2)
     FRAME{Frames=24}
     SET_SOUND(SND_LUNGE,Sword.PrimaryPart,0.8)
     KNOCKBACK { Model, Velocity=GET_LOOK()*9 }
     SWORD_TRAIL=true
     ATTACK { Frames=24, Whiff=10, Hitboxes={ [0]={
          [0]={Damage=5.0,DamageType='',HitStop=3,HitStun=0, Knockback=GET_LOOK()*9,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT2,Pitch=1.0,Volume=0.6}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(1,6,7),Off=COORD(0,0,-3.5),Frames=11,HitOwner=false,Color=HB_COLOR_SOUR, Special={}},
          [1]={Damage=5.5,DamageType='',HitStop=12,HitStun=0, Knockback=GET_LOOK()*9,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT2,Pitch=1.0,Volume=0.8}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(3,6,4),Off=COORD(0,0,-8),Frames=11,HitOwner=false,Color=HB_COLOR_SWEET, Special={}}} }, FrameSpecial={[8]=function() SWORD_TRAIL=false end} }
     BUSY-=1
     ANIM_BUSY=false
     
     elseif (COMBO==9) then

     SET_COMBO(1,80)
     BUSY+=1
     ANIM_BUSY=true
     ANIM_QUERY(ANIM_GET('ATTACK_A09'))
     SET_LOOK_AT_NEAREST()
     SET_SOUND(SND_SPCSHORT,Sword.PrimaryPart,1.0)
     SET_SOUND(SND_SHEATHE,Sword.PrimaryPart,0.9)
     HL(Model, 0,1,COLOR(1,1,1),COLOR(1,1,1),0.2)
     KNOCKBACK { Model, Velocity=GET_LOOK()*-12 }
     FRAME{Frames=24}
     SET_SOUND(SND_LUNGE,Sword.PrimaryPart,0.7)
     KNOCKBACK { Model, Velocity=GET_LOOK()*9 }
     SWORD_TRAIL=true
     ATTACK { Frames=38, Whiff=5, Hitboxes={ [0]={
          [0]={Damage=5.0,DamageType='',HitStop=3,HitStun=0, Knockback=GET_LOOK()*9,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT3,Pitch=1.0,Volume=0.6}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(1,6,7),Off=COORD(0,0,-3.5),Frames=18,HitOwner=false,Color=HB_COLOR_SOUR, Special={}},
          [1]={Damage=5.5,DamageType='',HitStop=12,HitStun=0, Knockback=GET_LOOK()*9,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT3,Pitch=1.0,Volume=0.8}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(3,6,4),Off=COORD(0,0,-8),Frames=18,HitOwner=false,Color=HB_COLOR_SWEET, Special={}}} }, FrameSpecial={[20]=function() SWORD_TRAIL=false end} }
     BUSY-=1
     ANIM_BUSY=false
     
     elseif (COMBO==10) then

     SET_COMBO(0,0)
     BUSY+=1
     ANIM_BUSY=true
     ANIM_QUERY(ANIM_GET('ATTACK_A0A'))
     SET_LOOK_AT_NEAREST()
     SET_SOUND(SND_SPCSHORT,Sword.PrimaryPart,0.9)
     SET_SOUND(SND_SHEATHE,Sword.PrimaryPart,0.8)
     HL(Model, 0,1,COLOR(1,1,1),COLOR(1,1,1),0.2)
     FRAME{Frames=29}
     SET_SOUND(SND_LUNGE,Sword.PrimaryPart,0.5)
     KNOCKBACK { Model, Velocity=GET_LOOK()*54, Time=0.6 }
     ATTACK { Frames=45, Whiff=10, Hitboxes={ [0]={
          [0]={Damage=6.0,DamageType='',HitStop=20,HitStun=0, Knockback=GET_LOOK()*55,KnockbackMax=nil,KnockbackTime=0.6, Sound={data=SND_CUT3,Pitch=1.0,Volume=0.6}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(6,6,7),Off=COORD(0,0,-3.5),Frames=25,HitOwner=false,Color=HB_COLOR_SOUR, Special={}},
          [1]={Damage=6.5,DamageType='',HitStop=20,HitStun=0, Knockback=GET_LOOK()*56,KnockbackMax=nil,KnockbackTime=0.6, Sound={data=SND_CUT3,Pitch=1.0,Volume=0.8}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(1,1,4),Off=COORD(0,0,-8),Frames=25,HitOwner=false,Color=HB_COLOR_SWEET, Special={}}} }, FrameSpecial={} }
     BUSY-=1
     ANIM_BUSY=false

     end
     end

end
end

function INPUT_ABILITY()
if (BUSY<=0) then
     SET_LOOK_AT_NEAREST()
     FRAME{Frames=4}
end
end

function INPUT_CRITICAL()
if (BUSY<=0) then
     SET_LOOK_AT_NEAREST()
     FRAME{Frames=4}
end
end

INPUTBEFORE='' ; INPUTBEFORE_TIMER = 0
INPUTS={ATTACK=false,ABILITY=false,CRITICAL=false}
INPUTF={ATTACK=INPUT_ATTACK,ABILITY=INPUT_ABILITY,CRITICAL=INPUT_CRITICAL}
----------------------------------------------------------------------------------------------------

Remote.OnServerEvent:Connect(function( plr,x,z )
     if(x:sub(1,1)~='@') then
          INPUTS [x]=z
          repeat if(not BLOCKING) then INPUTF [x]() end INPUTBEFORE='' INPUTBEFORE_TIMER=0 task.wait() until not INPUTS [x]
     else
          local x=x:sub(2)
          if(x=='B') then BLOCKING=z return end
          INPUTBEFORE_TIMER=10
          if(x=='W') then INPUTBEFORE=INPUTBEFORE..'↑'
          elseif(x=='A') then INPUTBEFORE=INPUTBEFORE..'←'
          elseif(x=='S') then INPUTBEFORE=INPUTBEFORE..'↓'
          elseif(x=='D') then INPUTBEFORE=INPUTBEFORE..'→' end
     end
end)

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

---------------------
elseif(IsClient) then
--------------------

workspace.CurrentCamera.CameraSubject = Humanoid
__DEBUG_UI.Parent = thisPlayer.PlayerGui
UI.Parent = thisPlayer.PlayerGui

Service'UserInputService'.InputBegan:Connect(function( key,registered )
     if (not registered) then
          if (key.UserInputType == Enum.UserInputType.MouseButton1) then
               Remote:FireServer('ATTACK',true)
               end
          if (key.KeyCode == Enum.KeyCode.W) then
               Remote:FireServer('@W',true)
          elseif (key.KeyCode == Enum.KeyCode.A) then
               Remote:FireServer('@A',true)
          elseif (key.KeyCode == Enum.KeyCode.S) then
               Remote:FireServer('@S',true)
          elseif (key.KeyCode == Enum.KeyCode.D) then
               Remote:FireServer('@D',true)
               end
          if (key.KeyCode == Enum.KeyCode.F) then
               Humanoid.WalkSpeed /= 2
               Remote:FireServer('@B',true)
               end
          end
     end)
Service'UserInputService'.InputEnded:Connect(function( key,registered )
     if (not registered) then
          if (key.UserInputType == Enum.UserInputType.MouseButton1) then
               Remote:FireServer('ATTACK',false)
          elseif (key.KeyCode == Enum.KeyCode.F) then
               Humanoid.WalkSpeed *= 2
               Remote:FireServer('@B',false)
               end
          end
     end)

end

setmetatable(Chrono,ChronoMT)
return Chrono