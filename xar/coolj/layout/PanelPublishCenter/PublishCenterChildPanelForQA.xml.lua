local json = require('json')
local table_data = nil

function PageChange(self, old, new)
	local objOld = self:GetControlObject(old)
	if objOld ~= nil then
		objOld:SetVisible(false)
		objOld:SetChildrenVisible(false)
	end
	
	local objNew = self:GetControlObject(new)
	if objNew ~= nil then
		objNew:SetVisible(true)
		objNew:SetChildrenVisible(true)
	end
end

function OnInitControl(self)
	local attr = self:GetAttribute()
	local bkg = self:GetControlObject("bkg")
	
	self:GetControlObject("main.page"):SetVisible(false)
	self:GetControlObject("main.page"):SetChildrenVisible(false)
	self:GetControlObject("history.list.page"):SetVisible(false)
	self:GetControlObject("history.list.page"):SetChildrenVisible(false)
	self:GetControlObject("new.list.page"):SetVisible(false)
	self:GetControlObject("new.list.page"):SetChildrenVisible(false)
	self:GetControlObject("topic.info.page"):SetVisible(false)
	self:GetControlObject("topic.info.page"):SetChildrenVisible(false)
	
	self:PageChange("topic.info.page", "main.page")
	
	self:GetControlObject("BtnFAQ"):SetEnable(false)
end

function OnVisibleChange(self, visible)

end

function Get_QAData(self)
	
end

function LB_OnListItemDbClick(self, event, itemObj, x, y, flags)
	if table_data == nil then
		return
	end
	self:GetOwnerControl():PageChange("main.page", "topic.info.page")
	if objControl == nil then
		return
	end
	
	objControl:GetControlObject("title"):SetText(itemObj:GetData().title)
	objControl:GetControlObject("id"):SetText(itemObj:GetData().id)
	objControl:GetControlObject("author"):SetText(itemObj:GetData().author)
	objControl:GetControlObject("content"):SetText(itemObj:GetData().content)
	objControl:GetControlObject("answer"):SetText(itemObj:GetData().answer)
	objControl:GetControlObject("topic_status"):SetText(itemObj:GetData().topic_status)
	if itemObj:GetData().status == 'noreply' then
		objControl:GetControlObject("topic_status"):SetTextColorResID("system.black")
	elseif itemObj:GetData().status == 'reply' then
		objControl:GetControlObject("topic_status"):SetTextColorResID("system.black")
	elseif itemObj:GetData().status == 'close' then
		objControl:GetControlObject("topic_status"):SetTextColorResID("system.red")
	end
	
	statuschange(self:GetOwnerControl())
end

