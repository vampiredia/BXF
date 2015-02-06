function OnInitControl(self)
	local attr = self:GetAttribute()
	local bkg = self:GetControlObject("bkg")
	--bkg:SetTextureID(attr.BorderTexture)
	
	--Page_Change(self, "ctrl_list", "ctrl_info")
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
	table.insert(attr.data, { IconResID = "", IconWidth = 0, LeftMargin = 10, TopMargin = 0, Text = "全部", Custom = nil, Func = nil, ID = 0 })
	self:SetText("全部")
end

function CBU_OnInitControl(self)
	local attr = self:GetAttribute()
	attr.data = {}
	table.insert(attr.data, { IconResID = "", IconWidth = 0, LeftMargin = 10, TopMargin = 0, Text = "全部", Custom = nil, Func = nil, ID = 0 })
	self:SetText("全部")
end

function CBR_OnInitControl(self)
	local attr = self:GetAttribute()
	attr.data = {}
	table.insert(attr.data, { IconResID = "", IconWidth = 0, LeftMargin = 10, TopMargin = 0, Text = "全部", Custom = nil, Func = nil, ID = 0 })
	self:SetText("全部")
end

function CBP_OnInitControl(self)
	local attr = self:GetAttribute()
	attr.data = {}
	local temp_data = {
		{id="0", text="全部"}, 
		{id="1", text="已缴费"},
		{id="2", text="未缴费"}
	}
	for i,v in ipairs(temp_data) do
		table.insert(attr.data, { IconResID = "", IconWidth = 0, LeftMargin = 10, TopMargin = 0, Text = v["text"], Custom = nil, Func = nil, ID = v["ID"] })
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
	local init_data = {id = "0", text = "全部"}
	table.insert(attr.data, { IconResID = "", IconWidth = 0, LeftMargin = 10, TopMargin = 0, Text = init_data["text"], Custom = nil, Func = nil, ID=init_data["id"] })
	self:SetText("全部")
end

function BTN_OnSearch(self)
	self:GetOwnerControl():GetBuildingInfo()
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

function OnClickInfoPageToListPage(self)
	--Page_Change(self:GetOwnerControl(), "ctrl_list", "ctrl_info")
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

function LBS_OnInitControl(self)
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	local headerTable = {
		{HeaderItemId='text', ItemWidth=160, Text="楼宇号", TextLeftOffset=7, TextHalign="left", SubItem=false, MaxSize=160, MiniSize=160, ShowSplitter=true, ShowSortIcon=false, IncludeNext=false, SortProperty=0},
		{HeaderItemId='status', ItemWidth=60, Text="状态", TextLeftOffset=7, TextHalign="left", SubItem=false, MaxSize=60, MiniSize=60, ShowSplitter=true, ShowSortIcon=false, IncludeNext=false, SortProperty=0},
		{HeaderItemId='pay', ItemWidth=70, Text="缴费状态", TextLeftOffset=7, TextHalign="left", SubItem=false, MaxSize=70, MiniSize=70, ShowSplitter=false, ShowSortIcon=false, IncludeNext=false, SortProperty=0},
		{HeaderItemId='other', ItemWidth=60, Text="", TextLeftOffset=2, TextHalign="left", SubItem=false, MaxSize=300, MiniSize=40, ShowSplitter=true, ShowSortIcon=false, IncludeNext=false, SortProperty=1}
	}
	table.foreach(headerTable, function(i, v) self:InsertColumn(v) end);
	self:ReloadHeader()
	--[[
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	local datasource = objFactory:CreateUIObject(1, "OwnerManager.DataSource")
	datasource:InitControl()
	local dataconverter = objFactory:CreateUIObject(2, "OwnerManager.DataConverter")
	dataconverter:InitControl()
	self:SetDataSourceAndDataConverter(datasource, dataconverter)
	self:ReloadData()
	]]
end

function LBS_OnHeaderItemPosChanged(self)
	if isDrag == true then
		self:GetTableViewObj():UpdateItemInfo(isDrag, GridInfoList)
	end
end

function LBS_OnItemEvent(self)

end

function LBU_OnInitControl(self)
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	local headerTable = {
		{HeaderItemId='name', ItemWidth=70, Text="姓名", TextLeftOffset=7, TextHalign="left", SubItem=false, MaxSize=70, MiniSize=70, ShowSplitter=true, ShowSortIcon=false, IncludeNext=false, SortProperty=0},
		{HeaderItemId='relation', ItemWidth=60, Text="关系", TextLeftOffset=7, TextHalign="left", SubItem=false, MaxSize=60, MiniSize=60, ShowSplitter=true, ShowSortIcon=false, IncludeNext=false, SortProperty=0},
		{HeaderItemId='telphone', ItemWidth=110, Text="电话", TextLeftOffset=7, TextHalign="left", SubItem=false, MaxSize=110, MiniSize=110, ShowSplitter=false, ShowSortIcon=false, IncludeNext=false, SortProperty=0},
		{HeaderItemId='status', ItemWidth=60, Text="状态", TextLeftOffset=7, TextHalign="left", SubItem=false, MaxSize=60, MiniSize=60, ShowSplitter=false, ShowSortIcon=false, IncludeNext=false, SortProperty=0},
		{HeaderItemId='other', ItemWidth=60, Text="", TextLeftOffset=2, TextHalign="left", SubItem=false, MaxSize=300, MiniSize=40, ShowSplitter=true, ShowSortIcon=false, IncludeNext=false, SortProperty=1}
	}
	table.foreach(headerTable, function(i, v) self:InsertColumn(v) end);
	self:ReloadHeader()
	--[[
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	local datasource = objFactory:CreateUIObject(1, "OwnerManager.DataSource")
	datasource:InitControl()
	local dataconverter = objFactory:CreateUIObject(2, "OwnerManager.DataConverter")
	dataconverter:InitControl()
	self:SetDataSourceAndDataConverter(datasource, dataconverter)
	self:ReloadData()
	]]
