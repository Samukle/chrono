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

local __ANIMATION_MANAGER = IsServer and require(14324331578)
local __CHRONO_MODEL = IsServer and require(14291945769)

local ASSET = require(script:WaitForChild('ASSET'))
local STATUS = require(script:WaitForChild('STATUS'))
local SIMPLE = require(script:WaitForChild('SIMPLEFX'))

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
SND_MAGIC1 = {ID='rbxassetid://260433721',START=0,END=60000}
SND_MAGIC2 = {ID='rbxassetid://260433746',START=0,END=60000}
SND_MAGIC3 = {ID='rbxassetid://260433768',START=0,END=60000}
SND_CHARGE = {ID='rbxassetid://4995664881',START=0,END=60000}
SND_SKIP = {ID='rbxassetid://3373982614',START=0,END=60000}
SND_EPITAPH = {ID='rbxassetid://3373995015',START=0,END=60000}
SND_SPIN = {ID='rbxassetid://158475221',START=0,END=60000}
SND_STONE_BREAK = {ID='rbxassetid://765590102',START=0,END=60000}
SND_CLOCK_BELL = {ID='rbxassetid://743521450',START=0,END=60000}
SND_CLOCK_BELLER = {ID='rbxassetid://8558107873',START=0,END=60000}
SND_CLOCK_TICK_HEAVY = {ID='rbxassetid://233856097',START=0,END=60000}
SND_CLOCK_TICKING = {ID='rbxassetid://850256806',START=0,END=60000}
SND_CLOCK_TICKING_2 = {ID='rbxassetid://8966275754',START=0,END=60000}
SND_CLOCK_TICKING_3 = {ID='rbxassetid://9043366459',START=0,END=60000}
SND_TIME_STOP = {ID='rbxassetid://4554999615',START=0.2,END=60000}
SND_TIME_STOP_2 = {ID='rbxassetid://840567549',START=0.2,END=60000}
SND_CLOCK_REWIND = {ID='rbxassetid://7390331288',START=0,END=60000}
SND_BOOST = {ID='rbxassetid://1295446488',START=0,END=60000}
SND_BOOST_CHARGE = {ID='rbxassetid://1295449565',START=0,END=60000}
SND_PHANTOM = {ID='rbxassetid://1585089970',START=0,END=60000}
SND_GLITCH = {ID='rbxassetid://8880764455',START=0,END=60000}
SND_SQUARE = {ID='rbxassetid://7527961200',START=0,END=60000}
SND_WOBBLY = {ID='rbxassetid://9085314270',START=0,END=60000}
SND_TEAR = {ID='rbxassetid://2818141062',START=0,END=60000}
SND_ERCHIUS_END = {ID='rbxassetid://2572705286',START=0,END=60000}

SND_CUT0 = {ID='rbxassetid://7171761940',START=0.2,END=60000}
SND_CUT1 = {ID='rbxassetid://5473058688',START=0,END=60000}
SND_CUT2 = {ID='rbxassetid://7072652156',START=0,END=60000}
SND_CUT3 = {ID='rbxassetid://7072651886',START=0,END=60000}
SND_BRUTAL = {ID='rbxassetid://8975141684',START=0,END=60000}

SND_MARKER = {ID='rbxassetid://7242037470',START=0,END=60000}

COMBO = 0
COMBO_TIMER = 0
HIT_STOP = 0
RUNNING = false
MIDAIR = false
ATTACKING = false
ATTACKWHIFF = false
ATTACKLANDED = false

UI_COMBO_HITS = 0
UI_COMBO_TIMER = 0
UI_COMBO_TOTAL = 0
UI_COMBO_DAMAGE = 0
UI_COMBOasset = UI:WaitForChild('Combo')
UI_COMBOspinny0 = UI_COMBOasset:WaitForChild('Spinny0')
UI_COMBOspinny1 = UI_COMBOasset:WaitForChild('Spinny1')
UI_COMBOrank = UI_COMBOasset:WaitForChild('ComboRank')
UI_COMBOhits = UI_COMBOasset:WaitForChild('Hits')
UI_COMBOtotal = UI_COMBOasset:WaitForChild('TextLabel')
UI_COMBOprefix = '<stroke thickness="5"><b>'
UI_COMBOsuffix = '</b></stroke>'
UI_COMBO_SCALAR = 0
UI_COMBO_SPIN = 0
UI_COMBO_RANKS = {
     [0]={NAME="D", COLOR=Color3.fromRGB(135,99,57)},
     [700]={NAME="C", COLOR=Color3.fromRGB(208,201,121)},
     [2000]={NAME="B", COLOR=Color3.fromRGB(140,229,182)},
     [4000]={NAME="A", COLOR=Color3.fromRGB(229,59,68)},
     [6000]={NAME="S", COLOR=Color3.fromRGB(229,102,216)},
     [10000]={NAME="SS", COLOR=Color3.fromRGB(255,233,110)},
}
UI_COMBO_RANK_THIS = UI_COMBO_RANKS [0]

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
if(Animator.CURRENT ~= INST and (
((INST ~= ANIM_JUMP or INST ~= ANIM_IDLE or INST ~= ANIM_RUN)
and (Animator.CURRENT == ANIM_JUMP or Animator.CURRENT == ANIM_IDLE or Animator.CURRENT == ANIM_RUN)) or
((INST == ANIM_JUMP or INST == ANIM_IDLE or INST == ANIM_RUN)
and (Animator.CURRENT == ANIM_JUMP or Animator.CURRENT == ANIM_IDLE or Animator.CURRENT == ANIM_RUN)) or
Animator.CURRENT==nil)
) then ANIM_QUERY(INST) return true else return false end
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
          if (result) then SET_LOOK ( result.CFrame ) return result end
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

function SET_LOOPER ( THING, resident, pitch, volume, time )
     local SND = Instance.new('Sound',resident)
     SND.SoundId = THING.ID
     SND.TimePosition = THING.START
     SND.Pitch = pitch or 1
     SND.Volume = volume or 0.5
     SND.Looped = true
     SND.Parent = resident
     SND:Play()
     SET_DEBRIS(SND, time)
     return SND
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
          if(HB and HB.Parent and not CANCEL) then
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
          else HBCONNECT:Disconnect() if(HB and HITBOXES [ID] [PART]==HB) then HB:Destroy() HITBOXES [ID] [PART] = nil end end
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

