local function RemoveDefaultAnimation(self)
    local attr = self:GetAttribute()
    if attr.defaultani then
        attr.defaultani:Stop()
    end
    local mask = self:GetControlObject("masktexture")
    if mask then
        self:RemoveChild(mask)
    end
end

local function SetDefaultAnimation(self)
    local attr = self:GetAttribute()
    local bkg = self:GetControlObject("button.bkg")
    if attr.IsDefaultButton then
        bkg:SetTextureID(attr.DefaultBkgNormal)
        local objectTree = self:GetOwner()
        if objectTree then
            local aniFactory = XLGetObject("Xunlei.UIEngine.AnimationFactory")
	        local ani = aniFactory:CreateAnimation("WHome.Animation.Button.DefaultChange")
	        ani:BindObj(self)
	        ani:SetTotalTime(9999999999)
	        objectTree:AddAnimation(ani)
	        attr.defaultani = ani
	        ani:Resume()
        end
    else
        if attr.defaultani then
            RemoveDefaultAnimation(self)
        end
	end
end

function RemoveTip(self)
	local attr = self:GetAttribute()
	local tipObj = attr.TipObj
	if tipObj ~= nil then
		self:RemoveChild(tipObj)
		attr.TipObj = nil
	end
end

function AddTip(self, x, y)
	local attr = self:GetAttribute()
	if attr.TipText == nil or attr.TipText == "" then
		return
	end

	local tipObj = attr.TipObj
	if tipObj ~= nil then
		return
	end

	local xarManager = XLGetObject("Xunlei.UIEngine.XARManager")
	local xarFactory = xarManager:GetXARFactory()
	
        local tipObj = xarFactory:CreateUIObject("tip","WHome.Windowless.Tip")
	
	local tipAttr = tipObj:GetAttribute()
	tipAttr.BkgTexture = "texture.mainwnd.tip.bkg"
	tipAttr.TextBeginH = 0
	tipAttr.TextBeginV = 2

	tipObj:SetText(attr.TipText)
	tipObj:SetZorder(10000)
	self:AddChild(tipObj)
	attr.TipObj = tipObj

	local width, height = tipObj:GetSize(40, 25)
	local tree = self:GetOwner()
	local hwnd = tree:GetBindHostWnd()
	local wnd_left, wnd_top, wnd_right, wnd_bottom = hwnd:GetWindowRect()
	local abs_left, abs_top, abs_right, abs_bottom = self:GetAbsPos()
	
	local left, top = x, y + 20
	local right, bottom = left + width, top + 22
	if abs_left + right > wnd_right - wnd_left then
		left = left - ( abs_left + right - ( wnd_right - wnd_left ) ) - 2
		right = left + width
	end
	if abs_top + bottom > wnd_bottom - wnd_top then
		top = top - ( abs_top + bottom - (wnd_bottom - wnd_top) ) - 2
		bottom = top + 25
	end
	tipObj:SetObjPos(left, top, right, bottom)
end

function GetTextExtent(self)
    local text = self:GetControlObject("button.text")
    return text:GetTextExtent()
end

function GetText(self)
    local text = self:GetControlObject("button.text")
    return text:GetText()
end

local function UpdateBkg(self, attr, noAni )	
	local bkg = self:GetControlObject("button.bkg")
	local oldbkg = self:GetControlObject("button.oldbkg")
	local ownerTree = self:GetOwner()
	local obj = self:GetControlObject("button.icon")

	local status = attr.Status
	local texture_id = ""
	if status == 1 then
	    if attr.IsDefaultButton then
		    texture_id = attr.DefaultBkgNormal
		else
		    texture_id = attr.BkgTextureID_Normal
		end
		if attr.IconBitmapID ~= nil then
			obj:SetResID( attr.IconBitmapID )
		end
	elseif status == 2 then
		texture_id = attr.BkgTextureID_Hover
		if attr.IconBitmapID_Hover ~= nil then
			obj:SetResID( attr.IconBitmapID_Hover )
		end
	elseif status == 3 then
		texture_id = attr.BkgTextureID_Down
		if attr.IconBitmapID_Down ~= nil then
			obj:SetResID( attr.IconBitmapID_Down )
		end
	elseif status == 4 then
		texture_id = attr.BkgTextureID_Disable
		if attr.IconBitmapID_Disable ~= nil then
			obj:SetResID( attr.IconBitmapID_Disable )
		end
	elseif status == 5 then
		texture_id = attr.BkgTextureID_Select
		if attr.IconBitmapID_Select ~= nil then
			obj:SetResID(attr.IconBitmapID_Select)
		end
	end
	local old_texture_id = bkg:GetTextureID()
	bkg:SetTextureID(texture_id)
	if noAni == nil or not noAni then
		oldbkg:SetTextureID(old_texture_id)
		oldbkg:SetAlpha(255)
		local aniFactory = XLGetObject("Xunlei.UIEngine.AnimationFactory")	
		local aniAlpha = aniFactory:CreateAnimation("AlphaChangeAnimation")
		aniAlpha:BindRenderObj(oldbkg)
		aniAlpha:SetTotalTime(200)
		aniAlpha:SetKeyFrameAlpha(255,0)
		ownerTree:AddAnimation(aniAlpha)
		aniAlpha:Resume()
	end

