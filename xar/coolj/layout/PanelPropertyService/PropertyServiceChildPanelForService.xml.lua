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
	-- load data for root service
	local request = function(ret, msg, result)
		if ret == 0 then
			local lb_service = self:GetControlObject("listbox.service")
			lb_service:GetDataSource():SetData(result['service_list'])
			lb_service:ReloadData()
		else
			AddNotify(self, msg, 5000)
		end
	end
	HttpRequest("/api/community/services?action=get_root_list", "GET", "", request)
end

function LBS_OnInitControl(self)
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	local headerTable = {
		{HeaderItemId='title', ItemWidth=200, Text="服务分类", TextLeftOffset=7, TextHalign="left", SubItem=false, MaxSize=200, MiniSize=200, ShowSplitter=false, ShowSortIcon=false, IncludeNext=false, SortProperty=0}
	}
	table.foreach(headerTable, function(i, v) self:InsertColumn(v) end);
	self:ReloadHeader()
	
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	local datasource = objFactory:CreateUIObject(1, "Service.DataSource")
	datasource:InitControl()
	local dataconverter = objFactory:CreateUIObject(2, "Service.DataConverter")
	dataconverter:InitControl()
	self:SetDataSourceAndDataConverter(datasource, dataconverter)
	self:ReloadData()
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
		
		local request = function(ret, msg, result)
			if ret == 0 then
				local lbs_service = self:GetOwnerControl():GetControlObject("listbox.subservices")
				lbs_service:GetDataSource():SetData(result['service_list'])
				lbs_service:ReloadData()
				lbs_service:GetAttribute().PID = UserData['id']
			else
				AddNotify(self, msg, 5000)
			end
		end
		HttpRequest("/api/community/services?action=get_info_list&id="..UserData['id'], "GET", "", request)
	elseif eventType == "OnDelDetails" then
		ret = MessageBox(nil, "删除服务项目", "确认删除服务项目 "..ItemObj:GetName())
		if ret == 1 then
			local request = function(ret, msg, result)
				if ret == 0 then
					self:GetOwnerControl():Get_PropertyServiceInfo()
				else
					AddNotify(self, msg, 5000)
				end
			end
			local param = "action=del_root&id="..UserData['id']
			HttpRequest("/api/community/services", "POST", param, request)
		end
	elseif eventType == "OnEditDetails" then
		ret = NewServiceBox(nil, "修改分类", 'edit_property_service_root', UserData)
		if ret == 1 then
			self:GetOwnerControl():Get_PropertyServiceInfo()
		end
	elseif eventType == "OnDragDetails" then
	
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
			local request = function(ret, msg, result)
				if ret == 0 then
					local lbs_service = self:GetOwnerControl():GetControlObject("listbox.subservices")
					lbs_service:GetDataSource():SetData(result['service_list'])
					lbs_service:ReloadData()
					lbs_service:GetAttribute().PID = UserData['pid']
				else
					AddNotify(self, msg, 5000)
				end
			end
			local param = "action=del_info&id="..UserData['id'].."&pid="..UserData['pid']
			HttpRequest("/api/community/services", "POST", param, request)
		end
	elseif eventType == "OnEditDetails" then
		ret = NewSubServiceBox(nil, "修改服务项目", 'edit_property_service_info', UserData)
		if ret == 1 then
			self:GetOwnerControl():Get_SubServiceInfo(UserData['pid'])
		end
	elseif eventType == "OnDragDetails" then
	
	end
end

function Btn_NewService(self)
	ret = NewServiceBox(nil, "新建分类", 'add_property_service_root', {})
	if ret == 1 then
		self:GetOwnerControl():Get_PropertyServiceInfo()
	end
end

function Btn_NewSubService(self)
	pid = self:GetOwnerControl():GetControlObject('listbox.subservices'):GetAttribute().PID
	ret = NewSubServiceBox(nil, "添加服务项目", 'add_property_service_info', {pid=pid})
	if ret == 1 then
		self:GetOwnerControl():Get_SubServiceInfo(pid)
	end
end

function Get_SubServiceInfo(self, pid)	
	local request = function(ret, msg, result)
		if ret == 0 then
			local lbs_service = self:GetControlObject("listbox.subservices")
			lbs_service:GetDataSource():SetData(result['service_list'])
			lbs_service:ReloadData()
			lbs_service:GetAttribute().PID = pid
		else
			AddNotify(self, msg, 5000)
		end
	end
	local param = ""
	local url = "/api/community/services?action=get_info_list&id="..pid
	HttpRequest(url, "GET", param, request)
end

function OnClick_UpdateData(self)
	self:GetOwnerControl():Get_PropertyServiceInfo()
	local lbs_service = self:GetOwnerControl():GetControlObject("listbox.subservices")
	lbs_service:GetDataSource():SetData({})
	lbs_service:ReloadData()
end