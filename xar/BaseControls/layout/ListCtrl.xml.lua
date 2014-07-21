--	列记录的map定义    header, item, list共同使用
--	{ID:string, Width:int, TextPos:int, Custom:bool, Title:string}
--
--

local function ChildToParent(child, x, y)
	local left, top = child:GetObjPos()
	return x + left, y + top
end


--====================================================================
--					header item
--		header item 属性		ColumnInfo
--		
function HeaderItem_SetText(self, text)
	local textObj = self:GetControlObject("text")
	textObj:SetText(text)
end

function HeaderItem_SetBkgTexture(self, id)
	local attr = self:GetAttribute()
	attr.BkgTexture = id
	local bkgObj = self:GetControlObject("bkg")
	bkgObj:SetTextureID(id)
end

local function SetSortIconPos(item)
	local textObj = item:GetControlObject("text")
	local iconObj = item:GetControlObject("sorticon")
	local iconLeft, iconTop, iconRight, iconBottom = iconObj:GetObjPos()
	local textLeft, textTop, textRight, textBottom = textObj:GetObjPos()
	local textWidth, textHeight = textObj:GetTextExtent()
	iconObj:SetObjPos(textLeft + textWidth + 4, iconTop, textLeft + textWidth + 4 + iconRight - iconLeft, iconBottom)
end

function HeaderItem_OnInitControl(self)
	local attr = self:GetAttribute()
	
	local bkgObj = self:GetControlObject("bkg")
	bkgObj:SetTextureID(attr.BkgTexture)
	attr.SortState = 0
end


function HeaderItem_OnMouseMove(self, x, y)
	local attr = self:GetAttribute()
	local header = self:GetFather()

	if x > (attr.ColumnInfo.Width - 10) then
		self:SetCursorID("IDC_SIZEWE")
	elseif 10 > x then
		if attr.ColumnIndex > 1 then
			self:SetCursorID("IDC_SIZEWE")
		end
	else
		self:SetCursorID("IDC_ARROW")
	end

	local sizingObj
	if attr.IsSizing then
		sizingObj = self
	elseif attr.ColumnIndex > 1 then
		local prevColumn = header:GetChildByIndex(attr.ColumnIndex - 2)
		if prevColumn:GetAttribute().IsSizing then
			sizingObj = prevColumn
			x = prevColumn:GetAttribute().ColumnInfo.Width + x
		end
	end

	if sizingObj then
		local columnAttr = sizingObj:GetAttribute()
		if x < columnAttr.ColumnInfo.MinWidth then
			x = columnAttr.ColumnInfo.MinWidth
		end
		columnAttr.ColumnInfo.Width = x
		local left, top, right, btttom = sizingObj:GetObjPos()
		right = left + x
		sizingObj:SetObjPos(left, top, right, btttom)
		sizingObj:FireExtEvent("OnHeaderItemWidthChanged", columnAttr.ColumnIndex)
		--listctrl:UpdateColumnWidth()
	end
end



function HeaderItem_OnLButtonDown(self, x, y)
	local attr = self:GetAttribute()
	if self:GetCursorID() == "IDC_SIZEWE" then
		if x > (attr.ColumnInfo.Width - 10) then
			attr.IsSizing = true
		elseif attr.ColumnIndex > 1 then
			local header = self:GetFather()
			local prevColumn = header:GetChildByIndex(attr.ColumnIndex - 2)
			prevColumn:GetAttribute().IsSizing = true
		end
		self:SetCaptureMouse(true)
	end
	
	if attr.ColumnInfo.CanSort then
		local iconObj = self:GetControlObject("sorticon")
		if attr.SortState == 0 or attr.SortState == 1 then
			self:SetSort(2)
			SetSortIconPos(self)
		elseif attr.SortState == 2 then
			self:SetSort(1)
			SetSortIconPos(self)
		end
	end
end

function UpdateListCtrl(header, columnid, sortfunc, sortstate)
	local listCtrl = header:GetOwnerControl()
	local headerAttr = header:GetAttribute()
	local dataList = listCtrl:GetAllItem()
	listCtrl:ClearItems()
	local headerItems = headerAttr.HeaderItems
	local headerItemIds = {}
	for i = 1, #headerItems do
		headerItemIds[i] = headerItems[i]:GetAttribute().ColumnInfo.ID
	end
	local itemIndex, itemIndexReverse = {}, {}
	for i = 1, #dataList do
		itemIndex[dataList[i][columnid]] = i
		itemIndexReverse[i] = dataList[i][columnid]
	end
	
	table.sort(itemIndexReverse, sortfunc)
	if sortstate == 2 then
		for i = 1, #dataList do
			listCtrl:InsertItem(dataList[itemIndex[itemIndexReverse[i]]], true)
		end
	elseif sortstate == 1 then
		for i = #dataList, 1, -1 do
			listCtrl:InsertItem(dataList[itemIndex[itemIndexReverse[i]]], true)
		end
	end
