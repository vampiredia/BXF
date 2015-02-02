-------------------------------------------------------------------------------
-- global values for table list view
-------------------------------------------------------------------------------
local table_service = nil
local json = require('json')

-------------------------------------------------------------------------------
function OnInitControl(self)
	local attr = self:GetAttribute()
	local bkg = self:GetControlObject("bkg")
	
	self:GetControlObject("Sub.Services"):SetVisible(false)
	self:GetControlObject("Sub.Services"):SetChildrenVisible(false)
end

function Get_PropertyServiceInfo(self)
	local lb_service = self:GetControlObject("listbox.service")
	local httpclient = XLGetObject("Whome.HttpCore.Factory"):CreateInstance()
	httpclient:AttachResultListener(
		function(result, code) 
			XLMessageBox(code)
			local response = json.decode(result)
			if response['ret'] == 0 then
				--GlobalDataTable = response['result']['service_list']
				local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
				local datasource = objFactory:CreateUIObject(1, "Service.DataSource")
				datasource:InitControl(response['result']['service_list'])
				local dataconverter = objFactory:CreateUIObject(2, "Service.DataConverter")
				dataconverter:InitControl()
				lb_service:SetDataSourceAndDataConverter(datasource, dataconverter)
				lb_service:ReloadData()
			end
		end
	)
	local param = ""
	local url = "/api/community/services?action=get_root_list"
	httpclient:Perform(url, "GET", param)
end

function LBS_OnInitControl(self)
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	local headerTable = {
		{HeaderItemId='title', ItemWidth=200, Text="服务分类", TextLeftOffset=7, TextHalign="left", SubItem=false, MaxSize=200, MiniSize=200, ShowSplitter=false, ShowSortIcon=false, IncludeNext=false, SortProperty=0}
	}
	table.foreach(headerTable, function(i, v) self:InsertColumn(v) end);
	self:ReloadHeader()
end

function LBS_OnHeaderItemPosChanged(self, event, isDrag, GridInfoList)
	if isDrag == true then
		self:GetTableViewObj():UpdateItemInfo(isDrag, GridInfoList)
	end
end

function LBS_OnItemEvent(self, eventName, eventType, UserData, ItemObj)
	if eventType == "OnSelect" then
		local owner = self:GetOwnerControl()
		owner:GetControlObject("Sub.Services"):SetVisible(true)
		owner:GetControlObject("Sub.Services"):SetChildrenVisible(true)
		
		local httpclient = XLGetObject("Whome.HttpCore.Factory"):CreateInstance()
		httpclient:AttachResultListener(
			function(result) 
				local response = json.decode(result)
				if response['ret'] == 0 then
					local lbs_service = self:GetOwnerControl():GetControlObject("listbox.subservices")
					lbs_service:GetDataSource():SetData(response['result']['service_list'])
					lbs_service:ReloadData()
					lbs_service:GetAttribute().PID = UserData['id']
				end
			end
		)
		local param = ""
		local url = "/api/community/services?action=get_info_list&id="..UserData['id']
		httpclient:Perform(url, "GET", param)
	end
end

function LBSS_OnInitControl(self)
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	local headerTable = {
		{HeaderItemId='title', ItemWidth=88, Text="服务标题", TextLeftOffset=7, TextHalign="left", SubItem=false, MaxSize=88, MiniSize=88, ShowSplitter=true, ShowSortIcon=false, IncludeNext=false, SortProperty=0},
		{HeaderItemId='content', ItemWidth=202, Text="服务描述", TextLeftOffset=7, TextHalign="left", SubItem=false, MaxSize=202, MiniSize=202, ShowSplitter=true, ShowSortIcon=false, IncludeNext=false, SortProperty=0},
		{HeaderItemId='contact', ItemWidth=101, Text="联系电话", TextLeftOffset=7, TextHalign="left", SubItem=false, MaxSize=101, MiniSize=101, ShowSplitter=true, ShowSortIcon=false, IncludeNext=false, SortProperty=0},
		{HeaderItemId='other', ItemWidth=80, Text="", TextLeftOffset=2, TextHalign="left", SubItem=false, MaxSize=300, MiniSize=40, ShowSplitter=true, ShowSortIcon=false, IncludeNext=false, SortProperty=1}
	}
	table.foreach(headerTable, function(i, v) self:InsertColumn(v) end);
	self:ReloadHeader()
	
	local datasource = objFactory:CreateUIObject(1, "SubService.DataSource")
	datasource:InitControl()
	local dataconverter = objFactory:CreateUIObject(2, "SubService.DataConverter")
	dataconverter:InitControl()
	self:SetDataSourceAndDataConverter(datasource, dataconverter)
	self:ReloadData()
end

function LBSS_OnHeaderItemPosChanged(self, event, isDrag, GridInfoList)
	if isDrag == true then
		self:GetTableViewObj():UpdateItemInfo(isDrag, GridInfoList)
	end
end

function LBSS_OnItemEvent(self, eventName, eventType, UserData, ItemObj)
	--XLMessageBox(eventType)
	if eventType == "OnDelDetails" then
		ret = MessageBox(nil, "删除服务项目", "确认删除服务项目 "..ItemObj:GetName())
		if ret == 1 then 
			local httpclient = XLGetObject("Whome.HttpCore.Factory"):CreateInstance()
			httpclient:AttachResultListener(
				function(result) 
					local response = json.decode(result)
					if response['ret'] == 0 then
						local lbs_service = self:GetOwnerControl():GetControlObject("listbox.subservices")
						lbs_service:GetDataSource():SetData(response['result']['service_list'])
						lbs_service:ReloadData()
						lbs_service:GetAttribute().PID = UserData['pid']
					end
				end
			)
			local param = "action=del_info&id="..UserData['id'].."&pid="..UserData['pid']
			local url = "/api/community/services"
			httpclient:Perform(url, "POST", param)
		end
	elseif eventType == "OnEditDetails" then
		ret = NewSubServiceBox(nil, "修改服务项目", 'edit_community_service_info', UserData)
		if ret == 1 then
			self:GetOwnerControl():Get_SubServiceInfo(UserData['pid'])
		end
	elseif eventType == "OnDragDetails" then
	
	end
end

function Btn_NewService(self)
	NewServiceBox(nil, "新建分类", '', '')
end

function Btn_NewSubService(self)
	pid = self:GetOwnerControl():GetControlObject('listbox.subservices'):GetAttribute().PID
	ret = NewSubServiceBox(nil, "添加服务项目", 'add_community_service_info', {pid=pid})
	if ret == 1 then
		self:GetOwnerControl():Get_SubServiceInfo(pid)
	end
end

function Get_SubServiceInfo(self, pid)
	local httpclient = XLGetObject("Whome.HttpCore.Factory"):CreateInstance()
	httpclient:AttachResultListener(
		function(result) 
			local response = json.decode(result)
			if response['ret'] == 0 then
				local lbs_service = self:GetControlObject("listbox.subservices")
				lbs_service:GetDataSource():SetData(response['result']['service_list'])
				lbs_service:ReloadData()
				lbs_service:GetAttribute().PID = pid
			end
		end
	)
	local param = ""
	local url = "/api/community/services?action=get_info_list&id="..pid
	httpclient:Perform(url, "GET", param)
end