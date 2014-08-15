--[[
	{type="owner", title="白杨", content="8号楼1单元402室 白杨 正在联系电路维修热线！", datetime="昨天"},
	{type="owner", title="白杨", content="8号楼1单元402室 白杨 正在联系水果外送热线！", datetime="星期三"},
	{type="owner", title="白杨", content="8号楼1单元402室 白杨 正在联系家政服务热线！", datetime="星期日"},
	{type="owner", title="白杨", content="8号楼1单元402室 白杨 正在联系送水服务热线！", datetime="04-08-01"},
	{type="owner", title="白杨", content="8号楼1单元402室 白杨 正在联系美食达热线！", datetime="04-07-15"},
	{type="owner", title="白小杨", content="1号楼1单元402室 白小杨 正在联系电路维修热线！", datetime="12:59"},
	{type="owner", title="白小杨", content="1号楼1单元402室 白小杨 正在联系电路维修热线！", datetime="12:59"},
	{type="owner", title="白小杨", content="1号楼1单元402室 白小杨 正在联系电路维修热线！", datetime="12:59"},
	{type="owner", title="白小杨", content="1号楼1单元402室 白小杨 正在联系电路维修热线！", datetime="12:59"},
	{type="oncall", title="白小杨", content="2号楼1单元402室 白小杨 发出救助信息！\n紧急联系人：杨晓白\n紧急联系电话：13811153243", datetime="12:59"},
	{type="oncall", title="白小杨", content="2号楼2单元402室 白小杨 发出救助信息！\n紧急联系人：杨晓白\n紧急联系电话：13811153243", datetime="12:59"},
	{type="oncall", title="白大杨", content="2号楼2单元402室 白大杨 发出救助信息！\n紧急联系人：杨晓白\n紧急联系电话：13811153243", datetime="12:59"},
	{type="oncall", title="白大杨", content="2号楼1单元402室 白大杨 发出救助信息！\n紧急联系人：杨晓白\n紧急联系电话：13811153243", datetime="12:59"}

]]
local table_data = {}
table.insert(table_data, {type="owner", uid=1, title="白杨", content="8号楼1单元402室 白杨 正在联系电路维修热线！", datetime="12:59"})
table.insert(table_data, {type="owner", uid=1, title="白杨", content="8号楼1单元402室 白杨 正在联系水路维修热线！", datetime="10:59"})
table.insert(table_data, {type="owner", uid=1, title="白杨", content="8号楼1单元402室 白杨 正在联系空调维修热线！", datetime="06:59"})
table.insert(table_data, {type="owner", uid=1, title="白杨", content="8号楼1单元402室 白杨 正在联系电路维修热线！", datetime="昨天"})
table.insert(table_data, {type="owner", uid=1, title="白杨", content="8号楼1单元402室 白杨 正在联系水果外送热线！", datetime="星期三"})
table.insert(table_data, {type="owner", uid=1, title="白杨", content="8号楼1单元402室 白杨 正在联系家政服务热线！", datetime="星期日"})
table.insert(table_data, {type="owner", uid=1, title="白杨", content="8号楼1单元402室 白杨 正在联系送水服务热线！", datetime="04-08-01"})
table.insert(table_data, {type="owner", uid=1, title="白杨", content="8号楼1单元402室 白杨 正在联系美食达热线！", datetime="04-07-15"})
table.insert(table_data, {type="owner", uid=2, title="白小杨", content="1号楼1单元402室 白小杨 正在联系电路维修热线！", datetime="12:59"})
table.insert(table_data, {type="owner", uid=2, title="白小杨", content="1号楼1单元402室 白小杨 正在联系电路维修热线！", datetime="12:59"})
table.insert(table_data, {type="owner", uid=2, title="白小杨", content="1号楼1单元402室 白小杨 正在联系电路维修热线！", datetime="12:59"})
table.insert(table_data, {type="owner", uid=2, title="白小杨", content="1号楼1单元402室 白小杨 正在联系电路维修热线！", datetime="12:59"})
table.insert(table_data, {type="oncall", uid=2, title="白小杨", content="2号楼1单元402室 白小杨 发出救助信息！\n紧急联系人：杨晓白\n紧急联系电话：13811153243", datetime="12:59"})
table.insert(table_data, {type="oncall", uid=2, title="白小杨", content="2号楼2单元402室 白小杨 发出救助信息！\n紧急联系人：杨晓白\n紧急联系电话：13811153243", datetime="12:59"})
table.insert(table_data, {type="oncall", uid=3, title="白大杨", content="2号楼2单元402室 白大杨 发出救助信息！\n紧急联系人：杨晓白\n紧急联系电话：13811153243", datetime="12:59"})
table.insert(table_data, {type="oncall", uid=3, title="白大杨", content="2号楼1单元402室 白大杨 发出救助信息！\n紧急联系人：杨晓白\n紧急联系电话：13811153243", datetime="12:59"})