end

function HeaderItem_OnLButtonUp(self, x, y)
	self:SetCaptureMouse(false)
	local attr = self:GetAttribute()
	attr.IsSizing = false
	if attr.ColumnIndex > 1 then
		local header = self:GetFather()
		local prevColumn = header:GetChildByIndex(attr.ColumnIndex - 2)
		prevColumn:GetAttribute().IsSizing = false
	end
	
	local owner = self:GetOwnerControl()
	if attr.ColumnInfo.CanSort then
		local index = owner:FindItem(self)
		if index ~= nil then
			owner:SelectItem(index)
		end
		
		UpdateListCtrl(owner, attr.ColumnInfo.ID, attr.ColumnInfo.SortFunc, attr.SortState)
	end
end

function HeaderItem_SetSort(self, sortstate)
	local attr = self:GetAttribute()
	local iconObj = self:GetControlObject("sorticon")
	if attr.ColumnInfo.CanSort and iconObj then
		if sortstate == 0 then
			iconObj:SetVisible(false)
		elseif sortstate == 1 then
			iconObj:SetVisible(true)
			iconObj:SetResID("ListCtrl.Header.SortBmp.down")
		elseif sortstate == 2 then
			iconObj:SetVisible(true)
			iconObj:SetResID("ListCtrl.Header.SortBmp.up")
		end
	end
	attr.SortState = sortstate
end

--====================================================================
--					header
function Header_GetColumnWidthByIndex(self, index)
	local bkgObj = self:GetControlObject("bkg")
	local headerItem = bkgObj:GetChildByIndex(index - 1)
	if headerItem == nil then
		return 0
	end

	local itemAttr = headerItem:GetAttribute()
	return itemAttr.Width
end

function Header_SetColumnWidth( self, columnID, width )
	local item = self:GetControlObject( columnID )
	if item ~= nil then
		local left, top, right, bottom = item:GetObjPos()
		if right - left ~= width then
			item:SetObjPos( left, top, left + width, bottom )
			local attr = item:GetAttribute()
			if width < attr.ColumnInfo.MinWidth then
				width = attr.ColumnInfo.MinWidth
			end
			attr.ColumnInfo.Width = width
			item:FireExtEvent("OnHeaderItemWidthChanged", item:GetAttribute().ColumnIndex)
		end
	end
end

function Header_SetBkgTexture(self, textureid)
	local bkg = self:GetControlObject("bkg")
	bkg:SetResID(textureid)
end

function Header_InsertColumn(self, columnInfo, textColor)
	local bkgObj = self:GetControlObject("bkg")

	local headerLeft, headerTop, headerRight, headerBottom = self:GetObjPos()
	local headerWidth = headerRight - headerLeft
	local headerHeight = headerBottom - headerTop

	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")

	local currentCount = bkgObj:GetChildCount()

	local newItem = objFactory:CreateUIObject(columnInfo.ID, "WHome.ListCtrl.HeaderItem")
	local newItemAttr = newItem:GetAttribute()
	newItem:GetControlObject("text"):SetHAlign(newItemAttr.TextHalign)
	bkgObj:AddChild(newItem)
	if textColor ~= nil then
		newItem:GetControlObject("text"):SetTextColorResID(textColor)
	end

	local attr = self:GetAttribute()
	if attr.HeaderItems == nil then
		attr.HeaderItems = {}
	end
	table.insert(attr.HeaderItems, newItem)
	local itemAttr = newItem:GetAttribute()
	itemAttr.ColumnInfo = columnInfo
	itemAttr.ColumnIndex = currentCount + 1

	local columnLeft = 0
	if currentCount > 0 then
		--调整最后一个列头的位置
		local lastItem = bkgObj:GetChildByIndex(currentCount - 1)
		local left, top, right, bottom = lastItem:GetObjPos()
	
		columnLeft = right
	end

	local columnRight = columnLeft + columnInfo.Width
	newItem:SetObjPos(columnLeft, 0, columnRight, headerHeight)
	newItem:SetText(columnInfo.Title)
	if columnInfo.Bkgtexture ~= nil then
		newItem:SetBkgTexture(columnInfo.Bkgtexture)
	end

	function OnHeaderItemWidthChanged(headerItem, eventName, index)
		--拖动表头通知
		index = index - 1 --index 从1开始的, 先减1, 方便处理
		local item = bkgObj:GetChildByIndex(index)
		local itemCount = bkgObj:GetChildCount()
		local left, top, right, bottom = item:GetObjPos()
		local beginPos = 0
		if index == itemCount - 1 then
			beginPos = left
		else
			beginPos = right
		end
		for i = index + 1, itemCount - 2 do
			local item = bkgObj:GetChildByIndex(i)
			left, top, right, bottom = item:GetObjPos()
			local width = right -left
			left = beginPos
			right = left + width
			item:SetObjPos(left, top, right, bottom)
			beginPos = right
		end
		local item = bkgObj:GetChildByIndex(itemCount - 1)
		left, top, right, bottom = item:GetObjPos()
		local width = right -left
		left = beginPos
		right = left + width
		item:SetObjPos(left, top, right, bottom)

		self:FireExtEvent("OnColumnWidthChanged", index)
	end
	newItem:AttachListener("OnHeaderItemWidthChanged", true, OnHeaderItemWidthChanged)
