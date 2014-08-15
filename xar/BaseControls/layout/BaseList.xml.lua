



--====================================================================
--					list

--list属性定义
--			ItemDataList:map			所有item的数据的列表(ListCtrl:InsertItem的参数data)		
--			BaseList为往data里加入四个值
--						_ItemIndex:int					在ListCtrl中的索引(从1开始)
--						_Select:bool					是否选中
--						_ItemID:string					item id.  标识数据的id.  每个data一个.
--						_ItemObjectID:string		itemObj id.  当前data对应的WHome.ListCtrlItem的对象id.  如果没有对应的对象, 就为空
--			SelectList:map								所有选择的行的映射记录.  {ItemID:string,  map{ItemObjectID:string, Index:int}}

--			ItemWidth:int								所有列的总长度

--			ClientWidth:int								客户区宽度			客户区:指Header和所有Item的区域, 不包括滚动条
--			ClientHeight:int							客户去高度

--			ShowHScroll:bool							是否显示横滚动条
--			ShowVScroll:bool							是否显示竖滚动条

--			HScrollCurrentPos:int					当前横向滚动条的位置
--			VScrollCurrentPos:int					当前竖向滚动条的位置
--			HScrollPageSize:int						当前横向滚动条的页大小(单位像素)
--			VScrollPageSize:int						当前竖向滚动条的页大小(单位像素)
--			MaxItemID:int								当前data 的最大id值. (给data分配id时 用 "Item"..MaxItemID), 不回收id




function SetItemTopPos(self, pos)
	local attr = self:GetAttribute()
	attr.ItemTopPos = pos
end


function SetItemLeftPos(self, pos)
	attr.ItemLeftPos = pos
end


function SetCtrlVisible(self, visible)
	local attr = self:GetAttribute()
	attr.CtrlVisible = visible

	self:SetVisible(visible)
	self:SetChildrenVisible(visible)
	if visible then
		if not attr.ShowHScroll then
			local sb = self:GetControlObject("hscrollbar")
			sb:SetVisible(false)
			sb:SetChildrenVisible(false)
		end
		if not attr.ShowVScroll then
			local sb = self:GetControlObject("vscrollbar")
			sb:SetVisible(false)
			sb:SetChildrenVisible(false)
		end
	end
end


function GetCtrlVisible(self)
	local attr = self:GetAttribute()
	return attr.CtrlVisible
end


function GetItemIndexByID(self, id)
	local attr = self:GetAttribute()
	local itemDataList = attr.ItemDataList 
	for i = 1, #itemDataList do
		local data = itemDataList[i]
		if data._ItemID == id then
			return data._ItemIndex
		end
	end
	return nil
end



function GetSelectItems(self)
	local attr = self:GetAttribute()
	local selectList = attr.SelectList
	if selectList == nil then
		return nil
	end

	local selectIndexList = {}
	for key, info in pairs(selectList) do
		table.insert(selectIndexList, info.Index)
	end
	return selectIndexList
end


function SetMultiSelect(self, isMulitSelect)
	local attr = self:GetAttribute()
	attr.MultiSelect = isMulitSelect
end


function UpdateItemWndSize(self)
	local left, top, right, bottom = self:GetObjPos()

	local attr = self:GetAttribute()
	top = top + attr.ItemTopPos
	left = left + attr.ItemLeftPos

	if attr.ShowHScroll then
		bottom = bottom - attr.VisibleHScrollBarSize
	end
	if attr.ShowVScroll then
		right = right - attr.VisibleVScrollBarSize
	end

	local itemWnd = self:GetControlObject("itemWnd")

	itemWnd:SetObjPos(left, top, right, bottom)

	attr.ClientWidth = right - left
	attr.ClientHeight = bottom - top
end


function UpdateObjectsPostion(self)
	local attr = self:GetAttribute()

	UpdateItemWndSize(self)

	local left, top, right, bottom = self:GetObjPos()
	local width, height = right - left, bottom - top

	local showHScroll, showVScroll = attr.ShowHScroll, attr.ShowVScroll
		
	local scrollBarSize = attr.ScrollBarSize


	--横向滚动条
	if attr.ShowHScroll then
		local hsb = self:GetControlObject("hscrollbar")
		local topPos = height - scrollBarSize
		if attr.ShowVScroll then
			hsb:SetObjPos(0, topPos, width-16, topPos + scrollBarSize)
		else
			hsb:SetObjPos(0, topPos, width, topPos + scrollBarSize)
		end
	end

	--纵向滚动条
	if attr.ShowVScroll then
		local vsb = self:GetControlObject("vscrollbar")
		local left = width - scrollBarSize
		local right = left + scrollBarSize
		local top = attr.ItemTopPos
		local bottom = height
		vsb:SetObjPos(left, top, right, bottom)
	end

end



function UpdateScrollVisibility(self)
	local attr = self:GetAttribute()
	local left, top, right, bottom = self:GetObjPos()
	local listWidth, listHeight = right - left, bottom - top

	local itemCount = #attr.ItemDataList

	local itemWnd = self:GetControlObject("itemWnd")

	local clientWidth = listWidth - attr.ItemLeftPos
	local clientHeight = listHeight - attr.ItemTopPos

	--竖滚动条
	local showVScroll = false
	if itemCount * attr.ItemHeight > clientHeight then
		showVScroll = true
		clientWidth = clientWidth - attr.VisibleVScrollBarSize	--减去滚动条的宽度
	end

	--横滚动条
	local showHScroll = false
	if attr.ItemWidth > clientWidth then
		showHScroll = true
		clientHeight = clientHeight - attr.VisibleHScrollBarSize	--减去滚动条的高度
		
		--出现的横滚动条会导致出现竖滚动条
		if not showVScroll and (itemCount * attr.ItemHeight) > clientHeight then
			showVScroll = true
			clientWidth = clientWidth - attr.VisibleVScrollBarSize	--减去滚动条的宽度
		end
	end

	attr.ShowHScroll = showHScroll
	attr.ShowVScroll = showVScroll
