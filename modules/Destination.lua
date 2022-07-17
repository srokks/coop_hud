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
---@field public THE_BEAST number
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
coopHUD.Destination.MOM = 1
coopHUD.Destination.IT_LIVES = 2
coopHUD.Destination.SATAN = 3
coopHUD.Destination.ISAAC = 4
coopHUD.Destination.THE_LAMB = 5
coopHUD.Destination.BLUE_BABY = 6
coopHUD.Destination.MEGA_SATAN = 7
coopHUD.Destination.HUSH = 8
coopHUD.Destination.DELIRIUM = 9
coopHUD.Destination.THE_BEAST = 11
---@private
function coopHUD.Destination.new(destination)
    ---@type coopHUD.Destination
    local self = setmetatable({}, coopHUD.Destination)
    ---@private
    self.dest = self.getDestination(destination)
    ---@private
    self.sprite = self:getSprite()
    return self
end
---@protected
---@return number
function coopHUD.Destination.getDestination(destination)
    local dest = destination
    return dest
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