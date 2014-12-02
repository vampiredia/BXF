function OnInitControl(self)
	local attr = self:GetAttribute()
	local bkg = self:GetControlObject("bkg")
	--bkg:SetTextureID(attr.BorderTexture)
	
	--Page_Change(self, "ctrl_list", "ctrl_info")
	Page_Change(self, "ctrl_info", "ctrl_list")
end

function LC_OnPublicInitControl(self)
	self:InsertColumn("name", 70, "姓名", "left", "center", 5, true, 20)
	self:InsertColumn("phone", 90, "电话", "left", "center", 5, true, 20)
	self:InsertColumn("xz", 60, "性质", "left", "center", 5, true, 20)
	self:InsertColumn("sfz", 150, "身份证", "left", "center", 5, true, 20)
	self:InsertColumn("lyxx", 145, "楼宇信息", "left", "center", 5, true, 20)
	self:InsertColumn("operate", 90, "操作", "left", "center", 5, true, 20)
	self:InsertColumn("status", 70, "缴费状态", "left", "center", 5, true, 20)
	
	local list_item_data = {}
	table.insert(list_item_data, {name="黄蓉", phone="13920001989", xz="业主", sfz="110122198702051110", lyxx="1号楼 2单元 301", operate="编辑 详情", status="已缴费"})
	table.insert(list_item_data, {name="黄蓉", phone="13920001989", xz="业主", sfz="110122198702051110", lyxx="1号楼 2单元 301", operate="编辑 详情", status="已缴费"})
	table.insert(list_item_data, {name="黄蓉", phone="13920001989", xz="业主", sfz="110122198702051110", lyxx="1号楼 2单元 301", operate="编辑 详情", status="已缴费"})
	table.insert(list_item_data, {name="黄蓉", phone="13920001989", xz="业主", sfz="110122198702051110", lyxx="1号楼 2单元 301", operate="编辑 详情", status="已缴费"})
	table.insert(list_item_data, {name="黄蓉", phone="13920001989", xz="业主", sfz="110122198702051110", lyxx="1号楼 2单元 301", operate="编辑 详情", status="已缴费"})
	table.insert(list_item_data, {name="黄蓉", phone="13920001989", xz="业主", sfz="110122198702051110", lyxx="1号楼 2单元 301", operate="编辑 详情", status="已缴费"})
	table.insert(list_item_data, {name="黄蓉", phone="13920001989", xz="业主", sfz="110122198702051110", lyxx="1号楼 2单元 301", operate="编辑 详情", status="已缴费"})
	table.insert(list_item_data, {name="黄蓉", phone="13920001989", xz="业主", sfz="110122198702051110", lyxx="1号楼 2单元 301", operate="编辑 详情", status="已缴费"})
	table.insert(list_item_data, {name="黄蓉", phone="13920001989", xz="业主", sfz="110122198702051110", lyxx="1号楼 2单元 301", operate="编辑 详情", status="已缴费"})
	table.insert(list_item_data, {name="黄蓉", phone="13920001989", xz="业主", sfz="110122198702051110", lyxx="1号楼 2单元 301", operate="编辑 详情", status="已缴费"})
	table.insert(list_item_data, {name="黄蓉", phone="13920001989", xz="业主", sfz="110122198702051110", lyxx="1号楼 2单元 301", operate="编辑 详情", status="已缴费"})
	table.insert(list_item_data, {name="黄蓉", phone="13920001989", xz="业主", sfz="110122198702051110", lyxx="1号楼 2单元 301", operate="编辑 详情", status="已缴费"})
	table.insert(list_item_data, {name="黄蓉", phone="13920001989", xz="业主", sfz="110122198702051110", lyxx="1号楼 2单元 301", operate="编辑 详情", status="已缴费"})
	table.insert(list_item_data, {name="黄蓉", phone="13920001989", xz="业主", sfz="110122198702051110", lyxx="1号楼 2单元 301", operate="编辑 详情", status="已缴费"})
	table.insert(list_item_data, {name="黄蓉", phone="13920001989", xz="业主", sfz="110122198702051110", lyxx="1号楼 2单元 301", operate="编辑 详情", status="已缴费"})
	
	self:InsertItemList(list_item_data, true)
	
end

function LC_OnListItemClick(self)

end

function RG_OnInitControl(self)
	local attr = self:GetAttribute()
	attr.SelectedButtonID = "address"

	self:AddRadioButton("address","住址查找",0,0,100,24)
	self:AddRadioButton("name","姓名查找",150,0,100,24)
	self:AddRadioButton("pay","缴费状态",300,0,100,24)
	
	SearchConditionChange(self:GetOwnerControl(), attr.SelectedButtonID)
end

function CBB_OnInitControl(self)
	local attr = self:GetAttribute()
	attr.data = {}
	local temp_data = {"全部", "1", "2", "3", "4", "5"}
	for i,valid_time in ipairs(temp_data) do
		table.insert(attr.data, { IconResID = "", IconWidth = 0, LeftMargin = 10, TopMargin = 0, Text = valid_time, Custom = nil, Func = nil })
	end
	self:SetText("全部")