end


local function UpdateText(self, attr)
	local textObj = self:GetControlObject("button.text")
	if attr.SpliceTextInfoID then
		--自动拼接ID
		local suf = {".normal", ".hover", ".down", ".disable", ".select"}


		local status = attr.Status
		local font_id = attr.TextFontID
		if font_id ~= "" then
			font_id = font_id .. suf[status]
			textObj:SetTextFontResID(font_id)
		end
		
		if attr.Status == 4 then
			textObj:SetTextColorResID(attr.DisableTextColor)
		else
			local color_id = attr.TextColorID
			if color_id ~= "" then
				color_id = color_id
				textObj:SetTextColorResID(color_id)
			end
		end
	else
		--不拼接ID
		if attr.TextSelectFontID and attr.Status == 5 then
			textObj:SetTextFontResID(attr.TextSelectFontID)
		else
			textObj:SetTextFontResID(attr.TextFontID)
		end
		if attr.Status == 4 then
			textObj:SetTextColorResID(attr.DisableTextColor)
		else
			textObj:SetTextColorResID(attr.TextColorID)
		end
	end
	
	if attr.Status == 5 then
		if attr.TextSelectTopPos then
			local l,t,r,b = textObj:GetObjPos()
			textObj:SetObjPos2(l, attr.TextSelectTopPos, r-l, b-t)
		end
	else
		if attr.TextTopPos then
			local l,t,r,b = textObj:GetObjPos()
			textObj:SetObjPos2(l, attr.TextTopPos, r-l, b-t)
		end
	end
end

function SetTextFontID(self, id)
	local attr = self:GetAttribute()
	attr.TextFontID = id
	UpdateText(self, attr)
end


function SetTextColorID(self, id)
	local attr = self:GetAttribute()
	attr.TextColorID = id
	UpdateText(self, attr)
end

function GetStatus(self)
	local attr = self:GetAttribute()
	return attr.Status
end

function SetStatus(self, status)
	local attr = self:GetAttribute()
	if attr.Status == status then
		return
	end
	attr.Status = status
	UpdateBkg(self, attr, attr.NoChangeAni)
	UpdateText(self, attr)
end

function SetSelect(self, select_)
	local attr = self:GetAttribute()
	if attr.Status ~= 4 then
		if select_ then
			SetStatus(self, 5)
		else
			SetStatus(self, 1)
		end
		attr.isSelect = select_
	end
end

function GetSelect(self)
	local attr = self:GetAttribute()
	return attr.isSelect
end


local function InitPosition(self)
	local attr = self:GetAttribute()
	local left, top, right, bottom = self:GetObjPos()
	local self_width = right - left
	local self_height = bottom - top

	local obj = self:GetControlObject("button.icon")
	left = attr.IconLeftPos
	right = left.."+"..attr.IconWidth
	top = attr.IconTopPos
	bottom = top.."+"..attr.IconHeight
	obj:SetObjPos(left, top, right, bottom)

	obj = self:GetControlObject("button.text")
	left = attr.TextLeftPos
	right = self_width
	top = attr.TextTopPos
	bottom = self_height
	obj:SetObjPos(left, top, right, bottom)
end


function SetObjPos(obj, left, top, right, bottom)
	local pre_left, pre_top, pre_right, pre_bottom = obj:GetObjPos()
	if left == nil then
		left = pre_left
	end
	if top == nil then
		top = pre_top
	end
	if right == nil then
		right = pre_right
	end
	if bottom == nil then
		bottom = pre_bottom
	end
	obj:SetObjPos(left, top, right, bottom)
end

function SetIconPos(self, left, top, right, bottom)
	local obj = self:GetControlObject("button.icon")
	SetObjPos(obj, left, top, right, bottom)
