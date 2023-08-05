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
SND_SPC = {ID='rbxassetid://8285477344',START=0,END=60000}
SND_SPCSHORT = {ID='rbxassetid://8386783529',START=0,END=60000}
SND_CHARGE = {ID='rbxassetid://4995664881',START=0,END=60000}
SND_CUT0 = {ID='rbxassetid://4766120930',START=0,END=60000}
SND_CUT1 = {ID='rbxassetid://4766121030',START=0,END=60000}
SND_CUT2 = {ID='rbxassetid://4766121138',START=0,END=60000}
SND_CUT3 = {ID='rbxassetid://4547246853',START=0,END=60000}

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
     subject:PivotTo(COORD(subject:GetPivot().p)*ANGLE(X,Y,Z))
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
                         if(that and thatHumanoid and thatRoot and (not HITBOXES [ID] ['$result'] [that]) and ((hitOwner) and true or not hit:IsDescendantOf(Model))) then
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

function KNOCKBACK ( knockback_data )
local Root = GET_ROOT (knockback_data [1])
for _,x in Root:GetChildren() do if x:IsA('BodyVelocity') then x:Destroy() end end
local Bv = Instance.new('BodyVelocity')
Bv.Velocity = knockback_data.Velocity
Bv.MaxForce = knockback_data.MaxForce or V3(1e6,1e6,1e6)
Bv.Parent = Root
SET_DEBRIS(Bv, knockback_data.Time or 0.1, true)
end

function DAMAGE ( damage_data )
     local that = damage_data.that
     HL(that.Model,0,1,COLOR(1,1,1),COLOR(1,1,1),0.5)
     SET_SOUND(SND_MARKER,that.Root,1,0.5)
     local assetX = ASSET("HITSTOP_SHAKE")
     assetX.Enabled=true
     assetX:SetAttribute("HITSTOP",damage_data.HitStop)
     local assetY = assetX:Clone()
     assetY.Enabled=true

     assetX.Parent=Model
     assetY.Parent=that.Model
     
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
                    LOCKED = thatRoot ; LOCKED_TIMER = 300
                    DAMAGE { Damage=HB_DATA.Damage,DamageType=HB_DATA.DamageType,HitStop=HB_DATA.HitStop,HitStun=HB_DATA.HitStun,that={Model=that,Humanoid=thatHumanoid,Root=thatRoot} }
                    KNOCKBACK { that, Velocity=HB_DATA.Knockback, MaxForce=HB_DATA.MaxForce, Time=HB_DATA.KnockbackTime }
                    if HB_DATA.Recoil then
                         KNOCKBACK { this, Velocity=HB_DATA.Recoil, MaxForce=HB_DATA.MaxForce, Time=HB_DATA.KnockbackTime }
                    end
                    SET_SOUND(HB_DATA.Sound.data,thatRoot,HB_DATA.Sound.Pitch,HB_DATA.Sound.Volume)
                    if (HB_DATA.Rehit>0) then
                         task.delay(HB_DATA.Rehit/60,function()
                              if(HITBOXES [ID] ['$result'] [that] and HITBOXES [ID] ['$result'] [that].tick==thatTICK) then
                                   HITBOXES [ID] ['result'] [that]=nil
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

Chrono.loop = OnTick(function()
Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding,false)
Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
TICK += 1
LOCKED = LOCKED_TIMER>0 and LOCKED or nil
LOCKED_TIMER = LOCKED_TIMER>0 and LOCKED_TIMER-1 or 0
COMBO = COMBO_TIMER>0 and COMBO or 0
COMBO_TIMER = COMBO_TIMER>0 and COMBO_TIMER-1 or 0
HIT_STOP = HIT_STOP>0 and HIT_STOP-1 or 0
Animator.BUSY = HIT_STOP>0

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
ATTACKING：　]]..tostring(ATTACKING)..(ATTACKWHIFF and ' (WHIFFED)' or '')..(ATTACKLANDED and ' (HIT)' or '')..[[　
]]
end)

----------------------------------------------------------------------------------------------------

