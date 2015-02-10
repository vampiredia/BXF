function OnInitControl(self)
	local attr = self:GetAttribute()
	local bkg = self:GetControlObject("bkg")
	--bkg:SetTextureID(attr.BorderTexture)
end


function LC_OnInfoInitControl(self)
	self:InsertColumn("info", 330, "详情", "left", "center", 5, true, 330)
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

function OnClick_Copy(self)
	local info = self:GetOwnerControl():GetControlObject("edit.info")
	info:Copy()
	AddNotify(self, "复制成功", 3000)
end

function LBN_OnInitControl(self)
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	local headerTable = {
		{HeaderItemId='title', ItemWidth=220, Text="主题", TextLeftOffset=7, TextHalign="left", SubItem=false, MaxSize=220, MiniSize=220, ShowSplitter=true, ShowSortIcon=false, IncludeNext=false, SortProperty=0},
		{HeaderItemId='s_time', ItemWidth=110, Text="消息时间", TextLeftOffset=7, TextHalign="left", SubItem=false, MaxSize=110, MiniSize=110, ShowSplitter=true, ShowSortIcon=false, IncludeNext=false, SortProperty=0}
	}
	table.foreach(headerTable, function(i, v) self:InsertColumn(v) end);
	self:ReloadHeader()
	
	local datasource = objFactory:CreateUIObject(1, "NoticePublic.DataSource")
	datasource:InitControl()
	local dataconverter = objFactory:CreateUIObject(2, "NoticePublic.DataConverter")
	dataconverter:InitControl()
	self:SetDataSourceAndDataConverter(datasource, dataconverter)
	self:ReloadData()
end

function LBN_OnHeaderItemPosChanged(self, event, isDrag, GridInfoList)
	if isDrag == true then
		self:GetTableViewObj():UpdateItemInfo(isDrag, GridInfoList)
	end
end

function LBN_OnItemEvent(self, eventName, eventType, UserData, ItemObj)
	if eventType == "OnSelect" then
		self:GetOwnerControl():GetControlObject("edit.info"):SetText(UserData["content"])
	end
end

function Get_NoticePublicInfo(self)
	-- load data for root service
	local request = function(ret, msg, result)
		if ret == 0 then
			local lb_service = self:GetControlObject("lb.notice")
			lb_service:GetDataSource():SetData(result['list'])
			lb_service:ReloadData()
		else
			AddNotify(self, msg, 5000)
		end
	end
	HttpRequest("/api/message/system?action=get_list", "GET", "", request)
end