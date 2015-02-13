local json = require('json')
local table_data = {}

local headerTable = {
	{HeaderItemId='id', ItemWidth=60, Text="编号", TextLeftOffset=2, TextHalign="left", SubItem=false, MaxSize=300, MiniSize=40, ShowSplitter=true, ShowSortIcon=false, IncludeNext=false, SortProperty=1},
	{HeaderItemId='title', ItemWidth=240, Text="通知标题", TextLeftOffset=2, TextHalign="left", SubItem=false, MaxSize=300, MiniSize=40, ShowSplitter=true, ShowSortIcon=true, IncludeNext=false, SortProperty=1},
	{HeaderItemId='author', ItemWidth=80, Text="提交人", TextLeftOffset=2, TextHalign="left", SubItem=false, MaxSize=300, MiniSize=40, ShowSplitter=true, ShowSortIcon=false, IncludeNext=false, SortProperty=1},
	{HeaderItemId='s_time', ItemWidth=120, Text="提交日期", TextLeftOffset=2, TextHalign="left", SubItem=false, MaxSize=300, MiniSize=40, ShowSplitter=true, ShowSortIcon=false, IncludeNext=false, SortProperty=1},
	{HeaderItemId='status', ItemWidth=60, Text="状态", TextLeftOffset=2, TextHalign="left", SubItem=false, MaxSize=300, MiniSize=40, ShowSplitter=true, ShowSortIcon=false, IncludeNext=false, SortProperty=1},
	{HeaderItemId='other', ItemWidth=60, Text="", TextLeftOffset=2, TextHalign="left", SubItem=false, MaxSize=300, MiniSize=40, ShowSplitter=true, ShowSortIcon=false, IncludeNext=false, SortProperty=1}
}

function OnInitControl(self)
	local attr = self:GetAttribute()
	attr.Classify = 27
	local bkg = self:GetControlObject("bkg")
	--bkg:SetTextureID(attr.BorderTexture)
	
	local controlObj = self:GetOwnerControl()
	local oldObj = self:GetObject("new.notice.page")
	oldObj:SetVisible(false)
	oldObj:SetChildrenVisible(false)
	
	oldObj = self:GetObject("history.notice.page")
	oldObj:SetVisible(false)
	oldObj:SetChildrenVisible(false)
	
	oldObj = self:GetObject("info.notice.page")
	oldObj:SetVisible(false)
	oldObj:SetChildrenVisible(false)
end

function OnClickNewNotice(self)
	PageChange(self, "main.page", "new.notice.page")
	self:GetOwnerControl():PublishInit()
end

function OnClickNewNoticePageToMainPage(self)
	PageChange(self, "new.notice.page", "main.page")
end

function OnClickNoticeHistory(self)

	--MessageBox(nil, "业主消息", "8号楼1单元402室 杨百 正在联系电路维修热线！ \n联系电话：13811152323")
	--AddNotifyBox("业主信息", "8号楼1单元402室 杨百 正在联系电路维修热线！\n联系电话：13811152323", "Owner")
	--AddNotifyBox("救助信息", "16号楼3单元708室 张乐 发出救助信息！\n紧急联系人：张小宝\n紧急联系电话：13811153235", "OnCall")
	
	
	PageChange(self, "main.page", "history.notice.page")
	self:GetOwnerControl():GetData()
	
end

function OnClickHistoryNoticePageToMainPage(self)
	PageChange(self, "history.notice.page", "main.page")
end

function OnInitCBControl(self)
	local attr = self:GetAttribute()
	attr.data = {
		{ IconResID = "", IconWidth = 0, LeftMargin = 10, TopMargin = 0, Text = "全体业主", Custom = nil, Func = nil },
	}
	self:SetText("全体业主")
end

function OnMainPageVisibleChange(self, visible)
	--self:SetVisible(visible)
	self:SetChildrenVisible(visible)
end

function PageChange(self, old, new)
	local controlObj = self:GetOwnerControl()
	
	local oldObj = controlObj:GetObject(old)
	oldObj:SetVisible(false)
	oldObj:SetChildrenVisible(false)
	
	local newObj = controlObj:GetObject(new)
	newObj:SetVisible(true)
	newObj:SetChildrenVisible(true)
end

