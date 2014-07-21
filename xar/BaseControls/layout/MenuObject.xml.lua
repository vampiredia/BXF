--print = debug.bind(debug.print, "MenuObject:")
--function print() end
--printError = debug.bind(print, "****ERROR****")
--printEnterFunction = debug.bind(debug.printEnterFunction, print)
--printLeaveFunction = debug.bind(debug.printLeaveFunction, print)
--prettytostring = debug.prettytostring
-----------------------------------------------------------------------

function GetMaxWidth(self)
	local attr = self:GetAttribute()
	local pos_x = attr.ItemLeft
	local pos_y = attr.ItemRight
	local max_width = 0
	for i = 1, #attr.ItemList do
		local temp_width = attr.ItemList[i]:GetMinWidth()
		if temp_width ~= nil and max_width < temp_width then
			max_width = temp_width
		end
	end
	if max_width > attr.MaxItemWidth then
		max_width = attr.MaxItemWidth
	end
	
	if attr.ItemWidth ~= 0 then
		max_width = attr.ItemWidth
	end
	return max_width
end

function AdjustItemPos( self )
	local attr = self:GetAttribute()
	local pos_x = attr.ItemLeft
	local pos_y = attr.ItemTop
	local max_width = GetMaxWidth( self )
	for i = 1, #attr.ItemList do
		local left, top, right, bottom = attr.ItemList[i]:GetObjPos()
		attr.ItemList[i]:SetObjPos( pos_x, pos_y, pos_x + max_width, pos_y + bottom - top )
		pos_y = pos_y + bottom - top
	end
	local self_left, self_top, self_right, self_bottom = self:GetObjPos()
	self:SetObjPos( self_left, self_top, self_left + max_width + attr.ItemLeft + attr.ItemRight, self_top + pos_y + attr.ItemBottom )
end

function EndMenu(self)
	local menuTree = self:GetOwner()
	local menuHost = menuTree:GetBindHostWnd()
	menuHost:EndMenu(true)
end

function InsertItem( self, index, item )
	local attr = self:GetAttribute()
	if index < 1 or index > #attr.ItemList then
		return
	end
	
	local itemID = item:GetID()
	for existIndex, existItem in pairs(attr.ItemList) do
		local existItemID = existItem:GetID()
		if itemID == existItemID then
			return
		end
	end
	
	local last = item
	for i = index, #attr.ItemList + 1 do
		local temp = nil
		if i ~= #attr.ItemList + 1 then
			temp = attr.ItemList[i]
		end
		attr.ItemList[ i ] = last
		last = temp
	end
	self:AddChild( item )
	AdjustItemPos( self )
end

