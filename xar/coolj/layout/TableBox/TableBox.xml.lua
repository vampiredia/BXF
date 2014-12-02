function TB_OnInitControl(self)
	local attr = self:GetAttribute()
	attr.DataCenterFactory = {}
	attr.CurTop = 0
	attr.MaxHeight = 0
end

function TB_AddItem(self, obj)
	local attr = self:GetAttribute()
	if self:GetID() == nil then return end
	
	local datacenter = self:GetAttribute().DataCenterFactory
	local item = self:GetControlObject("Item")
	item:AddChild(obj)
	table.insert(datacenter, {object=obj})
	self:UpdateUI()
	
	if self:IsVScrollVisible() then
		attr.CurTop = attr.CurTop + attr.ItemHeight + attr.Margin*2
		self:UpdateUI()
	end
end

function TB_DelItem(self, obj)
	local attr = self:GetAttribute()
	local datacenter = self:GetAttribute().DataCenterFactory
	
	local item = self:GetControlObject("Item")
	item:RemoveChild(obj)
	for i=1, #datacenter do
		local tmp = datacenter[i]['object']
		if tmp:GetID() == obj:GetID() then
			table.remove(datacenter, i)
			break
		end
	end
	
	--local attr.CurTop = attr.CurTop - attr.ItemHeight - attr.Margin*2
	self:UpdateUI()
	
	AddNotify(self, "删除成功！", 800)
end

function TB_DelAllItem(self)

end