-- CLOCK FORMAT --
-- CLOCK { Radius=70, Color=COLOR(1,1,1), Coord0=COORD(0,0,0), Coord1=COORD(0,0,0), Minute=15.0, Hour=6.0, Duration=2.0 }
function CLOCK ( data )
     SIMPLE { Save='StopClock0', Type='Block', Size0=V3(data.Radius,0,data.Radius), Transparency0=1.0, Color0=data.Color, Coord0=data.Coord0 or Model_Body[ROOT].CFrame, Coord1=data.Coord1 or data.Coord0 or Model_Body[ROOT].CFrame, Anchored=true, CastShadow=false, Time=data.Duration }
     SIMPLE { Holder='StopClock0', Type='Decal', Face='Top', Texture='rbxassetid://4975348081', Color0=COLOR(data.Color.R*2,data.Color.G*2,data.Color.B*2), Transparency0=0.0, Transparency1=1.0, Time=data.Duration}
     SIMPLE { Holder='StopClock0', Type='Decal', Face='Bottom', Texture='rbxassetid://4975348081', Color0=COLOR(data.Color.R*2,data.Color.G*2,data.Color.B*2), Transparency0=0.0, Transparency1=1.0, Time=data.Duration}

     SIMPLE { Save='StopClock1', Type='Block', Size0=V3(data.Radius*0.9,0,data.Radius*0.9), Transparency0=1.0, Color0=data.Color, Coord0=data.Coord0 or Model_Body[ROOT].CFrame, Coord1=data.Coord1 or data.Coord0 or Model_Body[ROOT].CFrame, CoordAdd=ANGLE(0,math.rad(data.Hour),0), Anchored=true, CastShadow=false, Time=2.0 }
     SIMPLE { Holder='StopClock1', Type='Decal', Face='Top', Texture='rbxassetid://4970076788', Color0=COLOR(data.Color.R*2,data.Color.G*2,data.Color.B*2), Transparency0=0.0, Transparency1=1.0, Time=data.Duration}
     SIMPLE { Holder='StopClock1', Type='Decal', Face='Bottom', Texture='rbxassetid://4970076788', Color0=COLOR(data.Color.R*2,data.Color.G*2,data.Color.B*2), Transparency0=0.0, Transparency1=1.0, Time=data.Duration}

     SIMPLE { Save='StopClock2', Type='Block', Size0=V3(data.Radius,0,data.Radius), Transparency0=1.0, Color0=data.Color, Coord0=data.Coord0 or Model_Body[ROOT].CFrame, Coord1=data.Coord1 or data.Coord0 or Model_Body[ROOT].CFrame, CoordAdd=ANGLE(0,math.rad(data.Minute),0), Anchored=true, CastShadow=false, Time=2.0 }
     SIMPLE { Holder='StopClock2', Type='Decal', Face='Top', Texture='rbxassetid://4970076788', Color0=COLOR(data.Color.R*2,data.Color.G*2,data.Color.B*2), Transparency0=0.0, Transparency1=1.0, Time=data.Duration}
     SIMPLE { Holder='StopClock2', Type='Decal', Face='Bottom', Texture='rbxassetid://4970076788', Color0=COLOR(data.Color.R*2,data.Color.G*2,data.Color.B*2), Transparency0=0.0, Transparency1=1.0, Time=data.Duration}
     
     SIMPLE { Save='StopClock0', Type='Block', Size0=V3(data.Radius,0,data.Radius), Size1=V3(data.Radius*2,0,data.Radius*2), Transparency0=1.0, Color0=data.Color, Coord0=data.Coord0 or Model_Body[ROOT].CFrame, Coord1=data.Coord1 or data.Coord0 or Model_Body[ROOT].CFrame, Anchored=true, CastShadow=false, Time=0.2 }
     SIMPLE { Holder='StopClock0', Type='Decal', Face='Top', Texture='rbxassetid://4975348081', Color0=COLOR(data.Color.R*2,data.Color.G*2,data.Color.B*2), Transparency0=0.0, Transparency1=1.0, Time=0.2}
     SIMPLE { Holder='StopClock0', Type='Decal', Face='Bottom', Texture='rbxassetid://4975348081', Color0=COLOR(data.Color.R*2,data.Color.G*2,data.Color.B*2), Transparency0=0.0, Transparency1=1.0, Time=0.2}
end

function CLONE ( data )
     local this = __CHRONO_MODEL ()
     CLONE_ACTIVE = this
     for _,x in this:GetChildren() do if (x:IsA('Humanoid')) then x:Destroy() end end

     local anim = require(__ANIMATION_MANAGER.new ( this ))

     this.PrimaryPart.Anchored = true
     this:PivotTo(Model_Body[ROOT].CFrame)

     for _,b in this:GetDescendants() do
     if (b:IsA('BasePart') or b:IsA('Decal')) then
          if (b:IsA('BasePart')) then b.CanCollide = false; b.CanTouch = false; b.CanQuery = false; end
          Service'TweenService':Create(b,TweenInfo.new(0.2,Enum.EasingStyle.Linear,Enum.EasingDirection.In,0,false,data.Time-0.2),{Transparency = b.Transparency+1}):Play()
     end
     end

     this.Parent = workspace
     
     if (data.Animation) then
     anim:PLAY( data.Animation )
     end

     SET_DEBRIS ( this, data.Time )
     return this, anim
end