end


function SetScrollBarAttr(self)	
	local attr = self:GetAttribute()
	local showHScroll = attr.ShowHScroll
	local showVScroll = attr.ShowVScroll
	local vsb = self:GetControlObject("vscrollbar")
	vsb:SetVisible(showVScroll)
	vsb:SetChildrenVisible(showVScroll)
	attr.VScrollPageSize = attr.ClientHeight
	if attr.ShowVScroll then
		vsb:SetPageSize(attr.ClientHeight)
		attr.VScrollRange = #attr.ItemDataList  * attr.ItemHeight - attr.VScrollPageSize
		vsb:SetScrollRange(0, attr.VScrollRange, true)
	else
		--如果垂直滚动条不可见，则将滚动条滚动到最顶位置
		vsb:FireExtEvent("OnVScroll", 4, 0)
	end

	local hsb = self:GetControlObject("hscrollbar")
	hsb:SetVisible(showHScroll)
	hsb:SetChildrenVisible(showHScroll)
	attr.HScrollPageSize = attr.ClientWidth
	if attr.ShowHScroll then
		hsb:SetPageSize(attr.ClientWidth)
		attr.HScrollRange = attr.ItemWidth - attr.HScrollPageSize
		local pos = hsb:GetScrollPos()
		hsb:SetScrollRange(0, attr.HScrollRange, true)
		if pos > attr.HScrollRange then
			hsb:SetScrollPos( attr.HScrollRange )
			OnHScroll( hsb, "OnHScroll", 4, attr.HScrollRange )
		end
	else	--隐藏滚动条时将列表滚到开头
		attr.HScrollCurrentPos = 0
		HScroll(self)
	end
end


function UpdateScrollInfo(self)
	local attr = self:GetAttribute()

	--计算滚动条是否可见
	UpdateScrollVisibility(self)

	--调整item窗口, 滚动条的位置
	UpdateObjectsPostion(self)

	--设置滚动条PageSize, Range
	SetScrollBarAttr(self)
end


--			ItemDataList:map			所有item的数据的列表(ListCtrl:InsertItem的参数data)		
--			BaseList为往data里加入四个值
--						_ItemIndex:int					在ListCtrl中的索引(从1开始)
--						_Select:bool					是否选中
--						_ItemID:string					item id.  标识数据的id.  每个data一个.
--						_ItemObjectID:string		itemObj id.  当前data对应的WHome.ListCtrlItem的对象id.  如果没有对应的对象, 就为空
--			SelectList:map							
--			所有选择的行的映射记录.  {ItemID:string,  map{ItemObjectID:string, Index:int}}

function SelectAllItem(self)
	local attr = self:GetAttribute()
	local selectList = attr.SelectList
	for i, itemData in ipairs(attr.ItemDataList) do
		selectList[itemData._ItemID] = {ItemObjectID = itemData._ItemObjectID, Index = itemData._ItemIndex}
		itemData._Select = true
	end
	self:RefreshAllItems()
	self:FireExtEvent("OnListSelectChange")	
end


function UnselectAllItem(self)
	local attr = self:GetAttribute()
	if attr.SelectList == nil then
		return
	end

	--先只设置可见对象.  不可见对象在UpdateUhI里面更新的时候处理
	for itemID, info in pairs(attr.SelectList) do
		local itemData = self:GetItemDataByIndex(info.Index)
		itemData._Select = false

		if itemData._ItemObjectID ~= nil then
			local item = self:GetControlObject(itemData._ItemObjectID)
			item:SetSelect(false)
		end
	end
	attr.SelectList = {}
	self:FireExtEvent("OnListSelectChange")	
end

function SetSelectdItemIndex(self, index)
	SelectItem(self, index,true)
end

function SelectItem(self, index, isSelect)
	local attr = self:GetAttribute()

	local itemData = attr.ItemDataList[index]
	itemData._Select = isSelect

	local itemID = itemData._ItemID
	
	if isSelect then
		attr.SelectList[itemID] = {ItemObjectID = itemData._ItemObjectID, Index = index}
	else
		attr.SelectList[itemID] = nil
	end

	local firstItemIndex = math.floor(attr.VScrollCurrentPos / attr.ItemHeight)
	local lastItemIndex = firstItemIndex + math.ceil(attr.VScrollPageSize / attr.ItemHeight)

	if index < firstItemIndex or index > lastItemIndex then
		self:FireExtEvent("OnListSelectChange")	
		return itemID
	end

	local itemWnd = self:GetControlObject("itemWnd")
	local item = itemWnd:GetChildByIndex(index - firstItemIndex - 1)
	if item ~= nil then
		item:SetSelect(isSelect)
	end
	self:FireExtEvent("OnListSelectChange")	
	return itemID
end