end

function LBU_OnHeaderItemPosChanged(self)
	if isDrag == true then
		self:GetTableViewObj():UpdateItemInfo(isDrag, GridInfoList)
	end
end

function LBU_OnItemEvent(self)

end

function SearchOwnerInfo(self)
	
end

function GetUserInfo(self)

end

function GetBuildingInfo(self)
	local request = function(ret, msg, result)
		if ret == 0 then
			local obj = self:GetControlObject("cb.building")
			local attr = obj:GetAttribute()
			attr.data = {}
			table.insert(attr.data, { IconResID = "", IconWidth = 0, LeftMargin = 10, TopMargin = 0, Text = "全部", Custom = nil, Func = nil, ID = 0 })
			for i,v in ipairs(result['building_list']) do
				table.insert(attr.data, { IconResID = "", IconWidth = 0, LeftMargin = 10, TopMargin = 0, Text = v["text"], Custom = nil, Func = nil, ID = v["id"] })
			end
			obj:SetText("全部")
			self:UnitInit()
			self:RoomInit()
		else
			AddNotify(self, msg, 5000)
		end
	end
	local param = ""
	HttpRequest("/api/user?action=building", "GET", param, request)
end

function GetUnitInfo(self, bid)
	local request = function(ret, msg, result)
		if ret == 0 then
			local obj = self:GetControlObject("cb.unit")
			local attr = obj:GetAttribute()
			attr.data = {}
			table.insert(attr.data, { IconResID = "", IconWidth = 0, LeftMargin = 10, TopMargin = 0, Text = "全部", Custom = nil, Func = nil, ID = 0 })
			for i,v in ipairs(result['unit_list']) do
				table.insert(attr.data, { IconResID = "", IconWidth = 0, LeftMargin = 10, TopMargin = 0, Text = v["text"], Custom = nil, Func = nil, ID = v["id"] })
			end
			obj:SetText("全部")
			self:RoomInit()
		else
			AddNotify(self, msg, 5000)
		end
	end
	local param = ""
	HttpRequest("/api/user?action=unit&building="..bid, "GET", param, request)
end

function GetRoomInfo(self, bid, uid)
	local request = function(ret, msg, result)
		if ret == 0 then
			local obj = self:GetControlObject("cb.room")
			local attr = obj:GetAttribute()
			attr.data = {}
			table.insert(attr.data, { IconResID = "", IconWidth = 0, LeftMargin = 10, TopMargin = 0, Text = "全部", Custom = nil, Func = nil, ID = 0 })
			for i,v in ipairs(result['room_list']) do
				table.insert(attr.data, { IconResID = "", IconWidth = 0, LeftMargin = 10, TopMargin = 0, Text = v["text"], Custom = nil, Func = nil, ID = v["id"] })
			end
			obj:SetText("全部")
		else
			AddNotify(self, msg, 5000)
		end
	end
	local param = ""
	HttpRequest("/api/user?action=room&building="..bid.."&unit="..uid, "GET", param, request)
end

function UnitInit(self)
	local obj = self:GetControlObject("cb.unit")
	local attr = obj:GetAttribute()
	attr.data = {}
	table.insert(attr.data, { IconResID = "", IconWidth = 0, LeftMargin = 10, TopMargin = 0, Text = "全部", Custom = nil, Func = nil, ID = 0 })
	obj:SetText("全部")
end

function BuildingInit(self)
	local obj = self:GetControlObject("cb.building")
	local attr = obj:GetAttribute()
	attr.data = {}
	table.insert(attr.data, { IconResID = "", IconWidth = 0, LeftMargin = 10, TopMargin = 0, Text = "全部", Custom = nil, Func = nil, ID = 0 })
	obj:SetText("全部")
end

function RoomInit(self)
	local obj = self:GetControlObject("cb.room")
	local attr = obj:GetAttribute()
	attr.data = {}
	table.insert(attr.data, { IconResID = "", IconWidth = 0, LeftMargin = 10, TopMargin = 0, Text = "全部", Custom = nil, Func = nil, ID = 0 })
	obj:SetText("全部")
end

function CBB_OnSelectItemChanged(self, eventname, id, focus)
	local attr = self:GetAttribute()
	selectID = self:GetOwnerControl():GetSelectID(self) + 0
	if focus == false then return end
	if selectID > 0 then
		self:GetOwnerControl():GetUnitInfo(selectID)
		self:GetOwnerControl():RoomInit()
	else
		self:GetOwnerControl():UnitInit()
		self:GetOwnerControl():RoomInit()
	end
end

function GetSelectID(self, obj)
	local attr = obj:GetAttribute()
	local selectData = attr.data[attr.select]
	return selectData["ID"]
end

function CBU_OnSelectItemChanged(self, eventname, id, focus)
	local attr = self:GetAttribute()
	selectID = self:GetOwnerControl():GetSelectID(self) + 0
	bid = self:GetOwnerControl():GetSelectID(self:GetOwnerControl():GetControlObject("cb.building")) + 0
	if focus == false then return end
	if selectID > 0 then
		self:GetOwnerControl():GetRoomInfo(bid, selectID)
	else
		self:GetOwnerControl():RoomInit()
	end
end