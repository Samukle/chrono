
local RunService = game:GetService('RunService')
local TweenService = game:GetService('TweenService')
local ServerSide = not game:GetService('Players').LocalPlayer
Tween = function(k,es,ed,t,q) return TweenService:Create(k,TweenInfo.new(t,Enum.EasingStyle[es],Enum.EasingDirection[ed],0,false,0),q) end

PROP_TIME = '$time'
PROP_LENGTH = '$length'
PROP_JOINT = '$joint'
PROP_KEY = '$key'
FLOOR, CEIL = math.floor, math.ceil

--------------------------------------------------------------------------------------------

local Animator = {}
local AnimatorMT = {}
AnimatorMT.__index = AnimatorMT

function Animator.new(Rig)
local self = {}
self.RIG = Rig

self.JOINTS = {}
self.JOINTS_C0 = {}

for _,b in self.RIG:GetDescendants() do
     if (b:IsA('Motor6D') or b:IsA('Weld')) then
          if b.Part0 and b.Part1 then
               self.JOINTS [b.Part1.Name] = b
               self.JOINTS_C0 [b.Part1.Name] = b.C0
               end
          end
     end

print(self.JOINTS)
print(self.JOINTS_C0)

self.BUSY = false
self.TICK = 0
self.TICK_SEC = 0
self.KEYFRAMES = {}
self.KEYFRAMES_ALREADY = {}
self.TWEENS = {}
self.POSE_READ = {}
self.POSE_READ_ALREADY = {}
self.POSE_THIS = {}
self.POSE_THAT = {}
self.LENGTH = 0
self.CURRENT = nil
self.LOOPED = false
self.PLAYING = false

self.CONNECTION = RunService.Heartbeat:Connect(function(delta)
if (not self.BUSY) then
if (self.CURRENT) then

     if (self.TICK_SEC>=self.LENGTH) then
     if (self.LOOPED) then self.TICK = 0 else self:STOP() end
     end

     self.TICK += 1
     self.TICK_SEC = self.TICK/60

     for LIMB,DATA in self.POSE_READ do
          if (DATA [PROP_JOINT]) then
               local MAX, THIS = 0, 1
               for KEY,FRAME in DATA do
                    if (type(KEY)=='number' and FRAME[PROP_TIME]<=self.TICK_SEC and FRAME[PROP_TIME]>=MAX) then MAX=FRAME[PROP_TIME] THIS=KEY end
               end
               local THAT = THIS+1
               if(DATA[THIS] and DATA[THAT]) then
                    local diff, alpha = 0, 0
                    diff = DATA[THAT][PROP_TIME]-DATA[THIS][PROP_TIME]
                    alpha = (self.TICK_SEC-DATA[THIS][PROP_TIME])/diff
                    DATA[PROP_JOINT].C0 = DATA[THIS].CF:Lerp(DATA[THAT].CF,alpha)
               elseif(DATA[THIS] and not DATA[THAT]) then
                    DATA[PROP_JOINT].C0 = DATA[THIS].CF:Lerp(DATA[THIS].CF,1)
               end
          end
     end

else self.PLAYING = false end
else self.PLAYING = false end
end)

setmetatable(self, AnimatorMT)
return self
end

do
     function AnimatorMT:READ( INST : KeyframeSequence )
          local KF = INST:GetKeyframes()
          table.sort(KF, function(a,b) return a.Time<=b.Time end)
          return KF
          end

     function AnimatorMT:PLAY( INST : KeyframeSequence, FADE : number )
          local FADE = FADE or 0.1
          if (INST) then
               local EXTRACTED_KEYFRAMES
               if (not self.KEYFRAMES_ALREADY [INST]) then
                    EXTRACTED_KEYFRAMES = self:READ(INST)
                    self.KEYFRAMES_ALREADY [INST] = EXTRACTED_KEYFRAMES
               else
                    EXTRACTED_KEYFRAMES = self.KEYFRAMES_ALREADY [INST]
                    end

               self.KEYFRAMES = EXTRACTED_KEYFRAMES

               self.TICK = 0
               self.TICK_SEC = 0
               self.POSE_READ = {}
               self.POSE_THIS = {}
               self.LENGTH = EXTRACTED_KEYFRAMES[#EXTRACTED_KEYFRAMES].Time
               self.CURRENT = INST
               self.LOOPED = INST.Loop
               self.PLAYING = true

               if (not self.POSE_READ_ALREADY [INST]) then
                    local function Read_This_Thing(PoseOrKeyframe,KEY,TIME)
                         local this = PoseOrKeyframe:IsA("Keyframe") and PoseOrKeyframe:GetPoses()
                                   or PoseOrKeyframe:IsA("Pose") and PoseOrKeyframe:GetSubPoses()
                         for _,POSE in this do
                              if(POSE.CFrame~=CFrame.identity) then
                              self.POSE_READ[POSE.Name]=self.POSE_READ[POSE.Name] or {[PROP_JOINT]=self.JOINTS [POSE.Name]}
                              self.POSE_READ[POSE.Name][#self.POSE_READ[POSE.Name]+1] = {CF=(self.JOINTS_C0[POSE.Name]~=nil and self.JOINTS_C0[POSE.Name] or CFrame.new())*POSE.CFrame,ES=POSE.EasingStyle.Name,ED=POSE.EasingDirection.Name,[PROP_TIME]=TIME,[PROP_KEY]=KEY}
                              end
                              Read_This_Thing(POSE,KEY,TIME)
                         end
                    end

                    for KEY,KEYFRAME in EXTRACTED_KEYFRAMES do
                         Read_This_Thing(KEYFRAME,KEY,KEYFRAME.Time)
                    end
                    self.POSE_READ_ALREADY [INST] = self.POSE_READ
               else
                    self.POSE_READ = self.POSE_READ_ALREADY [INST]
                    end
          else
               self.TICK = 0
               self.TICK_SEC = 0
               self.KEYFRAMES = {}
               self.KEYFRAMES_ALREADY = {}
               self.POSE_READ = {}
               self.POSE_READ_ALREADY = {}
               self.POSE_THIS = {}
               self.POSE_LENGTH = 0
               self.CURRENT = nil
               self.LOOPED = false
               self.PLAYING = false
               end
          end

     function AnimatorMT:STOP( )
          self:PLAY()
          end

end

return Animator.new(script.Parent)