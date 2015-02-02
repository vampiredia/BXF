-- ///////////////////////////////////////////////////
-- DataSource实现
-- 隐含属性
-- ItemDataList - list数据
-- {
--		ItemData,
-- }
-- ItemData - 一行item的数据
--	{
--		isSelected=false,	-- 当前节点是否被选中
--		ItemList={},
--	}
-- ItemGrid - item单个数据
-- {
-- 		ItemObjID="WHome.ListItem",
--		... 其他属性
-- }
-- ///////////////////////////////////////////////////

function TEMP_FillData(self)
	table_date = {
		{id=1, title='物业服务', author='Lydia', s_time='2014-10-08', status='已答复'},
		{id=2, title='社区医院', author='Lydia', s_time='2014-10-08', status='已答复'},
		{id=3, title='社区服务', author='Lydia', s_time='2014-10-08', status='已答复'},
		{id=4, title='乱七八糟', author='Lydia', s_time='2014-10-08', status='已答复'},
		{id=5, title='1234', author='Lydia', s_time='2014-10-08', status='已答复'},
		{id=6, title='5678', author='Lydia', s_time='2014-10-08', status='已答复'},
		{id=7, title='3333', author='Lydia', s_time='2014-10-08', status='已答复'},
		{id=8, title='1111', author='Lydia', s_time='2014-10-08', status='已答复'},
		{id=9, title='233', author='Lydia', s_time='2014-10-08', status='已答复'},
		{id=10, title='23', author='Lydia', s_time='2014-10-08', status='已答复'}
	}
	local attr = self:GetAttribute()
	attr.ItemDataList = table_date
end

function DS_InitControl(self, data)
	local attr = self:GetAttribute()
	if attr.ItemDataList == nil then attr.ItemDataList = {} end
	if attr.ItemSelectDataList == nil then attr.ItemSelectDataList = {} end
	if attr.ItemSelectIndexList == nil then attr.ItemSelectIndexList = {} end
	attr.ItemDataList = data
end

--
function DS_GetItemCount(self)
	local attr = self:GetAttribute()
	local itemDataList = attr.ItemDataList
	return #itemDataList
end

--
function DS_GetItemDataByIndex(self, nItemIndex)
	local attr = self:GetAttribute()
	attr.ItemDataList[nItemIndex]['strOperationType'] = ''
	for i=1, #attr.ItemSelectIndexList do
		if attr.ItemSelectIndexList[i] == nItemIndex then 
			attr.ItemDataList[nItemIndex]['strOperationType'] = 'mousedown'
			break
		end
	end

	return attr.ItemDataList[nItemIndex]
end

--
function DS_GetSelectedItemCount(self)
	local attr = self:GetAttribute()
	local itemSelectDataList = attr.ItemSelectDataList
	return #itemSelectDataList
end

--
function DS_GetSelectedItemIndexList(self)
	local attr = self:GetAttribute()
	return attr.ItemSelectIndexList
end

--
function DS_SelectAllItems(self)
	local attr = self:GetAttribute()
	attr.ItemSelectDataList = attr.ItemDataList
	attr.ItemSelectIndexList = {}
	table.foreach(attr.ItemSelectDataList, function(i, v) table.insert(attr.ItemSelectIndexList, i) end)
	table.foreach(attr.ItemDataList, function(i, v) v['strOperationType'] = 'mousedown' end)
	return 0
end

--
function DS_UnSelectAllItems(self)
	local attr = self:GetAttribute()
	attr.ItemSelectDataList = {}
	attr.ItemSelectIndexList = {}
	table.foreach(attr.ItemDataList, function(i, v) v['strOperationType'] = '' end)
	return 0
end

--
function DS_IsItemSelected(self, nItemIndex)
	local attr = self:GetAttribute()
	local selectedItemIndexList = attr.ItemSelectIndexList
	for i=1, #selectedItemIndexList do
		if selectedItemIndexList[i] == nItemIndex then return 0 end
	end
	return -1
end

function DS_SelectItem(self, tItemIndexList, strOperationType)
	local attr = self:GetAttribute()
	for i=1, #tItemIndexList do
		table.insert(attr.ItemSelectIndexList, tItemIndexList[i])
		table.insert(attr.ItemSelectDataList, attr.ItemDataList[tItemIndexList[i]])
		attr.ItemDataList[tItemIndexList[i]]['strOperationType'] = 'mousedown'
	end
	return 0
end

function DS_UnSelectItem(self, tItemIndexList, strOperationType)
	local attr = self:GetAttribute()
	for i=1, #tItemIndexList do
		local removeID = tItemIndexList[i]
		local removeItem = attr.ItemDataList[removeID]
		--XLMessageBox(removeID)
		attr.ItemDataList[removeID]['strOperationType'] = ''
		for j=1, #attr.ItemSelectDataList do
			if attr.ItemSelectDataList[j] == removeItem then 
				table.remove(attr.ItemSelectDataList, j) 
				break
			end
		end
		for j=1, #attr.ItemSelectIndexList do
			if attr.ItemSelectIndexList[j] == removeID then 
				table.remove(attr.ItemSelectIndexList, j) 
				break
			end
		end
	end
	return 0
end

function DS_ExclusiveSelectItem(self, tItemIndexList, strOperationType)
	self:UnSelectAllItems()
	self:SelectItem(tItemIndexList, strOperationType)
	return 0