local table_test = {}
table.insert(table_test, "紧急求助信息，请速联系电话13812345567")
table.insert(table_test, "紧急求助信息，请速联系电话13812345567")

local operate = {}

operate.Search = 
	function(data, key, value)
		local temp_data = {}
		for i=1, #data do
			if data[i][key] == value then table.insert(temp_data, data[i]) end
		end
		return temp_data
	end
	
operate.selectID = nil

function OnInitControl(self)
	local attr = self:GetAttribute()
end

function NLH_SetText(self, text)
	local obj = self:GetControlObject("text")
	obj:SetText(text)
end

function NLH_GetText(self)
	local obj = self:GetControlObject("text")
	return obj:GetText()
end

function LIST_OnInitControl(self)
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")

	local data_oncall = operate.Search(table_data, "type", "oncall")
	if #data_oncall > 0 then
		local obj = objFactory:CreateUIObject("listHead.OnCall", "CoolJ.NotifyBox.Left.Head")
		obj:SetText("紧急呼叫")
		local attr = obj:GetAttribute()
		obj:SetObjPos(0,0,attr.Width,attr.Height)
		self:InsertItem(obj)
		
		for i=1, #data_oncall do 
			local objID = "listHead.OnCall."..data_oncall[i]['uid']
			if operate.selectID == nil then operate.selectID = data_oncall[i] end
			if not self:IsItemValid(objID) then
				obj = objFactory:CreateUIObject(objID, "CoolJ.NotifyBox.Left.Item")
				local attr = obj:GetAttribute()
				attr.ID = data_oncall[i]['uid']
				attr.Type = data_oncall[i]['type']
				obj:GetControlObject("title"):SetText(table_data[i]['title'])
				obj:GetControlObject("content"):SetText(table_data[i]['content'])
				obj:GetControlObject("datetime"):SetText(table_data[i]['datetime'])
				obj:SetObjPos(0,0,attr.Width,attr.Height)
				self:InsertItem(obj)
			end
		end
	end
	
	local data_owner = operate.Search(table_data, "type", "owner")
	if #data_owner > 0 then
		local obj = objFactory:CreateUIObject("listHead.Owner", "CoolJ.NotifyBox.Left.Head")
		obj:SetText("业主信息")
		local attr = obj:GetAttribute()
		obj:SetObjPos(0,0,attr.Width,attr.Height)
		self:InsertItem(obj)
		
		for i=1, #data_owner do 
			local objID = "listHead.Owner."..data_owner[i]['uid']
			if not self:IsItemValid(objID) then
				obj = objFactory:CreateUIObject(objID, "CoolJ.NotifyBox.Left.Item")
				local attr = obj:GetAttribute()
				attr.ID = data_owner[i]['uid']
				attr.Type = data_owner[i]['type']
				obj:GetControlObject("title"):SetText(table_data[i]['title'])
				obj:GetControlObject("content"):SetText(table_data[i]['content'])
				obj:GetControlObject("datetime"):SetText(table_data[i]['datetime'])
				obj:SetObjPos(0,0,attr.Width,attr.Height)
				self:InsertItem(obj)
			end
		end		
	end