local RPARAM = RaycastParams.new()
RPARAM.IgnoreWater = true ; RPARAM.RespectCanCollide = true ; RPARAM.FilterDescendantsInstances = Model:GetDescendants()
function RAY ( origin : Vector3, direction : Vector3 )
     local RESULT = workspace:Raycast(origin,direction,RPARAM)  
     return RESULT
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
     UI_COMBO_TIMER = (2+math.ceil(UI_COMBO_TIMER/5))*60
     UI_COMBO_HITS += 1
     UI_COMBO_SCALAR += damage_data.Damage/600
     UI_COMBO_DAMAGE = damage_data.Damage
     UI_COMBO_TOTAL += damage_data.Damage
     local max=0 for VALUE,T in UI_COMBO_RANKS do
          if (VALUE>max and VALUE<=UI_COMBO_TOTAL) then
               UI_COMBO_RANK_THIS = T
               max = VALUE
          end
     end
     local assetX do for _,x in that.Model:GetChildren() do if (x.Name=="HITSTOP_SHAKE" and x:GetAttribute("HITSTOP")) then assetX=x end end end
     if(not assetX) then
     assetX = ASSET("HITSTOP_SHAKE")
     assetX.Enabled=true
     assetX:SetAttribute("HITSTOP",damage_data.HitStop)
     assetX.Parent=that.Model
     else assetX:SetAttribute("HITSTOP",damage_data.HitStop) end

     SIMPLE { Save='Hit', Coord0=that.Root.CFrame, Transparency0=1, Anchored=true, Time=0.1}
     SIMPLE { Holder='Hit', Type='PointLight', Range0=5, Range1=2, Brightness0=15, Brightness1=0, Time=0.1 }

     local DAMAGE_THING = Instance.new("Part")
     DAMAGE_THING.Size = Vector3.zero
     DAMAGE_THING.Transparency = 1
     DAMAGE_THING.CanCollide = false ; DAMAGE_THING.CanTouch = false ; DAMAGE_THING.CanQuery = false
     DAMAGE_THING.CFrame = that.Root.CFrame
     DAMAGE_THING.Velocity = V3(math.random(-12,12),math.random(30,60),math.random(-12,12))
     DAMAGE_THING.Parent = workspace

     local DAMAGE_UI = Instance.new("BillboardGui",DAMAGE_THING)
     DAMAGE_UI.Size=UDim2.new(100,0,2+(damage_data.Damage/34),0)
     DAMAGE_UI.AlwaysOnTop=true

     local DAMAGE_TXT = Instance.new("TextLabel",DAMAGE_UI)
     DAMAGE_TXT.Text = string.format('%.1f',damage_data.Damage)
     DAMAGE_TXT.Font = Enum.Font.SourceSansBold
     DAMAGE_TXT.TextScaled = 1
     DAMAGE_TXT.TextColor3 = 
     (damage_data.IS_BLOOD_DAMAGE) and COLOR(1,0,0) or
     (damage_data.IS_WARPED_DAMAGE) and COLOR(0,0.5,0) or
     (damage_data.Damage>=20) and COLOR(1,0,0) or (damage_data.Damage>=8) and COLOR(1,0.5,0) or (damage_data.Damage>=3) and COLOR(1,1,0) or COLOR(1,1,1)
     DAMAGE_TXT.TextStrokeTransparency = 0
     DAMAGE_TXT.BackgroundTransparency = 1
     DAMAGE_TXT.Size=UDim2.new(1,0,1,0)
     Service'TweenService':Create(DAMAGE_UI,TweenInfo.new(0.2,Enum.EasingStyle.Linear,Enum.EasingDirection.In,0,false,0.8),{Size=UDim2.new(0,0,0,0)}):Play()

     SET_DEBRIS(DAMAGE_THING, 1)

     SET_HEALTH(that.Model, GET_HEALTH(that.Model)-math.ceil(damage_data.Damage*10))

     HIT_STOP=(damage_data.HitStop or 0)+(damage_data.HitStopSelf or 0)

     if (not damage_data.IS_WARPED_DAMAGE) then
     local warp=STATUS:Has('WARP',damage_data.that.Model)
     if (warp) then
     local pitch = (2.0+math.random(-1,2*math.min(1+warp:GetAttribute('Stack')/60,2.0))/10)*math.max(1-warp:GetAttribute('Stack')/60,0.6)
     SET_SOUND (SND_CLOCK_BELL,that.Root,pitch,0.6+math.min(warp:GetAttribute('Stack')/60,2.0))
     damage_data.IS_WARPED_DAMAGE=true
     damage_data.WARP_OG_DAMAGE=damage_data.WARP_OG_DAMAGE or damage_data.Damage
     damage_data.Damage*=warp:GetAttribute('Stack')
     DAMAGE ( damage_data )
     end
     end
end

--- attack_data BASE ---
--[[--

ATTACK { Frames=1, Whiff=0, Hitboxes={ [0]={[0]={Damage=1.0,DamageType='',HitStop=0,HitStopSelf=0,HitStun=0, Inflict={'DEBUFF_NAME'}, Knockback=GET_LOOK()*2,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT0,Pitch=1.0,Volume=0.6}, Rehit=0, Host=Model_Body[ROOT],Size=V3(0,0,0),Off=COORD(0,0,0),Frames=60,HitOwner=false,Color=HB_COLOR_NORMAL, Special={}}} }, FrameSpecial={} }

--]]--
CANCEL = false
function ATTACK ( attack_data )
     CANCEL = false
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
                    DAMAGE { Damage=HB_DATA.Damage,DamageType=HB_DATA.DamageType,HitStop=HB_DATA.HitStop,HitStopSelf=HB_DATA.HitStopSelf,HitStun=HB_DATA.HitStun,that={Model=that,Humanoid=thatHumanoid,Root=thatRoot} }
                    KNOCKBACK { that, Velocity=HB_DATA.Knockback, MaxForce=HB_DATA.MaxForce, Time=HB_DATA.KnockbackTime }
                    if HB_DATA.Recoil then
                         KNOCKBACK { Model, Velocity=HB_DATA.Recoil, MaxForce=HB_DATA.MaxForce, Time=HB_DATA.KnockbackTime }
                    end
                    if (HB_DATA.Sound and HB_DATA.Sound.data) then
                         SET_SOUND(HB_DATA.Sound.data,thatRoot,HB_DATA.Sound.Pitch,HB_DATA.Sound.Volume)
                    end
                    if (HB_DATA.Inflict and #HB_DATA.Inflict>0) then
                         for _,DEBUFF in HB_DATA.Inflict do
                              STATUS:Inflict( DEBUFF, that )
                         end
                    end
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
     
     FRAME{Frames=attack_data.Frames,Pass=function(i) if(attack_data.FrameSpecial and attack_data.FrameSpecial[i]) then attack_data.FrameSpecial[i]() end if(CANCEL==true) then return '$stop' end end}
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

COOLDOWNS = {}
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

UI_COMBO_DAMAGE = UI_COMBO_TIMER>0 and UI_COMBO_DAMAGE or 0
UI_COMBO_HITS = UI_COMBO_TIMER>0 and UI_COMBO_HITS or 0
UI_COMBO_TOTAL = UI_COMBO_TIMER>0 and UI_COMBO_TOTAL or 0
UI_COMBO_TIMER = UI_COMBO_TIMER>0 and ((HIT_STOP<=0 and not BLOCKING) and UI_COMBO_TIMER-1 or UI_COMBO_TIMER) or 0
UI_COMBO_SCALAR = 0.8*UI_COMBO_SCALAR
UI_COMBO_SPIN += UI_COMBO_SCALAR
UI_COMBOspinny0.Size = UDim2.new(0.5+(UI_COMBO_SCALAR*1.2),0,0.5+(UI_COMBO_SCALAR*1.2),0)
UI_COMBOspinny0.Rotation = -UI_COMBO_SPIN
UI_COMBOspinny1.Size = UDim2.new(0.5+(UI_COMBO_SCALAR),0,0.5+(UI_COMBO_SCALAR),0)
UI_COMBOspinny1.Rotation = UI_COMBO_SPIN
UI_COMBOhits.Text = UI_COMBOprefix..tostring(UI_COMBO_HITS)..UI_COMBOsuffix
UI_COMBOtotal.Text = UI_COMBOprefix..string.format("%.1f",UI_COMBO_TOTAL/10).." ("..string.format("%.1f",UI_COMBO_DAMAGE/10)..")"..UI_COMBOsuffix
UI_COMBOrank.Text = UI_COMBOprefix..UI_COMBO_RANK_THIS.NAME..UI_COMBOsuffix
UI_COMBOrank.TextColor3 = UI_COMBO_RANK_THIS.COLOR
UI_COMBOasset.Visible = UI_COMBO_TIMER>0

UIBar.Size=UDim2.new(Humanoid.Health/Humanoid.MaxHealth,0,1,0)
UIBar.BackgroundColor3 = (Humanoid.Health>=Humanoid.MaxHealth/2) and COLOR(0.29,1,0.3) or (Humanoid.Health>=Humanoid.MaxHealth/4) and COLOR(1,1,0) or COLOR(1,0,0)
UIBarText.Text=Humanoid.Health>0 and string.format('HP: %.1f/%.1f',Humanoid.Health/10,Humanoid.MaxHealth/10) or '<b><i>DEAD</i></b>'

if(BLOCKING) then
     SET_LOOK_AT_NEAREST()
end

for x,z in COOLDOWNS do
     COOLDOWNS [x] = COOLDOWNS [x] > 0 and z - 1 or nil
end

for _,v in Model_Body do
     if(v : CanSetNetworkOwnership()) then
          v : SetNetworkOwner(nil)
     end
end

local function ANIMDEFAULT()
     if(not BLOCKING) then
          if(not MIDAIR) then
               if(not RUNNING) then
                    ANIM_QUERY_SAFE(ANIM_IDLE)
               else
                    ANIM_QUERY_SAFE(ANIM_RUN)
               end
          else
               ANIM_QUERY_SAFE(ANIM_JUMP)
          end
     else
          ANIM_QUERY_SAFE(ANIM_GET'BLOCK')
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

__DEBUG_TEXT.Visible = _G.DEBUG
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

LOCKED：　]]..tostring(LOCKED ~= nil and LOCKED:GetFullName() or '無し')..[[　
LOCKED_TIME：　]]..tostring(LOCKED_TIMER)..[[　
]]
end)

