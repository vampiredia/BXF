

function SetButtonActive(self, button, active)
	local attr = self:GetAttribute()

end

--	active:bool 是否激活
function AddTabItem(self, id, text, icon, icon_select, active, funcItemCallBack)
	local objExist = self:GetControlObject(id)
	if objExist ~= nil then
		return
	end
	local attr = self:GetAttribute()
	if attr.ItemClass == nil then attr.ItemClass = "Head.TabButton" end
	local xarManager = XLGetObject("Xunlei.UIEngine.XARManager")
	local objFactory = xarManager:GetXARFactory()

	local bkgObj = self:GetControlObject("bkg")
	local btn = objFactory:CreateUIObject(id, attr.ItemClass, "BaseControls")
	
	if attr.FuncItemCallBack ~= nil then 
		attr.FuncItemCallBack(btn)
	end
	
	local btnAttr = btn:GetAttribute()
	btnAttr.IconLeftPos = attr.IconLeftPos
	btnAttr.IconTopPos = attr.IconTopPos
	btnAttr.IconHAlign = attr.IconHAlign
	btnAttr.IconVAlign = attr.IconVAlign
	btnAttr.IconWidth = attr.IconWidth
	btnAttr.IconHeight = attr.IconHeight
	btnAttr.text_valign = attr.TextValign
	local btnStyle = btn:GetStyle()
	btnStyle.text_pos_left = attr.TextLeftPos
	btnStyle.text_pos_top = attr.TextTopPos
	btnStyle.text_normal_color = attr.TextColorID
	btnStyle.text_normal_font = attr.TextFontID
	btnStyle.text_hover_font = attr.TextFontID
	btnStyle.text_down_font = attr.TextFontID
	btnStyle.text_disable_font = attr.TextFontID
	btnStyle.bkg_normal_texture = attr.BtnBkgNormal
	btnStyle.bkg_hover_texture = attr.BtnBkgHover
	btnStyle.bkg_down_texture = attr.BtnBkgDown
	btnAttr.NormalIcon = icon
	btnAttr.SelectIcon = icon_select
	
	btn:SetText(text)
	btn:SetIcon(icon)
	btn:SetIconPos((attr.ButtonWidth-attr.IconWidth)/2, attr.ButtonHeight-attr.IconHeight)
	btn:UpdateUI()
	local pos = 0
	local btnCount = bkgObj:GetChildCount()
	if btnCount > 0 then
		local lastBtn = bkgObj:GetChildByIndex(btnCount - 1)
		local left, top, right, bottom = lastBtn:GetObjPos()
		if attr.TabDirection == "horizontal" then
			pos = right + attr.ButtonInternalSpace
		elseif attr.TabDirection == "vertical" then
			pos = bottom + attr.ButtonInternalSpace
		end
	end

	local function OnButtonClick(btn)
		local id = btn:GetID()
		if id == attr.CurrentActiveTab then
			return
		end
		self:SetActiveTab(id, true)
	end
	btn:AttachListener("OnClick", true, OnButtonClick)
	bkgObj:AddChild(btn)
	local bkgl, bkgt, bkgr, bkgb = bkgObj:GetObjPos()
	local bkgHeight = bkgb - bkgt
	if attr.TabDirection == "horizontal" then
		btn:SetObjPos(pos, 0, pos + attr.ButtonWidth, attr.ButtonHeight)
	elseif attr.TabDirection == "vertical" then
		btn:SetObjPos(0, pos, 0 + attr.ButtonWidth, pos + attr.ButtonHeight)
	end
	
	if active == true or
		(active == nil and attr.CurrentActiveTab == nil) then
		self:SetActiveTab(id, true)
	else
		SetButtonActive(self, btn, false)
	end
end

function RemoveTabItem(self, remove_id, active_id)
	local btn = self:GetControlObject(remove_id)
	if btn == nil then
		return
	end
	local bkgObj = self:GetControlObject("bkg")
	local attr = self:GetAttribute()
	local pos = 0
	local count = bkgObj:GetChildCount()
	for i = 0, count - 1 do
		local child = bkgObj:GetChildByIndex(i)
		local childID = child:GetID()
		if childID ~= remove_id then
			local childLeft, childTop, childRight, childBottom = child:GetObjPos()
			child:SetObjPos(pos, childTop, pos + attr.ButtonWidth, childBottom)
			pos = pos + attr.ButtonWidth + attr.ButtonInternalSpace
		end
	end
	bkgObj:RemoveChild(btn)
end

function SetBtnIcon(self, btn, state)
	local btnAttr = btn:GetAttribute()
	if state == 'normal' then 
		if btnAttr.NormalIcon ~= nil then btn:SetIcon(btnAttr.NormalIcon) end
	elseif state == 'down' then 
		if btnAttr.SelectIcon ~= nil then btn:SetIcon(btnAttr.SelectIcon) end
	end
end

function SetActiveTab(self, tabID, fireEvent)
	local attr = self:GetAttribute()
	if attr.CurrentActiveTab == tabID then
		return
	end

	local btn = self:GetControlObject(tabID)
	if btn == nil then
		return
	end

	SetButtonActive(self, btn, true)
	btn:ChangeStatus("down")
	SetBtnIcon(self, btn, 'down')
	
	local pre_active = attr.CurrentActiveTab
	if pre_active ~= nil then
		local btn = self:GetControlObject(pre_active)
		if btn == nil then
			return
		end
		SetButtonActive(self, btn, false)
		btn:ChangeStatus("normal")
		SetBtnIcon(self, btn, 'normal')
	end
	
	attr.CurrentActiveTab = tabID
	if fireEvent then
		self:FireExtEvent("OnActiveTabChanged", tabID, pre_active)
	end
end

function OnBind(self)

end