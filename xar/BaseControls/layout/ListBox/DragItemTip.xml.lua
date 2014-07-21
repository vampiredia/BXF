function SetText(self, text)
	local textobj = self:GetControlObject("tip.text")
	textobj:SetText(text)

	local textWidth, textHeight = textobj:GetTextExtent()

	local textObj = self:GetControlObject("tip.text")
	local left, top, right, bottom = textObj:GetObjPos()
	left = 5
	right = left + textWidth
	bottom = top + textHeight
	textObj:SetObjPos(left, top, right, bottom)
end

function GetSize(self, width, height)
    local text = self:GetControlObject("tip.text")
    local textwidth, textheight = text:GetTextExtent()
    local neededwidth, neededheight = width, height
    if neededwidth < textwidth + 14 then
        neededwidth = textwidth + 14
    end
    if neededheight < textheight + 16 then
        neededheight = textheight + 16
    end
    return neededwidth, neededheight
end

function DeleteSelf(self)
    local parent = self:GetParent()
    parent:RemoveChild(self)
end

function SetType(self, type_)
    local bkg = self:GetControlObject("tip.bkg")
    local text = self:GetControlObject("tip.text")
    local left, top, right, bottom = text:GetObjPos()
	local attr = self:GetAttribute()
    if type_ == 1 then
		attr.BkgTexture = "texture.tip.bkg.left.up"
        bkg:SetTextureID("texture.tip.bkg.left.up")
    elseif type_ == 2 then
		attr.BkgTexture = "texture.tip.bkg.left.down"
        bkg:SetTextureID("texture.tip.bkg.left.down")
        text:SetObjPos("5", "11", "father.width - 5", "father.height - 1")
    elseif type_ == 3 then
		attr.BkgTexture = "texture.tip.bkg.right.up"
        bkg:SetTextureID("texture.tip.bkg.right.up")
    elseif type_ == 4 then
		attr.BkgTexture = "texture.tip.bkg.right.down"
        bkg:SetTextureID("texture.tip.bkg.right.down")
        text:SetObjPos("5", "11", "father.width - 5", "father.height - 1")
    end
end

function SetMultilineParam(self, isMultiline, width)
	local text = self:GetControlObject("tip.text")
	text:SetMultiline(isMultiline)
	text:SetMultilineTextLimitWidth(width)
end



function OnPosChange(self)
	local attr = self:GetAttribute()
	local textObj = self:GetControlObject("tip.text")
	local left, top, right, bottom = textObj:GetObjPos()
	local width, height = right - left, bottom - top
	left = 7
	top = attr.TextBeginV
	right = left + width
	bottom = top + height
	textObj:SetObjPos(left, top, right, bottom)
end


function OnInitControl(self)
	local attr = self:GetAttribute()
	local bkgObj = self:GetControlObject("tip.bkg")
	bkgObj:SetTextureID(attr.BkgTexture)
	self:SetZorder( attr.Zorder )
end

function SetHAlign(self, _type)
	local textObj = self:GetControlObject("tip.text")
	textObj:SetHAlign(_type)
end