function LB_OnInitControl(self)
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	table.foreach(headerTable, function(i, v) self:InsertColumn(v) end);
	self:ReloadHeader()
	
	local datasource = objFactory:CreateUIObject(1, "WHome.DataSource")
	datasource:InitControl()
	local dataconverter = objFactory:CreateUIObject(2, "WHome.DataConverter")
	dataconverter:InitControl()
	self:SetDataSourceAndDataConverter(datasource, dataconverter)
	self:ReloadData()
end

function OnClickNoticePublishWarning(self)
	
end

function BTN_PublishNotice(self)
	local owner = self:GetOwnerControl()
	local html = owner:GetHtml()
	local content = owner:GetContent()
	local classify = owner:GetAttribute().Classify
	local title = owner:GetControlObject("edit.notice.title"):GetText()
	local httpclient = XLGetObject("Whome.HttpCore.Factory"):CreateInstance()
	
	local request = function(ret, msg, result)
		if ret == 0 then
			AddNotify(self, "发布成功", 3000)
		else
			AddNotify(self, msg, 3000)
		end
	end
	local param = "action=add_info&title="..title.."&html="..httpclient:EscapeParam(html).."&content="..httpclient:EscapeParam(content).."&classify="..classify
	HttpRequest("/api/message/notice", "POST", param, request)
end
function OnClickNoticePublishWarningInitControl(self)
	local l,t,r,b = self:GetTextPos()
	self:SetTextPos(l+10, t, r-l, b-t)
end

function LB_OnHeaderItemPosChanged(self, event, isDrag, GridInfoList)
	if isDrag == true then
		self:GetTableViewObj():UpdateItemInfo(isDrag, GridInfoList)
	end
end

function LB_OnItemEvent(self, eventName, eventType, UserData, ItemObj)
	if eventType == "OnShowDetails" then
		PageChange(self, "history.notice.page", "info.notice.page")
		local web = self:GetOwnerControl():GetControlObject("web.info")
		web:Navigate("http://www.coolj.com/api/message/notice?action=info&id="..UserData["id"])
		local attr = self:GetOwnerControl():GetAttribute()
		attr.SelectID = UserData["id"]
	end
end

function GetData(self)
	local request = function(ret, msg, result)
		if ret == 0 then
			local obj = self:GetControlObject("lb.result")
			obj:GetDataSource():SetData(result['msg_list'])
			obj:ReloadData()
		else
			AddNotify(self, msg, 3000)
		end
	end
	local param = ""
	HttpRequest("/api/message/notice?action=msg_list", "GET", param, request)
end

function Web_OnInitControl(self)

end

function Prev_OnClick(self)
	AddNotify(self, "开发中", 3000)
end

function GetContent(self)
	local web = self:GetControlObject("web")
	local iwebbrowser2 = web:GetRawWebBrowser()
	local osshell = XLGetObject("CoolJ.OSShell")
	
	local html = osshell:DoScript(iwebbrowser2, "Text")
	return html
end

function ClearContent(self)
	local web = self:GetControlObject("web")
	local iwebbrowser2 = web:GetRawWebBrowser()
	local osshell = XLGetObject("CoolJ.OSShell")
	osshell:DoScript(iwebbrowser2, "ClearAll")
end

function GetHtml(self)
	local web = self:GetControlObject("web")
	local iwebbrowser2 = web:GetRawWebBrowser()
	local osshell = XLGetObject("CoolJ.OSShell")
	
	local html = osshell:DoScript(iwebbrowser2, "Html")
	return html
end

function PublishInit(self)
	self:GetControlObject("edit.notice.title"):SetText("")
	self:ClearContent()
end

function OnClickInfoNoticePageToHistoryPage(self)
	PageChange(self, "info.notice.page", "history.notice.page")
	self:GetOwnerControl():GetData()
end

function OnDelDetails(self)
	ret = MessageBox(nil, "删除须知", "删除该通知后，移动客户端用户手动或自动刷新后，该通知则会从列表中消息。\n点击确认后删除该条内容")
	if ret == 1 then
		local request = function(ret, msg, result)
			if ret == 0 then
				AddNotify(self, "删除成功", 3000)
				PageChange(self, "info.notice.page", "history.notice.page")
				self:GetOwnerControl():GetData()
			else
				AddNotify(self, msg, 5000)
			end
		end
		local attr = self:GetOwnerControl():GetAttribute()
		local param = "action=del_info&id="..attr.SelectID
		HttpRequest("/api/message/notice", "POST", param, request)		
	end
end