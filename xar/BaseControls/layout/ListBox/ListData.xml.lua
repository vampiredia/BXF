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

function TEMP_FillData(tItemIndexList)
	table_date = {
		{id=1, title='关于新年放假200天的重大喜讯', author='Lydia', s_time='2014-10-08', status='已答复'},
		{id=2, title='关于新年放假200天的重大喜讯', author='Lydia', s_time='2014-10-08', status='已答复'},
		{id=3, title='关于新年放假200天的重大喜讯', author='Lydia', s_time='2014-10-08', status='已答复'}
	}

	tItemIndexList = table_date
end

function DS_InitControl(self)
	local attr = self:GetAttribute()
	if attr.ItemDataList == nil then attr.ItemDataList = {} end
	if attr.ItemSelectDataList == nil then attr.ItemSelectDataList = {} end
	if attr.ItemSelectIndexList == nil then attr.ItemSelectIndexList = {} end
	TEMP_FillData(attr.ItemDataList)
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
	return attr.ItemSelectIndexList
end

--
function DS_SelectAllItems(self)
	local attr = self:GetAttribute()
	attr.ItemSelectDataList = attr.ItemDataList
	attr.ItemSelectIndexList = {}
	table.foreach(attr.ItemSelectDataList, function(i, v) table.insert(attr.ItemSelectIndexList, i) end)
	return 0
end

--
function DS_UnSelectAllItems(self)
	local attr = self:GetAttribute()
	attr.ItemSelectDataList = {}
	attr.ItemSelectIndexList = {}
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
	end
	return 0
end

function DS_UnSelectItem(self, tItemIndexList, strOperationType)
	local attr = self:GetAttribute()
	for i=1, #tItemIndexList do
		local removeID = tItemIndexList[i]
		local removeItem = attr.ItemDataList[removeID]
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
	local moveItemDataList = {}
	local attr = self:GetAttribute()
	for i=1, #tItemIndexList do
		local moveID = tItemIndexList[i]
		table.insert(moveItemDataList, attr.ItemDataList[moveID])
		table.remove(attr.ItemDataList, moveID)
		if moveID < nTargetItemIndex then nTargetItemIndex = nTargetItemIndex-1 end
	end
	return 0
end

-- ///////////////////////////////////////////////////////
function DC_InitControl(self)

end

function DC_GetItemSize(self, nItemIndex)

end

function DC_CreateUIObjectFromData(self, strItemObjId, nItemIndex, tItemData, nOperationType)

end

function DC_UpdateUIObjectFromData(self, nItemIndex, objItem, tItemData, nOperationType)

end

function DC_SaveUIObjectState(self, nItemIndex)


end

function DC_SetItemBkgType(self, objItem, nBkgType)
	
end

function DC_GetItemObjPos(self, objItem)
	
end