----------------------------------------------------------------------------------------------------

local function FX_TIMESKIP()
     SET_SOUND(SND_CLOCK_BELL,Model_Body[ROOT],2,0.5)
     SET_SOUND(SND_SKIP,Model_Body[ROOT],1,0.5)
     AFTERIMAGE( Model )
end

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
          [0]={Damage=2.5,DamageType='',HitStop=3,HitStun=0, Inflict={}, Knockback=GET_LOOK()*9,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT1,Pitch=1.0,Volume=0.6}, Rehit=4, Host=Model_Body[HAND_R],Size=V3(1,6,7),Off=COORD(0,0,-3.5),Frames=19,HitOwner=false,Color=HB_COLOR_SOUR, Special={}},
          [1]={Damage=3.0,DamageType='',HitStop=12,HitStun=0, Inflict={}, Knockback=GET_LOOK()*11,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT1,Pitch=1.0,Volume=0.8}, Rehit=13, Host=Model_Body[HAND_R],Size=V3(3,6,4),Off=COORD(0,0,-8),Frames=19,HitOwner=false,Color=HB_COLOR_SWEET, Special={}}} }, FrameSpecial={[12]=function() SWORD_TRAIL=false end} }
     BUSY-=1
     ANIM_BUSY=false
     return
     end

     -- ATTACK_A11 --
     if (INPUTBEFORE=='↑↑') then
     SET_COMBO(-3,60)
     BUSY+=1
     ANIM_BUSY=true
     IMMUNE = true
     SET_LOOK_AT_NEAREST()
     FX_TIMESKIP()
     local TARGET, TARGETNT = LOCKED
     if (TARGET) then
          local X,Y,Z = TARGET.CFrame:ToEulerAnglesYXZ()
          local Q = RAY( (TARGET.CFrame*COORD(0,0,0.5)).p, TARGET.CFrame.LookVector*-8)
          if (Q) then TARGET = COORD(Q.Position)*ANGLE(X,Y,Z)
          else TARGET = TARGET.CFrame*COORD(0,0,8)
          end
     else
          local X,Y,Z = Model:GetPivot():ToEulerAnglesYXZ()
          local Q = RAY( (Model:GetPivot()*COORD(0,0,-0.5)).p, GET_LOOK()*17.7)
          if (Q) then TARGET = COORD(Q.Position)*ANGLE(X,Y,Z)
          else TARGET = Model:GetPivot()*COORD(0,0,-17.7)
          end
     end
     Model:PivotTo((TARGET~=nil) and TARGET or TARGETNT)
     SET_LOOK_AT_NEAREST()
     ANIM_QUERY(ANIM_GET('ATTACK_A11'))
     KNOCKBACK { Model, Velocity=GET_LOOK()*3, Time=1 }
     FRAME{Frames=14}
     SET_SOUND(SND_SPCSHORT,Sword.PrimaryPart,1,0.6)
     SET_SOUND(SND_LUNGE,Sword.PrimaryPart,0.7)
     KNOCKBACK { Model, Velocity=GET_LOOK()*70 }
     SWORD_TRAIL=true
     ATTACK { Frames=13, Whiff=7, Hitboxes={ [0]={
          [0]={Damage=10.0,DamageType='',HitStop=20,HitStun=0, Inflict={}, Knockback=GET_LOOK()*-20,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT3,Pitch=0.9,Volume=0.6}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(3,6,7),Off=COORD(0,0,-3.5),Frames=6,HitOwner=false,Color=HB_COLOR_SOUR, Special={}},
          [1]={Damage=10.0,DamageType='',HitStop=25,HitStun=0, Inflict={}, Knockback=GET_LOOK()*-25,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT3,Pitch=0.9,Volume=0.8}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(3,6,4),Off=COORD(0,0,-8),Frames=6,HitOwner=false,Color=HB_COLOR_SWEET, Special={}}} }, FrameSpecial={[6]=function() SWORD_TRAIL=false IMMUNE=false end} }
     BUSY-=1
     ANIM_BUSY=false
     return
     end

     -- ATTACK_A12 --
     if (INPUTBEFORE=='↓↑') then
     SET_COMBO(0,120)
     BUSY+=1
     ANIM_BUSY=true
     ANIM_QUERY(ANIM_GET('ATTACK_A12'))
     SET_LOOK_AT_NEAREST()
     FRAME{Frames=6}
     SET_SOUND(SND_LUNGE,Sword.PrimaryPart,2)
     __SPECIAL_SWORD_THROWING_SOUND=SET_LOOPER(SND_SPIN,Sword.PrimaryPart,2,0.5,1)
     KNOCKBACK { Model, Velocity=Vector3.zero, Time=1.1 }
     SWORD_TRAIL=true
     ATTACK { Frames=68, Whiff=0, Hitboxes={ [0]={
          [0]={Damage=1.0,DamageType='',HitStop=3,HitStopSelf=-3,HitStun=0, Inflict={}, Knockback=GET_LOOK()*9,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT0,Pitch=1.0,Volume=0.6}, Rehit=6, Host=Model_Body[HAND_R],Size=V3(1,6,20.5),Off=COORD(0,0,0),Frames=60,HitOwner=false,Color=HB_COLOR_NORMAL, Special={}}}}, FrameSpecial={[4]=function() __SPECIAL_SWORD_THROWING=true end, [60]=function() SWORD_TRAIL=false end}}
     __SPECIAL_SWORD_THROWING=false
     BUSY-=1
     ANIM_BUSY=false
     return
     end

     -- ATTACK_B10 --
     if (INPUTBEFORE=='↓↑↑') then
     if (not MIDAIR) then
     SET_COMBO(0,120)
     BUSY+=1
     ANIM_BUSY=true
     ANIM_QUERY(ANIM_GET('ATTACK_B10'))
     SET_LOOK_AT_NEAREST()
     FRAME{Frames=15}
     SET_SOUND(SND_SLASH,Sword.PrimaryPart,1.4,0.6)
     SET_SOUND(SND_TEAR,Sword.PrimaryPart,0.9,1.1)
     SET_SOUND(SND_SHEATHE,Sword.PrimaryPart,1.3,0.5)
     KNOCKBACK { Model, Velocity=V3(0,65,0), Time=0.2 }
     SWORD_TRAIL=true
     IMMUNE=true
     ATTACK { Frames=19, Whiff=4, Hitboxes={ [0]={
          [0]={Damage=8.0,DamageType='',HitStop=3,HitStun=0, Inflict={}, Knockback=V3(0,65,0),KnockbackMax=nil,KnockbackTime=0.2, Sound={data=SND_CUT2,Pitch=0.9,Volume=0.6}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(3,6,7),Off=COORD(0,-4.2,-3.5),Frames=14,HitOwner=false,Color=HB_COLOR_SOUR, Special={}},
          [1]={Damage=8.0,DamageType='',HitStop=4,HitStun=0, Inflict={}, Knockback=V3(0,65,0),KnockbackMax=nil,KnockbackTime=0.2, Sound={data=SND_CUT2,Pitch=0.9,Volume=0.8}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(3,6,4),Off=COORD(0,-4.2,-8),Frames=14,HitOwner=false,Color=HB_COLOR_SWEET, Special={}}} }, FrameSpecial={[12]=function() SWORD_TRAIL=false IMMUNE=false end} }
     BUSY-=1
     ANIM_BUSY=false
     else
     SET_COMBO(0,120)
     BUSY+=1
     ANIM_BUSY=true
     ANIM_QUERY(ANIM_GET('ATTACK_B11'))
     SET_LOOK_AT_NEAREST()
     SET_SOUND(SND_SLASH,Sword.PrimaryPart,1.5,0.5)
     FRAME{Frames=9}
     SET_SOUND(SND_SLASH,Sword.PrimaryPart,1.2,0.6)
     SET_SOUND(SND_TEAR,Sword.PrimaryPart,0.85,1.1)
     SET_SOUND(SND_SHEATHE,Sword.PrimaryPart,1.3,0.4)
     SWORD_TRAIL=true
     IMMUNE=true
     ATTACK { Frames=12, Whiff=8, Hitboxes={ [0]={
          [0]={Damage=10.0,DamageType='',HitStop=5,HitStun=0, Inflict={}, Knockback=V3(0,-40,0),Recoil=V3(0,43,0),KnockbackMax=nil,KnockbackTime=0.2, Sound={data=SND_CUT3,Pitch=0.9,Volume=0.6}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(3,6,7),Off=COORD(0,-4.2,-3.5),Frames=11,HitOwner=false,Color=HB_COLOR_SOUR, Special={}},
          [1]={Damage=20.0,DamageType='',HitStop=6,HitStun=0, Inflict={}, Knockback=V3(0,-40,0),Recoil=V3(0,43,0),KnockbackMax=nil,KnockbackTime=0.2, Sound={data=SND_BRUTAL,Pitch=0.9,Volume=0.8}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(3,8,4),Off=COORD(0,-4.2,-8),Frames=11,HitOwner=false,Color=HB_COLOR_SWEET, Special={}}} }, FrameSpecial={[8]=function() SWORD_TRAIL=false IMMUNE=false end} }
     BUSY-=1
     ANIM_BUSY=false
     end
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
          [0]={Damage=3.0,DamageType='',HitStop=6,HitStun=0, Inflict={}, Knockback=GET_LOOK()*15,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT2,Pitch=1.0,Volume=0.6}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(1,6,7),Off=COORD(0,0,-3.5),Frames=12,HitOwner=false,Color=HB_COLOR_SOUR, Special={}},
          [1]={Damage=3.5,DamageType='',HitStop=12,HitStun=0, Inflict={}, Knockback=GET_LOOK()*20,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT2,Pitch=1.0,Volume=0.8}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(3,6,4),Off=COORD(0,0,-8),Frames=12,HitOwner=false,Color=HB_COLOR_SWEET, Special={}}} }, FrameSpecial={[12]=function() SWORD_TRAIL=false end} }
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
          [0]={Damage=1.5,DamageType='',HitStop=3,HitStun=0, Inflict={}, Knockback=GET_LOOK()*9,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT1,Pitch=1.0,Volume=0.6}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(1,6,7),Off=COORD(0,0,-3.5),Frames=19,HitOwner=false,Color=HB_COLOR_SOUR, Special={}},
          [1]={Damage=2.0,DamageType='',HitStop=12,HitStun=0, Inflict={}, Knockback=GET_LOOK()*11,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT1,Pitch=1.0,Volume=0.8}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(3,6,4),Off=COORD(0,0,-8),Frames=19,HitOwner=false,Color=HB_COLOR_SWEET, Special={}}} }, FrameSpecial={[12]=function() SWORD_TRAIL=false end} }
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
          [0]={Damage=1.5,DamageType='',HitStop=3,HitStun=0, Inflict={}, Knockback=GET_LOOK()*9,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT1,Pitch=1.0,Volume=0.6}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(1,6,7),Off=COORD(0,0,-3.5),Frames=19,HitOwner=false,Color=HB_COLOR_SOUR, Special={}},
          [1]={Damage=2.0,DamageType='',HitStop=12,HitStun=0, Inflict={}, Knockback=GET_LOOK()*9,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT1,Pitch=1.0,Volume=0.8}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(3,6,4),Off=COORD(0,0,-8),Frames=19,HitOwner=false,Color=HB_COLOR_SWEET, Special={}}} }, FrameSpecial={[12]=function() SWORD_TRAIL=false end} }
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
          [0]={Damage=2.0,DamageType='',HitStop=3,HitStun=0, Inflict={}, Knockback=GET_LOOK()*12,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT0,Pitch=1.0,Volume=0.6}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(1,6,7),Off=COORD(0,0,-3.5),Frames=9,HitOwner=false,Color=HB_COLOR_SOUR, Special={}},
          [1]={Damage=2.5,DamageType='',HitStop=12,HitStun=0, Inflict={}, Knockback=GET_LOOK()*14,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT0,Pitch=1.0,Volume=0.8}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(3,6,4),Off=COORD(0,0,-8),Frames=9,HitOwner=false,Color=HB_COLOR_SWEET, Special={}}} }, FrameSpecial={[8]=function() SWORD_TRAIL=false end} }
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
          [0]={Damage=1.5,DamageType='',HitStop=3,HitStun=0, Inflict={}, Knockback=GET_LOOK()*9,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT0,Pitch=1.0,Volume=0.6}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(3,6,7),Off=COORD(0,0,-3.5),Frames=9,HitOwner=false,Color=HB_COLOR_SOUR, Special={}},
          [1]={Damage=2.0,DamageType='',HitStop=12,HitStun=0, Inflict={}, Knockback=GET_LOOK()*9,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT0,Pitch=1.0,Volume=0.8}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(3,6,4),Off=COORD(0,0,-8),Frames=9,HitOwner=false,Color=HB_COLOR_SWEET, Special={}}} }, FrameSpecial={[8]=function() SWORD_TRAIL=false end} }
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
          [0]={Damage=1.5,DamageType='',HitStop=3,HitStun=0, Inflict={}, Knockback=GET_LOOK()*9,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT1,Pitch=1.0,Volume=0.6}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(3,6,7),Off=COORD(0,0,-3.5),Frames=8,HitOwner=false,Color=HB_COLOR_SOUR, Special={}},
          [1]={Damage=2.0,DamageType='',HitStop=12,HitStun=0, Inflict={}, Knockback=GET_LOOK()*9,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT1,Pitch=1.0,Volume=0.8}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(3,6,4),Off=COORD(0,0,-8),Frames=8,HitOwner=false,Color=HB_COLOR_SWEET, Special={}}} }, FrameSpecial={[8]=function() SWORD_TRAIL=false end} }
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
          [0]={Damage=4.0,DamageType='',HitStop=7,HitStun=0, Inflict={}, Knockback=GET_LOOK()*43,KnockbackMax=nil,KnockbackTime=0.4, Sound={data=SND_CUT3,Pitch=1.0,Volume=0.6}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(1,6,7),Off=COORD(0,0,-3.5),Frames=19,HitOwner=false,Color=HB_COLOR_SOUR, Special={}},
          [1]={Damage=4.5,DamageType='',HitStop=14,HitStun=0, Inflict={}, Knockback=GET_LOOK()*43,KnockbackMax=nil,KnockbackTime=0.4, Sound={data=SND_CUT3,Pitch=1.0,Volume=0.8}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(1,1,7),Off=COORD(0,0,-5),Frames=19,HitOwner=false,Color=HB_COLOR_SWEET, Special={}}} }, FrameSpecial={} }
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
          [0]={Damage=1.5,DamageType='',HitStop=9,HitStun=0, Inflict={}, Knockback=GET_LOOK()*13,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT0,Pitch=1.0,Volume=0.6}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(12,10,7),Off=COORD(0,0,-3.5),Frames=8,HitOwner=false,Color=HB_COLOR_SOUR, Special={}},
          [1]={Damage=2.0,DamageType='',HitStop=12,HitStun=0, Inflict={}, Knockback=GET_LOOK()*13,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT0,Pitch=1.0,Volume=0.8}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(5,8,4),Off=COORD(0,0,-8),Frames=8,HitOwner=false,Color=HB_COLOR_SWEET, Special={}}} }, FrameSpecial={[8]=function() SWORD_TRAIL=false end} }
     KNOCKBACK { Model, Velocity=GET_LOOK()*13 }
     SET_LOOK_AT_NEAREST()
     SWORD_TRAIL=true
     SET_SOUND(SND_SHEATHE,Sword.PrimaryPart,1.1)
     ATTACK { Frames=21, Whiff=4, Hitboxes={ [0]={
          [0]={Damage=2.0,DamageType='',HitStop=9,HitStun=0, Inflict={}, Knockback=GET_LOOK()*13,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT0,Pitch=1.0,Volume=0.6}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(12,10,7),Off=COORD(0,0,-3.5),Frames=9,HitOwner=false,Color=HB_COLOR_SOUR, Special={}},
          [1]={Damage=2.5,DamageType='',HitStop=12,HitStun=0, Inflict={}, Knockback=GET_LOOK()*13,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT0,Pitch=1.0,Volume=0.8}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(5,8,4),Off=COORD(0,0,-8),Frames=9,HitOwner=false,Color=HB_COLOR_SWEET, Special={}}} }, FrameSpecial={[8]=function() SWORD_TRAIL=false end} }
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
          [0]={Damage=8.0,DamageType='',HitStop=3,HitStun=0, Inflict={}, Knockback=GET_LOOK()*9,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT2,Pitch=1.0,Volume=0.6}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(1,6,7),Off=COORD(0,0,-3.5),Frames=11,HitOwner=false,Color=HB_COLOR_SOUR, Special={}},
          [1]={Damage=8.5,DamageType='',HitStop=12,HitStun=0, Inflict={}, Knockback=GET_LOOK()*9,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT2,Pitch=1.0,Volume=0.8}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(3,6,4),Off=COORD(0,0,-8),Frames=11,HitOwner=false,Color=HB_COLOR_SWEET, Special={}}} }, FrameSpecial={[8]=function() SWORD_TRAIL=false end} }
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
          [0]={Damage=8.0,DamageType='',HitStop=3,HitStun=0, Inflict={}, Knockback=GET_LOOK()*9,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT3,Pitch=1.0,Volume=0.6}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(1,6,7),Off=COORD(0,0,-3.5),Frames=18,HitOwner=false,Color=HB_COLOR_SOUR, Special={}},
          [1]={Damage=8.5,DamageType='',HitStop=12,HitStun=0, Inflict={}, Knockback=GET_LOOK()*9,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT3,Pitch=1.0,Volume=0.8}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(3,6,4),Off=COORD(0,0,-8),Frames=18,HitOwner=false,Color=HB_COLOR_SWEET, Special={}}} }, FrameSpecial={[20]=function() SWORD_TRAIL=false end} }
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
          [0]={Damage=9.0,DamageType='',HitStop=20,HitStun=0, Inflict={}, Knockback=GET_LOOK()*55,KnockbackMax=nil,KnockbackTime=0.6, Sound={data=SND_CUT3,Pitch=1.0,Volume=0.6}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(6,6,7),Off=COORD(0,0,-3.5),Frames=25,HitOwner=false,Color=HB_COLOR_SOUR, Special={}},
          [1]={Damage=10.0,DamageType='',HitStop=20,HitStun=0, Inflict={}, Knockback=GET_LOOK()*56,KnockbackMax=nil,KnockbackTime=0.6, Sound={data=SND_CUT3,Pitch=1.0,Volume=0.8}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(1,1,4),Off=COORD(0,0,-8),Frames=25,HitOwner=false,Color=HB_COLOR_SWEET, Special={}}} }, FrameSpecial={} }
     BUSY-=1
     ANIM_BUSY=false

     end
     end

