local json = require('json')

local json_data = '{ "error_msg": "成功", "result": { "service_list": [ { "id": 3, "name": "更换", "service": [] }, { "id": 2, "name": "维修", "service": [ { "area_code": "010", "content": "厂家定价", "id": 8, "name": " 防盗门", "pid": 2, "telphone": "62257583" }, { "area_code": "010", "content": "120元/套", "id": 7, "name": "车位", "pid": 2, "telphone": "59886709" }, { "area_code": "010", "content": "实际消耗", "id": 5, "name": "电路维修", "pid": 2, "telphone": "59883939" }, { "area_code": null, "content": "免费", "id": 6, "name": "电梯维修", "pid": 2, "telphone": "13810012120" } ] }, { "id": 1, "name": "水路疏通", "service": [ { "area_code": "010", "content": "80元/把", "id": 9, "name": "门锁", "pid": 3, "telphone": "62222222" } ] } ], "stime": 1404985646 }, "ret": 0 }'

local table_service = nil

function OnInitControl(self)
	local attr = self:GetAttribute()
	local bkg = self:GetControlObject("bkg")
	--bkg:SetTextureID(attr.BorderTexture)
end

function LB_Service_OnInitControl(self)
	self:InsertColumn("service", 100, "服务类型", "left", "center", 5, true, 120)
	local list_item_data = {
		{service = "家电维修"},
		{service = "蔬菜水果"},
		{service = "干洗"},
		{service = "饮用水"},
		{service = "宽带服务"},
		{service = "烟酒饮料"},
	}
	self:InsertItemList(list_item_data, true)
	--XLMessageBox(json_data)
	local table_data = json.decode(json_data)
	local service_list = table_data.result.service_list
	--XLMessageBox(table_data['ret'])
end

function LC_OnListItemClick(self, event, itemObj, x, y, flags)
	local obj = self:GetOwnerControl():GetControlObject("tableview.sub.service.list")
	local list_item_data = {}
	if itemObj:GetData().service == "家电维修" then 
		table.insert(list_item_data, {service="电视", complain="1"})
		table.insert(list_item_data, {service="电冰箱", complain="3"})
		table.insert(list_item_data, {service="空调移机", complain="0"})
		table.insert(list_item_data, {service="空调加氟", complain="0"})
		table.insert(list_item_data, {service="电脑维修", complain="0"})
		table.insert(list_item_data, {service="楼宇门禁", complain="0"})
	elseif itemObj:GetData().service == "蔬菜水果" then 
		for i = 0, 10 do
			table.insert(list_item_data, {service="苹果", complain="10"})
		end
	elseif itemObj:GetData().service == "干洗" then
		for i = 0, 20 do
			table.insert(list_item_data, {service="羽绒服", complain="10"})
		end		
	elseif itemObj:GetData().service == "饮用水" then
	
	elseif itemObj:GetData().service == "宽带服务" then
	
	elseif itemObj:GetData().service == "干洗" then
	
	elseif itemObj:GetData().service == "烟酒饮料" then
	
	end
	obj:ClearItems()
	obj:InsertItemList(list_item_data, true)
	
end

function LB_SubService_OnInitControl(self)
	self:InsertColumn("service", 140, "详细分类", "left", "center", 5, true, 80)
	self:InsertColumn("complain", 100, "投诉量", "left", "center", 5, true, 60)
	
	local list_item_data = {}
	table.insert(list_item_data, {service="电视", complain="1"})
	table.insert(list_item_data, {service="电冰箱", complain="3"})
	table.insert(list_item_data, {service="空调移机", complain="0"})
	table.insert(list_item_data, {service="空调加氟", complain="0"})
	table.insert(list_item_data, {service="电脑维修", complain="0"})
	table.insert(list_item_data, {service="楼宇门禁", complain="0"})
	local obj = self:GetOwnerControl():GetControlObject("tableview.sub.service.list")
	obj:ClearItems()
	obj:InsertItemList(list_item_data, true)
end

function LB_InfoService_OnInitControl(self)
	self:InsertColumn("complain_user", 170, "投诉人", "left", "center", 5, true, 80)
	self:InsertColumn("complain_time", 140, "投诉时间", "left", "center", 5, true, 60)
	
	local list_item_data = {}
	table.insert(list_item_data, {complain_user="白*西", complain_time="2014-05-22 13:24"})
	local obj = self:GetOwnerControl():GetControlObject("tableview.info.service.list")
	obj:ClearItems()
	obj:InsertItemList(list_item_data, true)
end

function LC_OnInfoListItemClick(self, event, itemObj, x, y, flags)
	local obj = self:GetOwnerControl():GetControlObject("edit.content")
	if itemObj:GetData().complain_user == "白*西" then 
		obj:SetText("头天订水，竟然第二天才送来，说是下班了，太夸张了")
	elseif itemObj:GetData().complain_user == "杨*白" then 
		obj:SetText("什么乱七八糟的")
	elseif itemObj:GetData().complain_user == "白沙" then 
		obj:SetText("好吧")
	end
end

function LC_OnSubListItemClick(self, event, itemObj, x, y, flags)
	local obj = self:GetOwnerControl():GetControlObject("tableview.info.service.list")
	local list_item_data = {}
	if itemObj:GetData().service == "电视" then 
		table.insert(list_item_data, {complain_user="白*西", complain_time="2014-05-22 13:24"})
	elseif itemObj:GetData().service == "电冰箱" then 
		table.insert(list_item_data, {complain_user="杨*白", complain_time="2014-03-22 13:24"})
		table.insert(list_item_data, {complain_user="白沙", complain_time="2014-05-12 13:24"})
		table.insert(list_item_data, {complain_user="杨*白", complain_time="2014-03-22 13:24"})
	end
	
	obj:ClearItems()
	obj:InsertItemList(list_item_data, true)
end