function AddItem( self, item )
	local attr = self:GetAttribute()
	
	local itemID = item:GetID()
	for existIndex, existItem in pairs(attr.ItemList) do
		local existItemID = existItem:GetID()
		if itemID == existItemID then
			return
		end
	end
	
	attr.ItemList[ #attr.ItemList + 1 ] = item
	self:AddChild( item )
	AdjustItemPos( self )
end

function GetItemCount( self )
	local attr = self:GetAttribute()
	return #attr.ItemList
end

function GetItem( self, index )
	local attr = self:GetAttribute()
	if index < 1 or index > #attr.ItemList then
		return
	end
	return attr.ItemList[index]
end

function RemoveItem( self, index )
	local attr = self:GetAttribute()
	if index < 1 or index > #attr.ItemList then
		return
	end
	self:RemoveChild( attr.ItemList[index] )
	for i = index, #attr.ItemList - 1 do
		attr.ItemList[ i ] = attr.ItemList[ i + 1 ]
	end
	attr.ItemList[#attr.ItemList] = nil
	AdjustItemPos( self )
end

function OnInitControl(self)
	local attr = self:GetAttribute()
	attr.ShadingID = nil
	attr.ItemList = {}
	local count = self:GetChildCount()
	for i = 0, count - 1 do
		local child = self:GetChildByIndex( i )
		local class = child:GetClass()
		if class == "MenuItemObject" then
			attr.ItemList[#attr.ItemList + 1] = child
		end
	end
	
	local bknRes = attr.BknID
	if bknRes ~= nil then
		local bkn = self:GetControlObject("menu.bkg")
		bkn:SetResID(bknRes)
	else
		local bkn = self:GetControlObject("menu.bkg")
		bkn:SetVisible( false )
	end
	
	--[[local shadingID = attr.ShadingID
	if shadingID ~= nil then
		local shading = self:GetControlObject("menu.shading")
		shading:SetResID(shadingID)
		shading:SetVisible( true )
	else
		local shading = self:GetControlObject("menu.shading")
		shading:SetVisible( false )
	end]]
	AdjustItemPos( self )
end

function OnDestroy(self)
	local attr = self:GetAttribute()
	
	local tm = XLGetObject("Xunlei.UIEngine.TimerManager")
	if attr.ShowSubMenuTimer ~= nil then
		tm:KillTimer( attr.ShowSubMenuTimer )
		attr.ShowSubMenuTimer = nil
	end
end

function SetHoverItem(self, item, show_sub )
	local owner = self:GetOwnerControl()
	if owner then
		local ownerAttr = owner:GetAttribute()
		if not ownerAttr.MenuAniFinish then
		--菜单动画未完成之前不让选择菜单
			return
		end
	end
		
	local itembkn = self:GetControlObject("ItemBkn")
	local attr = self:GetAttribute()
	if item == nil then
		if attr.HoverItem == nil or not attr.HoverItem:HasSubMenu() then
			itembkn:SetVisible( false )
			itembkn:SetChildrenVisible( false )
			if attr.HoverItem ~= nil then
				attr.HoverItem:ChangeState( 0 )
			end
			attr.HoverItem = nil
		elseif attr.HoverItem:HasSubMenu() and not attr.HoverItem:IsShowSubMenu() and attr.ShowSubMenuTimer == nil then
			itembkn:SetVisible( false )
			itembkn:SetChildrenVisible( false )
			attr.HoverItem:ChangeState( 0 )
			attr.HoverItem = nil
		end
		return
	end
	if item ~= nil and attr.HoverItem ~= nil and item:GetID() == attr.HoverItem:GetID() then
		return
	end
	
	local menuTree = self:GetOwner()
	
	local tm = XLGetObject("Xunlei.UIEngine.TimerManager")
	
	if attr.ShowSubMenuTimer ~= nil then
		tm:KillTimer( attr.ShowSubMenuTimer )
		attr.ShowSubMenuTimer = nil
	end
	
	local function OnShowSubMenuTimer( tm, id )		
		tm:KillTimer( attr.ShowSubMenuTimer )
		attr.ShowSubMenuTimer = nil
		if item ~= nil then
			item:ShowSubMenu()
		end
	end
	
	if show_sub == nil or show_sub then
		if item:HasSubMenu() then
			attr.ShowSubMenuTimer = tm:SetTimer( OnShowSubMenuTimer, 200 )
		end
	end
	if attr.HoverItem ~= nil and attr.HoverItem:HasSubMenu() then
		attr.HoverItem:EndSubMenu()
	end
	
	local oldItem = attr.HoverItem
	attr.HoverItem = item
	
	if oldItem == nil then
		local left,top,right,bottom = item:GetObjPos() 
		itembkn:SetObjPos(left,top,right,bottom)
		itembkn:SetVisible( true )
		itembkn:SetChildrenVisible( true )
		attr.HoverItem:ChangeState( 1 )
	else
		oldItem:ChangeState( 0 )
		local left, top, right, bottom = attr.HoverItem:GetObjPos()
		itembkn:SetObjPos(left,top,right,bottom)
		itembkn:SetVisible( true )
		itembkn:SetChildrenVisible( true )
		attr.HoverItem:ChangeState( 1 )
	end
	return oldItem
end

function SetBknID( self, id )
	local attr = self:GetAttribute()
	attr.BknID = id
	local bknRes = id
	if bknRes ~= nil then
		local bkn = self:GetControlObject("menu.bkg")
		bkn:SetResID(bknRes)
		bkn:SetVisible( true )
	else
		local bkn = self:GetControlObject("menu.bkg")
		bkn:SetVisible( false )
	end
end

function SetShadingID( self, id )
	--[[local attr = self:GetAttribute()
	attr.ShadingID = id
	local shadingID = id
	if shadingID ~= nil then
		local shading = self:GetControlObject("menu.shading")
		shading:SetResID(shadingID)
		shading:SetVisible( true )
	else
		local shading = self:GetControlObject("menu.shading")
		shading:SetVisible( false )
	end]]
end

function GetNextEnableItem( self, cur )
	local attr = self:GetAttribute()
	for i = cur, #attr.ItemList do
		if attr.ItemList[ i ]:GetEnable() then
			return attr.ItemList[ i ]
		end
	end
	for i = 1, cur - 1 do
		if attr.ItemList[ i ]:GetEnable() then
			return attr.ItemList[ i ]
		end
	end
end

function MoveToNextItem( self )
	local attr = self:GetAttribute()
	if attr.HoverItem == nil then
		if #attr.ItemList > 1 then
			self:SetHoverItem( GetNextEnableItem( self, 1 ), false )
		end
	else
		for i = 1, #attr.ItemList do
			local id_1 = attr.ItemList[i]:GetID()
			local id_2 = attr.HoverItem:GetID()
			if id_1 == id_2 then
				self:SetHoverItem( GetNextEnableItem( self, i + 1 ), false )
				break
			end
		end
	end	
end

function GetPrevEnableItem( self, cur )
	local attr = self:GetAttribute()
	for i = cur, 1, -1 do
		if attr.ItemList[ i ]:GetEnable() then
			return attr.ItemList[ i ]
		end
	end
	for i = #attr.ItemList, cur + 1, -1 do
		if attr.ItemList[ i ]:GetEnable() then
			return attr.ItemList[ i ]
		end
	end
end

function MoveToPrevItem( self )
	local attr = self:GetAttribute()
	if attr.HoverItem == nil then
		if #attr.ItemList > 1 then
			self:SetHoverItem( GetPrevEnableItem( self , #attr.ItemList ), false )
		end
	else
		for i = 1, #attr.ItemList do
			if attr.ItemList[i]:GetID() == attr.HoverItem:GetID() then
				self:SetHoverItem( GetPrevEnableItem( self , i - 1 ), false )
				break
			end
		end
	end	
end


function OnKeyDown( self, char )
	self:RouteToFather()
end

function GetHoverItem( self )
	local attr = self:GetAttribute()
	return attr.HoverItem
end

function GetKeyItem( self, key )
	local key_item_list = {}
	local attr = self:GetAttribute()
	for i = 1, #attr.ItemList do
		if attr.ItemList[i]:GetEnable() then
			local attr_item = attr.ItemList[i]:GetAttribute()
			if attr_item.HotKey == key then
				key_item_list[ #key_item_list + 1 ] = attr.ItemList[i]
			end
		end
	end
	return key_item_list
end