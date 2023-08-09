local STATUS = { list = {} }
local STATUS_MT = { }
STATUS_MT.__index = STATUS_MT

local StatusEffectClass = { } ; StatusEffectClass.__index = StatusEffectClass

------------------------------------------------

do

     function STATUS_MT:Index( thisName, thisData )
     local this = { }
     this.Name      = thisName
     this.Duration  = thisData.Duration or 1.0
     this.Color     = thisData.Color    or Color3.new(1,1,1)
     this.Display   = thisData.Display  or this.thisName
     this.Ocurrance = { }

     this.TICKStart = function( self, Ocurrance ) thisData.TICKStart( self, Ocurrance ) end
     this.TICKWhile = function( self, Ocurrance ) thisData.TICKWhile( self, Ocurrance ) end
     this.TICKAdd   = function( self, Ocurrance ) thisData.TICKAdd( self, Ocurrance ) end
     this.TICKEnd   = function( self, Ocurrance ) thisData.TICKEnd( self, Ocurrance ) if (Ocurrance.UI and Ocurrance.UI.Parent) then Ocurrance.UI:Destroy() end if (Ocurrance.Connection) then Ocurrance.Connection:Disconnect() end self.Ocurrance [Ocurrance.Subject] = nil end

     setmetatable( this, StatusEffectClass )
     self.list [thisName] = this
     return this
     end

     function STATUS_MT:Inflict( thisName, subject )
     local status = self.list [thisName] or (script:FindFirstChild(thisName) ~= nil and require(script[thisName]) or nil)
     if (status ~= nil) then status:Inflict(subject) end
     end

     function STATUS_MT:Has( thisName, subject )
     local get for _,x in subject:GetChildren() do
          if (x.Name == "$EFFECTS" and x:IsA('BillboardGui')) then get=x end
     end

     if (get) then
          return (get:FindFirstChild(thisName))
     end
     return nil

     end

end

-----------------------------------------------

do

     function StatusEffectClass:Inflict( subject )
     local this = self.Ocurrance [subject]
     if (this == nil) then this = self:NewOcurrance(subject) ; self.Ocurrance [subject] = this
     self:TICKStart ( this ) else self:TICKAdd( this ) end
     this.Stack += 1 ; this.Time = 0
     end

     function StatusEffectClass:Clear( subject )
     local this = self.Ocurrance [subject]
     if (this ~= nil) then this.Time = self.Duration end
     self:TICKEnd ( this )
     end

     function StatusEffectClass:NewOcurrance( subject )
     local Billboard for _,x in subject:GetChildren() do
          if (x.Name == "$EFFECTS" and x:IsA('BillboardGui')) then Billboard=x end
     end
     if (not Billboard) then
          Billboard = Instance.new('BillboardGui')
          Billboard.Name = "$EFFECTS"
          Billboard.Adornee = subject
          Billboard.AlwaysOnTop = true
          Billboard.SizeOffset = Vector2.new(0,3)
          Billboard.Size = UDim2.new(10000,0,1.25,0)
               local ListLayout = Instance.new('UIListLayout', Billboard)
               ListLayout.HorizontalAlignment = "Center"
               ListLayout.VerticalAlignment = "Center"
               ListLayout.FillDirection = "Horizontal"
               ListLayout.Padding = UDim.new(0.00001,0)
          Billboard.Parent = subject
     end

     local UI = Instance.new('TextLabel')
     UI.Font = Enum.Font.SourceSansBold
     UI.Size = UDim2.new(0.001,0,1,0)
     UI.Name = self.Name
     UI.BackgroundTransparency = 1
     UI.TextStrokeTransparency = 0
     UI.Text = self.Display:upper()
     UI.TextColor3 = self.Color
     UI.TextScaled = true
     UI.ZIndex = 2
     UI.RichText = true
          local TimeBar = Instance.new('Frame')
          TimeBar.Name = "TimeBar"
          TimeBar.Size = UDim2.new(1,0,1,0)
          TimeBar.BackgroundTransparency = 0.9
          TimeBar.BackgroundColor3 = Color3.new(0,0,0)
          TimeBar.BorderSizePixel = 0
               local TimingBar = Instance.new('Frame')
               TimingBar.Name = "TimingBar"
               TimingBar.Size = UDim2.new(1,0,1,0)
               TimingBar.BackgroundTransparency = 0.5
               TimingBar.BackgroundColor3 = self.Color
               TimingBar.BorderSizePixel = 0
               TimingBar.Parent = TimeBar
          TimeBar.Parent = UI

          local StackText = Instance.new('TextLabel')
          StackText.Font = Enum.Font.SourceSansBold
          StackText.Size = UDim2.new(0.5,0,0.5,0)
          StackText.Position = UDim2.new(0.5,0,1,0)
          StackText.AnchorPoint = Vector2.new(0.5,1)
          StackText.Name = "Stack"
          StackText.BackgroundTransparency = 1
          StackText.TextStrokeTransparency = 0
          StackText.TextColor3 = Color3.new(1,1,1)
          StackText.TextScaled = true
          StackText.ZIndex = 3
          StackText.Parent = UI
     UI.Parent = Billboard

     local connec;connec = game:GetService'RunService'.Heartbeat:Connect(function()
     local Ocurrance = self.Ocurrance [subject]
     if (Ocurrance) then 
          Ocurrance.Time += 1 
          TimingBar.Size=UDim2.new(1-(Ocurrance.Time/(Ocurrance.Duration*60)),0,1,0)
          StackText.Text=(Ocurrance.Stack>1 and 'x'..tostring(Ocurrance.Stack) or '')
          UI:SetAttribute('Stack',Ocurrance.Stack)
          UI:SetAttribute('Time',Ocurrance.Time)
          UI:SetAttribute('Duration',Ocurrance.Duration)
          self:TICKWhile( Ocurrance )
          if (Ocurrance.Time>=Ocurrance.Duration*60) then self:Clear(subject) end 
     else connec:Disconnect() end
     end)
     self.Ocurrance [subject] = { Subject = subject, UI = UI, Stack = 0, Time = 0, Duration = self.Duration, Variables = {}, Connection = connec }
     return self.Ocurrance [subject]
     end

end

setmetatable(STATUS, STATUS_MT)
return STATUS