function SelectItemRange(self, beginSelectPos, endSelectPos)

	local attr = self:GetAttribute()
	attr.RangeSelectEndID = attr.ItemDataList[endSelectPos]._ItemID

	local beginPos = math.min(beginSelectPos, endSelectPos)
	local endPos = math.max(beginSelectPos, endSelectPos)

	local firstItemIndex = math.floor(attr.VScrollCurrentPos / attr.ItemHeight) + 1
	local lastItemIndex = firstItemIndex + math.ceil(attr.VScrollPageSize / attr.ItemHeight) + 1

	local itemWnd = self:GetControlObject("itemWnd")

	local selectList = attr.SelectList
	for i = beginPos, endPos do
		local itemData = attr.ItemDataList[i]
		itemData._Select = true
		local itemID = itemData._ItemID
		selectList[itemID] = {ItemObjectID = itemData._ItemObjectID, Index = i}

		if i >= firstItemIndex and i <= lastItemIndex then
			local item = itemWnd:GetChildByIndex(i - firstItemIndex)
			if item ~= nil then
				item:SetSelect(true)
			end
		end
	end
	self:FireExtEvent("OnListSelectChange")	
end


function ClearItems(self)
	local itemWnd = self:GetControlObject("itemWnd")
	local itemObjCount = itemWnd:GetChildCount()
	for i = itemObjCount - 1, 0, -1 do				--从后面开始删
		local item = itemWnd:GetChildByIndex(i)
		itemWnd:RemoveChild(item)
	end

	local attr = self:GetAttribute()
	attr.ItemDataList = {}	
	attr.SelectList = {}
	self:FireExtEvent("OnListSelectChange")	
end


function UpdateUI(self)
	local itemWnd = self:GetControlObject("itemWnd")

	local attr = self:GetAttribute()
	local dataList = attr.ItemDataList
	if #dataList * attr.ItemHeight > attr.VScrollPageSize and
					attr.VScrollCurrentPos > #dataList * attr.ItemHeight - attr.VScrollPageSize then
		attr.VScrollCurrentPos = #dataList * attr.ItemHeight - attr.VScrollPageSize
	end

	local itemHeight = attr.ItemHeight

	local beginItemIndex = attr.VScrollCurrentPos / itemHeight
	local dis = (beginItemIndex - math.floor(beginItemIndex)) * itemHeight
	beginItemIndex = math.floor(beginItemIndex) + 1

	local selectList = attr.SelectList

	local itemObjCount = itemWnd:GetChildCount()
	for i = 0, itemObjCount do
		local itemObj = itemWnd:GetChildByIndex(i)
		if itemObj ~= nil then
			local left, top, right, bottom = itemObj:GetObjPos()
			
			top = i * itemHeight - dis
			bottom = top + itemHeight
			itemObj:SetObjPos(left, top, right, bottom)

			local itemAttr = itemObj:GetAttribute()
			local data = dataList[beginItemIndex + i]
			if data ~= nil then
				--更新选中.  UnselectAllItem中只处理了当时可见的对象, 这里处理其他的
				if selectList[data._ItemID] == nil then
					data._Select = false
				else
					data._Select = true
				end

				data._ItemObjectID = itemObj:GetID()
		
				self:FireExtEvent("OnItemFillData", itemObj, itemIndex)
				itemObj:FillData(attr.UserData, itemIndex, data)
				if not itemAttr.IsVisible then
					itemAttr.IsVisible = true
					itemObj:SetVisible(true)
					itemObj:SetChildrenVisible(true)
				end
			else
				itemAttr.IsVisible = false
				itemObj:SetVisible(false)
				itemObj:SetChildrenVisible(false)
			end
		end	--if itemObj ~= nil then
	end	--for i = 0, itemObjCount do
end


--删除[beginIndex, endIndex)内的行
function RemoveItemRange(self, beginIndex, endIndex)
	local attr = self:GetAttribute()

	local itemDataList = attr.ItemDataList 
	local itemCount = #itemDataList
	if beginIndex > itemCount then
		return
	end
	
	--将删除的项设置为非选中状态
	if endIndex > beginIndex then
		for i = beginIndex, endIndex-1 do
			if i > itemCount then
				break
			end
			SelectItem(self, i, false)
		end
	end

	if endIndex > itemCount then
		local removeCount = (itemCount + 1) - beginIndex
		for i = 1, removeCount do
			table.remove(itemDataList)
		end
	else
		local remainCount = (itemCount + 1) - beginIndex
		for i = 0, remainCount - 1 do
			if endIndex + i <= itemCount then
				itemDataList[beginIndex + i] = itemDataList[endIndex + i]
				itemDataList[beginIndex + i]._ItemIndex = beginIndex + i
			else
				itemDataList[beginIndex + i] = nil
			end
		end
	end
	UpdateScrollInfo(self)
	UpdateUI(self)
end


function RemoveItem(self, index)
	local attr = self:GetAttribute()

	local itemDataList = attr.ItemDataList 
	local itemCount = #itemDataList
	if index > itemCount then	--index从1开始的
		return
	end
	--将删除的项设置为非选中状态
	SelectItem(self, index, false)
	for i = index, itemCount - 1 do
		itemDataList[i] = itemDataList[i + 1]
		itemDataList[i]._ItemIndex = i
	end
	itemDataList[itemCount] = nil
	UpdateScrollInfo(self)
	UpdateUI(self)
end



function OnPosChange(self)
	UpdateItemWndSize(self)
	local attr = self:GetAttribute()
	local itemWidth = attr.ItemWidth
	local itemWnd = self:GetControlObject("itemWnd")
	local wndleft, wndtop, wndright, wndbottom = itemWnd:GetObjPos()
	if itemWidth < wndright - wndleft then
		itemWidth = wndright - wndleft
	end
	local child_count = itemWnd:GetChildCount()
	for i = 0, child_count - 1 do
		local item = itemWnd:GetChildByIndex(i)
		local left, top, right, bottom = item:GetObjPos()
		right = left + itemWidth
		item:SetObjPos(left, top, right, bottom)
	end

	UpdateItemObjectCount(self, attr.ItemDataList, true)