end

function SetTextPos(self, left, top, right, bottom)
	local obj = self:GetControlObject("button.text")
	SetObjPos(obj, left, top, right, bottom)
end

function SetValign(self, align)
	local attr = self:GetAttribute()
	local obj = self:GetControlObject("button.text")
	attr.VAlign = align
	obj:SetVAlign(align)
end

function SetHalign(self, align)
	local attr = self:GetAttribute()
	local obj = self:GetControlObject("button.text")
	attr.HAlign = align
	obj:SetHAlign(align)
end

function SetText(self, text)
	local attr = self:GetAttribute()
	if attr.Text == text then
		return 0
	end

	attr.Text = text
	local obj = self:GetControlObject("button.text")
	local oldWidth, oldHeight = obj:GetTextExtent()
	obj:SetText(text)
	local newWidth, newHeight = obj:GetTextExtent()
	return newWidth - oldWidth
end

function SetBkgTexture(self, texture_id)
	local attr = self:GetAttribute()
	attr.BkgTextureID_Normal = texture_id .. ".normal"
	attr.BkgTextureID_Hover = texture_id .. ".hover"
	attr.BkgTextureID_Down = texture_id .. ".down"
	attr.BkgTextureID_Disable = texture_id .. ".disable"

	UpdateBkg(self, attr, true)
end

function SetNormalBkgTexture(self, texture_id)
	local attr = self:GetAttribute()
	attr.BkgTextureID_Normal = texture_id

	UpdateBkg(self, attr, true)
end

function SetSelectBkgTexture(self, texture_id)
	local attr = self:GetAttribute()
	attr.BkgTextureID_Select = texture_id
	
	UpdateBkg(self, attr, true)
end

function SetHoverBkgTexture(self, texture_id)
	local attr = self:GetAttribute()
	attr.BkgTextureID_Hover = texture_id

	UpdateBkg(self, attr, true)
end

function SetDownBkgTexture(self, texture_id)
	local attr = self:GetAttribute()
	attr.BkgTextureID_Down = texture_id

	UpdateBkg(self, attr, true)
end

function SetDisableBkgTexture(self, texture_id)
	local attr = self:GetAttribute()
	attr.BkgTextureID_Disable = texture_id

	UpdateBkg(self, attr, true)
end


function SetIconImage(self, image_id, hover, down, disable, select_)
	local attr = self:GetAttribute()
	attr.IconBitmapID = image_id
	attr.IconBitmapID_Hover = hover
	if hover == nil then
		attr.IconBitmapID_Hover = image_id
	end
	attr.IconBitmapID_Down = down
	if down == nil then
		attr.IconBitmapID_Down = image_id
	end
	attr.IconBitmapID_Disable = disable
	if disable == nil then
		attr.IconBitmapID_Disable = image_id
	end
	attr.IconBitmapID_Select = select_
	if select_ == nil then
		attr.IconBitmapID_Select = image_id
	end
	local obj = self:GetControlObject("button.icon")
	obj:SetResID(image_id)
end


function OnBind(self)
	local attr = self:GetAttribute()
	if attr.IconBitmapID_Hover == nil or attr.IconBitmapID_Hover == "" then
		attr.IconBitmapID_Hover = attr.IconBitmapID
	end
	if attr.IconBitmapID_Down == nil or attr.IconBitmapID_Down == "" then
		attr.IconBitmapID_Down = attr.IconBitmapID
	end
	if attr.IconBitmapID_Disable == nil or attr.IconBitmapID_Disable == "" then
		attr.IconBitmapID_Disable = attr.IconBitmapID
	end
	UpdateBkg(self, attr)
	UpdateText(self, attr)
	
	InitPosition(self)
	
	local icon = self:GetControlObject("button.icon")
	if attr.IconBitmapID ~= nil then
		icon:SetResID(attr.IconBitmapID)
	else
		icon:SetResID("")
	end
	
	local textObj = self:GetControlObject("button.text")
	textObj:SetText(attr.Text)
	textObj:SetVAlign(attr.VAlign)
	textObj:SetHAlign(attr.HAlign)
end


function OnPosChange(self, focus)
	InitPosition(self)
	if not focus then
		RemoveTip(self)
	end
	return true
end



function OnLButtonDown(self)
	RemoveTip( self )
	local attr = self:GetAttribute()
	local status = attr.Status
		
	if status ~= 4 and status ~= 3 and status ~= 5 then
		self:SetCaptureMouse(true)
		attr.Capture = true
		SetStatus(self, 3)
	end
	return 0, false
