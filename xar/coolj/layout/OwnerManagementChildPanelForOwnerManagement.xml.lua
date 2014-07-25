function OnInitControl(self)
	local attr = self:GetAttribute()
	local bkg = self:GetControlObject("bkg")
	--bkg:SetTextureID(attr.BorderTexture)
end



function LC_OnPublicInitControl(self)
	self:InsertColumn("name", 70, "姓名", "left", "center", 5, true, 20)
	self:InsertColumn("phone", 90, "电话", "left", "center", 5, true, 20)
	self:InsertColumn("xz", 60, "性质", "left", "center", 5, true, 20)
	self:InsertColumn("sfz", 150, "身份证", "left", "center", 5, true, 20)
	self:InsertColumn("lyxx", 145, "楼宇信息", "left", "center", 5, true, 20)
	self:InsertColumn("operate", 90, "操作", "left", "center", 5, true, 20)
	self:InsertColumn("status", 70, "缴费状态", "left", "center", 5, true, 20)
	
	local list_item_data = {}
	table.insert(list_item_data, {name="黄蓉", phone="13920001989", xz="业主", sfz="110122198702051110", lyxx="1号楼 2单元 301", operate="编辑 详情", status="已缴费"})
	table.insert(list_item_data, {name="黄蓉", phone="13920001989", xz="业主", sfz="110122198702051110", lyxx="1号楼 2单元 301", operate="编辑 详情", status="已缴费"})
	table.insert(list_item_data, {name="黄蓉", phone="13920001989", xz="业主", sfz="110122198702051110", lyxx="1号楼 2单元 301", operate="编辑 详情", status="已缴费"})
	table.insert(list_item_data, {name="黄蓉", phone="13920001989", xz="业主", sfz="110122198702051110", lyxx="1号楼 2单元 301", operate="编辑 详情", status="已缴费"})
	table.insert(list_item_data, {name="黄蓉", phone="13920001989", xz="业主", sfz="110122198702051110", lyxx="1号楼 2单元 301", operate="编辑 详情", status="已缴费"})
	table.insert(list_item_data, {name="黄蓉", phone="13920001989", xz="业主", sfz="110122198702051110", lyxx="1号楼 2单元 301", operate="编辑 详情", status="已缴费"})
	table.insert(list_item_data, {name="黄蓉", phone="13920001989", xz="业主", sfz="110122198702051110", lyxx="1号楼 2单元 301", operate="编辑 详情", status="已缴费"})
	table.insert(list_item_data, {name="黄蓉", phone="13920001989", xz="业主", sfz="110122198702051110", lyxx="1号楼 2单元 301", operate="编辑 详情", status="已缴费"})
	table.insert(list_item_data, {name="黄蓉", phone="13920001989", xz="业主", sfz="110122198702051110", lyxx="1号楼 2单元 301", operate="编辑 详情", status="已缴费"})
	table.insert(list_item_data, {name="黄蓉", phone="13920001989", xz="业主", sfz="110122198702051110", lyxx="1号楼 2单元 301", operate="编辑 详情", status="已缴费"})
	table.insert(list_item_data, {name="黄蓉", phone="13920001989", xz="业主", sfz="110122198702051110", lyxx="1号楼 2单元 301", operate="编辑 详情", status="已缴费"})
	table.insert(list_item_data, {name="黄蓉", phone="13920001989", xz="业主", sfz="110122198702051110", lyxx="1号楼 2单元 301", operate="编辑 详情", status="已缴费"})
	table.insert(list_item_data, {name="黄蓉", phone="13920001989", xz="业主", sfz="110122198702051110", lyxx="1号楼 2单元 301", operate="编辑 详情", status="已缴费"})
	table.insert(list_item_data, {name="黄蓉", phone="13920001989", xz="业主", sfz="110122198702051110", lyxx="1号楼 2单元 301", operate="编辑 详情", status="已缴费"})
	table.insert(list_item_data, {name="黄蓉", phone="13920001989", xz="业主", sfz="110122198702051110", lyxx="1号楼 2单元 301", operate="编辑 详情", status="已缴费"})
	
	self:InsertItemList(list_item_data, true)
	
end

function LC_OnListItemClick(self)

end