end
end

CLONE_ACTIVE=nil
function INPUT_ABILITY()
if (__SPECIAL_SWORD_THROWING==true) then
     FX_TIMESKIP()
     if __SPECIAL_SWORD_THROWING_SOUND ~= nil then __SPECIAL_SWORD_THROWING_SOUND:Destroy() end
     Animator:STOP()
     SWORD_TRAIL=false
     CANCEL=true
     local X,Y,Z = Model_Body[ROOT].CFrame:ToEulerAnglesYXZ()
     local POS = Model_Body[HAND_R].CFrame.p
     Model:PivotTo(COORD(POS)*ANGLE(X,Y,Z))
     __SPECIAL_SWORD_THROWING=false

     BUSY+=1
     ANIM_BUSY=true
     IMMUNE = true
     SET_LOOK_AT_NEAREST()
     ANIM_QUERY(ANIM_GET('ATTACK_A11'))
     KNOCKBACK { Model, Velocity=GET_LOOK()*3, Time=1 }
     SET_SOUND(SND_SPCSHORT,Sword.PrimaryPart,1,0.6)
     FRAME{Frames=14, Pass=function(i) if (i%4==0) then AFTERIMAGE( Model ) end end}
     SET_SOUND(SND_LUNGE,Sword.PrimaryPart,0.7)
     SET_SOUND(SND_CLOCK_BELL,Sword.PrimaryPart,1,0.6)
     CLOCK { Radius=15, Color=COLOR(1,1,1), Coord1=Model_Body[ROOT].CFrame*COORD(0,0,-12), Minute=30.0, Hour=12.0, Duration=0.2 }
     KNOCKBACK { Model, Velocity=GET_LOOK()*70 }
     SWORD_TRAIL=true
     ATTACK { Frames=13, Whiff=7, Hitboxes={ [0]={
          [0]={Damage=10.0,DamageType='',HitStop=5,HitStun=0, Inflict={'STOPshort'}, Knockback=GET_LOOK()*-20,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT3,Pitch=0.9,Volume=0.6}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(3,6,7),Off=COORD(0,0,-3.5),Frames=6,HitOwner=false,Color=HB_COLOR_SOUR, Special={}},
          [1]={Damage=10.0,DamageType='',HitStop=5,HitStun=0, Inflict={'STOPshort'}, Knockback=GET_LOOK()*-25,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT3,Pitch=0.9,Volume=0.8}, Rehit=0, Host=Model_Body[HAND_R],Size=V3(3,6,4),Off=COORD(0,0,-8),Frames=6,HitOwner=false,Color=HB_COLOR_SWEET, Special={}}} }, FrameSpecial={[6]=function() SWORD_TRAIL=false IMMUNE=false end} }
     BUSY-=1
     ANIM_BUSY=false
     return
     end