end


function Header_OnPosChange(self)
	local headerLeft, headerTop, headerRight, headerBttom = self:GetObjPos()
	local headerWidth = headerRight - headerLeft

	local bkgObj = self:GetControlObject("bkg")
	local itemCount = bkgObj:GetChildCount()
	if itemCount == 0 then
		return
	end
	local lastItem = bkgObj:GetChildByIndex(itemCount - 1)	--
	local left, top, right, bottom = lastItem:GetObjPos()

	local lastItemAttr = lastItem:GetAttribute()
	local right = left + lastItemAttr.ColumnInfo.Width

	lastItem:SetObjPos(left, top, right, bottom)
end

function Header_FindItem(self, item)
	local attr = self:GetAttribute()
	if attr.HeaderItems == nil or #attr.HeaderItems == 0 then
		return nil
	end
	for i = 1, #attr.HeaderItems do
		if attr.HeaderItems[i]:GetID() == item:GetID() then
			return i
		end
	end
	return nil
end

function Header_SelectItem(self, index)
	local attr = self:GetAttribute()
	if attr.HeaderItems == nil or #attr.HeaderItems == 0 then
		return
	end
	for i = 1, #attr.HeaderItems do
		if i ~= index then
			attr.HeaderItems[i]:SetSort(0)
		end
	end
end

--====================================================================
--					grid
function Grid_GetText(self)
	local textObj = self:GetControlObject("text")
	return textObj:GetText()
end


function Grid_SetText(self, text)
	local textObj = self:GetControlObject("text")
	textObj:SetText(text)
	if text ~= nil and text ~= "" then
		textObj:SetVisible(true)
	else
		textObj:SetVisible(false)
	end
end

function Grid_GetSuitSize( self )
	local textObj = self:GetControlObject("text")
	local width, height = textObj:GetTextExtent()
	local left, top, right, bottom = textObj:GetObjPos()
	return width + left, height
end

function Grid_GetUserObject(self, id)
	return self:GetControlObject(id)
end

function Grid_SetTextFont(self, id)
	local textObj = self:GetControlObject("text")
	textObj:SetTextFontResID(id)
end


function Grid_InsertUserObject(self, obj, left, top, width, height)
	--OnLButtonDown 	OnLButtonUp	OnLButtonDbClick	OnRButtonDown	OnRButtonUp	OnRButtonDbClick	OnMouseMove		OnMouseHover
	function OnMouseEvent(userObj, event, eventName, x, y, flags)
		x, y = ChildToParent(userObj, x, y)
		x, y = ChildToParent(self, x, y)
		self:FireExtEvent("OnMouseEvent", eventName, x, y, flags)
	end
	if obj:EventExists("OnMouseEvent") then
		obj:AttachListener("OnMouseEvent", true, OnMouseEvent)
	end

	--		OnKeyDown		OnKeyUp		OnChar
	function OnKeyEvent(userObj, event, eventName, uChar, uRepeatCount, uFlags)
		self:FireExtEvent("OnKeyEvent", eventName, uChar, uRepeatCount, uFlags)
	end
	if obj:EventExists("OnKeyEvent") then
		obj:AttachListener("OnKeyEvent", true, OnKeyEvent)
	end

	self:AddChild(obj)
	obj:SetObjPos(left, top, left + width, top + height)
end


function Grid_SetTextPos(self, textPos)
	local text = self:GetControlObject("text")
	local left, top, right, bottom = text:GetObjPos()
	left = textPos
	text:SetObjPos(left, top, right, bottom)
end


function Grid_OnPosChange(self)
	local left, top, right, bottom = self:GetObjPos()
	local gridWidth = right - left
	local gridHeight = bottom - top

	local textObj = self:GetControlObject("text")
	left, top, right, bottom = textObj:GetObjPos()
	textObj:SetObjPos(left, 0, gridWidth, gridHeight)
