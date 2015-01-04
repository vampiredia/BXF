local json = require('json')
local table_data = {}

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
				local objList = controlObj:GetObject("tableview.result.list")
				table_data = table_result['result']['notice_list']
				for i=1, #table_data do
					table_data[i]['author'] = '管理员'
					table_data[i]['status'] = '正常'
					table_data[i]['modify_time'] = os.date("%c", table_data[i]['modify_time'])
				end
				objList:ClearItems()
				objList:InsertItemList(table_data, true)
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
	attr.Text = "sd"
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
	-- columnID, 
	-- columnWidth, 
	-- title, 
	-- header halign
	-- item halign
	-- textPos, 
	-- custom, 
	-- minWidth, 
	-- bkgtexture, 
	-- canSort, 
	-- sortFunc, 
	-- headerTextColor
	self:InsertColumn("id", 40, "编号", "center", "center", 5, true, 40)
	self:InsertColumn("title", 240, "通知标题", "center", "left", 15, true, 140)
	self:InsertColumn("author", 90, "发布人", "center", "center", 15, true, 40)
	self:InsertColumn("modify_time", 140, "发布时间", "center", "center", 15, true, 40)
	self:InsertColumn("status", 60, "状态", "center", "center", 5, true, 40)
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
	--XLMessageBox(response)
	--XLMessageBox(httpclient:EscapeParam("哈哈"))
end

function BTN_PublishNotice(self)
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
end

function LB_OnListItemDbClick(self, event, itemObj, x, y, flags)
	if table_data == nil then 
		return
	end
	PageChange(self, "history.notice.page", "new.notice.page")
	
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