end


function GetItemCount(self)
	local attr = self:GetAttribute()
	return #attr.ItemDataList
end


function GetItemDataByIndex(self, index)
	local attr = self:GetAttribute()
	return attr.ItemDataList[index]
end

function GetAllItem(self)
	local attr = self:GetAttribute()
	if attr then
		return attr.ItemDataList
	end
end


function GetItemObjCount(self)
	local itemWnd = self:GetControlObject("itemWnd")
	return itemWnd:GetChildCount()
end

function GetItemObjByIndex(self, index)
	local itemWnd = self:GetControlObject("itemWnd")
	return itemWnd:GetChildByIndex(index - 1)
end


function RefreshItem(self, index, key)
	local attr = self:GetAttribute()
	local itemWnd = self:GetControlObject("itemWnd")

	local firstItemIndex = math.floor(attr.VScrollCurrentPos / attr.ItemHeight)
	local lastItemIndex = firstItemIndex + math.ceil(attr.VScrollPageSize / attr.ItemHeight)

	if index < firstItemIndex or index > lastItemIndex then
		return
	end

	local item = itemWnd:GetChildByIndex(index - firstItemIndex - 1)
	if item ~= nil then
		item:Refresh(attr.UserData, key)
	end
end


function RefreshAllItems(self, key)
	local attr = self:GetAttribute()
	local itemWnd = self:GetControlObject("itemWnd")
	local itemObjCount = itemWnd:GetChildCount()
	for i = 0, itemObjCount -1 do
		local item = itemWnd:GetChildByIndex(i)
		item:Refresh(attr.UserData, key)
	end
end


function GetScrollBarVisible(self)
	local attr = self:GetAttribute()	
	return attr.ShowHScroll, attr.ShowVScroll
end


function GetScrollPosition(self)
	local attr = self:GetAttribute()	
	return attr.HScrollCurrentPos, attr.VScrollCurrentPos
end


function OnInitControl(self)
	local attr = self:GetAttribute()

	attr.HScrollCurrentPos = 0
	attr.VScrollCurrentPos = 0

	attr.HScrollPageSize = 0
	attr.VScrollPageSize = 0
	
	attr.ClientWidth = 0
	attr.ClientHeight = 0

	attr.ItemDataList = {}
	attr.UserData = {}
	attr.SelectList = {}

	attr.MaxItemID = 0

	attr.ItemWidth = 0

	attr.ShowHScroll = false
	attr.ShowVScroll = false

	local itemWnd = self:GetControlObject("itemWnd")
	local left, top, right, bottom = itemWnd:GetObjPos()
	local itemWndHeight = bottom - top
	
	local hsb = self:GetControlObject("hscrollbar")
	hsb:SetVisible(false)
	hsb:SetChildrenVisible(false)

	local vsb = self:GetControlObject("vscrollbar")
	vsb:SetVisible(false)
	vsb:SetChildrenVisible(false)
	UpdateObjectsPostion(self)
end


--		点击纵向进度条的上箭头			self	“OnVScroll”	1	0
--		点击纵向进度条的下箭头			self	“OnVScroll”	2	0
--		点击纵向进度条的非滑块位置		self	“OnVScroll”	3	OnLButtonDown的y值
--		拖动纵向进度条的滑块				self	“OnVScroll”	4	onMouseMove的y值
function OnVScroll(scrollBar, eventName, ntype, param)
	local self = scrollBar:GetOwnerControl()

	local sb = self:GetControlObject("vscrollbar")

	local attr = self:GetAttribute()

	if ntype == 4 then
		attr.VScrollCurrentPos = param
	else	
		local scrollPos = attr.VScrollCurrentPos
		if ntype == 1 then			--上滚一行
			scrollPos = scrollPos - attr.ItemHeight
		elseif ntype == 2 then	--下滚一行
			scrollPos = scrollPos + attr.ItemHeight
		elseif ntype == 3 then	--滚一页
			if param == -1 then	--在滑块上面点击  上滚一页
				scrollPos = scrollPos - attr.VScrollPageSize
			else							--在滑块下面点击	  下滚一页
				scrollPos = scrollPos + attr.VScrollPageSize
			end
		end

		if scrollPos < 0 then
			scrollPos = 0
		elseif scrollPos > attr.VScrollRange then
			scrollPos = attr.VScrollRange
		end

		if scrollPos == attr.VScrollCurrentPos then
			return
		end
		attr.VScrollCurrentPos = scrollPos
		sb:SetScrollPos(attr.VScrollCurrentPos, true)
	end
	UpdateUI(self)

	self:FireExtEvent("OnVScrollPosChanged", attr.VScrollCurrentPos)
end


function SetObjectLeftPos(obj, newValue)
	local left, top, right, bottom = obj:GetObjPos()
	local width = right - left
	left = newValue
	right = newValue + width
	obj:SetObjPos(left, top, right, bottom)
end


function HScroll(self)
	local attr = self:GetAttribute()
	local hScrollPos = attr.HScrollCurrentPos

	if attr.HScrollCurrentPos > attr.ItemWidth then
		attr.HScrollCurrentPos = attr.ItemWidth
	end

	local scrollPos = attr.HScrollCurrentPos

	local itemWnd = self:GetControlObject("itemWnd")
	local itemObjCount = itemWnd:GetChildCount()
	for i = 0, itemObjCount - 1 do
		local item = itemWnd:GetChildByIndex(i)
		SetObjectLeftPos(item, -scrollPos)
	end
	
	self:FireExtEvent("OnHScrollPosChanged", scrollPos)
