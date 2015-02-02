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
	local bkg = self:GetControlObject("bkg")
	--bkg:SetTextureID(attr.BorderTexture)
	
	local controlObj = self:GetOwnerControl()
	local oldObj = self:GetObject("new.notice.page")
	oldObj:SetVisible(false)
	oldObj:SetChildrenVisible(false)
	
	oldObj = self:GetObject("history.notice.page")
	oldObj:SetVisible(false)
	oldObj:SetChildrenVisible(false)
end

function OnClickNewNotice(self)
	PageChange(self, "main.page", "new.notice.page")
end

function OnClickNewNoticePageToMainPage(self)
	PageChange(self, "new.notice.page", "main.page")
end

function OnClickNoticeHistory(self)

	--MessageBox(nil, "业主消息", "8号楼1单元402室 杨百 正在联系电路维修热线！ \n联系电话：13811152323")
	--AddNotifyBox("业主信息", "8号楼1单元402室 杨百 正在联系电路维修热线！\n联系电话：13811152323", "Owner")
	--AddNotifyBox("救助信息", "16号楼3单元708室 张乐 发出救助信息！\n紧急联系人：张小宝\n紧急联系电话：13811153235", "OnCall")
	
	
	PageChange(self, "main.page", "history.notice.page")
	
	local controlObj = self:GetOwnerControl()
	local httpclient = XLGetObject("Whome.HttpCore.Factory"):CreateInstance()
	
	url = "/community/notice"
	param = ""
	httpclient:AttachResultListener(
		function(result)
			table_result = json.decode(result)
			if table_result['ret'] == 0 then
				--local objList = controlObj:GetObject("tableview.result.list")
				table_data = table_result['result']['notice_list']
				for i=1, #table_data do
					table_data[i]['author'] = '管理员'
					table_data[i]['status'] = '正常'
					table_data[i]['modify_time'] = os.date("%c", table_data[i]['modify_time'])
				end
				--objList:ClearItems()
				--objList:InsertItemList(table_data, true)
			end
		end
	)
	httpclient:Perform(url, "GET", param)
	
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

function TV_OnInitControl(self)
	
end

function OnClickNoticePublishWarning(self)
	local httpclient = XLGetObject("Whome.HttpCore.Factory"):CreateInstance()
	httpclient:AttachResultListener(
		function(result) 
			XLMessageBox("result is "..result) 
		end
	)
	url = "/community/topic?action=get_list&target="..httpclient:EscapeParam("投诉")
	httpclient:Perform(url, "GET", "")
end

function BTN_PublishNotice(self)
	local ret = MessageBox(nil, "社区公告", "是否确定提交公告信息？")
	--XLMessageBox(ret)
	if ret == 1 then
		AddNotify(self, "公告提交成功！")
	end
	--[[
	local controlObj = self:GetOwnerControl()
	local titleObj = controlObj:GetObject("edit.notice.title")
	local contentObj = controlObj:GetObject("richedit.notice.content")
	local httpclient = XLGetObject("Whome.HttpCore.Factory"):CreateInstance()
	
	local title = httpclient:EscapeParam(titleObj:GetText())
	local content = httpclient:EscapeParam(contentObj:GetText())
	
	url = "/community/notice"
	param = "action=add_notice&title="..title.."&content="..content
	httpclient:AttachResultListener(
		function(result)
			table_result = json.decode(result)
			if table_result['ret'] == 0 then
				
			end
		end
	)
	httpclient:Perform(url, "POST", param)
	]]
end

function LB_OnListItemDbClick(self, event, itemObj, x, y, flags)
end

function OnClickNoticeHistory1(self)
	--AddNotify(self, math.random(1,1000))
	local shell = XLGetObject("CoolJ.OSShell")
	local a, b = shell:FileOpenDialog("image")
	XLMessageBox(a)
	XLMessageBox(b)
end

function TB_OnInitControl(self)
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	local obj = objFactory:CreateUIObject(nil, "CoolJ.Upload.ItemForImage")
	self:AddDefaultItem(obj)
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
	if table_data == nil then 
		return
	end
	PageChange(self, "history.notice.page", "new.notice.page")
end