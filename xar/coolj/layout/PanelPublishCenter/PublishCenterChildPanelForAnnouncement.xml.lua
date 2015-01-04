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
	
	NoticePosInit(self)
end

function OnClickNewNotice(self)
	PageChange(self, "main.page", "new.notice.page")
end

function OnClickNewNoticePageToMainPage(self)
	PageChange(self, "new.notice.page", "main.page")
end

function OnClickNoticeHistory(self)
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
	if table_data == nil then 
		return
	end
	PageChange(self, "history.notice.page", "new.notice.page")
	
end

function OnClickNoticeHistory1(self)
	AddNotify(self, math.random(1,1000))
end

-- 是否设定定时推送功能，不选择默认直接发布推送
-- 否则参考日期和时间参数
function OnCheck(self, event, state, bClick)
	if event ~= 'OnCheck' then return end
	
	local owner = self:GetOwnerControl()
	local attr = owner:GetAttribute()
	attr.IsCheck = state
	--NoticePosInit(owner)
	--XLMessageBox(owner:GetID())
	if state then
		AniPosChangeShow(owner)
	else
		AniPosChangeHide(owner)
	end
end

function AniPosChangeShow(self)
	-- obj pos move 80px
	if self:GetID() ~= "PublishCenterChildPanelForAnnouncement" then return end
	
	local owner = self:GetOwner()
	local objPic = self:GetObject("layout.upload.pic")
	local objPush = self:GetObject("layout.notice.pushtime")
	local objSetting = self:GetObject("layout.notice.setting")
	
	local aniFactory = XLGetObject("Xunlei.UIEngine.AnimationFactory")
	local posAni = aniFactory:CreateAnimation("PosChangeAnimation")
	local l,t,r,b = objPic:GetObjPos()
	posAni:SetTotalTime(400)
	posAni:BindLayoutObj(objPic)
	posAni:SetKeyFramePos(l, t, l, t+80)
	owner:AddAnimation(posAni)
	posAni:Resume()
	
	posAni2 = aniFactory:CreateAnimation("PosChangeAnimation")
	local l,t,r,b = objPush:GetObjPos()
	posAni2:SetTotalTime(400)
	posAni2:BindLayoutObj(objPush)
	posAni2:SetKeyFramePos(l, t, l, t+80)
	owner:AddAnimation(posAni2)
	posAni2:Resume()

	local onAniFinish = 
		function (ani)
			objSetting:SetVisible(true)
			objSetting:SetChildrenVisible(true)			
		end
	posAni:AttachListener(true,onAniFinish)
end

function AniPosChangeHide(self)
	-- obj pos move -80px
	if self:GetID() ~= "PublishCenterChildPanelForAnnouncement" then return end
	
	local owner = self:GetOwner()
	local objPic = self:GetObject("layout.upload.pic")
	local objPush = self:GetObject("layout.notice.pushtime")
	local objSetting = self:GetObject("layout.notice.setting")
	
	local aniFactory = XLGetObject("Xunlei.UIEngine.AnimationFactory")
	local posAni = aniFactory:CreateAnimation("PosChangeAnimation")
	local l,t,r,b = objPic:GetObjPos()
	posAni:SetTotalTime(400)
	posAni:BindLayoutObj(objPic)
	posAni:SetKeyFramePos(l, t, l, t-80)
	owner:AddAnimation(posAni)
	posAni:Resume()
	
	posAni2 = aniFactory:CreateAnimation("PosChangeAnimation")
	local l,t,r,b = objPush:GetObjPos()
	posAni2:SetTotalTime(400)
	posAni2:BindLayoutObj(objPush)
	posAni2:SetKeyFramePos(l, t, l, t-80)
	owner:AddAnimation(posAni2)
	posAni2:Resume()
	
	objSetting:SetVisible(false)
	objSetting:SetChildrenVisible(false)
end

function NoticePosInit(owner)
	if owner:GetID() ~= "PublishCenterChildPanelForAnnouncement" then return end
	
	local attr = owner:GetAttribute()
	local objPic = owner:GetObject("layout.upload.pic")
	local objPush = owner:GetObject("layout.notice.pushtime")
	local objSetting = owner:GetObject("layout.notice.setting")
	if attr.IsCheck then
		objSetting:SetVisible(true)
		objSetting:SetChildrenVisible(true)
		
		objPush:SetObjPos2(440, 200, 211, 100)
		objPic:SetObjPos2(440, 240, 250, 170)
	else
		objSetting:SetVisible(false)
		objSetting:SetChildrenVisible(false)
		
		objPush:SetObjPos2(440, 120, 211, 100)
		objPic:SetObjPos2(440, 160, 250, 170)
	end
end

function CST_OnInitControl(self)
	local attr = self:GetAttribute()
	attr.data = {}
	local temp_data = {"", "00:00", "06:00", "07:00", "08:00", "09:00", "10:00", "11:00", "12:00", "13:00", "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00", "21:00", "22:00", "23:00"}
	for i,datetime in ipairs(temp_data) do
		table.insert(attr.data, { IconResID = "", IconWidth = 0, LeftMargin = 10, TopMargin = 0, Text = datetime, Custom = nil, Func = nil })
	end
end

function CNV_OnInitControl(self)
	local attr = self:GetAttribute()
	attr.data = {}
	local temp_data = {"", "一天", "二天", "三天", "一周", "半个月", "一个月", "三个月", "半年"}
	for i,valid_time in ipairs(temp_data) do
		table.insert(attr.data, { IconResID = "", IconWidth = 0, LeftMargin = 10, TopMargin = 0, Text = valid_time, Custom = nil, Func = nil })
	end
end

function CSPA_OnInitControl(self)
	local attr = self:GetAttribute()
	attr.data = {}
	local temp_data = {"全部", "张三", "李四", "管理员"}
	for i,valid_time in ipairs(temp_data) do
		table.insert(attr.data, { IconResID = "", IconWidth = 0, LeftMargin = 10, TopMargin = 0, Text = valid_time, Custom = nil, Func = nil })
	end
	self:SetText("全部")
end

function CSPD_OnInitControl(self)
	local attr = self:GetAttribute()
	attr.data = {}
	local temp_data = {"最近一个月", "最近两周", "最近三天", "全部"}
	for i,valid_time in ipairs(temp_data) do
		table.insert(attr.data, { IconResID = "", IconWidth = 0, LeftMargin = 10, TopMargin = 0, Text = valid_time, Custom = nil, Func = nil })
	end
	self:SetText("最近一个月")
end

function CSPS_OnInitControl(self)
	local attr = self:GetAttribute()
	attr.data = {}
	local temp_data = {"全部", "正常", "已过期", "已撤销"}
	for i,valid_time in ipairs(temp_data) do
		table.insert(attr.data, { IconResID = "", IconWidth = 0, LeftMargin = 10, TopMargin = 0, Text = valid_time, Custom = nil, Func = nil })
	end
	self:SetText("全部")
end