end


function OnHScroll(scrollBar, eventName, ntype, param)
	local self = scrollBar:GetOwnerControl()

	local sb = self:GetControlObject("hscrollbar")

	local attr = self:GetAttribute()

	if ntype == 4 then
		attr.HScrollCurrentPos = param
	else	
		local scrollPos = attr.HScrollCurrentPos
		if ntype == 1 then			--左滚一行
			scrollPos = scrollPos - attr.HScrollPageSize / 6
		elseif ntype == 2 then	--右滚一行
			scrollPos = scrollPos + attr.ItemHeight / 6
		elseif ntype == 3 then	--滚一页
			if param == -1 then	--在滑块左边点击  左滚一页
				scrollPos = scrollPos - attr.HScrollPageSize
			else							--在滑块有变点击	  右滚一页
				scrollPos = scrollPos + attr.HScrollPageSize
			end
		end
		
		if scrollPos < 0 then
			scrollPos = 0
		elseif scrollPos > attr.HScrollRange then
			scrollPos = attr.HScrollRange
		end

		if scrollPos == attr.HScrollCurrentPos then
			return
		end
		attr.HScrollCurrentPos = scrollPos
		sb:SetScrollPos(attr.HScrollCurrentPos, true)
	end
	HScroll(self)
end


function SetItemWidth(self, width, bUpdateScrollInfo)
	local attr = self:GetAttribute()
	if attr.ItemWidth == width then
		return
	end

	attr.ItemWidth = width
	
	local itemWnd = self:GetControlObject("itemWnd")
	local left, top, right, bottom = itemWnd:GetObjPos()
	local itemWndWidth = right - left	

	if width < itemWndWidth then
		width = itemWndWidth
	end

	local itemObjCount = itemWnd:GetChildCount()
	for i = 0, itemObjCount - 1 do
		local item = itemWnd:GetChildByIndex(i)
		left, top, right, bottom = item:GetObjPos()
		item:SetObjPos(left, top, left + width, bottom)
	end

	if bUpdateScrollInfo then
		self:UpdateScrollInfo()
	end
end

function SetItemHeight(self, height)
	local attr = self:GetAttribute()
	attr.ItemHeight = height
end

function SelectSingleItem(self, itemIndex)
	UnselectAllItem(self)
	
	local attr = self:GetAttribute()
	attr.RangeSelectEndID = nil
	return SelectItem(self, itemIndex, true)
end

--		处理鼠标单击时的选中
function OnItemClick(self, item, ctrlDown, shiftDown)
	local attr = self:GetAttribute()
	if item == nil then
		UnselectAllItem(self)
		return
	end

	local isSelect = item:GetSelect()

	local data = item:GetData()
	local itemID = data._ItemID
	local itemIndex = data._ItemIndex

	if not attr.MultiSelect then
		--单选
		attr.LastSelectItemID = itemID
		if isSelect and #attr.SelectList == 1 then
			return
		end

		SelectSingleItem(self, itemIndex)
	else
		local lastSelectItemID = attr.LastSelectItemID
		--多选
		if ctrlDown then
			--ctrl 多选
			attr.LastSelectItemID = itemID
			SelectItem(self, itemIndex, not isSelect)
		elseif shiftDown and lastSelectItemID ~= nil then
			--shift多选
			UnselectAllItem(self)

			local lastSelectItemIndex = GetItemIndexByID(self, attr.LastSelectItemID)	--lastSelectItemIndex从1开始
			if lastSelectItemIndex == nil then
				return
			end
			SelectItemRange(self, lastSelectItemIndex, itemIndex)
		else
			attr.LastSelectItemID = itemID
			if isSelect and #attr.SelectList == 1 then
				return
			end

			SelectSingleItem(self, itemIndex)
		end
	end	--end if not attr.MultiSelect
end


