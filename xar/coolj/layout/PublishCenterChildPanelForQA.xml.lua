local json = require('json')
local table_data = nil

function pagechange(self, old, new)
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
	--bkg:SetTextureID(attr.BorderTexture)
	
	pagechange(self, "topic.info.page", "main.page")
	
	self:GetControlObject("BtnFAQ"):SetEnable(false)
end

function LB_OnInitControl(self)
	self:InsertColumn("id", 40, "编号", "center", "center", 5, true, 40)
	self:InsertColumn("title", 240, "话题标题", "center", "left", 15, true, 140)
	self:InsertColumn("author", 90, "提交人", "center", "center", 15, true, 40)
	self:InsertColumn("modify_time", 140, "提交时间", "center", "center", 15, true, 40)
	self:InsertColumn("worker", 90, "操作人", "center", "center", 15, true, 40)
	self:InsertColumn("topic_status", 60, "状态", "center", "center", 5, true, 40)	
end

function OnVisibleChange(self, visible)

end

function Get_QAData(self)
	local objControl = self:GetControlObject("tableview.result.list")
	
	httpclient = XLGetObject("Whome.HttpCore.Factory"):CreateInstance()
	url = "/community/topic?action=get_list&status=all"
	param = ""
	httpclient:AttachResultListener(
		function(result)
			local table_result = json.decode(result)
			if table_result['ret'] == 0 then
				table_data = table_result['result']['topic_list']
				for i=1, #table_data do
					--table_data[i]['author'] = '管理员'
					--table_data[i]['status'] = '正常'
					table_data[i]['modify_time'] = os.date("%c", table_data[i]['modify_time'])
					if table_data[i]['status'] == 'noreply' then
						table_data[i]['topic_status'] = '未答复'
					elseif table_data[i]['status'] == 'reply' then
						table_data[i]['topic_status'] = '已答复'
					elseif table_data[i]['status'] == 'close' then
						table_data[i]['topic_status'] = '关闭'
					end
					table_data[i]['author'] = '小白'
					table_data[i]['worker'] = '管理员'
				end
				objControl:ClearItems()
				objControl:InsertItemList(table_data, true)
			end
		end
	)
	httpclient:Perform(url, "GET", param)
end

function LB_OnListItemDbClick(self, event, itemObj, x, y, flags)
	if table_data == nil then
		return
	end
	local objControl = self:GetOwnerControl()
	pagechange(objControl, "main.page", "topic.info.page")
	
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
		objControl:GetControlObject("topic_status"):SetTextColor("system.green")
	elseif itemObj:GetData().status == 'reply' then
		objControl:GetControlObject("topic_status"):SetTextColor("system.orange")
	elseif itemObj:GetData().status == 'close' then
		objControl:GetControlObject("topic_status"):SetTextColor("system.red")
	end
	
	statuschange(self:GetOwnerControl())
end

function BTN_GotoMainPage(self)
	pagechange(self:GetOwnerControl(), "topic.info.page", "main.page")
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
	local id = tonumber(self:GetOwnerControl():GetControlObject("id"):GetText())
	for i=1, #table_data do
		if id == table_data[i]['id'] then
			showinfo(self:GetOwnerControl(), table_data[i+1]['id'])
		end
	end
end

function BTN_Prev(self)
	-- 上一条
	local id = tonumber(self:GetOwnerControl():GetControlObject("id"):GetText())
	for i=1, #table_data do
		if id == table_data[i]['id'] then
			showinfo(self:GetOwnerControl(), table_data[i-1]['id'])
		end
	end
end

function showinfo(self, id)
	if table_data == nil then
		return
	end
	
	for i=1, #table_data  do
		if id == table_data[i]['id'] then
			self:GetControlObject("title"):SetText(table_data[i]['title'])
			self:GetControlObject("id"):SetText(table_data[i]['id'])
			self:GetControlObject("author"):SetText(table_data[i]['author'])
			self:GetControlObject("content"):SetText(table_data[i]['content'])
			self:GetControlObject("answer"):SetText(table_data[i]['answer'])
			self:GetControlObject("topic_status"):SetText(table_data[i]['topic_status'])
		if table_data[i]['status'] == 'noreply' then
			self:GetControlObject("topic_status"):SetTextColor("system.green")
		elseif table_data[i]['status'] == 'reply' then
			self:GetControlObject("topic_status"):SetTextColor("system.orange")
		elseif table_data[i]['status'] == 'close' then
			self:GetControlObject("topic_status"):SetTextColor("system.red")
		end
			statuschange(self)				
		end
	end
end

function BTN_Reply(self)
	-- 答复话题
	local id = tonumber(self:GetOwnerControl():GetControlObject("id"):GetText())
	local answer = self:GetOwnerControl():GetControlObject("answer"):GetText()
	
	httpclient = XLGetObject("Whome.HttpCore.Factory"):CreateInstance()
	local url = "/community/topic"
	local param = "action=answer&id="..id.."&answer="..httpclient:EscapeParam(answer)
	httpclient:AttachResultListener(
		function(result)
			local table_result = json.decode(result)
			if table_result['ret'] == 0 then
				Get_QAInfo(self:GetOwnerControl(), id)
			end
		end
	)
	httpclient:Perform(url, "POST", param)	
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
	local id = tonumber(self:GetOwnerControl():GetControlObject("id"):GetText())
	
	httpclient = XLGetObject("Whome.HttpCore.Factory"):CreateInstance()
	url = "/community/topic"
	param = "action=close&id="..id
	httpclient:AttachResultListener(
		function(result)
			local table_result = json.decode(result)
			if table_result['ret'] == 0 then
				Get_QAInfo(self:GetOwnerControl(), id)
			end
		end
	)
	httpclient:Perform(url, "POST", param)	
end