end

function LIST_Sub_OnInitControl(self)
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")	
	
	if operate.selectID ~= nil then 
		local data_info = operate.Search(table_data, "type", operate.selectID['type'])
		local data_show = operate.Search(data_info, "uid", operate.selectID["uid"])
		for i=1, #data_show do
			obj = objFactory:CreateUIObject("listHead.Info."..i, "CoolJ.NotifyBox.Right.Item")
			obj:SetContent(data_show[i]["content"])
			local attr = obj:GetAttribute()
			obj:SetObjPos(0,0,attr.Width,attr.Height)
			self:InsertItem(obj)
		end
	end

	self:UpdateScroll()
end

function OnLinkNotify(self)
	
end	

function GetRootControl(owner)
	if owner == nil then return nil end
	if owner:GetClass() == "CoolJ.SimpleListCtrl" then return owner end
	return GetRootControl(owner:GetOwnerControl())
end

function OnMouseWheel(self, x, y, distance, flags)
	local owner = GetRootControl(self)
	owner:MouseWheel(distance)
	--return true
end

function OnSelectChanged(self)
	--XLMessageBox("change")
end

function NLI_SetSel(self, value)
	local bkg = self:GetControlObject("bkg")
	if not bkg then return end
	if value then
		bkg:SetResID("texture.tasklist.select_item.bk")
	else
		bkg:SetResID("texture.tasklist.item.bk")	
	end
end

function LIST_ITEM_OnLButtonDown(self)
	local list = self:GetOwnerControl()
	list:SetSel(self)
end

function NRI_SetSel(self, value)
	local bkg = self:GetControlObject("bkg")
	if not bkg then return end
	if value then
		bkg:SetResID("texture.listctrl.selected")
	else
		bkg:SetResID("texture.tasklist.item.bk")	
	end
end

function ITEM_OnLButtonDown(self)
	self:GetOwnerControl():Click()
	
	--local osShell = XLGetObject("CoolJ.OSShell")
	--local l = osShell:OpenUrl("http://www.baidu.com")
	--local x, y = osShell:GetCurSorPos()
	--XLMessageBox(l)
end

function NRI_Click(self)
	local list = self:GetOwnerControl()
	list:SetSel(self)
end

function NRI_SetContent(self, text)
	--XLMessageBox("tes")
	local attr = self:GetAttribute()
	local obj = self:GetControlObject("content")
	obj:SetText(text)
	
	local function GetTotalHeight(obj)
		local count = obj:GetLineCount()
		return count
		--local height = 0
		--for i=1, count do 
		--	height = height + obj:GetLineLength(i)
		--end
		--return height
	end
	
	local w, h = obj:GetNaturalSize("fittocontext", attr.Width, 1000)
	--local h = GetTotalHeight(obj)
	if h > attr.MiniEditHeight then
		attr.Height = attr.Height + h - attr.MiniEditHeight
	end
end

function LIST_ITEM_OnBind(self)
	--XLMessageBox("onbind")
end

function LIST_ITEM_OnInitControl(self)
	local attr = self:GetAttribute()
	
	local objBkg = self:GetControlObject("bkg")
	local l,t,r,b = objBkg:GetObjPos()
	objBkg:SetObjPos(l,t,r,l+attr.Height)
end

function NLI_Click(self)
	local list = self:GetOwnerControl()
	list:SetSel(self)
	
	local owner = list:GetOwnerControl()
	local objRight = owner:GetControlObject("right.content")
	objRight:DeleteAllItems()
	
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	local attr = self:GetAttribute()
	local data_info = operate.Search(table_data, "type", attr.Type)
		local data_show = operate.Search(data_info, "uid", attr.ID)
		for i=1, #data_show do
			obj = objFactory:CreateUIObject("listHead.Info."..i, "CoolJ.NotifyBox.Right.Item")
			obj:SetContent(data_show[i]["content"])
			local attr = obj:GetAttribute()
			obj:SetObjPos(0,0,attr.Width,attr.Height)
			objRight:InsertItem(obj)
		end
end