--		处理键盘的选中
-- VK_END			0x23
-- VK_HOME		0x24
-- VK_LEFT			0x25
-- VK_UP			0x26
-- VK_RIGHT		0x27
-- VK_DOWN		0x28
function InnerOnKeyDown(self, uChar)
	local attr = self:GetAttribute()

	local multiSelect = attr.MultiSelect
	local shell = XLGetObject( "CoolJ.OSShell" )
	local ctrlDown, shiftDown = false, false
	if shell:GetKeyState(0x11) < 0 then
		ctrlDown = true
	end
	if shell:GetKeyState(0x10) < 0 then
		shiftDown = true
	end

	local lastSelectItemIndex = GetItemIndexByID(self, attr.LastSelectItemID)	--lastSelectItemIndex从1开始
	if lastSelectItemIndex == nil then
		return
	end

	local itemCount = self:GetItemCount()
	if (uChar == 'a' or uChar == 'A') and ctrlDown then
	elseif uChar == 0x26 then			--VK_UP
		if lastSelectItemIndex == 1 then
			return
		end
		if not multiSelect then
			attr.LastSelectItemID = SelectSingleItem(self, lastSelectItemIndex - 1)
		elseif shiftDown then
			local endIndex = lastSelectItemIndex - 1
			if attr.RangeSelectEndID ~= nil then
				local temp = GetItemIndexByID(self, attr.RangeSelectEndID)
				if temp ~= nil then
					endIndex = temp - 1
				end
			end
			if endIndex < 1 then
				return
			end
			UnselectAllItem(self)
			SelectItemRange(self, lastSelectItemIndex, endIndex)
			attr.LastSelectItemID = attr.ItemDataList[lastSelectItemIndex]._ItemID
		elseif not ctrlDown then
			attr.LastSelectItemID = SelectSingleItem(self, lastSelectItemIndex - 1)
		end
	elseif uChar == 0x28 then		--VK_DOWN
		if lastSelectItemIndex == itemCount then
			return
		end

		if not multiSelect then
			attr.LastSelectItemID = SelectSingleItem(self, lastSelectItemIndex + 1)
		elseif shiftDown then
			local endIndex = lastSelectItemIndex + 1
			if attr.RangeSelectEndID ~= nil then
				local temp = GetItemIndexByID(self, attr.RangeSelectEndID)
				if temp ~= nil then
					endIndex = temp + 1
				end
			end
			if endIndex > itemCount then
				return
			end
			UnselectAllItem(self)
			SelectItemRange(self, lastSelectItemIndex, endIndex)
			attr.LastSelectItemID = attr.ItemDataList[lastSelectItemIndex]._ItemID
		elseif not ctrlDown then
			attr.LastSelectItemID = SelectSingleItem(self, lastSelectItemIndex + 1)
		end
	elseif uChar == 0x23 then		--VK_END
		if lastSelectItemIndex == itemCount then
			return
		end

		if not multiSelect then
			attr.LastSelectItemID = SelectSingleItem(self, itemCount)
		elseif shiftDown then
			SelectItemRange(self, lastSelectItemIndex, itemCount)
			attr.LastSelectItemID = attr.ItemDataList[itemCount]._ItemID
		elseif not ctrlDown then
			attr.LastSelectItemID = SelectSingleItem(self, itemCount)
		end
	elseif uChar == 0x24 then		--VK_HOME
		if lastSelectItemIndex == 1 then
			return
		end
		
		if not multiSelect then
			attr.LastSelectItemID = SelectSingleItem(self, 1)
		elseif shiftDown then
			SelectItemRange(self, lastSelectItemIndex, 1)
			attr.LastSelectItemID = attr.ItemDataList[1]._ItemID
		elseif not ctrlDown then
			attr.LastSelectItemID = SelectSingleItem(self, 1)
		end
	end
	
	local lastSelectItemIndex = GetItemIndexByID(self, attr.LastSelectItemID)
	if lastSelectItemIndex ~= nil then
		ScrollShowItem(self, lastSelectItemIndex)
	end
end



function OnLButtonDown(self, x, y, flags)
	--self:FireExtEvent("OnMouseEvent", "OnLButtonDown", x, y, flags)
end


function OnLButtonUp(self, x, y, flags, item)
	--		MK_LBUTTON			0x0001
	--		MK_RBUTTON			0x0002
	--		MK_SHIFT					0x0004
	--		MK_CONTROL			0x0008
	--		MK_MBUTTON			0x0010
	local ctrlDown = BitAnd(flags, 8) ~= 0
	local shiftDown = BitAnd(flags, 4) ~= 0
	OnItemClick(self, item, ctrlDown, shiftDown)
	if item ~= nil then
		self:FireExtEvent("OnListItemClick", item, x, y, flags)
	else
		self:FireExtEvent("OnListSpaceClick", x, y, flags)	
	end
	--self:FireExtEvent("OnMouseEvent", "OnLButtonUp", x, y, flags)
end


function OnLButtonDbClick(self, x, y, flags, item)
	if item ~= nil then
		self:FireExtEvent("OnListItemDbClick", item, x, y, flags)
	end
end


function OnRButtonDown(self, x, y, flags)
	--self:FireExtEvent("OnMouseEvent", "OnRButtonDown", x, y, flags)
end


function OnRButtonUp(self, x, y, flags)
	--self:FireExtEvent("OnMouseEvent", "OnRButtonUp", x, y, flags)
end


function OnRButtonDbClick(self, x, y, flags)
	--self:FireExtEvent("OnMouseEvent", "OnRButtonDbClick", x, y, flags)
end


function OnMouseMove(self, x, y, flags, item)
	--self:FireExtEvent("OnMouseEvent", "OnMouseMove", x, y, flags)
	local attr = self:GetAttribute()
	if item ~= nil and item.DoEvent ~= nil then
		item:DoEvent("OnMouseMove", x, y)
		attr.HoverItem = item
	end
end

function OnMouseLeave(self, x, y, flags, item)
	XLPrint("bear BaseList OnMouseLeave")
	local attr = self:GetAttribute()
	if item ~= nil and item.DoEvent ~= nil then
		item:DoEvent("OnMouseLeave", x, y)
	end
	
	if attr.HoverItem ~= nil and attr.HoverItem.DoEvent ~= nil then
		XLPrint("bear BaseList OnMouseLeave attr.HoverItem ~= nil")
		attr.HoverItem:DoEvent("OnMouseLeave", x, y)
	end
end

function OnMouseHover(self, x, y, flags)
	--self:FireExtEvent("OnMouseEvent", "OnMouseHover", x, y, flags)
end


function OnMouseWheel(self, x, y, distance)
	local attr = self:GetAttribute()
	
	if not attr.ShowVScroll then
		return
	end

	local vsb = self:GetControlObject("vscrollbar")
	if distance < 0 then
		attr.VScrollCurrentPos = attr.VScrollCurrentPos + 30
	else
		attr.VScrollCurrentPos = attr.VScrollCurrentPos - 30
		if attr.VScrollCurrentPos < 0 then
			attr.VScrollCurrentPos = 0
		end
	end
	vsb:SetScrollPos(attr.VScrollCurrentPos, true)
	UpdateUI(self)
	--self:FireExtEvent("OnMouseEvent", "OnMouseWheel", x, y, distance)
