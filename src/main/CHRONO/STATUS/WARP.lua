local STATUS = require(script.Parent)

function TICKStart ( self, Ocurrance )
end
function TICKAdd ( self, Ocurrance )
Ocurrance.Duration += 1.0
Ocurrance.Time = Ocurrance.Duration
end
function TICKWhile ( self, Ocurrance )
end
function TICKEnd ( self, Ocurrance )
end

return STATUS:Index( 'WARP', { Duration=10.0, Color=Color3.new(0,0.5,0), Display='WARPED', TICKStart=TICKStart, TICKWhile=TICKWhile, TICKAdd=TICKAdd, TICKEnd=TICKEnd } )