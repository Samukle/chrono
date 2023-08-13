local PartTypes = { Ball=true, Block=true, Cylinder=true, CornerWedge=true, Wedge=true, Mesh=true }
local HighlightTypes = { BallHighlight=true, BlockHighlight=true }
local LightTypes = { PointLight=true, SurfaceLight=true }
local DecalTypes = { Decal=true, Texture=true }

local function tween ( obj, result, ES, ED, time )
return game:GetService('TweenService'):Create( obj, TweenInfo.new(time, Enum.EasingStyle[ES], Enum.EasingDirection[ED], 0,false,0), result )
end

local proxy={}
return function ( data )
     task.spawn(function()
     local Type = data.Type or 'Ball'
     local Time = data.Time
     local TimeFRAMES = math.floor(Time*60)
     local SAVED_SPACE = data.Save
     if (PartTypes [Type]) then
          local Material = data.Material or 'Neon'
          local Size0, Size1                 = data.Size0 or Vector3.zero, data.Size1 or data.Size0 or Vector3.zero
          local Transparency0, Transparency1 = data.Transparency0 or 0, data.Transparency1 or data.Transparency0 or 0
          local Coord0, Coord1, CoordAdd     = data.Coord0 or CFrame.identity, data.Coord1, data.CoordAdd
          local Color0, Color1               = data.Color0 or Color3.new(1,1,1), data.Color1 or data.Color0 or Color3.new(1,1,1)
          local Anchored, CastShadow         = data.Anchored or true, data.CastShadow or false
          local randomSize         = data.randomSize -- { min:{x:0,y:0,z:0}, max:{x:0,y:0,z:0} }
          local randomTransparency = data.randomTransparency -- { min:number, max:number }
          local randomCoord        = data.randomCoord -- { min:{x:0,y:0,z:0,xR:0,yR:0,zR:0}, max:{x:0,y:0,z:0,xR:0,yR:0,zR:0} }

          local this = Instance.new('Part')
          this.Material = Material
          this.Size = Size0 ; this.CFrame = Coord0 ; this.Color = Color0 ; this.Transparency = Transparency0
          this.Anchored = Anchored ; this.CastShadow = CastShadow
          this.CanCollide = false ; this.Massless = true
          this.Shape = (Type~='Mesh') and Type or 'Block'
          this.Parent = data.Parent or workspace

          if (SAVED_SPACE) then proxy [SAVED_SPACE] = this end

          local Adder = CFrame.identity
          for i=1,TimeFRAMES do
               local alpha = i/TimeFRAMES
               this.Size = Size0:Lerp(Size1 or Size0,alpha) + (randomSize~=nil and Vector3.new(math.random(randomSize.min.x,randomSize.max.x)/100,math.random(randomSize.min.y,randomSize.max.y)/100,math.random(randomSize.min.z,randomSize.max.z)/100) or Vector3.zero)

               this.CFrame = Coord0:Lerp(Coord1 or Coord0,alpha) * Adder * (randomCoord~=nil and CFrame.new(math.random(randomCoord.min.x,randomCoord.max.x)/100,math.random(randomCoord.min.y,randomCoord.max.y)/100,math.random(randomCoord.min.z,randomCoord.max.z)/100)*CFrame.Angles(math.rad(math.random(randomCoord.min.xR,randomCoord.max.xR)/100),math.rad(math.random(randomCoord.min.yR,randomCoord.max.yR)/100),math.rad(math.random(randomCoord.min.zR,randomCoord.max.zR)/100)) or CFrame.identity)

               Adder *= (CoordAdd ~= nil and CoordAdd or CFrame.identity)

               this.Transparency = (Transparency0+(Transparency1-Transparency0)*alpha) + (randomTransparency~=nil and math.random(randomTransparency.min,randomTransparency.max)/100 or 0)
               this.Color = Color3.new(Color0.R+(Color1.R-Color0.R)*alpha, Color0.G+(Color1.G-Color0.G)*alpha, Color0.B+(Color1.B-Color0.B)*alpha)
               task.wait()
          end

          if (proxy [SAVED_SPACE] == this) then proxy [SAVED_SPACE] = nil end
          this:Destroy()
          
     elseif (HighlightTypes [Type]) then
          local OutlineColor0, OutlineColor1 = data.OutlineColor0, data.OutlineColor1

     elseif (LightTypes [Type]) then
          local Color0, Color1 = data.Color0 or Color3.new(1,1,1), data.Color1 or data.Color0 or Color3.new(1,1,1)
          local Range0, Range1 = data.Range0 or 1, data.Range1 or data.Range0 or 1
          local Brightness0, Brightness1 = data.Brightness0 or 1, data.Brightness1 or data.Brightness0 or 1
          local Holder = type(data.Holder)~='string' and data.Holder or proxy [data.Holder]

          local this = Instance.new(Type)
          this.Color = Color0 ; this.Range = Range0 ; this.Brightness = Brightness0
          this.Parent = Holder

          if (SAVED_SPACE) then proxy [SAVED_SPACE] = this end

          for i=1,TimeFRAMES do
               local alpha = i/TimeFRAMES
               this.Brightness = Brightness0+(Brightness1-Brightness0)*alpha
               this.Range = Range0+(Range1-Range0)*alpha
               this.Color = Color3.new(Color0.R+(Color1.R-Color0.R)*alpha, Color0.G+(Color1.G-Color0.G)*alpha, Color0.B+(Color1.B-Color0.B)*alpha)
               task.wait()
          end

          if (proxy [SAVED_SPACE] == this) then proxy [SAVED_SPACE] = nil end
          this:Destroy()

     elseif (DecalTypes [Type]) then
          local Color0, Color1               = data.Color0 or Color3.new(1,1,1), data.Color1 or data.Color0 or Color3.new(1,1,1)
          local Transparency0, Transparency1 = data.Transparency0 or 0, data.Transparency1 or data.Transparency0 or 0
          local Texture = data.Texture
          local Face = data.Face
          local Holder = type(data.Holder)~='string' and data.Holder or proxy [data.Holder]

          local this = Instance.new(Type)
          this.Color3 = Color0 ; this.Texture = data.Texture ; this.Face = Enum.NormalId [Face]
          this.Parent = Holder

          if (SAVED_SPACE) then proxy [SAVED_SPACE] = this end

          for i=1,TimeFRAMES do
               local alpha = i/TimeFRAMES
               this.Color3 = Color3.new(Color0.R+(Color1.R-Color0.R)*alpha, Color0.G+(Color1.G-Color0.G)*alpha, Color0.B+(Color1.B-Color0.B)*alpha)
               this.Transparency = (Transparency0+(Transparency1-Transparency0)*alpha) + (randomTransparency~=nil and math.random(randomTransparency.min,randomTransparency.max)/100 or 0)
               task.wait()
          end

          if (proxy [SAVED_SPACE] == this) then proxy [SAVED_SPACE] = nil end
          this:Destroy()

     end
     return
     end)
end