function TB_UpdateUI(self)
	local attr = self:GetAttribute()
	local datacenter = self:GetAttribute().DataCenterFactory
	
	self:AdjustTop()
	for i=1, #datacenter do
		local item = datacenter[i]
		item['left'] = attr.Margin + ((i-1)%attr.ColumnNum)*(attr.ItemWidth+attr.Margin*2)
		item['right'] = item['left'] + attr.ItemWidth
		item['top'] = attr.Margin + math.floor((i-1)/attr.ColumnNum)*(attr.ItemHeight+attr.Margin*2) - attr.CurTop
		item['bottom'] = item['top'] + attr.ItemHeight
		item['center_x'] = (item['left'] + item['right'] ) / 2
		item['center_y'] = (item['bottom'] + item['top'] ) / 2
		item['hittest_left'] = ( item['left'] + item['center_x'] ) /2
		item['hittest_right'] = ( item['right'] + item['center_x'] ) /2
		item['hittest_top'] = ( item['top'] + item['center_y'] ) /2
		item['hittest_bottom'] = ( item['bottom'] + item['center_y'] ) /2
		local isSelect = item['object']:GetAttribute().DragMouse
		if isSelect == false then
			local obj = item['object']
			obj:SetObjPos(item['left'], item['top'], item['right'], item['bottom'])		
		end
	end
	
	local l = attr.Margin + ((#datacenter)%attr.ColumnNum)*(attr.ItemWidth+attr.Margin*2)
	local t = attr.Margin + math.floor((#datacenter)/attr.ColumnNum)*(attr.ItemHeight+attr.Margin*2)  - attr.CurTop
	local r = l + attr.ItemWidth
	local b = t + attr.ItemHeight
	local addObj = self:GetControlObject("add")
	if addObj ~= nil then 
		addObj:SetObjPos(l, t, r, b)
	end

	self:UpdateVScroll()
end

function TB_UpdateVScroll(self)
	local attr = self:GetAttribute()
	if not attr.VScrollShow then 
		self:GetControlObject("vscroll"):SetVisible(false, false)
		return 
	end
	
	local datacenter = attr.DataCenterFactory
	local rowcount = math.ceil((#datacenter+1)/attr.ColumnNum)
	local itemHeight = attr.ItemHeight + attr.Margin*2
	attr.MaxHeight = rowcount * itemHeight
	local l,t,r,b = self:GetObjPos()
	local height = b-t
	if attr.MaxHeight > height then 
		-- 滚动条操作
		local objVScroll = self:GetControlObject("vscroll")
		objVScroll:SetPageSize(height)
		objVScroll:SetScrollRange(0, attr.MaxHeight)
		objVScroll:SetVisible(true, true)
		--objVScroll:SetScrollPos(50)
	else
		self:GetControlObject("vscroll"):SetVisible(false, false)
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
		if oattr.DragMouse then
			selectIndex = i
		end
		
		if x > item['hittest_left'] and x < item['hittest_right'] and y > item['hittest_top'] and y < item['hittest_bottom'] then
			local moveenable = item['object']:GetAttribute().MoveEnable
			if moveenable == true then
				nowIndex = i
			end
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

function TB_OnVScroll(self, event, type, pos)
	local owner = self:GetOwnerControl()
	local attr = owner:GetAttribute()
	if type == 4 then
		--attr.m_top = math.ceil(-newpos / 22)
		--owner:SetAdjust(true)
	end
end

function TB_OnScrollBarMouseWheel(self)
	self:GetOwnerControl():MouseWheel(distance)
end

function TB_OnPosChange(self, oldl, oldt, oldr, oldb, newl, newt, newr, newb)
	local objVScroll = self:GetControlObject("vscroll")
	objVScroll:SetPageSize(newb-newt)
	
	local attr = self:GetAttribute()
	attr.PageSize = newb - newt
	self:UpdateUI()
end

function TB_OnControlMouseWheel(self, x, y, flags)
	self:MouseWheel(flags)
end

function TB_MouseWheel(self, distance)
	local attr = self:GetAttribute()
	local itemHeight = attr.ItemHeight + attr.Margin * 2
	if distance < 0 then 
		attr.CurTop = attr.CurTop + itemHeight
	else
		attr.CurTop = attr.CurTop - itemHeight
	end
	
	self:UpdateUI()
end

function TB_OnScrollPosChange(self, flags)
	local pos = self:GetScrollPos()
	local ctrl = self:GetOwnerControl()
	local attr = ctrl:GetAttribute()
	attr.CurTop = pos
	ctrl:UpdateUI()
end

function TB_VSCroll_OnInitControl(self)
	local ctrl = self:GetOwnerControl()
	local l,t,r,b = ctrl:GetObjPos()
	
	local attr = self:GetAttribute()
	local cattr = ctrl:GetAttribute()
	attr.WheelSpeed = cattr.Margin*2 + cattr.ItemHeight
	attr.PageSize = b-t
	attr.NavigationSpeed = cattr.Margin*2 + cattr.ItemHeight
end

function TB_AdjustTop(self)
	local attr = self:GetAttribute()
	if not attr.VScrollShow then 
		self:GetControlObject("vscroll"):SetVisible(false, false)
		return 
	end
	
	local datacenter = attr.DataCenterFactory	
	local rowcount = math.ceil((#datacenter+1)/attr.ColumnNum)
	local itemHeight = attr.ItemHeight + attr.Margin*2
	attr.MaxHeight = rowcount * itemHeight
	
	if attr.MaxHeight > attr.PageSize then
		local itemHeight = attr.ItemHeight + attr.Margin * 2
		if attr.CurTop < 0 then attr.CurTop = 0 end
		
		if attr.CurTop > 0 and attr.MaxHeight < attr.CurTop + attr.PageSize then
			local offset = attr.CurTop + attr.PageSize - attr.MaxHeight
			attr.CurTop = attr.CurTop - offset + attr.Margin		
		end
		
		local vscroll = self:GetControlObject("vscroll")
		vscroll:SetScrollPos(attr.CurTop)
	else
		attr.CurTop = 0
	end
end

function TB_IsVScrollVisible(self)
	local vscroll = self:GetControlObject("vscroll")
	return vscroll:GetVisible()
end

function TB_AddDefaultItem(self, obj)
	local attr = self:GetAttribute()
	if self:GetID() == nil then return end
	
	local datacenter = self:GetAttribute().DataCenterFactory
	local item = self:GetControlObject("Item")
	item:AddChild(obj)
	self:UpdateUI()
	
	if self:IsVScrollVisible() then
		attr.CurTop = attr.CurTop + attr.ItemHeight + attr.Margin*2
		self:UpdateUI()
	end	
end