function statuschange(self)
	if table_data == nil then
		return 
	end
	
	local objID = tonumber(self:GetControlObject("id"):GetText())
	
	-- first info
	if objID == table_data[1]['id'] then
		local objBtnPrev = self:GetControlObject("BtnPrev")
		objBtnPrev:SetEnable(false)
	else
		local objBtnPrev = self:GetControlObject("BtnPrev")
		objBtnPrev:SetEnable(true)		
	end
	
	-- last info
	if objID == table_data[#table_data]['id'] then
		local objBtnNext = self:GetControlObject("BtnNext")
		objBtnNext:SetEnable(false)
	else
		local objBtnNext = self:GetControlObject("BtnNext")
		objBtnNext:SetEnable(true)		
	end
	
	self:GetControlObject("BtnClose"):SetEnable(true)
	for i=1, #table_data do
		if objID == table_data[i]['id'] then
			if table_data[i]['status'] == 'close' then
				self:GetControlObject("BtnClose"):SetEnable(false)
				break
			end
		end
	end
end

function BTN_Next(self)
	-- 下一条
	local UserData = self:GetOwnerControl():GetAttribute().UserData
	local request = function(ret, msg, result)
		if ret == 0 then
			self:GetOwnerControl():PageChange("history.list.page", "topic.info.page")
			self:GetOwnerControl():GetAttribute().UserData = result['info']
			self:GetOwnerControl():RefreshDetails()
		else
			AddNotify(self, msg, 3000)
		end
	end
	local param = ""
	HttpRequest("/api/message/estate?action=get_info_next&id="..UserData['id'].."&status="..UserData['status'], "GET", param, request)
end

function BTN_Prev(self)
	-- 上一条
	local UserData = self:GetOwnerControl():GetAttribute().UserData
	local request = function(ret, msg, result)
		if ret == 0 then
			self:GetOwnerControl():PageChange("history.list.page", "topic.info.page")
			self:GetOwnerControl():GetAttribute().UserData = result['info']
			self:GetOwnerControl():RefreshDetails()
		else
			AddNotify(self, msg, 3000)
		end
	end
	local param = ""
	HttpRequest("/api/message/estate?action=get_info_prev&id="..UserData['id'].."&status="..UserData['status'], "GET", param, request)
end

function BTN_Reply(self)
	-- 答复话题
	local UserData = self:GetOwnerControl():GetAttribute().UserData
	local request = function(ret, msg, result)
		if ret == 0 then
			--
			AddNotify(self, "答复成功", 3000)
		else
			AddNotify(self, msg, 3000)
		end
	end
	local answer = self:GetOwnerControl():GetControlObject("answer"):GetText()
	local param = "action=answer&id="..UserData['id'].."&answer="..answer
	HttpRequest("/api/message/estate", "POST", param, request)	
end

function Get_QAInfo(self, id)
	local objControl = self:GetControlObject("tableview.result.list")
	
	httpclient = XLGetObject("Whome.HttpCore.Factory"):CreateInstance()
	url = "/community/topic?action=get_info&id="..id
	param = ""
	httpclient:AttachResultListener(
		function(result)
			local table_result = json.decode(result)
			if table_result['ret'] == 0 then
				for i=1, #table_data do
					if table_data[i]['id'] == id then
						table_data[i]['title'] = table_result['result']['title']
						table_data[i]['content'] = table_result['result']['content']
						table_data[i]['answer'] = table_result['result']['answer']
						
						table_data[i]['modify_time'] = os.date("%c", table_result['result']['modify_time'])
						table_data[i]['status'] = table_result['result']['status']
						if table_data[i]['status'] == 'noreply' then
							table_data[i]['topic_status'] = '新'
						elseif table_data[i]['status'] == 'reply' then
							table_data[i]['topic_status'] = '已答复'
						elseif table_data[i]['status'] == 'close' then
							table_data[i]['topic_status'] = '关闭'
						end
						break
					end
				end
				objControl:ClearItems()
				objControl:InsertItemList(table_data, true)
			end
		end
	)
	httpclient:Perform(url, "GET", param)	
end

function BTN_Close(self)
	-- 关闭答复
	local UserData = self:GetOwnerControl():GetAttribute().UserData
	if UserData['status'] == 'open' then
		local request = function(ret, msg, result)
			if ret == 0 then
				--
				AddNotify(self, "关闭成功", 3000)
			else
				AddNotify(self, msg, 3000)
			end
		end
		local param = "action=close&id="..UserData['id']
		HttpRequest("/api/message/estate", "POST", param, request)	
	else
		self:GetOwnerControl():PageChange("topic.info.page", "history.list.page")
		self:GetOwnerControl():Get_QAHistoryData()
	end
		
end

function OnNewList(self)
	self:GetOwnerControl():PageChange("main.page", "new.list.page")
	self:GetOwnerControl():Get_QANewData()
end

function OnHistoryList(self)
	self:GetOwnerControl():PageChange("main.page", "history.list.page")
	self:GetOwnerControl():Get_QAHistoryData()
end

function OnMainPage(self)
	local id = self:GetID()
	if id == 'btn.new' then
		self:GetOwnerControl():PageChange("new.list.page", "main.page")
	elseif id == 'btn.history' then
		self:GetOwnerControl():PageChange("history.list.page", "main.page")
	end
end

function OnClickNoticePublishWarningInitControl(self)
	local l,t,r,b = self:GetTextPos()
	self:SetTextPos(l+10, t, r-l, b-t)	
end

function OnClickNoticePublishWarning(self)

end

function LBN_OnInitControl(self)
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	local headerTable = {
		{HeaderItemId='id', ItemWidth=60, Text="编号", TextLeftOffset=7, TextHalign="left", SubItem=false, MaxSize=60, MiniSize=60, ShowSplitter=true, ShowSortIcon=false, IncludeNext=false, SortProperty=0},
		{HeaderItemId='title', ItemWidth=300, Text="问题描述", TextLeftOffset=7, TextHalign="left", SubItem=false, MaxSize=300, MiniSize=300, ShowSplitter=true, ShowSortIcon=false, IncludeNext=false, SortProperty=0},
		{HeaderItemId='author', ItemWidth=80, Text="提交人", TextLeftOffset=7, TextHalign="left", SubItem=false, MaxSize=80, MiniSize=80, ShowSplitter=true, ShowSortIcon=false, IncludeNext=false, SortProperty=0},
		{HeaderItemId='s_time', ItemWidth=100, Text="提交日期", TextLeftOffset=7, TextHalign="left", SubItem=false, MaxSize=100, MiniSize=100, ShowSplitter=true, ShowSortIcon=false, IncludeNext=false, SortProperty=0},
		{HeaderItemId='other', ItemWidth=80, Text="", TextLeftOffset=2, TextHalign="left", SubItem=false, MaxSize=80, MiniSize=80, ShowSplitter=true, ShowSortIcon=false, IncludeNext=false, SortProperty=1}
	}
	table.foreach(headerTable, function(i, v) self:InsertColumn(v) end);
	self:ReloadHeader()
	
	local datasource = objFactory:CreateUIObject(1, "New.DataSource")
	datasource:InitControl()
	local dataconverter = objFactory:CreateUIObject(2, "New.DataConverter")
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
	--XLMessageBox(eventType)
	if eventType == "OnShowDetails" then
		local request = function(ret, msg, result)
			if ret == 0 then
				self:GetOwnerControl():PageChange("new.list.page", "topic.info.page")
				self:GetOwnerControl():GetAttribute().UserData = result['info']
				self:GetOwnerControl():RefreshDetails()
			else
				AddNotify(self, msg, 3000)
			end
		end
		local param = ""
		HttpRequest("/api/message/estate?action=get_info&id="..UserData, "GET", param, request)
	end
end

function LBH_OnInitControl(self)
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	local headerTable = {
		{HeaderItemId='id', ItemWidth=60, Text="编号", TextLeftOffset=7, TextHalign="left", SubItem=false, MaxSize=60, MiniSize=60, ShowSplitter=true, ShowSortIcon=false, IncludeNext=false, SortProperty=0},
		{HeaderItemId='title', ItemWidth=250, Text="问题描述", TextLeftOffset=7, TextHalign="left", SubItem=false, MaxSize=250, MiniSize=250, ShowSplitter=true, ShowSortIcon=false, IncludeNext=false, SortProperty=0},
		{HeaderItemId='author', ItemWidth=80, Text="提交人", TextLeftOffset=7, TextHalign="left", SubItem=false, MaxSize=80, MiniSize=80, ShowSplitter=true, ShowSortIcon=false, IncludeNext=false, SortProperty=0},
		{HeaderItemId='s_time', ItemWidth=100, Text="提交日期", TextLeftOffset=7, TextHalign="left", SubItem=false, MaxSize=100, MiniSize=100, ShowSplitter=true, ShowSortIcon=false, IncludeNext=false, SortProperty=0},
		{HeaderItemId='nick', ItemWidth=80, Text="操作人", TextLeftOffset=7, TextHalign="left", SubItem=false, MaxSize=80, MiniSize=80, ShowSplitter=true, ShowSortIcon=false, IncludeNext=false, SortProperty=0},
		{HeaderItemId='status', ItemWidth=60, Text="状态", TextLeftOffset=7, TextHalign="left", SubItem=false, MaxSize=60, MiniSize=60, ShowSplitter=true, ShowSortIcon=false, IncludeNext=false, SortProperty=0},
		{HeaderItemId='other', ItemWidth=80, Text="", TextLeftOffset=2, TextHalign="left", SubItem=false, MaxSize=80, MiniSize=80, ShowSplitter=true, ShowSortIcon=false, IncludeNext=false, SortProperty=1}
	}
	table.foreach(headerTable, function(i, v) self:InsertColumn(v) end);
	self:ReloadHeader()
	
	local datasource = objFactory:CreateUIObject(1, "History.DataSource")
	datasource:InitControl()
	local dataconverter = objFactory:CreateUIObject(2, "History.DataConverter")
	dataconverter:InitControl()
	self:SetDataSourceAndDataConverter(datasource, dataconverter)
	self:ReloadData()
end

function LBH_OnHeaderItemPosChanged(self, event, isDrag, GridInfoList)
	if isDrag == true then
		self:GetTableViewObj():UpdateItemInfo(isDrag, GridInfoList)
	end
end

function LBH_OnItemEvent(self, eventName, eventType, UserData, ItemObj)	
	--XLMessageBox(eventType)
	if eventType == "OnShowDetails" then
		local request = function(ret, msg, result)
			if ret == 0 then
				self:GetOwnerControl():PageChange("history.list.page", "topic.info.page")
				self:GetOwnerControl():GetAttribute().UserData = result['info']
				self:GetOwnerControl():RefreshDetails()
			else
				AddNotify(self, msg, 3000)
			end
		end
		local param = ""
		HttpRequest("/api/message/estate?action=get_info&id="..UserData, "GET", param, request)
	end
end

function RG_OnInitControl(self)
	local attr = self:GetAttribute()
	attr.SelectedButtonID = "status"

	self:AddRadioButton("status","状态筛选：",5,5,100,34)
	self:AddRadioButton("author","操作人：",5,44,100,34)
	self:AddRadioButton("search_name","姓名查找：",200,5,100,34)
	self:AddRadioButton("search_id","ID查找：",395,5,100,34)
end

function RG_OnButtonSelectedChanged(self)
 
end

function CBS_OnInitControl(self)
	local attr = self:GetAttribute()
	attr.data = {}
	local init_data = {
		{id = "0", text = "全部"},
		{id = "1", text = "已删除"},
		{id = "2", text = "已答复"}
	}
	for i,v in pairs(init_data) do
		table.insert(attr.data, { IconResID = "", IconWidth = 0, LeftMargin = 10, TopMargin = 0, Text = v["text"], Custom = nil, Func = nil, ID=v["id"] })
	end
	self:SetText("全部")
end

function CBA_OnInitControl(self)
	local attr = self:GetAttribute()
	attr.data = {}
	local init_data = {
		{id = "0", text = "全部"},
		{id = "1", text = "管理员"},
		{id = "2", text = "张三"}
	}
	for i,v in pairs(init_data) do
		table.insert(attr.data, { IconResID = "", IconWidth = 0, LeftMargin = 10, TopMargin = 0, Text = v["text"], Custom = nil, Func = nil, ID=v["id"] })
	end
	self:SetText("全部")
end

function Get_QANewData(self)
	-- load data for root service
	local request = function(ret, msg, result)
		if ret == 0 then
			local obj = self:GetControlObject("listbox.new")
			obj:GetDataSource():SetData(result['list'])
			obj:ReloadData()
		else
			AddNotify(self, msg, 3000)
		end
	end
	HttpRequest("/api/message/estate?action=get_new_list", "GET", "", request)
end

function Get_QAHistoryData(self)
	-- load data for root service
	local request = function(ret, msg, result)
		if ret == 0 then
			local obj = self:GetControlObject("listbox.history")
			obj:GetDataSource():SetData(result['list'])
			obj:ReloadData()
		else
			AddNotify(self, msg, 3000)
		end
	end
	HttpRequest("/api/message/estate?action=get_history_list", "GET", "", request)
end

function RefreshDetails(self)
	local attr = self:GetAttribute()
	if attr.UserData == nil then return end
	if attr.UserData['status'] == 'open' then
		self:GetControlObject("btn.details"):SetText("返回业主最新问题列表")
		self:GetControlObject("title"):SetText(attr.UserData['title'])
		self:GetControlObject("id"):SetText(attr.UserData['id'])
		self:GetControlObject("author"):SetText(attr.UserData['author'])
		self:GetControlObject("content"):SetText(attr.UserData['question'])
		self:GetControlObject("answer"):SetText(attr.UserData['answer'])
		self:GetControlObject("BtnClose"):SetText("删除")
	else
		self:GetControlObject("btn.details"):SetText("返回业主历史问题列表")
		self:GetControlObject("title"):SetText(attr.UserData['title'])
		self:GetControlObject("id"):SetText(attr.UserData['id'])
		self:GetControlObject("author"):SetText(attr.UserData['author'])
		self:GetControlObject("content"):SetText(attr.UserData['question'])
		self:GetControlObject("answer"):SetText(attr.UserData['answer'])
		self:GetControlObject("BtnClose"):SetText("放弃修改")
	end
end

function OnPrePage(self)
	local attr = self:GetOwnerControl():GetAttribute()
	if attr.UserData == nil then return end
	if attr.UserData['status'] == 'open' then
		self:GetOwnerControl():PageChange("topic.info.page", "new.list.page")
		self:GetOwnerControl():Get_QANewData()
	else
		self:GetOwnerControl():PageChange("topic.info.page", "history.list.page")
		self:GetOwnerControl():Get_QAHistoryData()
	end
end