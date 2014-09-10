-----------------------------------------------------------
function ItemMoveEnable(ctrl, enable)
	local cattr = ctrl:GetAttribute()
	
	if enable == true then
		cattr.DragMouse = true
		ctrl:SetZorder(cattr.zorder+9999)
		local parent = ctrl:GetOwnerControl()
		parent:FireExtEvent("OnItemMoveBegin")
		ctrl:GetControlObject("bkg"):SetCursorID("IDC_SIZEALL")
	else
		cattr.DragMouse = false
		ctrl:SetZorder(cattr.zorder)
		local parent = ctrl:GetOwnerControl()
		parent:FireExtEvent("OnItemMoveEnd")
		ctrl:GetControlObject("bkg"):SetCursorID("IDC_ARROW")
	end
end

function TFI_OnInitControl(self)
	local attr = self:GetAttribute()
	
	attr.zorder = self:GetZorder()
	attr.HitTest = true
	self:SetHitTest(false)
end

function TFI_OnLButtonDown(self, x, y)
	local ctrl = self:GetOwnerControl()
	local attr = ctrl:GetAttribute()
	attr.src_x = x
	attr.src_y = y
	ItemMoveEnable(ctrl, true)
end

function TFI_OnLButtonUp(self)
	local ctrl = self:GetOwnerControl()
	ItemMoveEnable(ctrl, false)
end

function TFI_OnMouseMove(self, x, y)
	local ctrl = self:GetOwnerControl()
	local cattr = ctrl:GetAttribute()
	
	local l,t,r,b = ctrl:GetObjPos()
	if cattr.DragMouse then
		local offset_x = x - cattr.src_x
		local offset_y = y - cattr.src_y
		ctrl:SetObjPos(l+offset_x, t+offset_y, r+offset_x, b+offset_y)
		
		local parent = ctrl:GetOwnerControl()
		
		local pl, pt, pr, pb = parent:GetObjPos()
		local pwidth = pr - pl 
		local pheight = pb - pt
		
		if l+offset_x < 0 then offset_x = -l end
		if t+offset_y < 0 then offset_y = -t end
		if r+offset_x > pwidth then offset_x = pwidth - r end
		if b+offset_y > pheight then offset_y = pheight - b end
		
		ctrl:SetObjPos(l+offset_x, t+offset_y, r+offset_x, b+offset_y)
		
		parent:FireExtEvent("OnItemMove", ctrl, (l+r)/2+offset_x, (b+t)/2+offset_y)
	end
end

function TFI_OnMouseLeave(self, x, y)
	local ctrl = self:GetOwnerControl()
	ItemMoveEnable(ctrl, false)
end

function TFI_SetText(self, text)
	local test = self:GetControlObject("test")
	if test == nil then return end
	test:SetText(text)
end

function TFI_SetHitTest(self, visible)
	local cattr = self:GetAttribute()
	if cattr.HitTest == visible then return end
	
	cattr.HitTest = visible
	if visible == true then
		self:GetControlObject("bkg"):SetTextureID(cattr.SelectItemBkgID)
		self:GetControlObject("copy"):SetVisible(true)
		self:GetControlObject("copy"):SetChildrenVisible(true)
		self:GetControlObject("close"):SetVisible(true)
		self:GetControlObject("close"):SetChildrenVisible(true)
	else
		self:GetControlObject("bkg"):SetTextureID(cattr.NormalItemBkgID)
		self:GetControlObject("copy"):SetVisible(false)
		self:GetControlObject("copy"):SetChildrenVisible(false)
		self:GetControlObject("close"):SetVisible(false)
		self:GetControlObject("close"):SetChildrenVisible(false)
	end
end

function TFI_OnControlMouseEnter(self, x, y, flags)
	self:SetHitTest(true)
end

function TFI_OnControlMouseLeave(self)
	self:SetHitTest(false)
end

function TFI_Btn_OnCopy(self)
	local ctrl = self:GetOwnerControl()
	local answer = ctrl:GetControlObject("answer")
	if answer ~= nil then answer:Copy() end
	AddNotify(self, "复制成功！", 1200)
end

function TFI_Btn_OnClose(self)
	local ret = MessageBox(nil, "FAQ中心", "删除后无法恢复，确认要删除吗？")
	if ret == 1 then
		local ctrl = self:GetOwnerControl()
		local owner = ctrl:GetOwnerControl()
		owner:DelItem(ctrl)
	end
end

function TFI_SetCaptionText(self, text)
	local caption = self:GetControlObject("question")
	caption:SetText(text)
end

function TFI_GetCaptionText(self)
	return self:GetControlObject("question"):GetText()
end

function TFI_SetAnswerText(self, text)
	self:GetControlObject("answer"):SetText(text)
end

function TFI_GetAnswerText(self)
	return self:GetControlObject("answer"):GetText()
end