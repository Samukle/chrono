CONST = {

ANIM_PLAY="\x00";
ANIM_STOP="\x01";
ANIM_PAUSE="\x02";
ANIM_RESUME="\x03";

}

local f = getfenv(1)
for CNST, VAL in CONST do
     f [CNST] = VAL
     end

return CONST