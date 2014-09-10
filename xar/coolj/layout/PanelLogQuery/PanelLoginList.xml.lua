function OnInitControl(self)
	local attr = self:GetAttribute()
	local bkg = self:GetControlObject("bkg")
	--bkg:SetTextureID(attr.BorderTexture)
end

function LC_OnInitControl(self)
	self:InsertColumn("name", 75, "管理员", "left", "center", 5, true, 20)
	self:InsertColumn("login_time", 150, "登录时间", "left", "center", 5, true, 20)
	self:InsertColumn("login_state", 90, "状态", "left", "center", 5, true, 20)
	self:InsertColumn("login_ip", 145, "登录IP", "left", "center", 5, true, 20)
	self:InsertColumn("login_op", 90, "操作", "left", "center", 5, true, 20)
	
	local list_item_data = {}
	table.insert(list_item_data, {name="黄蓉", login_time="2014-02-02 12:31", login_state="登录成功", login_ip="127.0.0.1", login_op="查看操作日志"})
	table.insert(list_item_data, {name="黄蓉", login_time="2014-02-02 12:31", login_state="登录成功", login_ip="127.0.0.1", login_op="查看操作日志"})
	table.insert(list_item_data, {name="黄蓉", login_time="2014-02-02 12:31", login_state="登录成功", login_ip="127.0.0.1", login_op="查看操作日志"})
	table.insert(list_item_data, {name="黄蓉", login_time="2014-02-02 12:31", login_state="登录成功", login_ip="127.0.0.1", login_op="查看操作日志"})
	table.insert(list_item_data, {name="黄蓉", login_time="2014-02-02 12:31", login_state="登录成功", login_ip="127.0.0.1", login_op="查看操作日志"})
	table.insert(list_item_data, {name="黄蓉", login_time="2014-02-02 12:31", login_state="登录成功", login_ip="127.0.0.1", login_op="查看操作日志"})
	table.insert(list_item_data, {name="黄蓉", login_time="2014-02-02 12:31", login_state="登录成功", login_ip="127.0.0.1", login_op="查看操作日志"})
	table.insert(list_item_data, {name="黄蓉", login_time="2014-02-02 12:31", login_state="登录成功", login_ip="127.0.0.1", login_op="查看操作日志"})
	table.insert(list_item_data, {name="黄蓉", login_time="2014-02-02 12:31", login_state="登录成功", login_ip="127.0.0.1", login_op="查看操作日志"})
	table.insert(list_item_data, {name="黄蓉", login_time="2014-02-02 12:31", login_state="登录成功", login_ip="127.0.0.1", login_op="查看操作日志"})
	table.insert(list_item_data, {name="黄蓉", login_time="2014-02-02 12:31", login_state="登录成功", login_ip="127.0.0.1", login_op="查看操作日志"})
	table.insert(list_item_data, {name="黄蓉", login_time="2014-02-02 12:31", login_state="登录成功", login_ip="127.0.0.1", login_op="查看操作日志"})
	table.insert(list_item_data, {name="黄蓉", login_time="2014-02-02 12:31", login_state="登录成功", login_ip="127.0.0.1", login_op="查看操作日志"})
	table.insert(list_item_data, {name="黄蓉", login_time="2014-02-02 12:31", login_state="登录成功", login_ip="127.0.0.1", login_op="查看操作日志"})
	table.insert(list_item_data, {name="黄蓉", login_time="2014-02-02 12:31", login_state="登录成功", login_ip="127.0.0.1", login_op="查看操作日志"})
	
	self:InsertItemList(list_item_data, true)
	
end

function LC_OnListItemClick(self)

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