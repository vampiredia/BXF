function OnInitControl(self)
	local attr = self:GetAttribute()
	local bkg = self:GetControlObject("bkg")
	--bkg:SetTextureID(attr.BorderTexture)
end


function LC_OnInfoInitControl(self)
	self:InsertColumn("info", 330, "详情", "left", "center", 5, true, 330)
end

function LC_OnPublicInitControl(self)
	self:InsertColumn("title", 220, "主题", "left", "left", 5, true, 220)
	self:InsertColumn("date_time", 110, "消息时间", "left", "center", 5, true, 90)
	
	local list_item_data = {}
	table.insert(list_item_data, {title="征集物业上门服务信息", date_time="2014-02-03 08:45"})
	table.insert(list_item_data, {title="2月1日维护通知", date_time="2014-02-03 08:45"})
	table.insert(list_item_data, {title="关于社区服务板块调整通知", date_time="2014-02-03 08:45"})
	table.insert(list_item_data, {title="征集物业上门服务信息", date_time="2014-02-03 08:45"})
	table.insert(list_item_data, {title="2月1日维护通知", date_time="2014-02-03 08:45"})
	table.insert(list_item_data, {title="关于社区服务板块调整通知", date_time="2014-02-03 08:45"})
	table.insert(list_item_data, {title="征集物业上门服务信息", date_time="2014-02-03 08:45"})
	table.insert(list_item_data, {title="2月1日维护通知", date_time="2014-02-03 08:45"})
	table.insert(list_item_data, {title="关于社区服务板块调整通知", date_time="2014-02-03 08:45"})
	table.insert(list_item_data, {title="征集物业上门服务信息", date_time="2014-02-03 08:45"})
	table.insert(list_item_data, {title="2月1日维护通知", date_time="2014-02-03 08:45"})
	table.insert(list_item_data, {title="关于社区服务板块调整通知", date_time="2014-02-03 08:45"})
	
	self:InsertItemList(list_item_data, true)
end

function LC_OnListItemClick(self, event, itemObj, x, y, flags)
	
	local content = ""
	if itemObj:GetData().title == "征集物业上门服务信息" then 
		content = "征集物业上门服务信息"
	elseif itemObj:GetData().title == "2月1日维护通知" then 
		content = "您好！\n	由于沃家平台系统全面升级，特此通知"
	elseif itemObj:GetData().title == "关于社区服务板块调整通知" then
		content = "关于社区服务板块调整通知"
	end		
	local infoObj = self:GetOwnerControl():GetControlObject("edit.info")
	infoObj:SetText(content)
end