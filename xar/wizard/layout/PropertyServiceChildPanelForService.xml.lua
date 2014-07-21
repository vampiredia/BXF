local json_data = '{ "error_msg": "成功", "result": { "service_list": [ { "id": 2, "name": "蔬菜水果", "service": [] }, { "id": 1, "name": "家电维修", "service": [ { "area_code": null, "content": "50元/台", "id": 8, "name": "空调加氟", "pid": 1, "telphone": "13810030293" }, { "area_code": "010", "content": "30元/个", "id": 9, "name": "电脑维修", "pid": 1, "telphone": "8222222" }, { "area_code": null, "content": "无上门费", "id": 5, "name": "电视", "pid": 1, "telphone": "18601082187" }, { "area_code": null, "content": "无上门费", "id": 6, "name": "电冰箱", "pid": 1, "telphone": "13898712120" }, { "area_code": null, "content": "无上们分", "id": 7, "name": "空调移机", "pid": 1, "telphone": "13827362819" } ] }, { "id": 11, "name": "烟酒饮料", "service": [] }, { "id": 10, "name": "宽带服务", "service": [] }, { "id": 4, "name": "饮用水", "service": [] }, { "id": 2, "name": "蔬菜水果", "service": [] } ], "stime": 1405328297 }, "ret": 0 }'
local table_service = nil
local json = require('json')

function OnInitControl(self)
	local attr = self:GetAttribute()
	local bkg = self:GetControlObject("bkg")
	bkg:SetTextureID(attr.BorderTexture)
end

function Get_PropertyServiceInfo(self)
	local httpclient = XLGetObject("Whome.HttpCore.Factory"):CreateInstance()
	httpclient:AttachResultListener(
		function(result) 
			local response = json.decode(result)
			if response['ret'] == 0 then
				table_service = response
				-- 添加一级菜单
				local objControl = self:GetControlObject("tableview.service.list")
				local service_list = response['result']['service_list']
				objControl:ClearItems()
				objControl:InsertItemList(service_list, true)
				-- 添加二级菜单， 默认table中index=1
				local objSubControl = self:GetControlObject("tableview.sub.service.list")
				local sub_service_list = service_list[1]['service']
				objSubControl:ClearItems()
				objSubControl:InsertItemList(sub_service_list, true)
			end
		end
	)
	url = "/service/life?action=get_life_list"
	httpclient:Perform(url, "GET", "")	
end

function LB_Service_OnInitControl(self)
	self:InsertColumn("name", 130, "服务类型", "left", "center", 5, true, 130)
	
	--AsynCall(function() self:GetOwnerControl():Get_PropertyServiceInfo() end )
end

function LB_SubService_OnInitControl(self)
	self:InsertColumn("name", 80, "详细分类", "left", "center", 5, true, 80)
	self:InsertColumn("content", 315, "收费标准", "left", "center", 5, true, 130)
	self:InsertColumn("telphone", 120, "联系电话", "left", "center", 5, true, 120)
end

function LC_OnListItemClick(self, event, itemObj, x, y, flags)
	if table_service == nil then
		return
	end
	
	local obj = self:GetOwnerControl():GetControlObject("tableview.sub.service.list")
	local service_list = table_service['result']['service_list']
	for i=1, #service_list do
		if service_list[i]['id'] == itemObj:GetData().id then
			obj:ClearItems()
			obj:InsertItemList(service_list[i]['service'], true)
			break
		end
	end
end