end

function OnLButtonUp(self, x, y, flags)
	local attr = self:GetAttribute()
	local status = attr.Status
	
	if attr.Capture then
		self:SetCaptureMouse(false)
		attr.Capture = false
		if status ~= 4 and status ~= 5 then
			local left, top, right, bottom = self:GetObjPos()
			if x >= 0 and x <= right - left and y >= 0 and y <= bottom - top then
				if attr.Status ~= 2 then
					SetStatus(self, 2)
				end
				self:FireExtEvent("OnButtonClick")
			else
				if attr.Status ~= 1 then
					SetStatus( self, 1 )
				end
			end
		end
	end
end



function OnMouseMove(self, x, y )
	local attr = self:GetAttribute()
	local status = attr.Status
	if status ~= 4 and status ~= 5 then
		local left, top, right, bottom = self:GetObjPos()
		if x >= 0 and x <= right - left and y >= 0 and y <= bottom - top then
			if attr.Capture then
				SetStatus(self, 3)
			else
				SetStatus(self, 2)
			end
		else
			SetStatus(self, 1)
		end
	end
	return 0
end

function OnMouseLeave( self )
	local attr = self:GetAttribute()
	if attr.Status ~= 4 and attr.Status ~= 5 then
		SetStatus( self, 1 )
	end
	RemoveTip(self)
	return 0
end

function OnMouseHover( self, x, y )
	AddTip(self, x, y)
	return 0
end

function OnInitControl( self )
	local attr = self:GetAttribute()
	if attr.EffectColorResID ~= nil then
		
		local textObj = self:GetControlObject("button.text")
		textObj:SetEffectType("bright")
		textObj:SetEffectColorResID( attr.EffectColorResID )
		if attr.BkgTextureID_Normal == "siamese.button.left.normal" or attr.BkgTextureID_Normal == "siamese.button.right.normal" then
		    local left, top, right, bottom = textObj:GetObjPos()
		    textobj:SetObjPos(left, top, right, bottom-4)
		end
	end
	
	SetDefaultAnimation(self)
	return true
end

function AddTipText(self,newText)
	local attr = self:GetAttribute()
	if attr then
		attr.TipText = newText
	end
end

function SetDefaultButton(self, isdefault)
    local attr = self:GetAttribute()
    if isdefault == attr.IsDefaultButton then
        return
    end
    attr.IsDefaultButton = isdefault
    SetDefaultAnimation(self)
    UpdateBkg(self, attr, true)
end

function OnEnableChange(self, enable)
	local attr = self:GetAttribute()
	if not attr then
		return
	end
	
 	if enable then
        if attr.lastEnableStatus ~= nil then
            attr.Status = attr.lastEnableStatus
        else
            attr.Status = 1		-- enable
        end
	else
        attr.lastEnableStatus = attr.Status
        if attr.Status ~= 5 then
            attr.Status = 4		-- disable
        end
	end
	
	UpdateBkg(self, attr, true)
	UpdateText(self, attr )
end

function OnVisibleChange(self, visible)
    -- self:SetVisible(visible)
    self:SetChildrenVisible(visible)
end

function SetTextLeftPos(self, textLeftPos)
	local attr = self:GetAttribute()
	attr.TextLeftPos = textLeftPos
end

function GetTextLeftPos(self)
	local attr = self:GetAttribute()
	return attr.TextLeftPos
end

function SetTextTopPos(self, textTopPos)
	local attr = self:GetAttribute()
	attr.TextTopPos = textTopPos
end

function GetTextTopPos(self)
	local attr = self:GetAttribute()
	return attr.TextTopPos
end

function SetIconLeftPos(self, iconLeftPos)
	local attr = self:GetAttribute()
	attr.IconLeftPos = iconLeftPos
end

function GetIconLeftPos(self)
	local attr = self:GetAttribute()
	return attr.IconLeftPos
end

function SetIconTopPos(self, iconTopPos)
	local attr = self:GetAttribute()
	attr.IconTopPos = iconTopPos
end

function GetIconTopPos(self)
	local attr = self:GetAttribute()
	return attr.IconTopPos
end

function SetIconWH(self, iconWidth, iconHeight)
	local attr = self:GetAttribute()
	attr.IconWidth = iconWidth
	attr.IconHeight = iconHeight
end

function GetIconWH(self)
	local attr = self:GetAttribute()
	return attr.IconWidth, attr.IconHeight
end