end


function OnKeyDown(self, eventName, uChar, uRepeatCount, uFlags)
	InnerOnKeyDown(self, uChar)
	--self:FireExtEvent("OnKeyEvent", "OnKeyDown", uChar, uRepeatCount, uFlags)
end

function OnKeyUp(self, eventName, uChar, uRepeatCount, uFlags)
	--self:FireExtEvent("OnKeyEvent", "OnKeyUp", uChar, uRepeatCount, uFlags)
end

function OnChar(self, eventName, uChar, uRepeatCount, uFlags)
	--self:FireExtEvent("OnKeyEvent", "OnChar", uChar, uRepeatCount, uFlags)
end


function SetUserData(self, userData)
	local attr = self:GetAttribute()
	attr.UserData = userData
end


function GetUserData(self)
	local attr = self:GetAttribute()
	return attr.UserData
end


local function ChildToParent(child, x, y)
	local left, top = child:GetObjPos()
	return x + left, y + top
end

local function AddNewItem(self, itemWnd)
	--创建item对象
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")

	local attr = self:GetAttribute()
	local itemIndex = itemWnd:GetChildCount() + 1
	local itemObjID = "item"..itemIndex
	local itemObj = objFactory:CreateUIObject(itemObjID, attr.ItemCtrlID)
	local itemAttr = itemObj:GetAttribute()
	itemAttr.limitchild = 1
	itemWnd:AddChild(itemObj)


	--监听消息
	--鼠标消息
	--OnLButtonDown, OnLButtonUp, OnLButtonDbClick
	--OnRButtonDown, OnRButtonUp, OnRButtonDbClick
	--OnMouseMove, OnMouseHover
	function OnMouseEvent(item, eventName, eventType, x, y, param)
		x, y = ChildToParent(item, x, y)	--转为list坐标
		if eventType == "OnLButtonDown" then
			OnLButtonDown(self, x, y, param)
		elseif eventType == "OnLButtonUp" then
			OnLButtonUp(self, x, y, param, item)
		elseif eventType == "OnLButtonDbClick" then
			OnLButtonDbClick(self, x, y, param, item)
		elseif eventType == "OnRButtonDown" then
			OnRButtonDown(self, x, y, param)
		elseif eventType == "OnRButtonUp" then
			OnRButtonUp(self, x, y, param)
		elseif eventType == "OnRButtonDbClick" then
			OnRButtonDbClick(self, x, y, param)
		elseif eventType == "OnMouseMove" then
			OnMouseMove(self, x, y, param, item)
		elseif eventType == "OnMouseHover" then
			OnMouseHover(self, x, y, param)
		elseif eventType == "OnMouseWheel" then
			OnMouseWheel(self, x, y, param)	
		elseif eventType == "OnMouseLeave" then
			OnMouseLeave(self, x, y, param, item)		
		end
	end
	itemObj:AttachListener("OnMouseEvent", true, OnMouseEvent)

	--按键消息
	--		OnKeyDown		OnKeyUp		OnChar
	function OnKeyEvent(grid, eventName, eventType, uChar, uRepeatCount, uFlags)
		if eventType == "OnKeyDown" then
			OnKeyDown(self, "OnKeyDown", uChar, uRepeatCount, uFlags)
		elseif eventType == "OnKeyUp" then
			OnKeyUp(self, "OnKeyUp", uChar, uRepeatCount, uFlags)
		elseif eventType == "OnChar" then
			OnChar(self, "OnChar", uChar, uRepeatCount, uFlags)
		end
		self:FireExtEvent(eventName, eventType, uChar, uRepeatCount, uFlags)
	end
	itemObj:AttachListener("OnKeyEvent", true, OnKeyEvent)

	--调整item位置
	left = 0
	right = left + attr.ItemWidth
	local wndleft, wndtop, wndright, wndbottom = itemWnd:GetObjPos()
	if right < (wndright - wndleft) then
		right = wndright - wndleft
	end
	top = (itemIndex - 1) * attr.ItemHeight
	bottom = top + attr.ItemHeight
	itemObj:SetObjPos(left, top, right, bottom)

	if attr.HScrollCurrentPos > attr.ItemWidth then
		attr.HScrollCurrentPos = attr.ItemWidth
	end
	local scrollPos = attr.HScrollCurrentPos
	SetObjectLeftPos(itemObj, -scrollPos)

	--发item初始化事件
	self:FireExtEvent("OnItemInit", itemObj, itemIndex)
	itemObj:InitItem(itemIndex, attr.UserData)
end


function UpdateItemObjectCount(self, itemDataList, updateScroll, bUpdateUI)
	local attr = self:GetAttribute()
	local itemWnd = self:GetControlObject("itemWnd")
	local left, top, right, bottom = itemWnd:GetObjPos()
	local width, height = right - left, bottom - top

	local itemCount = #itemDataList
	local itemObjCount = itemWnd:GetChildCount()
	local maxItemObjCount = height / attr.ItemHeight + 2	 -- 允许创建的最大item数量
	while itemCount > itemObjCount and
				itemObjCount <= maxItemObjCount do
		AddNewItem(self, itemWnd)
		itemObjCount = itemWnd:GetChildCount()
	end

	if bUpdateUI == nil or bUpdateUI == true then
		UpdateUI(self)
	end
	if updateScroll == true then
		self:UpdateScrollInfo()
	end
