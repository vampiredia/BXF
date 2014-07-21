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
		{
			service="维修",
			sub_service={
				{
					service="房屋防水",
					content="30元/天",
					phone="010-110",
				},
				{
					service="电脑维护",
					content="实际消耗",
					phone="010-110"
				},
			},
		},
		{
			service="更换",
			sub_service={
				{
					service="屋锁更换",
					content="80元",
					phone="010-110",
				},
				{
					service="防盗门",
					content="1800",
					phone="010-110"
				},
			},
		},
	}

	tItemIndexList = table_date
end

function DS_InitControl(self)
	local attr = self:GetAttribute()
	if attr.ItemDataList == nil then
		attr.ItemDataList = {}
	end
	TEMP_FillData(attr.ItemDataList)
end

function DS_GetItemCount(self)
	local attr = self:GetAttribute()
	return #attr.ItemDataList
end

function DS_GetItemDataByIndex(self, nItemIndex)
	local attr = self:GetAttribute()
	return attr.ItemDataList[nItemIndex]
end

function DS_GetSelectedItemCount(self)
	return 0
end

function DS_GetSelectedItemIndexList(self)
	local selectedItemList = {}
	
	return selectedItemList
end

function DS_SelectAllItems(self)
	return 0
end

function DS_UnSelectAllItems(self)
	return 0
end

function DS_IsItemSelected(self, nItemIndex)
	return 0
end

function DS_SelectItem(self, tItemIndexList, strOperationType)
	return 0
end

function DS_UnSelectItem(self, tItemIndexList, strOperationType)
	return 0
end

function DS_ExclusiveSelectItem(self, tItemIndexList, strOperationType)
	return 0
end

function DS_MoveItem(self, tItemIndexList, nTargetItemIndex, cb)
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