end

function CBPY_OnInitControl(self)
	local attr = self:GetAttribute()
	attr.data = {}
	local temp_data = {"业主"}
	for i,valid_time in ipairs(temp_data) do
		table.insert(attr.data, { IconResID = "", IconWidth = 0, LeftMargin = 10, TopMargin = 0, Text = valid_time, Custom = nil, Func = nil })
	end
	self:SetText("业主")
end

function CBU_OnInitControl(self)
	local attr = self:GetAttribute()
	attr.data = {}
	local temp_data = {"全部", "1", "2", "3"}
	for i,valid_time in ipairs(temp_data) do
		table.insert(attr.data, { IconResID = "", IconWidth = 0, LeftMargin = 10, TopMargin = 0, Text = valid_time, Custom = nil, Func = nil })
	end
	self:SetText("全部")
end

function CBF_OnInitControl(self)
	local attr = self:GetAttribute()
	attr.data = {}
	local temp_data = {"全部", "1", "2", "3"}
	for i,valid_time in ipairs(temp_data) do
		table.insert(attr.data, { IconResID = "", IconWidth = 0, LeftMargin = 10, TopMargin = 0, Text = valid_time, Custom = nil, Func = nil })
	end
	self:SetText("全部")
end

function CBR_OnInitControl(self)
	local attr = self:GetAttribute()
	attr.data = {}
	local temp_data = {"全部", "1", "2", "3"}
	for i,valid_time in ipairs(temp_data) do
		table.insert(attr.data, { IconResID = "", IconWidth = 0, LeftMargin = 10, TopMargin = 0, Text = valid_time, Custom = nil, Func = nil })
	end
	self:SetText("全部")
end

function CBP_OnInitControl(self)
	local attr = self:GetAttribute()
	attr.data = {}
	local temp_data = {"全部", "已缴费", "未缴费"}
	for i,valid_time in ipairs(temp_data) do
		table.insert(attr.data, { IconResID = "", IconWidth = 0, LeftMargin = 10, TopMargin = 0, Text = valid_time, Custom = nil, Func = nil })
	end
	self:SetText("全部")
end

function SearchConditionChange(self, selectID)
	if self:GetClass() ~= "CoolJ.OwnerManagementChildPanelForOwnerManagement" then return end
	
	if selectID == "address" then
		self:GetControlObject("layout.address"):SetChildrenVisible(true)
		self:GetControlObject("layout.name"):SetChildrenVisible(false)
		self:GetControlObject("layout.pay"):SetChildrenVisible(false)
	elseif selectID == "name" then
		self:GetControlObject("layout.address"):SetChildrenVisible(false)
		self:GetControlObject("layout.name"):SetChildrenVisible(true)
		self:GetControlObject("layout.pay"):SetChildrenVisible(false)
	elseif selectID == "pay" then
		self:GetControlObject("layout.address"):SetChildrenVisible(false)
		self:GetControlObject("layout.name"):SetChildrenVisible(false)
		self:GetControlObject("layout.pay"):SetChildrenVisible(true)
	else
		self:GetControlObject("layout.address"):SetChildrenVisible(true)
		self:GetControlObject("layout.name"):SetChildrenVisible(false)
		self:GetControlObject("layout.pay"):SetChildrenVisible(false)
	end
end

function RG_OnButtonSelectedChanged(self)
	local attr = self:GetAttribute()
	SearchConditionChange(self:GetOwnerControl(), attr.SelectedButtonID)
end

function CBN_OnInitControl(self)
	local attr = self:GetAttribute()
	attr.data = {}
	local temp_data = {"全部", "李天一", "李天二", "李天三"}
	for i,valid_time in ipairs(temp_data) do
		table.insert(attr.data, { IconResID = "", IconWidth = 0, LeftMargin = 10, TopMargin = 0, Text = valid_time, Custom = nil, Func = nil })
	end
	self:SetText("全部")	
end

function BTN_OnSearch(self)
	
end

function Page_Change(self, newPage, oldPage)
	local hidePage = self:GetControlObject(oldPage)
	if hidePage ~= nil then 
		hidePage:SetVisible(false)
		hidePage:SetChildrenVisible(false)
	end
	
	local showPage = self:GetControlObject(newPage)
	if showPage ~= nil then 
		showPage:SetVisible(true)
		showPage:SetChildrenVisible(true)
	end
end

function LC_OnListItemDbClick(self)
	Page_Change(self:GetOwnerControl(), "ctrl_info", "ctrl_list")
end

function OnClickInfoPageToListPage(self)
	Page_Change(self:GetOwnerControl(), "ctrl_list", "ctrl_info")
end

function BTN_OnSave(self)
 
end

function CCP_OnCheck(self, event, state, bClick)
	if event ~= 'OnCheck' then return end
	
	local owner = self:GetOwnerControl()
	local attr = owner:GetAttribute()
	attr.IsCheck = state
	--NoticePosInit(owner)
	--XLMessageBox(owner:GetID())
	if state then
		self:SetText("身份已验证")
	else
		self:SetText("身份未验证")
	end
end