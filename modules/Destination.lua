---@class coopHUD.Destination
---@field public MOM number
---@field public IT_LIVES number
---@field public SATAN number
---@field public ISAAC number
---@field public THE_LAMB number
---@field public BLUE_BABY number
---@field public MEGA_SATAN number
---@field public HUSH number
---@field public DELIRIUM number
---@field public MOTHER number
---@protected field anim_path string
---@type coopHUD.Destination | fun(destination:number):coopHUD.Destination
coopHUD.Destination = {}
coopHUD.Destination.__index = coopHUD.Destination
setmetatable(coopHUD.Destination, {
    __call = function(cls, ...)
        return cls.new(...)
    end,
})
coopHUD.Destination.anim_path = "gfx/ui/hudpickups.anm2"
coopHUD.Destination.MOM = 0
coopHUD.Destination.IT_LIVES = 1
coopHUD.Destination.SATAN = 2
coopHUD.Destination.ISAAC = 3
coopHUD.Destination.THE_LAMB = 4
coopHUD.Destination.BLUE_BABY = 5
coopHUD.Destination.MEGA_SATAN = 6
coopHUD.Destination.HUSH = 8
coopHUD.Destination.DELIRIUM = 9
coopHUD.Destination.MOTHER = 11
--Table of challenges end stage. Cannot get from api, and in xml file there's only stage number
--In future to support modded chalenges somehow only need to append them into table
local challenge_to_type = {
    [1] = coopHUD.Destination.MOM,
    [2] = coopHUD.Destination.MOM,
    [3] = coopHUD.Destination.MOM,
    [4] = coopHUD.Destination.SATAN,
    [5] = coopHUD.Destination.MOM,
    [6] = coopHUD.Destination.IT_LIVES,
    [7] = coopHUD.Destination.ISAAC,
    [8] = coopHUD.Destination.MOM,
    [9] = coopHUD.Destination.IT_LIVES,
    [10] = coopHUD.Destination.MOM,
    [11] = coopHUD.Destination.SATAN,
    [12] = coopHUD.Destination.MOM,
    [13] = coopHUD.Destination.MOM,
    [14] = coopHUD.Destination.MOM,
    [15] = coopHUD.Destination.MOM,
    [16] = coopHUD.Destination.MOM,
    [17] = coopHUD.Destination.MOM,
    [18] = coopHUD.Destination.MOM,
    [19] = coopHUD.Destination.ISAAC,
    [20] = coopHUD.Destination.MOM,
    [21] = coopHUD.Destination.MOM,
    [22] = coopHUD.Destination.MOM,
    [23] = coopHUD.Destination.SATAN,
    [24] = coopHUD.Destination.ISAAC,
    [25] = coopHUD.Destination.IT_LIVES,
    [26] = coopHUD.Destination.MEGA_SATAN,
    [27] = coopHUD.Destination.BLUE_BABY,
    [28] = coopHUD.Destination.IT_LIVES,
    [29] = coopHUD.Destination.ISAAC,
    [30] = coopHUD.Destination.MOM,
    [31] = coopHUD.Destination.MEGA_SATAN,
    [32] = coopHUD.Destination.IT_LIVES,
    [33] = coopHUD.Destination.ISAAC,
    [34] = coopHUD.Destination.MEGA_SATAN,
    [35] = coopHUD.Destination.BLUE_BABY,
    [36] = coopHUD.Destination.MOM,
    [37] = coopHUD.Destination.SATAN,
    [38] = coopHUD.Destination.ISAAC,
    [39] = coopHUD.Destination.MOTHER,
    [40] = coopHUD.Destination.IT_LIVES,
    [41] = coopHUD.Destination.ISAAC,
    [42] = coopHUD.Destination.SATAN,
    [43] = coopHUD.Destination.MOM,
    [44] = coopHUD.Destination.MOTHER,
    [45] = coopHUD.Destination.BLUE_BABY,
}
---@private
function coopHUD.Destination.new(destination)
    ---@type coopHUD.Destination
    local self = setmetatable({}, coopHUD.Destination)
    if destination then
        self.dest = destination
    else
        self.dest = self.getDestination()
    end
    ---@private
    self.sprite = self:getSprite()
    return self
end
---@protected
---@return number
function coopHUD.Destination.getDestination()
    local challenge_type = Isaac.GetChallenge()
    return challenge_to_type[challenge_type]
end
---@private
---@param self coopHUD.Destination
---@return Sprite
function coopHUD.Destination.getSprite(self)
    local sprite = Sprite()
    sprite:Load(self.anim_path, true)
    sprite:SetFrame('Destination', self.dest)
    sprite:LoadGraphics()
    return sprite
end
---@param self coopHUD.Destination
---@param pos Vector
---@param mirrored boolean
---@param down_anchor boolean
function coopHUD.Destination.render(self, pos, mirrored, down_anchor)
    local temp_pos = Vector(pos.X, pos.Y)
    local offset = Vector(0, 0)
    if self.sprite then
        offset = Vector(16, 16)
        if down_anchor then
            temp_pos.Y = temp_pos.Y - 16
            offset.Y = offset.Y * -1
        end
        if mirrored then
            temp_pos.X = temp_pos.X - 16
            offset.X = offset.X * -1
        end
        self.sprite:Render(temp_pos)
    end
    return offset
end