end






--====================================================================
--					item
--		item属性
--			ItemData:map  item对应的数据  InsertItem的参数data
--			Select:bool		是否选中
--			IsVisible:bool	是否可见	

function Item_RemoveColumn(self, index)
end


function Item_GetSelect(self)
	local attr = self:GetAttribute()
	return attr.Select
end


function Item_SetSelect(self, isSelect)
	local bkgObj = self:GetControlObject("bkg")
	local attr = self:GetAttribute()
	attr.Select = isSelect

	if isSelect and attr.SelectBkgTexture ~= "" then
		local attr = self:GetAttribute()
		bkgObj:SetTextureID(attr.SelectBkgTexture)
	elseif attr.ItemData._ItemIndex % 2 == 0 then	--_ItemIndex从1开始
		bkgObj:SetTextureID(attr.EvenItemBkgTexture)
	else
		bkgObj:SetTextureID(attr.NormalItemBkgTexture)
	end
end


function Item_InitItem(self, itemIndex, columnInfoList)
	--初始化item.		 根据ListCtrl的列记录创建格子对象
	local columnCount = #columnInfoList

	local bkgObj = self:GetControlObject("bkg")

	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")

	local left, top, right, bottom = self:GetObjPos()
	local itemHeight = bottom - top

	--OnLButtonDown 	OnLButtonUp	OnLButtonDbClick	OnRButtonDown	OnRButtonUp	OnRButtonDbClick	OnMouseMove		OnMouseHover
	function OnMouseEvent(grid, event, eventName, x, y, flags)
		x, y = ChildToParent(grid, x, y)
		x, y = ChildToParent(self, x, y)
		self:FireExtEvent("OnMouseEvent", eventName, x, y, flags)
	end

	--		OnKeyDown		OnKeyUp		OnChar
	function OnKeyEvent(grid, event, eventName, uChar, uRepeatCount, uFlags)
		self:FireExtEvent("OnKeyEvent", eventName, uChar, uRepeatCount, uFlags)
	end

	local list = self:GetOwnerControl()
	
	local attr = self:GetAttribute()
	local listCtrlObj = attr._ListCtrlObj

	local pos = 0
	for i = 1, columnCount do
		local column = columnInfoList[i]
		local grid = objFactory:CreateUIObject(column.ID, "WHome.ListCtrl.ItemGrid")
		grid:GetControlObject("text"):SetHAlign(column.ItemHalign)
		grid:SetLimitChild(true)
		bkgObj:AddChild(grid)

		grid:AttachListener("OnMouseEvent", true, OnMouseEvent)
		grid:AttachListener("OnKeyEvent", true, OnKeyEvent)

		grid:SetTextPos(column.TextPos)
		
		local left = pos
		local right = pos + column.Width
		grid:SetObjPos(left, 0, right, itemHeight)
		pos = right

		if column.Custom then
			local columnID = column.ID
			listCtrlObj:FireExtEvent("OnGridInit", itemIndex, i, columnID, self, grid)		
		end
	end
end


function Item_GetGridByIndex(self, index)
		local bkg = self:GetChildByIndex(0)			--先取背景
		return bkg:GetChildByIndex(index - 1)	--GetChildByIndex 索引从0开始的, GetGridByIndex为了与lua保持一致, 索引从1开始, 所以-1
end


function Item_GetGridByID(self, id)
	return self:GetControlObject(id)
end


function Item_GetData(self)
	local attr = self:GetAttribute()
	return attr.ItemData
end


function Item_GetIndex(self)
	local attr = self:GetAttribute()
	return attr.ItemData._ItemIndex
end


function Item_FillData(self, columnInfoList, itemIndex, data)
	local attr = self:GetAttribute()
	attr.ItemData = data

	local columnCount = #columnInfoList

	self:SetSelect(data._Select)

	local listCtrlObj = attr._ListCtrlObj

	for i = 1, columnCount do
		local columnInfo = columnInfoList[i]
		local grid = self:GetGridByIndex(i)

		local columnID = columnInfo.ID

		if data[columnID] ~= nil then	
			grid:SetText(data[columnID]) 
		end
		
		if columnInfo.Custom then
			--自定义列
			listCtrlObj:FireExtEvent("OnGridFillData", itemIndex, i, columnID, self, grid)
		end
	end
end


