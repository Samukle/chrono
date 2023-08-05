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

BUSY = 0
TICK = 0
ANIM_BUSY = false
ANIM_TICK = 0
ANIM = nil
ANIM_LIST = script:WaitForChild("ANIM")
ANIM_IDLE = ANIM_LIST:WaitForChild("IDLE")
ANIM_TIME = 0.1
ANIM_LERP = 0.1
ANIM_POSES = {}
ANIM_POSE_THIS = {}
ANIM_KEYS = {}
ANIM_PLAYING = {}
ANIM_LENGTH = 0

do
local ANIM_PLAYING_MT = {}
ANIM_PLAYING_MT.__index = ANIM_PLAYING_MT
function ANIM_PLAYING_MT:Cancel()
for K,_ in self do self[K]=nil end
end

setmetatable(ANIM_PLAYING,ANIM_PLAYING_MT)
end

COMBO = 0
SWORD = true
SWORD_TRAIL = false
SWORD_PARTICLE = false

Model = script.Parent         Chrono.Model = Model
Player = Player(Model.name)   Chrono.Player = Player
Humanoid = Model:FindFirstChildOfClass("Humanoid")

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

ANIM_QUERY = function(INST)
if(INST) then
     local Keyframes = INST:GetKeyframes()
     table.sort(Keyframes,function(a,b) return a.Time<=b.Time end)
     ANIM_TICK = 0
     ANIM_LENGTH = Keyframes [#Keyframes].Time
     ANIM = INST
     ANIM_KEYS = Keyframes
     local function CHECK_POSE(INPUT,KEY)
          --print(INPUT,KEY)
          local this = INPUT:IsA("Keyframe") and INPUT:GetPoses()
                    or INPUT:IsA("Pose") and INPUT:GetSubPoses()
          for _,POSE in this do
               --warn("LOAD:",POSE.Name,POSE.CFrame)
               local CF = {CF=Model_Joints_Basic [POSE.Name]*POSE.CFrame,ES=POSE.EasingStyle.Name,ED=POSE.EasingDirection.Name}
               ANIM_POSES[KEY][POSE.Name] = POSE.Name~="HumanoidRootPart" and CF or nil
               CHECK_POSE(POSE,KEY)
          end
     end
     for KEY,KEYFRAME in Keyframes do
     ANIM_POSES[KEY]={['$time']=KEYFRAME.Time}
     CHECK_POSE(KEYFRAME,KEY)
     end
     ANIM_POSE_THIS=ANIM_POSES[1]
     ANIM_POSE(ANIM_POSE_THIS)
else
     ANIM = nil
     ANIM_POSES = {}
     ANIM_KEYS = {}
     ANIM_TICK = 0
     ANIM_LENGTH = 0
     end
end

ANIM_POSE = function(LIST)
for NAME,POSE in LIST do if(NAME:sub(1,1)~="$") then local this = Model_Joints[NAME]
Service'TweenService':Create(this,
     TweenInfo.new(LIST['$time'],
                    Enum.EasingStyle[POSE.ES],Enum.EasingDirection[POSE.ED],
                    0,false,0),
                    {C0=POSE.CF}):Play() end end
end

if(IsServer) then

Chrono.loop = OnTick(function()
TICK += 1

if(Model_Body [ROOT] : CanSetNetworkOwnership()) then
     Model_Body[ROOT] : SetNetworkOwner(nil)
end

if(ANIM) then
     ANIM_TICK += 1
     if(not ANIM_BUSY) then
          if(not RUNNING) then
               ANIM_QUERY_SAFE(ANIM_IDLE)
          else
               ANIM_QUERY_SAFE(ANIM_RUN)
          end
     end

     local SECOND = ANIM_TICK/60
     --print(ANIM_POSES)
     --print(ANIM_POSE_THIS)

     for TIME,K in ANIM_POSES do
     if(ANIM_TICK==math.ceil(K['$time']*60)) then
     print(ANIM_TICK,"|",TIME,TIME*60)
     --print(NEXTFRAME,POSE)
     ANIM_POSE_THIS=K
     ANIM_POSE(ANIM_POSE_THIS)
     end
     end

     if(SECOND>=ANIM_LENGTH) then
     if(ANIM.Loop) then ANIM_TICK = 0 else ANIM_QUERY() end
     end

 else

     if(not ANIM_BUSY) then
     ANIM_QUERY(ANIM_IDLE)
     end

     end

__DEBUG_TEXT.Text = [[-- CHRONO DEBUGGING --
]]..[[アニメ：]]..(ANIM~=nil and ANIM:GetFullName() or "無し")..[[　
アニメ　フレム：]]..tostring(ANIM_TICK)..[[/]]..tostring(math.ceil(ANIM_LENGTH*60))..[[　
アニメ　秒：　]]..tostring(ANIM_TICK/60)..[[/]]..tostring(ANIM_LENGTH)..[[　
]]
end)

elseif(IsClient) then

workspace.CurrentCamera.CameraSubject = Humanoid
__DEBUG_UI.Parent = Player.PlayerGui

end

setmetatable(Chrono,ChronoMT)
return Chrono