end

function DoInsertItem(self, data, isDataList, updateScroll, position, bUpdateUI)	--position为nil或大于最大值 时在最后面插入
	local attr = self:GetAttribute()

	local itemDataList = attr.ItemDataList
	local itemCount = #itemDataList
	if position == nil or position > itemCount then
		position = itemCount + 1
	elseif position == 0 then
		position = 1
	end

	--local itemIndex = #itemDataList + 1
	local maxItemID = attr.MaxItemID
	if not isDataList then
		--插入单项
		table.insert(itemDataList, position, data)
		data._ItemIndex = position
		data._ItemID = "Item"..maxItemID
		maxItemID = maxItemID + 1
		for i = position + 1, itemCount + 1 do
			itemDataList[i]._ItemIndex = i
		end
	else
		--插入多项
		local newDataList = data
		local newDataCount = #newDataList
		for i = newDataCount, 1, -1 do
			local data = newDataList[i]
			table.insert(itemDataList, position, data)
			data._ItemIndex = position + i - 1
			data._ItemID = "Item"..maxItemID
			maxItemID = maxItemID + 1
		end

		local totalItemCount = #itemDataList
		for i = position + newDataCount, totalItemCount do
			itemDataList[i]._ItemIndex = itemDataList[i]._ItemIndex + newDataCount
		end
	end

	attr.MaxItemID = maxItemID
	
	UpdateItemObjectCount(self, itemDataList, updateScroll, bUpdateUI)
end

function InsertItemList(self, dataList, updateScroll, position, bUpdateUI)	--position为nil或大于最大值 时在最后面插入
	DoInsertItem(self, dataList, true, updateScroll, position, bUpdateUI)
end


--updateScroll:bool 是否更新滚动条信息
function InsertItem(self, data, updateScroll, position, bUpdateUI)	--position为nil或大于最大值 时在最后面插入
	DoInsertItem(self, data, false, updateScroll, position, bUpdateUI)
end


function OnScrollBarFocusChange(self, event, focus)
	if focus then
		local focusid = self:GetID()
		local unfocusid = "vscrollbar"
		if focusid == "vscrollbar" then
			unfocusid = "hscrollbar"
		end
		local owner = self:GetOwnerControl()
		local unfocus = owner:GetControlObject(unfocusid)
		self:SetZorder(400)
		unfocus:SetZorder(0)
	end
end


function OnScrollBarMouseWheel( self, name, x, y, distance )
	local ThumbPos = self:GetThumbPos()
	self:SetThumbPos(ThumbPos - distance/10)
end

function MoveItemUp(self)
	local selectindexlist = GetSelectItems(self)
	if selectindexlist == nil or #selectindexlist ~= 1 then
		return
	end
	
	local attr = self:GetAttribute()
	local itemDataList = attr.ItemDataList
	local itemCount = #itemDataList
	local index = selectindexlist[1]
	if index <= 1 then
		return
	end
	local temp = itemDataList[index]
	itemDataList[index] = itemDataList[index-1]
	itemDataList[index-1] = temp
	itemDataList[index]._ItemIndex = index
	itemDataList[index-1]._ItemIndex = index - 1
	
	local itemData = itemDataList[index-1]
	local itemID = itemData._ItemID
	attr.SelectList = {}
	attr.SelectList[itemID] = {ItemObjectID = itemData._ItemObjectID, Index = index - 1}
	UpdateUI(self)
	self:FireExtEvent("OnListSelectChange")	
end

function MoveItemDown(self)
	local selectindexlist = GetSelectItems(self)
	if selectindexlist == nil or #selectindexlist ~= 1 then
		return
	end
	
	local attr = self:GetAttribute()
	local itemDataList = attr.ItemDataList
	local itemCount = #itemDataList
	local index = selectindexlist[1]
	if index >= itemCount then
		return
	end
	local temp = itemDataList[index+1]
	itemDataList[index+1] = itemDataList[index]
	itemDataList[index] = temp
	itemDataList[index]._ItemIndex = index
	itemDataList[index+1]._ItemIndex = index + 1
	
	local itemData = itemDataList[index+1]
	local itemID = itemData._ItemID
	attr.SelectList = {}
	attr.SelectList[itemID] = {ItemObjectID = itemData._ItemObjectID, Index = index + 1}
	UpdateUI(self)
	self:FireExtEvent("OnListSelectChange")	
end

function ScrollShowItem(self, index)
	local totalcount = GetItemCount(self)
	if index == nil or index < 1 or index > totalcount then
		return
	end

	local attr = self:GetAttribute()
	local firstshowitem = math.ceil(attr.VScrollCurrentPos / attr.ItemHeight) + 1
	local lastshowitem = math.floor((attr.VScrollCurrentPos + attr.VScrollPageSize) / attr.ItemHeight)
	if index >= firstshowitem and index <= lastshowitem then
		return
	end
	local scrollpos = 0
	if index < firstshowitem then
		scrollpos = (index - 1) * attr.ItemHeight 
	elseif index > lastshowitem then
		scrollpos = index * attr.ItemHeight - attr.VScrollPageSize
	end
	if scrollpos == attr.VScrollCurrentPos then
		return
	end
	attr.VScrollCurrentPos = scrollpos
	local sb = self:GetControlObject("vscrollbar")
	sb:SetScrollPos(attr.VScrollCurrentPos, true)
	UpdateUI(self)
	self:FireExtEvent("OnVScrollPosChanged", attr.VScrollCurrentPos)
end