if (not CLONE_ACTIVE) then
     -- ABILITY_A10 --
     if (INPUTBEFORE=='↑') then
     BUSY+=1
     SET_LOOK_AT_NEAREST()
     local thisCLONE, thisCLONE_ANIM = CLONE { Time=40/60, Animation=ANIM_GET('ATTACK_A11') }
     local valx = 4.2
     local ticker = valx
     SET_SOUND(SND_MAGIC3,Model_Body[ROOT],3.2,0.5)
     SET_SOUND(SND_SPCSHORT,Model_Body[ROOT],1,0.6)
     SET_SOUND(SND_CLOCK_BELL,Model_Body[ROOT],2,0.7)
     FRAME{Frames=14, Pass=function(i) if (i%4==0) then thisCLONE:PivotTo(thisCLONE:GetPivot()*COORD(0,0,-ticker)) ticker=valx*1-((i/14)^0.5) AFTERIMAGE( thisCLONE ) end end}
     BUSY-=1
     SET_SOUND(SND_LUNGE,thisCLONE[HAND_R],0.7)
     ATTACK { Frames=13, Whiff=0, Hitboxes={ [0]={
          [0]={Damage=5.0,DamageType='',HitStop=5,HitStopSelf=-5,HitStun=0, Inflict={}, Knockback=GET_LOOK(thisCLONE)*20,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT3,Pitch=0.9,Volume=0.6}, Rehit=0, Host=thisCLONE[HAND_R],Size=V3(3,6,7),Off=COORD(0,0,-3.5),Frames=9,HitOwner=false,Color=HB_COLOR_SOUR, Special={}},
          [1]={Damage=5.0,DamageType='',HitStop=5,HitStopSelf=-5,HitStun=0, Inflict={}, Knockback=GET_LOOK(thisCLONE)*25,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_CUT3,Pitch=0.9,Volume=0.8}, Rehit=0, Host=thisCLONE[HAND_R],Size=V3(3,6,4),Off=COORD(0,0,-8),Frames=9,HitOwner=false,Color=HB_COLOR_SWEET, Special={}}} }, FrameSpecial={} }
     CLONE_ACTIVE=nil
     return
     end
     
     -- ABILITY_A12 --
     if (INPUTBEFORE=='↓↑' and BUSY<=0) then
     BUSY+=1
     SET_LOOK_AT_NEAREST()
     ANIM_QUERY(ANIM_GET('ABILITY_A12'))
     KNOCKBACK { Model, Velocity=GET_LOOK()*1, Time=1 }
     SET_SOUND(SND_SPCSHORT,Model_Body[ROOT],1,0.6)
     FRAME{Frames=7, Pass=function(i) if (i%4==0) then AFTERIMAGE( Model ) end end}
     KNOCKBACK { Model, Velocity=GET_LOOK()*-14, Time=0.1 }
     SET_SOUND(SND_MAGIC3,Model_Body[ROOT],2.9,0.5)
     SET_SOUND(SND_EPITAPH,Model_Body[ROOT],0.9,0.6)
     SET_SOUND(SND_CLOCK_BELL,Model_Body[ROOT],2,0.7)

     local thisCLONE, thisCLONE_ANIM = CLONE { Time=9/60, Animation=ANIM_GET('CLONE_DASH') }
     local function CA () AFTERIMAGE( thisCLONE ) end
     Service'TweenService':Create(thisCLONE.PrimaryPart,TweenInfo.new(8/60,Enum.EasingStyle.Linear,Enum.EasingDirection.In,0,false,0),{CFrame=thisCLONE:GetPivot()*COORD(0,0,-20)}):Play()
     
     ATTACK { Frames=11, Whiff=0, Hitboxes={ [0]={
          [0]={Damage=6.5,DamageType='',HitStop=5,HitStopSelf=-5,HitStun=0, Inflict={'WARP'}, Knockback=GET_LOOK(thisCLONE)*45,KnockbackMax=nil,KnockbackTime=0.1, Sound={data=SND_GLITCH,Pitch=1.0,Volume=0.8}, Rehit=0, Host=thisCLONE[ROOT],Size=V3(3,6,7),Off=COORD(0,0,-3.5),Frames=8,HitOwner=false,Color=HB_COLOR_NORMAL, Special={}} } }, FrameSpecial={[2]=CA,[4]=CA,[6]=CA,[8]=CA}}
     BUSY-=1
     CLONE_ACTIVE=nil
     return
     end
