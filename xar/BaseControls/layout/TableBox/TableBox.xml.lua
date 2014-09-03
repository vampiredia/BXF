function TAI_OnMouseMove(self)
	
end

function TAI_OnMouseLeave(self)
	
end

function TAI_OnLButtonDown(self)

end

function TAI_OnLButtonUp(self)

end

function TAI_OnDragQuery(self, dataObject, keyState, x, y)
	return 1, true
end

local effect = 2

function TAI_OnDragEnter(self, dataObject, keyState, x, y)
	--XLMessageBox("enter")
	return effect, true
end

function TAI_OnDragOver(self)
	--XLMessageBox("over")
	return effect, true
end

function TAI_OnDrop(self, dataObject, keyState, x, y)
	--XLMessageBox("drap")
end

function TAI_OnInitControl(self)
	--XLMessageBox(self:GetClass())
	local attr = self:GetAttribute()
	attr.dragmouse = true
	self:SetDropEnable(true)
end

-----------------------------------------------------------
function ItemMoveEnable(ctrl, enable)
	local cattr = ctrl:GetAttribute()
	
	if enable == true then
		cattr.dragmouse = true
		ctrl:SetZorder(cattr.zorder+9999)
		local parent = ctrl:GetOwnerControl()
		parent:FireExtEvent("OnItemMoveBegin")
		ctrl:GetControlObject("bkg"):SetCursorID("IDC_SIZEALL")
	else
		cattr.dragmouse = false
		ctrl:SetZorder(cattr.zorder)
		local parent = ctrl:GetOwnerControl()
		parent:FireExtEvent("OnItemMoveEnd")
		ctrl:GetControlObject("bkg"):SetCursorID("IDC_ARROW")
	end
end

function TFI_OnInitControl(self)
	local attr = self:GetAttribute()
	attr.dragmouse = false
	self:SetDropEnable(true)
	
	attr.zorder = self:GetZorder()
end


function TFI_OnLButtonDown(self, x, y)
	local ctrl = self:GetOwnerControl()
	local attr = ctrl:GetAttribute()
	attr.src_x = x
	attr.src_y = y
	ItemMoveEnable(ctrl, true)
	
	local attr = ctrl:GetAttribute()
	local bkg = ctrl:GetControlObject("bkg")
	bkg:SetTextureID(attr.SelectItemBkgID)
end

function TFI_OnLButtonUp(self)
	local ctrl = self:GetOwnerControl()
	ItemMoveEnable(ctrl, false)
end

function TFI_OnMouseMove(self, x, y)
	local ctrl = self:GetOwnerControl()
	local cattr = ctrl:GetAttribute()
	
	--local offset_x = x - cattr.scr_x
	--local offset_y = y - cattr.src_y
	local l,t,r,b = ctrl:GetObjPos()
	if cattr.dragmouse then
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
	--XLMessageBox(x.."|"..y.."|"..l.."|"..t.."|"..r.."|"..b)
	
	local attr = ctrl:GetAttribute()
	local bkg = ctrl:GetControlObject("bkg")
	bkg:SetTextureID(attr.SelectItemBkgID)
end

function TFI_OnMouseLeave(self)
	local ctrl = self:GetOwnerControl()
	ItemMoveEnable(ctrl, false)
	
	local attr = ctrl:GetAttribute()
	local bkg = ctrl:GetControlObject("bkg")
	bkg:SetTextureID(attr.NormalItemBkgID)
end

function TFI_OnDrop(self)

end

function TFI_OnDragQuery(self)

end

function TFI_OnDragEnter(self)

end

function TFI_OnDragOver(self)

end

function TFI_SetText(self, text)
	local test = self:GetControlObject("test")
	if test == nil then return end
	test:SetText(text)
end

-------------------------------------------------------------------------------
function TB_OnInitControl(self)
	local attr = self:GetAttribute()
	attr.DataCenterFactory = {}
end

function TB_AddItem(self, obj)
	local attr = self:GetAttribute()
	local datacenter = self:GetAttribute().DataCenterFactory
	
	local item = self:GetControlObject("Item")
	item:AddChild(obj)
	table.insert(datacenter, {object=obj})
	self:UpdateUI()
end

function TB_DelItem(self)

end

function TB_DelAllItem(self)

end

function TB_UpdateUI(self)
	local attr = self:GetAttribute()
	local datacenter = self:GetAttribute().DataCenterFactory
	
	for i=1, #datacenter do
		local item = datacenter[i]
		item['left'] = attr.Margin + ((i-1)%attr.ColumnNum)*(attr.ItemWidth+attr.Margin*2)
		item['right'] = item['left'] + attr.ItemWidth
		item['top'] = attr.Margin + math.floor((i-1)/attr.ColumnNum)*(attr.ItemHeight+attr.Margin*2)
		item['bottom'] = item['top'] + attr.ItemHeight
		item['center_x'] = (item['left'] + item['right'] ) / 2
		item['center_y'] = (item['bottom'] + item['top'] ) / 2
		item['hittest_left'] = ( item['left'] + item['center_x'] ) /2
		item['hittest_right'] = ( item['right'] + item['center_x'] ) /2
		item['hittest_top'] = ( item['top'] + item['center_y'] ) /2
		item['hittest_bottom'] = ( item['bottom'] + item['center_y'] ) /2
		local isSelect = item['object']:GetAttribute().dragmouse
		if isSelect == false then
			local obj = item['object']
			obj:SetObjPos(item['left'], item['top'], item['right'], item['bottom'])		
		end
	end
end

function TB_MoveItem(self, obj, x, y)

end

function TB_OnItemMove(self, event, obj, x, y)
	local attr = self:GetAttribute()
	local datacenter = self:GetAttribute().DataCenterFactory
	
	local selectIndex = nil
	local nowIndex = nil
	for i=1, #datacenter do
		local item = datacenter[i]
		local l,t,r,b = item['hittest_left'], item['hittest_right'], item['hittest_top'], item['hittest_bottom']
		
		local oattr = item['object']:GetAttribute()
		if oattr.dragmouse then
			selectIndex = i
		end
		
		if x > item['hittest_left'] and x < item['hittest_right'] and y > item['hittest_top'] and y < item['hittest_bottom'] then
			nowIndex = i
		end
	end
	
	if selectIndex == nil or nowIndex == nil then return end
	if selectIndex == nowIndex then return end
	table.remove(datacenter, selectIndex)
	table.insert(datacenter, nowIndex, {object=obj})
	
	self:UpdateUI()
end

function TB_OnItemMoveEnd(self)
	self:UpdateUI()
end

function TB_OnVScroll(self)
	local owner = self:GetOwnerControl()
	local attr = owner:GetAttribute()
	if type == 4 then
		attr.m_top = math.ceil(-newpos / 22)
		owner:SetAdjust(true)
	end
end

function TB_OnScrollBarMouseWheel(self)
	self:GetOwnerControl():MouseWheel(distance)
end