function Item_Refresh(self, columnInfoList, columnID)
	local attr = self:GetAttribute()
	local itemData = attr.ItemData 

	if columnID == nil then
		self:FillData(columnInfoList, itemData._ItemIndex, itemData)
	else
		local columnIndex = -1
		local columnInfo
		for i = 1, #columnInfoList do
			local info = columnInfoList[i]
			if info.ID == columnID then
				columnIndex = i
				columnInfo = info
				break
			end
		end
		if columnInfo == nil then
			return
		end

		local listCtrlObj = attr._ListCtrlObj

		local grid = self:GetGridByIndex(columnIndex)
		if itemData[columnID] ~= nil then		
			grid:SetText(itemData[columnID]) 
		end
		if columnInfo.Custom then
			--自定义列
			listCtrlObj:FireExtEvent("OnGridFillData", itemData._ItemIndex, columnIndex, columnID, self, grid)
		end
	end
end

function Item_OnInitControl(self)
		local attr = self:GetAttribute()
		attr.Select = false
		attr.IsVisible = true
end

function Item_OnLButtonDown(self, x, y, flags)
	x, y = ChildToParent(self, x, y)
	self:FireExtEvent("OnMouseEvent", "OnLButtonDown", x, y, flags)
end

function Item_OnLButtonUp(self, x, y, flags)
	x, y = ChildToParent(self, x, y)
	self:FireExtEvent("OnMouseEvent", "OnLButtonUp", x, y, flags)
end

function Item_OnLButtonDbClick(self, x, y, flags)
	x, y = ChildToParent(self, x, y)
	self:FireExtEvent("OnMouseEvent", "OnLButtonDbClick", x, y, flags)
end

function Item_OnRButtonDown(self, x, y, flags)
	x, y = ChildToParent(self, x, y)
	self:FireExtEvent("OnMouseEvent", "OnRButtonDown", x, y, flags)
end

function Item_OnRButtonUp(self, x, y, flags)
	self:FireExtEvent("OnMouseEvent", "OnRButtonUp", x, y, flags)
end


function Item_OnRButtonDbClick(self, x, y, flags)
	x, y = ChildToParent(self, x, y)
	self:FireExtEvent("OnMouseEvent", "OnRButtonDbClick", x, y, flags)
end


function Item_OnMouseMove(self, x, y, flags)
	x, y = ChildToParent(self, x, y)
	self:FireExtEvent("OnMouseEvent", "OnMouseMove", x, y, flags)
end

function Item_OnMouseLeave(self, x, y, flags)
	self:FireExtEvent("OnMouseEvent", "OnMouseLeave", x, y, flags)
end

function Item_DoEvent(self, event, x, y)
	local attr = self:GetAttribute()
	if event == "OnMouseMove" then
		local isselect = self:GetSelect()
		local attr = self:GetAttribute()
		if (not isselect or attr.SelectBkgTexture == "" ) and attr.HoverItemBkgTexture ~= "" then
			local bkgObj = self:GetControlObject("bkg")
			bkgObj:SetTextureID(attr.HoverItemBkgTexture)
		end
	elseif event == "OnMouseLeave" then
		local isselect = self:GetSelect()
		if (not isselect or attr.SelectBkgTexture == "" ) and attr.HoverItemBkgTexture ~= "" then
			local left, top, right, bottom = self:GetObjPos()
			if x <= left or x >= right or y <= top or y >= bottom then
				local bkgObj = self:GetControlObject("bkg")
				if attr.ItemData._ItemIndex % 2 == 0 then	--_ItemIndex从1开始
					bkgObj:SetTextureID(attr.EvenItemBkgTexture)
				else
					bkgObj:SetTextureID(attr.NormalItemBkgTexture)
				end
			end
		end
	end
end

function Item_OnMouseHover(self, x, y, flags)
	x, y = ChildToParent(self, x, y)
	self:FireExtEvent("OnMouseEvent", "OnMouseHover", x, y, flags)
end


function Item_OnMouseWheel(self, x, y, distance)
	x, y = ChildToParent(self, x, y)
	self:FireExtEvent("OnMouseEvent", "OnMouseWheel", x, y, distance)
end


function Item_OnKeyDown(self, uChar, uRepeatCount, uFlags)
	self:FireExtEvent("OnKeyEvent", "OnKeyDown", uChar, uRepeatCount, uFlags)
end


function Item_OnKeyUp(self, uChar, uRepeatCount, uFlags)
	self:FireExtEvent("OnKeyEvent", "OnKeyUp", uChar, uRepeatCount, uFlags)
end


function Item_OnChar(self, uChar, uRepeatCount, uFlags)
	self:FireExtEvent("OnKeyEvent", "OnChar", uChar, uRepeatCount, uFlags)
end


function Item_UpdateGridPos(self, columnInfoList)
	local left, top, right, bottom = self:GetObjPos()
	local itemHeight = bottom - top

	local gridleft = 0
	local gridright = 0
	for i = 1, #columnInfoList do
		local column = columnInfoList[i]
		local grid = self:GetGridByIndex(i)

		gridleft = gridright
		gridright = gridleft + column.Width
		grid:SetObjPos(gridleft, 0, gridright, itemHeight)
	end
