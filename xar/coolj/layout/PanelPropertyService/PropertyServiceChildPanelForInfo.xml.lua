
function OnInitControl(self)
	local attr = self:GetAttribute()
	local bkg = self:GetControlObject("bkg")
	--bkg:SetTextureID(attr.BorderTexture)
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
	HttpRequest("/api/community/vas?action=root_list", "GET", "", request)
end

function Get_SubServiceInfo(self, pid)
	if pid == nil then
		--AddNotify(self, "请先选择要添加的项目条目", 5000)
		local lbs_service = self:GetControlObject("listbox.subservices")
		lbs_service:GetDataSource():SetData({})
		lbs_service:ReloadData()
		lbs_service:GetAttribute().PID = nil
		return
	end
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
	local url = "/api/community/vas?action=info_list&id="..pid
	HttpRequest(url, "GET", param, request)
end

function OnClick_UpdateData(self)
	self:GetOwnerControl():Get_PropertyServiceInfo()
	local lbs_service = self:GetOwnerControl():GetControlObject("listbox.subservices")
	lbs_service:GetDataSource():SetData({})
	lbs_service:ReloadData()
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
		self:GetOwnerControl():Get_SubServiceInfo(UserData['id'])
	elseif eventType == "OnDelDetails" then
		ret = MessageBox(nil, "删除服务项目", "确认删除服务项目 "..ItemObj:GetName())
		if ret == 1 then
			local request = function(ret, msg, result)
				if ret == 0 then
					self:GetOwnerControl():Get_PropertyServiceInfo()
					self:GetOwnerControl():Get_SubServiceInfo()
				else
					AddNotify(self, msg, 5000)
				end
			end
			local param = "action=del_root&id="..UserData['id']
			HttpRequest("/api/community/vas", "POST", param, request)
		end
	elseif eventType == "OnEditDetails" then
		ret = ServiceVasBox(nil, "修改分类", 'edit_vas_root', UserData)
		if ret == 1 then
			self:GetOwnerControl():Get_PropertyServiceInfo()
		end
	end
end

function Btn_NewService(self)
	ret = ServiceVasBox(nil, "新建分类", 'add_vas_root', {})
	if ret == 1 then
		self:GetOwnerControl():Get_PropertyServiceInfo()
	end
end

function LBSS_OnInitControl(self)
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	local headerTable = {
		{HeaderItemId='title', ItemWidth=88, Text="服务内容", TextLeftOffset=7, TextHalign="left", SubItem=false, MaxSize=88, MiniSize=88, ShowSplitter=true, ShowSortIcon=false, IncludeNext=false, SortProperty=0},
		{HeaderItemId='content', ItemWidth=202, Text="标准描述", TextLeftOffset=7, TextHalign="left", SubItem=false, MaxSize=202, MiniSize=202, ShowSplitter=true, ShowSortIcon=false, IncludeNext=false, SortProperty=0},
		{HeaderItemId='contact', ItemWidth=101, Text="服务定价", TextLeftOffset=7, TextHalign="left", SubItem=false, MaxSize=101, MiniSize=101, ShowSplitter=true, ShowSortIcon=false, IncludeNext=false, SortProperty=0},
		{HeaderItemId='other', ItemWidth=80, Text="", TextLeftOffset=2, TextHalign="left", SubItem=false, MaxSize=300, MiniSize=40, ShowSplitter=true, ShowSortIcon=false, IncludeNext=false, SortProperty=1}
	}
	table.foreach(headerTable, function(i, v) self:InsertColumn(v) end);
	self:ReloadHeader()
	
	local datasource = objFactory:CreateUIObject(1, "SubVasService.DataSource")
	datasource:InitControl()
	local dataconverter = objFactory:CreateUIObject(2, "SubVasService.DataConverter")
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
	if eventType == "OnDelDetails" then
		ret = MessageBox(nil, "删除服务项目", "确认删除服务项目 "..ItemObj:GetName())
		if ret == 1 then
			local request = function(ret, msg, result)
				if ret == 0 then
					self:GetOwnerControl():Get_SubServiceInfo(UserData['pid'])
				else
					AddNotify(self, msg, 5000)
				end
			end
			local param = "action=del_info&id="..UserData['id']
			HttpRequest("/api/community/vas", "POST", param, request)
		end
	elseif eventType == "OnEditDetails" then
		ret = ServiceVasBox(nil, "修改服务项目", 'edit_vas_info', UserData)
		if ret == 1 then
			self:GetOwnerControl():Get_SubServiceInfo(pid)
		end
	end
end

function Btn_NewSubService(self)
	pid = self:GetOwnerControl():GetControlObject('listbox.subservices'):GetAttribute().PID
	if pid == nil then 
		AddNotify(self, "请先选择要添加的项目条目", 5000)
		return
	end
	ret = ServiceVasBox(nil, "添加服务项目", 'add_vas_info', {pid=pid})
	if ret == 1 then
		self:GetOwnerControl():Get_SubServiceInfo(pid)
	end
--[[
	local imagecore = XLGetObject("CoolJ.ImageCore")
	local bitmap = imagecore:LoadImage("http://192.168.1.9/img/627/388/65b56c60331387268a472cec615f4973/normal.png")
	
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	local newImageObject = objFactory:CreateUIObject("","ImageObject")
	newImageObject:SetBitmap(theBitmap)
	self:GetOwnerControl():AddChild(newImageObject)
	]]
end