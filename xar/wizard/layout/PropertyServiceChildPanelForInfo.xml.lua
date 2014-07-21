local table_service = nil
local json = require('json')

function OnInitControl(self)
	local attr = self:GetAttribute()
	local bkg = self:GetControlObject("bkg")
	bkg:SetTextureID(attr.BorderTexture)
end

function LC_Info_OnInitControl(self)
	self:InsertColumn("name", 110, "信息类型", "left", "center", 5, true, 110)
	self:InsertColumn("telphone", 210, "详细", "left", "center", 5, true, 140)
	
	--AsynCall(function() self:GetOwnerControl():Get_PropertyServiceInfo() end )
end

function LC_Address_OnInitControl(self)
	--self:InsertColumn("address", 330, "通信地址", "left", "left", 5, true, 200)
end

function LC_Pay_OnInitControl(self)
	--self:InsertColumn("payinfo", 330, "缴费账号", "left", "left", 5, true, 200)
end

function Get_PropertyServiceInfo(self)
	local httpclient = XLGetObject("Whome.HttpCore.Factory"):CreateInstance()
	httpclient:AttachResultListener(
		function(result) 
			local response = json.decode(result)
			if response['ret'] == 0 then
				table_service = response
				-- 添加联系信息
				local objControl = self:GetControlObject("tabview.info.list")
				local service_list = response['result']['service']
				objControl:ClearItems()
				objControl:InsertItemList(service_list, true)
				-- 添加地址信息
				local objAddressControl = self:GetControlObject("edit.address")
				objAddressControl:SetText(response['result']['address'])
			end
		end
	)
	url = "/service/community?action=get_estate_contact_list"
	httpclient:Perform(url, "GET", "")		
end