end






--====================================================================
--					list

--list属性定义
--			ColumnInfoList:map							记录列信息的列表. 定义见本文件头
--			TotalColumnWidth:int					所有列的总长度



function List_SetCtrlVisible(self, visible)
	local attr = self:GetAttribute()
	attr.CtrlVisible = visible

	self:SetVisible(visible)
	self:SetChildrenVisible(visible)
	
	local baseListObj = self:GetControlObject("base_list")
	baseListObj:SetCtrlVisible(visible)
end


function List_GetCtrlVisible(self)
	local attr = self:GetAttribute()
	return attr.CtrlVisible
end


function List_UpdateUI(self)
	local baseListObj = self:GetControlObject("base_list")
	return baseListObj:UpdateUI()
end

function List_ClearItems(self)
	local baseListObj = self:GetControlObject("base_list")
	return baseListObj:ClearItems()
end


function List_RemoveItem(self, index)
	local baseListObj = self:GetControlObject("base_list")
	return baseListObj:RemoveItem(index)
end


--删除[beginIndex, endIndex)内的行
function List_RemoveItemRange(self, beginIndex, endIndex)
	local baseListObj = self:GetControlObject("base_list")
	return baseListObj:RemoveItemRange(beginIndex, endIndex)
end

--columnID:string		列ID.  Header创建item时候用这个做ID, ListItem创建格子(ItemGrid时候也用这个做ID)
--textPos:int				文字开始的横坐标(垂直方向居中).	
--custom:bool			如果custom为True,  当那列对应的格子初始化或者填数据时 会发事件到外面, 使的外面有机会自定义
function List_InsertColumn(self, columnID, columnWidth, title, headerhalign, itemhalign, textPos, custom, minWidth, bkgtexture, canSort, sortFunc, headerTextColor)
	local attr = self:GetAttribute()

	if custom == nil then
		custom = false
	end
	if minWidth == nil or minWidth < 10 then
		minWidth = 10
	end
	
	attr.TotalColumnWidth = attr.TotalColumnWidth + columnWidth

	local baseListObj = self:GetControlObject("base_list")
	baseListObj:SetItemWidth(attr.TotalColumnWidth, false)

	local columnInfo = {ID = columnID, Width = columnWidth, Title = title, HeaderHalign = headerhalign, ItemHalign = itemhalign, TextPos = textPos, Custom = custom, MinWidth = minWidth, Bkgtexture = attr.HeaderBkgTexture, CanSort = canSort, SortFunc = sortFunc}
	table.insert(attr.ColumnInfoList, columnInfo)

	local headerObj = self:GetControlObject("header")
	headerObj:InsertColumn(columnInfo, headerTextColor)

	headerObj:SetObjPos(0, 0, attr.TotalColumnWidth, 22)

	if attr.ItemDataList ~= nil then
		return
	end
	--先不做动态添加列了
end


function GetColumnIndexByID(columnInfoList, columnID)
	if columnInfoList == nil then
		return nil
	end
	
	local index = 0
	local columnCount = #columnInfoList

	for i = 1, columnCount do
		local column = columnInfoList[i]
		if column.ID == columnID then
			index = i
			return index
		end
	end
	return nil
end


function List_RemoveColumn(self, columnID)
	local attr = self:GetAttribute()

	--取列索引(从1开始)
	local index = GetColumnIndexByID(attr.ColumnInfoList, columnID)
	if index == nil then
		return
	end

	--在列的记录中删除该列
	local columnCount = #attr.ColumnInfoList
	for i = index, columnCount - 1 do
		attr.ColumnInfoList[i] = attr.ColumnInfoList[i + 1]
	end
	attr.ColumnInfoList[columnCount] = nil
end



function List_UpdateScrollInfo(self)
	local baseListObj = self:GetControlObject("base_list")
	local ret = baseListObj:UpdateScrollInfo()	
	UpdateHeaderPos(self)
	return ret
end


function List_OnPosChange(self)
end


function List_GetSelectItems(self)
	local baseListObj = self:GetControlObject("base_list")
	return baseListObj:GetSelectItems()
end


function List_GetItemCount(self)
	local baseListObj = self:GetControlObject("base_list")
	return baseListObj:GetItemCount()
end


function List_GetItemDataByIndex(self, index)
	local baseListObj = self:GetControlObject("base_list")
	return baseListObj:GetItemDataByIndex(index)
end

function List_GetAllItem(self)
	local baseListObj = self:GetControlObject("base_list")
	return baseListObj:GetAllItem()
end

