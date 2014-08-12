local function SetStatus(self, newState, forceupdate)
    local attr = self:GetAttribute()
    if forceupdate or newState ~= attr.Status then
        local ownerTree = self:GetOwner()
		if attr.ResType == "bitmap" then
			local bkg = self:GetControlObject("bitmap.button.bkg")
			if newState == 1 then
				bkg:SetResID(attr.NormalBkgID)
			elseif newState == 2 then
				bkg:SetResID(attr.HoverBkgID)
			elseif newState == 3 then
				bkg:SetResID(attr.DownBkgID)
			elseif newState == 4 then
				bkg:SetResID(attr.DisableBkgID)
			end		
		else
			local bkg = self:GetControlObject("texture.button.bkg")
			if newState == 1 then
				bkg:SetTextureID(attr.NormalBkgID)
			elseif newState == 2 then
				bkg:SetTextureID(attr.HoverBkgID)
			elseif newState == 3 then
				bkg:SetTextureID(attr.DownBkgID)
			elseif newState == 4 then
				bkg:SetTextureID(attr.DisableBkgID)
			end			
		end
        attr.Status = newState
    end
end

function UpdateUI(self)
    local attr = self:GetAttribute()
	if attr.ResType == "bitmap" then
		local bkg = self:GetControlObject("bitmap.button.bkg")
		if newState == 1 then
			bkg:SetResID(attr.NormalBkgID)
		elseif newState == 2 then
			bkg:SetResID(attr.HoverBkgID)
		elseif newState == 3 then
			bkg:SetResID(attr.DownBkgID)
		elseif newState == 4 then
			bkg:SetResID(attr.DisableBkgID)
		end		
	else
		local bkg = self:GetControlObject("texture.button.bkg")
		if newState == 1 then
			bkg:SetTextureID(attr.NormalBkgID)
		elseif newState == 2 then
			bkg:SetTextureID(attr.HoverBkgID)
		elseif newState == 3 then
			bkg:SetTextureID(attr.DownBkgID)
		elseif newState == 4 then
			bkg:SetTextureID(attr.DisableBkgID)
		end			
	end
end

function OnLButtonDown(self)
    local attr = self:GetAttribute()
	if attr.Status ~= 4 and attr.Status ~= 3 then
		self:SetCaptureMouse(true)
		attr.Capture = true
		SetStatus(self, 3)
	end
end

function OnLButtonUp(self, x, y, flags)
	local attr = self:GetAttribute()
	local status = attr.Status
	
	if attr.Capture then
		self:SetCaptureMouse(false)
		attr.Capture = false
	end
	if status ~= 4 then
		if status ~= 2 then
			SetStatus(self, 2)
		end
		local left, top, right, bottom = self:GetObjPos()
		if x >= 0 and x <= right - left and y >= 0 and y <= bottom - top then
			self:FireExtEvent("OnClick")
		end
	end
end

function OnRButtonDown(self)
    local attr = self:GetAttribute()
	if attr.EnableRightBtnClick == false then
		return
	end

	OnLButtonDown(self)
end

function OnRButtonUp(self, x, y, flags)
	local attr = self:GetAttribute()
	local status = attr.Status

	if attr.EnableRightBtnClick == false then
		return
	end
	
	OnLButtonUp(self,x,y,flags)
end

function OnMouseMove(self, x, y)
    local left, top, right, bottom = self:GetObjPos()
    local width, height = right - left, bottom - top
    
    local attr = self:GetAttribute()
    if attr.Status ~= 4 then
        if attr.HandHover then
            self:SetCursorID("IDC_HAND")
        end
		SetStatus(self, 2)
    end
end

function OnMouseLeave(self)
    local attr = self:GetAttribute()
    if attr.Status ~= 4 then
		if attr.HandHover then
            self:SetCursorID("IDC_ARROW")
        end
        SetStatus(self, 1)
    end
end

function OnBind(self)
    local attr = self:GetAttribute()
	if attr.ResType == "bitmap" then 
		local bkg = self:GetControlObject("bitmap.button.bkg")
		bkg:SetVisible(1)
		if attr.NormalBkgID then
			bkg:SetResID(attr.NormalBkgID)
		end
		bkg:SetDrawMode(attr.DrawMode)	
	else
		local bkg = self:GetControlObject("texture.button.bkg")
		bkg:SetVisible(1)
		if attr.NormalBkgID then
			bkg:SetTextureID(attr.NormalBkgID)
		end			
	end
end

function SetBitmap( self, nor, hover, down, disable )
	local attr = self:GetAttribute()
	attr.NormalBkgID = ""
	if nor ~= nil then
		attr.NormalBkgID = nor
	end
	attr.DownBkgID = ""
	if down ~= nil then
		attr.DownBkgID = down
	end
	attr.DisableBkgID = ""
	if disable ~= nil then
		attr.DisableBkgID = disable
	end
	attr.HoverBkgID = ""
	if hover ~= nil then
		attr.HoverBkgID = hover
	end
	SetStatus(self, attr.Status, true)
end

function GetBitmap(self)
    local attr = self:GetAttribute()
    return attr.NormalBkgID, attr.HoverBkgID, attr.DownBkgID, attr.DisableBkgID
end

function AddTip(self,nType,strText,maxTextWidth)
	if maxTextWidth == nil then
		maxTextWidth = 133
	end
	local tipId = RemoveTip(self)
	if strText == nil or strText == "" then
		return
	end

	local xarManager = XLGetObject("Xunlei.UIEngine.XARManager")
	local xarFactory = xarManager:GetXARFactory()
	local tipObj = xarFactory:CreateUIObject(tipId,"WHome.CommonTips")
	
	local tipAttr = tipObj:GetAttribute()
	if nType == 1 then
		tipAttr.BkgTexture = "texture.tip.bkg.left.up"
	elseif nType == 2 then
		tipAttr.BkgTexture = "texture.tip.bkg.right.up"
	elseif nType == 3 then
		tipAttr.BkgTexture = "texture.tip.bkg.left.down"
	else
		tipAttr.BkgTexture = "texture.tip.bkg.right.down"
	end
	tipAttr.TextMarginH = 5
	tipAttr.TextMarginV = 6
	tipAttr.TextHAlign ="center"
	tipAttr.TextVAlign ="center"
	tipAttr.TrackMouse = false
	tipAttr.Multiline = true
	tipAttr.MultilineTextLimitWidth = maxTextWidth
	tipObj:SetText(strText)
	tipObj:SetType(nType)
	tipObj:SetZorder(50000000)
	self:AddChild(tipObj)
	local tipLeft,tipTop,tipRight,tipBottom = tipObj:GetTipRect(self)
	tipObj:SetObjPos(tipLeft-5-5, tipTop-2, tipRight-3-2,tipBottom+2)
end

function RemoveTip(self)
	local id = self:GetID()
	id = id.."ImageButtonTip"
	local tempObj = self:GetControlObject(id)
	if tempObj then
		self:RemoveChild(tempObj)
	end
	return id
end

function SetButtonAlpha(self, alpha)
	local attr = self:GetAttribute()
	if attr.ResType == "bitmap" then
		local bkgObj = self:GetControlObject("bitmap.button.bkg")
		bkgObj:SetAlpha(alpha)
	end
end

function OnEnableChange(self, enable)
	local attr = self:GetAttribute()
	if attr.Status == 4 and not enable or
		attr.Status ~= 4 and enable then
		return
	end

	local status = 1
	if not enable then
		status = 4
	end

	SetStatus(self, status)
end

function OnVisibleChange(self, visible)
	-- self:SetVisible(visible)
	self:SetChildrenVisible(visible)	
end