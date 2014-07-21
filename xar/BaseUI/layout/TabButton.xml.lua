local function UpdateRes(self, state, ani)
	local style = self:GetStyle()
	local attr = self:GetAttribute()
	local bkgTexture, textFont, textColor
	--if state ~= attr.Status then
		if state == "hover" then
			bkgTexture = style.bkg_hover_texture
			textFont = style.text_hover_font
			textColor = style.text_hover_color
		elseif state == "down" then
		
			bkgTexture = style.bkg_down_texture
			textFont = style.text_down_font
			textColor = style.text_down_color
		elseif state == "disable" then
			bkgTexture = style.bkg_disable_texture
			textFont = style.text_disable_font
			textColor = style.text_disable_color
		else
			bkgTexture = style.bkg_normal_texture
			textFont = style.text_normal_font
			textColor = style.text_normal_color
		end
	
		local bkgObj = self:GetControlObject("ctrl")
		local textObj = self:GetControlObject("text")
		local oldObj = self:GetControlObject("button.oldbkg")
		old_texture_id = bkgObj:GetTextureID()
		if bkgTexture then
			bkgObj:SetTextureID(bkgTexture)
			if textFont and textFont ~= "" then
				textObj:SetTextFontResID(textFont)
			end
			if textColor and textColor ~= "" then
				textObj:SetTextColorResID(textColor)
			end
			if old_texture_id ~= "" and old_texture_id ~= bkgTexture and ani ~= true then
				oldObj:SetTextureID(old_texture_id)
				local animationHelper = XLGetGlobal("xunlei.LuaThunderAnimationHelper")
				if animationHelper then
					animationHelper:AppearDestObjDisappearSrcObj(bkgObj, false, oldObj, false, nil, nil, "")
				end
			end
		end
		attr.status = state
	--end
	
	local left,top,right,bottom = self:GetObjPos()

	local left,top,right,bottom = textObj:GetObjPos()
	textObj:SetObjPos(style.text_pos_left,style.text_pos_top,"father.width - "..style.text_pos_left, "father.height -".. style.text_pos_top)
	
end

function UpdateUI(self)
    local attr = self:GetAttribute()
    UpdateRes(self, attr.status, true)
end

function OnUpdateStyle(self)
	UpdateUI(self)
end

function OnInitControl(self)
	local attr = self:GetAttribute()
	local bkgObj = self:GetControlObject("ctrl")
	if not self:GetVisible() then
		bkgObj:SetVisible(false)
		bkgObj:SetChildrenVisible(false)
	end
	
	local newState = nil
	
	if not self:GetEnable() then
		bkgObj:SetEnable(false)
		bkgObj:SetChildrenEnable(false)
		
		newState = "disable"
	else
	    newState = "normal"
	end
	
	local textObj = self:GetControlObject("text")
	if attr.Text ~= nil and attr.Text ~= "" then
		textObj:SetText(attr.Text)
	end
	
	local iconObj = self:GetControlObject("icon")
	iconObj:SetObjPos2(attr.IconLeftPos, attr.IconTopPos, attr.IconSize, attr.IconSize)
	iconObj:SetHAlign(attr.IconHAlign)
	iconObj:SetVAlign(attr.IconVAlign)

	UpdateRes(self, newState)	
	if attr.IsDefaultButton then
	    local animationHelper = XLGetGlobal("xunlei.LuaThunderAnimationHelper")
		if animationHelper then
			animationHelper:FocusLight(bkgObj, "")
		end
	end
end

function ChangeStatus(self, newStatus)
	local attr = self:GetAttribute()	
	if attr.Status == newStatus then
		return
	end	
	attr.Status = newStatus	
	UpdateRes(self, newStatus)	
end

function SetText(self, text)
	local attr = self:GetAttribute()
	attr.Text = text
	
	local textObj = self:GetControlObject("text")
	textObj:SetText(text)
	self:SetTextPos(attr.text_pos_left, attr.text_pos_top)
end

function GetText(self)
	local textObj = self:GetControlObject("text")
	return textObj:GetText()	
end

function SetTextPos(self,x,y)
	local textObj = self:GetControlObject("text")
	local left,top,right,bottom = textObj:GetObjPos()
	textObj:SetObjPos(left+x,top+y,right+x,bottom+y)
	local style = self:GetStyle()
	style.text_pos_left,style.text_pos_top = left+x,top+y
end

function SetIcon(self, icon)
	local attr = self:GetAttribute()
	attr.Icon = icon
	
	local imageObj = self:GetControlObject("icon")
	imageObj:SetResID(icon)
end

function GetIcon(self, icon)
	local imageObj = self:GetControlObject("icon")
	return imageObj:GetResID()
end

function SetIconPos(self, x, y)
    local attr = self:GetAttribute()
    attr.IconLeftPos = x
    attr.IconTopPos = y
    local iconObj = self:GetControlObject("icon")
    iconObj:SetObjPos2(x, y, attr.IconSize, attr.IconSize)
end

function OnVisibleChange(self, visible)
	local bkgObj = self:GetControlObject("ctrl")
	if bkgObj then
		bkgObj:SetVisible(visible)
		bkgObj:SetChildrenVisible(visible)
	end
end

function OnEnableChange(self, enable)
	local bkgObj = self:GetControlObject("ctrl")
	bkgObj:SetEnable(enable)
	bkgObj:SetChildrenEnable(enable)
	
	if enable then
		self:ChangeStatus("normal")
	else
		self:ChangeStatus("disable")
	end
end

function OnLButtonDown(self)
	return 0, false
end

function OnLButtonUp(self, x, y)
	self:FireExtEvent("OnClick")
	
	return 0, false
end

function OnMouseMove(self, x, y)
	local attr = self:GetAttribute()
	if attr.Status ~= "down" then
		self:ChangeStatus("hover")
	end
	return 0, false
end

function OnMouseLeave(self)
	local attr = self:GetAttribute()	
	if attr.Status == "hover" then
		self:ChangeStatus("normal")	
	end
	return 0, false
end