function List_SetSelectdItemIndex(self, index)
	local baseListObj = self:GetControlObject("base_list")
	return baseListObj:SetSelectdItemIndex(index)
end


function List_RefreshItem(self, index, columnID)
	local baseListObj = self:GetControlObject("base_list")
	return baseListObj:RefreshItem(index, columnID)
end


function List_RefreshAllItems(self, columnID)
	local baseListObj = self:GetControlObject("base_list")
	return baseListObj:RefreshAllItems(columnID)
end


function List_OnInitControl(self)
	local attr = self:GetAttribute()

	local bkg = self:GetControlObject("bkg")
	bkg:SetTextureID(attr.BkgTexture)

	attr.ColumnInfoList = {}

	attr.TotalColumnWidth = 0

	local baseListObj = self:GetControlObject("base_list")
	baseListObj:SetUserData(attr.ColumnInfoList)

	baseListObj:SetMultiSelect(attr.MultiSelect)
	baseListObj:SetItemHeight(attr.ItemHeight)
	
	local baseListAttr = baseListObj:GetAttribute()
	baseListAttr.VisibleVScrollBarSize = attr.VisibleVScrollBarSize
	baseListAttr.VisibleHScrollBarSize = attr.VisibleHScrollBarSize

	local headerObj = self:GetControlObject("header")
	if attr.ShowHeader == false then
		baseListObj:SetItemTopPos(0)
		headerObj:SetVisible(false)
		headerObj:SetChildrenVisible(false)
	end
	headerObj:SetBkgTexture(attr.HeaderBkgTexture)
end


function List_OnItemClick(self, item, ctrlDown, shiftDown)
end




--self:FireExtEvent("OnListItemClick", item, x, y, flags)
function UpdateHeaderPos(self)
	local baseListObj = self:GetControlObject("base_list")
	local hScrollVisible, vScrollVisible = baseListObj:GetScrollBarVisible()

	local wndObj = self:GetControlObject("wnd")
	local left, top, right, bottom = wndObj:GetObjPos()
	local headerWidth = right - left
	headerWidth = math.max(self:GetAttribute().TotalColumnWidth, headerWidth)

	leftPos = 0
	if hScrollVisible then
		local hScrollPos = baseListObj:GetScrollPosition()
		leftPos = hScrollPos
	end

	local headerObj = self:GetControlObject("header")
	left, top, right, bottom = headerObj:GetObjPos()
	left = -leftPos
	right = left + headerWidth
	right = math.max(right, headerWidth)
	headerObj:SetObjPos(left, top, right, bottom)
end


function List_InsertItemList(self, dataList, updateScroll, position, bUpdateUI)
	local baseListObj = self:GetControlObject("base_list")
	local ret = baseListObj:InsertItemList(dataList, updateScroll, position, bUpdateUI)
	if updateScroll then
		UpdateHeaderPos(self)
	end
	return ret
end


--updateScroll:bool 是否更新滚动条信息
function List_InsertItem(self, data, updateScroll, position, bUpdateUI)	--position为nil或大于最大值 时在最后面插入
	local baseListObj = self:GetControlObject("base_list")
	local ret = baseListObj:InsertItem(data, updateScroll, position, bUpdateUI)
	if updateScroll then
		UpdateHeaderPos(self)
	end
	return ret
end


function List_OnItemInit(baseListObj, eventName, item, index)
	local self = baseListObj:GetOwnerControl()	--ListCtrl
	local itemAttr = item:GetAttribute()
	itemAttr._ListCtrlObj = self

	local attr = self:GetAttribute()
	itemAttr.EvenItemBkgTexture = attr.EvenItemBkgTexture
	itemAttr.SelectBkgTexture = attr.SelectBkgTexture
	itemAttr.HoverItemBkgTexture = attr.HoverItemBkgTexture
	itemAttr.NormalItemBkgTexture = attr.NormalItemBkgTexture
end



function List_OnItemFillData(baseListObj, eventName, item, index)
end


function SetObjectLeftPos(obj, newValue)
	local left, top, right, bottom = obj:GetObjPos()
	local width = right - left
	left = newValue
	right = newValue + width
	obj:SetObjPos(left, top, right, bottom)
end


function List_OnHScrollPosChanged(baseListObj, eventName, pos)
	local self = baseListObj:GetOwnerControl()

	local baseListObj = self:GetControlObject("base_list")
	local left, top, right, bottom = baseListObj:GetObjPos()
	local listRight = right

	local headerObj = self:GetControlObject("header")

	left, top, right, bottom = headerObj:GetObjPos()
	local width = right - left
	left = -pos
	right = math.max(left + width, listRight)
	headerObj:SetObjPos(left, top, right, bottom)
end