function INPUT_ATTACK()
if (BUSY<=0) then

     --- ATTACK_A0 series ---
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
          [0]={Damage=1.0,DamageType='',HitStop=6,HitStun=0, Knockback=GET_LOOK()*15,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT1,Pitch=1.0,Volume=0.6}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(1,6,7),Off=COORD(0,0,-3.5),Frames=12,HitOwner=false,Color=HB_COLOR_SOUR, Special={}},
          [1]={Damage=1.0,DamageType='',HitStop=12,HitStun=0, Knockback=GET_LOOK()*20,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT2,Pitch=1.0,Volume=0.8}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(3,6,2),Off=COORD(0,0,-8),Frames=12,HitOwner=false,Color=HB_COLOR_SWEET, Special={}}} }, FrameSpecial={[12]=function() SWORD_TRAIL=false end} }
     BUSY-=1
     ANIM_BUSY=false
     
     elseif (COMBO==1) then

     SET_COMBO(1,60)
     BUSY+=1
     ANIM_BUSY=true
     ANIM_QUERY(ANIM_GET('ATTACK_A00'))
     SET_LOOK_AT_NEAREST()
     FRAME{Frames=5}
     SET_SOUND(SND_SLASH,Sword.PrimaryPart,1)
     KNOCKBACK { Model, Velocity=GET_LOOK()*9 }
     SWORD_TRAIL=true
     ATTACK { Frames=24, Whiff=12, Hitboxes={ [0]={
          [0]={Damage=1.0,DamageType='',HitStop=3,HitStun=0, Knockback=GET_LOOK()*9,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT1,Pitch=1.0,Volume=0.6}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(1,6,7),Off=COORD(0,0,-3.5),Frames=10,HitOwner=false,Color=HB_COLOR_SOUR, Special={}},
          [1]={Damage=1.0,DamageType='',HitStop=12,HitStun=0, Knockback=GET_LOOK()*9,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT2,Pitch=1.0,Volume=0.8}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(3,6,2),Off=COORD(0,0,-8),Frames=10,HitOwner=false,Color=HB_COLOR_SWEET, Special={}}} }, FrameSpecial={[12]=function() SWORD_TRAIL=false end} }
     BUSY-=1
     ANIM_BUSY=false
     
     elseif (COMBO==2) then

     SET_COMBO(1,60)
     BUSY+=1
     ANIM_BUSY=true
     ANIM_QUERY(ANIM_GET('ATTACK_A00'))
     SET_LOOK_AT_NEAREST()
     FRAME{Frames=4}
     SET_SOUND(SND_SLASH,Sword.PrimaryPart,1.2)
     KNOCKBACK { Model, Velocity=GET_LOOK()*9 }
     SWORD_TRAIL=true
     ATTACK { Frames=24, Whiff=10, Hitboxes={ [0]={
          [0]={Damage=1.0,DamageType='',HitStop=3,HitStun=0, Knockback=GET_LOOK()*9,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT1,Pitch=1.0,Volume=0.6}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(1,6,7),Off=COORD(0,0,-3.5),Frames=10,HitOwner=false,Color=HB_COLOR_SOUR, Special={}},
          [1]={Damage=1.0,DamageType='',HitStop=12,HitStun=0, Knockback=GET_LOOK()*9,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT2,Pitch=1.0,Volume=0.8}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(3,6,2),Off=COORD(0,0,-8),Frames=10,HitOwner=false,Color=HB_COLOR_SWEET, Special={}}} }, FrameSpecial={[12]=function() SWORD_TRAIL=false end} }
     BUSY-=1
     ANIM_BUSY=false

     end

end
end

function INPUT_ABILITY()
if (BUSY<=0) then
end
end

function INPUT_CRITICAL()
if (BUSY<=0) then
end
end

----------------------------------------------------------------------------------------------------

Remote.OnServerEvent:Connect(function( plr,x )
     if(x=='ATTACK') then
     INPUT_ATTACK()
     end
end)

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

---------------------
elseif(IsClient) then
--------------------

workspace.CurrentCamera.CameraSubject = Humanoid
__DEBUG_UI.Parent = thisPlayer.PlayerGui

Service'UserInputService'.InputBegan:Connect(function( key,registered )
     if (not registered) then
          if (key.UserInputType == Enum.UserInputType.MouseButton1) then
               Remote:FireServer('ATTACK')
               end
          end
     end)

end

setmetatable(Chrono,ChronoMT)
return Chrono