end

--TODO yangjs
function DS_MoveItem(self, tItemIndexList, nTargetItemIndex, cb)
	local attr = self:GetAttribute()
	if #tItemIndexList == 1 then
		local moveID = tItemIndexList[1]
		newItem = table.remove(attr.ItemDataList, moveID)
		table.insert(attr.ItemDataList, nTargetItemIndex, newItem)
		return 0
	else
		return -1
	end
end

-- ///////////////////////////////////////////////////////
function DC_InitControl(self)
	local attr = self:GetAttribute()
	attr.ItemTotalWidth = 200
	attr.ItemTotalHeight = 48
end

function DC_GetItemSize(self, nItemIndex)
	local attr = self:GetAttribute()
	return attr.ItemTotalHeight, attr.ItemTotalWidth
end

function DC_UpdateItemInfo(self, GridInfoList)
	local attr = self:GetAttribute()
	local width = 0
	for i=1, #GridInfoList do width = width + GridInfoList[i]['ItemWidth'] end
	attr.GridInfoList = GridInfoList
end

function DC_CreateUIObjectFromData(self, strItemObjId, nItemIndex, tItemData, nOperationType)
	local attr = self:GetAttribute()
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	local itemObj = objFactory:CreateUIObject(strItemObjId, "Service.List")
	return itemObj
end

function DC_UpdateUIObjectFromData(self, nItemIndex, objItem, tItemData, nOperationType)
	local attr = self:GetAttribute()
	objItem:SetText(tItemData)
	if attr.GridInfoList ~= nil then 
		objItem:SetPosition(attr.GridInfoList, attr.ItemTotalHeight)
	end
	if tItemData['strOperationType'] == 'mousedown' then 
		objItem:GetControlObject("bkg"):SetTextureID("listbox.item.bkg.down")
		objItem:GetControlObject("btn.details"):SetVisible(true)
		objItem:GetControlObject("btn.details"):SetChildrenVisible(true)
		objItem:FireExtEvent("OnItemEvent", "OnSelect", tItemData)
	elseif tItemData['strOperationType'] == 'mousemove' then 
		objItem:GetControlObject("bkg"):SetTextureID("listbox.item.bkg.hover")
		objItem:GetControlObject("btn.details"):SetVisible(false)
		objItem:GetControlObject("btn.details"):SetChildrenVisible(false)
	else
		objItem:GetControlObject("bkg"):SetTextureID("listbox.item.bkg.normal")
		objItem:GetControlObject("btn.details"):SetVisible(false)
		objItem:GetControlObject("btn.details"):SetChildrenVisible(false)
	end
end

function DC_SaveUIObjectState(self, itemObj, nItemIndex)

end

function DC_SetItemBkgType(self, objItem, nBkgType)

end

function DC_GetItemObjPos(self, objItem)
	return objItem:GetObjPos()
end

function Item_OnLButtonDown(self, x, y, flags)
	self:FireExtEvent("OnItemMouseEvent", "OnLButtonDown", x, y, flags)
end

function Item_OnLButtonUp(self, x, y, flags)
	self:FireExtEvent("OnItemMouseEvent", "OnLButtonUp", x, y, flags)
end

function Item_OnRButtonDown(self, x, y, flags)
	self:FireExtEvent("OnItemMouseEvent", "OnRButtonDown", x, y, flags)
end

function Item_OnRButtonUp(self, x, y, flags)
	self:FireExtEvent("OnItemMouseEvent", "OnRButtonUp", x, y, flags)
end

function Item_OnMouseWheel(self, x, y, flags)
	self:FireExtEvent("OnItemMouseEvent", "OnMouseWheel", x, y, flags)
end

function Item_OnMouseMove(self, x, y, flags)
	local bkg = self:GetControlObject("bkg"):GetTextureID()
	if bkg == 'listbox.item.bkg.normal' then 
		self:GetControlObject("bkg"):SetTextureID("listbox.item.bkg.hover")
	end
	self:FireExtEvent("OnItemMouseEvent", "OnMouseMove", x, y, flags)
end

function Item_OnMouseHover(self, x, y, flags)
	self:FireExtEvent("OnItemMouseEvent", "OnMouseHover", x, y, flags)
end

function Item_OnMouseLeave(self, x, y, flags)
	local bkg = self:GetControlObject("bkg"):GetTextureID()
	if bkg == 'listbox.item.bkg.hover' then 
		self:GetControlObject("bkg"):SetTextureID("listbox.item.bkg.normal")
	end
	self:FireExtEvent("OnItemMouseEvent", "OnMouseLeave", x, y, flags)
end

function SetText(self, item)
	self:GetControlObject("text.title"):SetText(item['name'])
end


function SetPosition(self, gridInfoList, height)
	local offset_x = 0
	self:GetControlObject("text.title"):SetObjPos(offset_x, 0, offset_x+gridInfoList[1]['ItemWidth'], height)
end

function Item_OnInitControl(self)
	self:GetControlObject("btn.details"):SetVisible(false)
	self:GetControlObject("btn.details"):SetChildrenVisible(false)
end

function Btn_OnDetails(self)
	local owner = self:GetOwnerControl()
	owner:FireExtEvent("OnItemEvent", "OnShowDetails")
end