function List_OnListItemClick(baseListObj, eventName, itemObj, x, y, flags)
	local self = baseListObj:GetOwnerControl()
	self:FireExtEvent("OnListItemClick", itemObj, x, y, flags)
end

function List_OnListSpaceClick(baseListObj, eventName, x, y, flags)
	local self = baseListObj:GetOwnerControl()
	self:FireExtEvent("OnListSpaceClick", x, y, flags)
end

function List_OnListSelectChange(baseListObj)
	local self = baseListObj:GetOwnerControl()
	self:FireExtEvent("OnListSelectChange")
end

function List_OnListItemDbClick(baseListObj, eventName, itemObj, x, y, flags)
	local self = baseListObj:GetOwnerControl()
	self:FireExtEvent("OnListItemDbClick", itemObj, x, y, flags)
end


--[[
function List_UpdateColumnWidth(self)
	local attr = self:GetAttribute()
	attr.TotalColumnWidth = 0

	local headerObj = self:GetControlObject("header")
	local headerLeft, headerTop, headerRight, headerBottom = headerObj:GetObjPos()
	local columnCount = headerObj:GetChildCount()
	local baseListObj = self:GetControlObject("base_list")
	local columnleft = 0
	local columnright = 0
	local colwidths = {}
	for i = 1, columnCount do
		local column = headerObj:GetChildByIndex(i - 1)
		local columnattr = column:GetAttribute()
		attr.TotalColumnWidth = attr.TotalColumnWidth + columnattr.Width
		columnright = columnleft + columnattr.Width
		column:SetObjPos(columnleft, headerTop, columnright, headerBottom)
		columnleft = columnright
		
		colwidths[column:GetID()] = columnattr.Width
	end
	
	baseListObj:SetItemWidth(attr.TotalColumnWidth, true)

	for i = 1, #attr.ColumnInfoList do
		attr.ColumnInfoList[i].Width = colwidths[ attr.ColumnInfoList[i].ID ]
	end

	local headerleft = baseListObj:GetScrollPosition()
	headerleft = -headerleft
	headerObj:SetObjPos(headerleft, headerTop, headerleft + attr.TotalColumnWidth, headerBottom)

	baseListObj:UpdateAllItemGridPos()
end
]]

function List_OnColumnWidthChanged(header, eventName, index)
	local self = header:GetOwnerControl()
	local columnInfoList = self:GetAttribute().ColumnInfoList

	local bkgObj = header:GetControlObject("bkg")
	local sizingcolumn = bkgObj:GetChildByIndex(index)
	for i = 1, #columnInfoList do
		if columnInfoList[i].ID == sizingcolumn:GetID() then
			columnInfoList[i].Width = sizingcolumn:GetAttribute().ColumnInfo.Width
			break
		end
	end
	
	local width = 0
	for i, columnInfo in ipairs(columnInfoList) do
		width = width + columnInfo.Width
	end
	self:GetAttribute().TotalColumnWidth = width
	
	local baseListObj = self:GetControlObject("base_list")
	baseListObj:SetItemWidth(width, false)
	local itemCount = baseListObj:GetItemObjCount()
	for i = 1, itemCount do
		local item = baseListObj:GetItemObjByIndex(i)
		item:UpdateGridPos(columnInfoList)
	end

	self:UpdateScrollInfo()
end

function List_GetColumnSuitWidth( self, ColumnID )
	local columnInfoList = self:GetAttribute().ColumnInfoList
	local index = GetColumnIndexByID( columnInfoList, ColumnID )
	if index == nil then
		return nil
	end
	local suit_width = 0
	local baseListObj = self:GetControlObject("base_list")
	local itemCount = baseListObj:GetItemObjCount()
	for j = 1, itemCount do
		local item = baseListObj:GetItemObjByIndex(j)
		if item ~= nil then
			local grid = item:GetGridByIndex( index )
			if grid ~= nil then
				local width, height = grid:GetSuitSize()
				if width > suit_width then
					suit_width = width
				end
			end
		end		
	end
	return suit_width
end

function List_SetColumnWidth( self, ColumnID, width )
	local headerObj = self:GetControlObject("header")
	headerObj:SetColumnWidth( ColumnID, width )
end

function List_MoveItemUp(self)
	local baseListObj = self:GetControlObject("base_list")
	return baseListObj:MoveItemUp()
end

function List_MoveItemDown(self)
	local baseListObj = self:GetControlObject("base_list")
	return baseListObj:MoveItemDown()
end

function List_ScrollShowItem(self, index)
	local baseListObj = self:GetControlObject("base_list")
	return baseListObj:ScrollShowItem(index)
end

function Grid_OnClick(self)
	self:FireExtEvent("OnClick")
end