end

if (BUSY<=0) then
     if (not COOLDOWNS ['ABILITY']) then
     SET_SOUND(SND_CLOCK_BELL,Model_Body[ROOT],4,0.5)
     SET_SOUND(SND_MAGIC2,Model_Body[ROOT],2.5,0.7)
     AFTERIMAGE ( Model )
     CLOCK { Radius=12, Color=COLOR(1,1,1), Minute=15.0, Hour=3.0, Duration=1.0 }
     local RANGE = 25
     local RESULT = RAY ( Model:GetPivot().p, GET_LOOK()*RANGE )
     local X,Y,Z = Model:GetPivot():ToEulerAnglesYXZ()
     if (RESULT) then
          Model:PivotTo(COORD(RESULT.Position)*ANGLE(X,Y,Z))
     else
          Model:PivotTo(Model:GetPivot()*COORD(0,0,-RANGE))
     end
     CLOCK { Radius=12, Color=COLOR(1,1,1), Minute=15.0, Hour=3.0, Duration=1.0 }
     COOLDOWNS ['ABILITY'] = 60
     end
end
end

local STOP_RADIUS = 70
function INPUT_CRITICAL()
if (BUSY<=0) then
     if (not COOLDOWNS ['CRITICAL']) then
     BUSY+=1
     ANIM_BUSY=true
     SET_LOOK_AT_NEAREST()
     SET_SOUND( SND_CHARGE, Model_Body[ROOT], 1.5 )
     SET_LOOPER( SND_CLOCK_TICKING, Sword.PrimaryPart, 5.0, 0.7, 0.47 )
     HL( Model, 0, 1, COLOR(1,1,1), COLOR(1,1,1), 0.2 )
     ANIM_QUERY( ANIM_GET('CRITICAL_A00') )
     FRAME { Frames=24, Pass=function(i) if (i%4==0) then AFTERIMAGE( Model ) end end }
     SIMPLE { Type='Ball', Material='Neon', Size0=V3(1,1,1)*STOP_RADIUS, Size1=V3(0,0,0), Transparency0=0.9, Color0=COLOR(1,1,1), Coord0=Model_Body[ROOT].CFrame, Anchored=true, CastShadow=false, Time=0.5 }
     SIMPLE { Type='Ball', Material='Neon', Size0=V3(1,1,1)*STOP_RADIUS, Size1=V3(0,0,0), Transparency0=0.9, Color0=COLOR(1,1,1), Coord0=Model_Body[ROOT].CFrame, Anchored=true, CastShadow=false, Time=0.75 }
     SIMPLE { Type='Ball', Material='Neon', Size0=V3(1,1,1)*STOP_RADIUS, Size1=V3(0,0,0), Transparency0=0.9, Color0=COLOR(1,1,1), Coord0=Model_Body[ROOT].CFrame, Anchored=true, CastShadow=false, Time=1.0 }
     SIMPLE { Type='Ball', Material='Neon', Size0=V3(1,1,1)*STOP_RADIUS, Size1=V3(0,0,0), Transparency0=0.9, Color0=COLOR(1,1,1), Coord0=Model_Body[ROOT].CFrame, Anchored=true, CastShadow=false, Time=1.25 }
     SIMPLE { Type='Ball', Material='Neon', Size0=V3(1,1,1)*STOP_RADIUS, Size1=V3(0,0,0), Transparency0=0.9, Color0=COLOR(1,1,1), Coord0=Model_Body[ROOT].CFrame, Anchored=true, CastShadow=false, Time=1.5 }
     SIMPLE { Save='StopBall', Type='Ball', Material='Neon', Size0=V3(1,1,1)*STOP_RADIUS, Transparency0=0.0, Transparency1=1.0, Color0=COLOR(1,1,1), Coord0=Model_Body[ROOT].CFrame, Anchored=true, CastShadow=false, Time=1.0 }
     SIMPLE { Holder='StopBall', Type='PointLight', Range0=60, Range1=5, Brightness0=1, Brightness1=0, Time=0.5 }

     CLOCK { Radius=STOP_RADIUS, Color=COLOR(1,1,1), Minute=15.0, Hour=6.0, Duration=2.0 }

     for _,x in workspace:GetDescendants() do
          if (not x:IsDescendantOf(Model) and x~=Model) then
               if (x:IsA('BasePart')) then
                    if ((not x.Anchored) and (x.Parent:IsA('Model')==false or x.Parent==workspace) and (x.Parent:IsA('BasePart')==false) and x.Parent:IsA('Accessory')==false and (x:GetPivot().p-Model_Body[ROOT].CFrame.p).Magnitude<=STOP_RADIUS/2) then
                         STATUS:Inflict( 'STOP', x )
                    end
               elseif (x:IsA('Model')) then
                    if ((x.Parent:IsA('Model')==false or x.Parent==workspace) and (x.Parent:IsA('BasePart')==false) and x.Parent:IsA('Accessory')==false and (x:GetPivot().p-Model_Body[ROOT].CFrame.p).Magnitude<=STOP_RADIUS/2) then
                         STATUS:Inflict( 'STOP', x )
                    end
               end
          end
     end

     FRAME { Frames=8 }
     SET_SOUND( SND_CLOCK_BELLER, Model_Body[ROOT], 1.0, 2.0 )
     SET_SOUND( SND_TIME_STOP, Model_Body[ROOT], 1.0, 1.0 )
     COOLDOWNS ['CRITICAL'] = 300
     BUSY-=1
     ANIM_BUSY=false
     end
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
          elseif(x=='D') then INPUTBEFORE=INPUTBEFORE..'→'
          elseif(x=='R') then 
               LOCKED = nil
               LOCKED_TIMER=0 end
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
          elseif (key.KeyCode == Enum.KeyCode.Q) then
               Remote:FireServer('ABILITY',true)
          elseif (key.KeyCode == Enum.KeyCode.E) then
               Remote:FireServer('CRITICAL',true)
          elseif (key.KeyCode == Enum.KeyCode.Z) then
               Remote:FireServer('@R',true)
               HL( Model, 0, 1, COLOR(1,1,1), COLOR(1,1,1), 0.1 )
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
          elseif (key.KeyCode == Enum.KeyCode.Q) then
               Remote:FireServer('ABILITY',false)
          elseif (key.KeyCode == Enum.KeyCode.E) then
               Remote:FireServer('CRITICAL',false)
          elseif (key.KeyCode == Enum.KeyCode.F) then
               Humanoid.WalkSpeed *= 2
               Remote:FireServer('@B',false)
               end
          end
     end)

end

setmetatable(Chrono,ChronoMT)
return Chrono