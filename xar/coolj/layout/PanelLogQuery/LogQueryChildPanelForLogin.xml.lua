function OnInitControl(self)
	local attr = self:GetAttribute()
	local bkg = self:GetControlObject("bkg")
	--bkg:SetTextureID(attr.BorderTexture)
end

function CBA_OnInitControl(self)
	local attr = self:GetAttribute()
	attr.data = {}
	local temp_data = {"全部", "李天一", "李天二", "李天三"}
	for i,valid_time in ipairs(temp_data) do
		table.insert(attr.data, { IconResID = "", IconWidth = 0, LeftMargin = 10, TopMargin = 0, Text = valid_time, Custom = nil, Func = nil })
	end
	self:SetText("全部")
end

function BTN_OnSelect(self)

end

function LB_OnInitControl(self)
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	local headerTable = {
		{HeaderItemId='user', ItemWidth=80, Text="管理员", TextLeftOffset=7, TextHalign="left", SubItem=false, MaxSize=80, MiniSize=80, ShowSplitter=false, ShowSortIcon=false, IncludeNext=false, SortProperty=0},
		{HeaderItemId='user', ItemWidth=120, Text="登录时间", TextLeftOffset=7, TextHalign="left", SubItem=false, MaxSize=120, MiniSize=120, ShowSplitter=false, ShowSortIcon=false, IncludeNext=false, SortProperty=0},
		{HeaderItemId='user', ItemWidth=292, Text="操作内容", TextLeftOffset=7, TextHalign="left", SubItem=false, MaxSize=292, MiniSize=292, ShowSplitter=false, ShowSortIcon=false, IncludeNext=false, SortProperty=0},
		{HeaderItemId='user', ItemWidth=120, Text="登录IP", TextLeftOffset=7, TextHalign="left", SubItem=false, MaxSize=120, MiniSize=120, ShowSplitter=false, ShowSortIcon=false, IncludeNext=false, SortProperty=0},
		{HeaderItemId='user', ItemWidth=60, Text="操作", TextLeftOffset=7, TextHalign="left", SubItem=false, MaxSize=60, MiniSize=60, ShowSplitter=false, ShowSortIcon=false, IncludeNext=false, SortProperty=0}
	}
	table.foreach(headerTable, function(i, v) self:InsertColumn(v) end);
	self:ReloadHeader()
	
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	local datasource = objFactory:CreateUIObject(1, "LogInfo.DataSource")
	datasource:InitControl()
	local dataconverter = objFactory:CreateUIObject(2, "LogInfo.DataConverter")
	dataconverter:InitControl()
	self:SetDataSourceAndDataConverter(datasource, dataconverter)
	self:ReloadData()
end

function LB_OnHeaderItemPosChanged(self)

end

function LB_OnItemEvent(self, eventName, eventType, UserData, ItemObj)
	if eventType == "OnShowDetails" then
		MessageBox(nil, "查看操作详情", "日志内容：\n"..UserData)
	end
end

function GetLogInfo(self)
	-- load data for root service
	local request = function(ret, msg, result)
		if ret == 0 then
			local lb_service = self:GetControlObject("lb.log")
			lb_service:GetDataSource():SetData(result['list'])
			lb_service:ReloadData()
		else
			AddNotify(self, msg, 5000)
		end
	end
	HttpRequest("/api/log?action=login_info", "GET", "", request)
end