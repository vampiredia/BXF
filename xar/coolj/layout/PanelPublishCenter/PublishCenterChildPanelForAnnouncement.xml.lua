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
	-- add header
	table.foreach(headerTable, function(i, v) self:InsertColumn(v) end);
	self:ReloadHeader()
	
	-- add data
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
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
	--XLMessageBox(response)
	--XLMessageBox(httpclient:EscapeParam("哈哈"))
end

function BTN_PublishNotice(self)
	local ret = MessageBox(nil, "社区公告", "是否确定提交公告信息？")
	--XLMessageBox(ret)
	if ret == 1 then
		AddNotify(self, "公告提交成功！")
	end
end

function LB_OnListItemDbClick(self, event, itemObj, x, y, flags)	
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
		--AniPosChangeShow(owner)
	else
		--AniPosChangeHide(owner)
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
		
		--objPush:SetObjPos2(440, 200, 211, 100)
		--objPic:SetObjPos2(440, 240, 250, 170)
	else
		--objSetting:SetVisible(false)
		--objSetting:SetChildrenVisible(false)
		
		--objPush:SetObjPos2(440, 120, 211, 100)
		--objPic:SetObjPos2(440, 160, 250, 170)
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

function OnEditChange(self)
	local textLength = self:GetLength()
	if textLength == nil then return end
	local textMaxLength = self:GetMaxLength()
	if textMaxLength == nil then return end
	--XLMessageBox(textMaxLength)
	local wordTips = self:GetOwnerControl():GetControlObject("text.notice.words.tip")
	if wordTips ~= nil then wordTips:SetText("还能输入"..textMaxLength-textLength.."个汉字") end
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
		if table_data == nil then 
			return
		end
		PageChange(self, "history.notice.page", "new.notice.page")
	end
end

function GetData(self)
	local request = function(ret, msg, result)
		if ret == 0 then
			local obj = self:GetControlObject("lb.result")
			obj:GetDataSource():SetData(result['msg_list'])
			obj:ReloadData()
		else
			AddNotify(self, msg, 5000)
		end
	end
	local param = ""
	HttpRequest("/api/message/notice?action=notice_list", "GET", param, request)
end