local table_service = nil
local json = require('json')

function OnInitControl(self)
	local attr = self:GetAttribute()
	local bkg = self:GetControlObject("bkg")
	bkg:SetTextureID(attr.BorderTexture)
end

function LB_SubService_OnInitControl(self)
	self:InsertColumn("name", 80, "详细分类", "left", "center", 5, true, 80)
	self:InsertColumn("content", 250, "收费标准", "left", "center", 5, true, 140)
	self:InsertColumn("telphone", 110, "联系电话", "left", "center", 5, true, 120)
	self:InsertColumn("complain", 60, "投诉量", "left", "center", 5, true, 60)
end

function LC_OnListItemClick(self, event, itemObj, x, y, flags)
	if table_service == nil then
		return
	end
	
	local obj = self:GetOwnerControl():GetControlObject("tableview.sub.service.list")
	local service_list = table_service['result']['service_list']
	for i=1, #service_list do
		if service_list[i]['id'] == itemObj:GetData().id then
			local sub_service_list = service_list[i]['service']
			for j=1, #sub_service_list do
				sub_service_list[j]['complain'] = 0
			end
			obj:ClearItems()
			obj:InsertItemList(sub_service_list, true)
			break
		end
	end
end

function LB_Service_OnInitControl(self)
	self:InsertColumn("name", 130, "服务类型", "left", "center", 5, true, 130)
	
	--AsynCall(function() self:GetOwnerControl():Get_CommunityServiceInfo() end )
end

function Get_CommunityServiceInfo(self)
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
	url = "/service/jiazheng?action=get_jiazheng_list"
	httpclient:Perform(url, "GET", "")	
end