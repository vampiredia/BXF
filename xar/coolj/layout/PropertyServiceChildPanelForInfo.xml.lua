-------------------------------------------------------------------------------
-- global values for table list view
-------------------------------------------------------------------------------
local table_service = nil
local json = require('json')

local operation = {}
local GlobalObj = {}
local GlobalDataTable = {}
local GlobalControl = nil

-------------------------------------------------------------------------------
-- list view for first service
-------------------------------------------------------------------------------
local GlobalListView = nil

-- Item in List View's Factory
function GetItemFactory()
	local callbackTable = {}
	local userdata = nil
	
	callbackTable.CreateObject = 
		function (userdata, column)
			local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
			local itemObj = nil
			if column == 1 then 
				itemObj = objFactory:CreateUIObject(nil, "TextObject") 
			elseif column == 4 then
				itemObj = objFactory:CreateUIObject(nil, "CoolJ.Telphone.ListView")
				local cookie, ret = itemObj:AttachListener("OnEditChange", true, LV_OnEditChange)
			elseif column == 5 then 
				itemObj = objFactory:CreateUIObject(nil, "WHome.Button")
				itemObj:GetAttribute().NormalBkgID = "blue.big.button.normal"
				itemObj:GetAttribute().DownBkgID = "blue.big.button.down"
				itemObj:GetAttribute().HoverBkgID = "blue.big.button.hover"
				local cookie, ret = itemObj:AttachListener("OnClick", true, LV_OnClick)
				itemObj:SetText("删")
				itemObj:SetVisible(false)
			else
				itemObj = objFactory:CreateUIObject(nil,"WHome.Edit")
				local attr = itemObj:GetAttribute()
				attr.ReadOnly = true
				itemObj:SetBorder(false)
				itemObj:SetReadOnly(true)

				local cookie, ret = itemObj:AttachListener("OnEditChange", true, LV_OnEditChange)			
			end
			table.insert(GlobalObj, itemObj)
			
			return itemObj
		end
		
	-- table 列宽
	callbackTable.GetRowHeight = 
		function (userdata)
			return 26
		end
		
	-- table 行宽
	callbackTable.GetColumnWidth = 
		function (userdata, column, widthInAll)
			-- first column is nil, just for space
			local colWidth = {5, 110, 380, 155, 25}
			return colWidth[column]
		end
		
	callbackTable.SetItemData = 
		function(userdata, itemObj, data, row, column)
			if itemObj == nil then return end
			
			if column == 1 then 
				itemObj:SetText(data)
				itemObj:SetVisible(false)
				return 
			elseif column ~= 5 then
				itemObj:SetText(data)
			end
			
			itemObj:GetAttribute().row = row
			itemObj:GetAttribute().column = column
		end
		
	callbackTable.SetItemPos2 = 
		function (userdata, itemObj, left, top, width, height)
			if itemObj~=nil and itemObj:GetClass()=="WHome.Button" then
				itemObj:SetObjPos2(left, top, 25, 26)
			end
			if itemObj~=nil then
				itemObj:SetObjPos2(left, top, width, height) 
			end			
		end
		
	return userdata, callbackTable
end

--
function GetDataModelObject()
local callbackTable = {}
	local nameList = {"", "信息类型", "详细", "联系电话", ""}
	callbackTable.GetCount = 
		function (userdata)
			return #GlobalDataTable
		end
	callbackTable.GetColumnCount=
		function (userdata)
			return #nameList
		end
	callbackTable.GetColumnNameList =
		function (userdata)
			return nameList			
		end
	callbackTable.GetItemAtIndex = 
		function (userdata, row, column)
			if GlobalDataTable[row] ~= nil then
				if column == 1 then return GlobalDataTable[row]['id'] end
				if column == 2 then return GlobalDataTable[row]['name'] end
				if column == 3 then return GlobalDataTable[row]['content'] end
				if column == 4 then 
					local contact = {area=GlobalDataTable[row]['area_code'], telphone=GlobalDataTable[row]['telphone']}
					return contact
				end
			end
			return nil
		end
	callbackTable.SetDataChangeListener = 
		function (userdata, dataChangedListener)
			callbackTable.DataChangeListener = dataChangedListener
		end

	
	-- add item
	operation.AddItem =
		function (row)
			if row == nil then row = #GlobalDataTable + 1 end
			local count = #GlobalDataTable
			for r=row+1, count+1 do
				GlobalDataTable[r] = GlobalDataTable[r-1]
			end
			GlobalDataTable[row]={id="new", name="", content="", area_code="", telphone=""}
			if callbackTable.DataChangeListener ~= nil then
				callbackTable.DataChangeListener(row, count+1)
			end
			operation.Update(#GlobalDataTable)
		end
	-- del item
	operation.DelItem = 
		function (row)
			if row == nil then return end
			local count = #GlobalDataTable
			if count > 0 then
				for r=row, count do
					GlobalDataTable[r] = GlobalDataTable[r+1]
				end
			end
			if callbackTable.DataChangeListener ~= nil then
				callbackTable.DataChangeListener(row, count)
			end
			operation.Update(#GlobalDataTable)
		end
	-- change text
	operation.ChangeItem = 
		function (row, column, text)
			if column == 2 then GlobalDataTable[row]['name'] = text end
			if column == 3 then GlobalDataTable[row]['content'] = text end
			if column == 4 then 
				GlobalDataTable[row]['area_code'] = text['area']
				GlobalDataTable[row]['telphone'] = text['telphone']
			end
			if callbackTable.DataChangeListener ~= nil then
				callbackTable.DataChangeListener(row, row)
			end
		end
	operation.Check = 
		function ()
			for i=1, #GlobalDataTable do
				if GlobalDataTable[i].name == "" or GlobalDataTable[i].telphone == "" then
					table.remove(GlobalDataTable, i)
					operation.Check()
					break
				end
			end
		end
	-- save all data
	operation.Save =
		function ()
			operation.Check()
			if #GlobalDataTable > 0 then
				if callbackTable.DataChangeListener ~= nil then callbackTable.DataChangeListener(1, #GlobalDataTable) end				
			end			
		end
	-- load data
	operation.LoadData = 
		function ()
			if #GlobalDataTable > 0 then
				if callbackTable.DataChangeListener ~= nil then callbackTable.DataChangeListener(1, #GlobalDataTable) end				
			end
		end
	operation.Update = 
		function(row)
			local count = #GlobalDataTable
			for i=1, #GlobalObj do
				local obj = GlobalObj[i]
				if obj:GetClass() == "TextObject" then 
				
				elseif obj:GetClass() == "WHome.Button" then
					if obj:GetAttribute().row == row then
						obj:SetText("加")
					else
						obj:SetText("删")
					end
				else
					if obj:GetAttribute().row == row then
						obj:SetVisible(false)
						obj:SetChildrenVisible(false)
					else
						obj:SetVisible(true)
						obj:SetChildrenVisible(true)
					end
				end
			end			
		end
	-- edit
	operation.Edit = 
		function ()
			local row = #GlobalDataTable + 1
			GlobalDataTable[row]={id="add", name="", content="", area_code="", telphone=""}
			if callbackTable.DataChangeListener ~= nil then
				callbackTable.DataChangeListener(row, row)
			end
			operation.Update(row)
		end
	
	return nil, callbackTable
end

function LV_OnClick(self)
	if self:GetText() == "删" then 
		operation.DelItem(self:GetAttribute().row) 
	elseif self:GetText() == "加" then 
		operation.AddItem(self:GetAttribute().row) 
	end
end

function LV_OnEditChange(self)
	local text = self:GetText()
	local row = self:GetAttribute().row
	local column = self:GetAttribute().column
	
	operation.ChangeItem(row, column, text)
end

-------------------------------------------------------------------------------
--
function OnInitControl(self)
	local attr = self:GetAttribute()
	local bkg = self:GetControlObject("bkg")
	--bkg:SetTextureID(attr.BorderTexture)
end

function LC_Info_OnInitControl(self)
	self:InsertColumn("name", 110, "信息类型", "left", "center", 5, true, 110)
	self:InsertColumn("telphone", 210, "详细", "left", "center", 5, true, 140)
	
	--AsynCall(function() self:GetOwnerControl():Get_PropertyServiceInfo() end )
end

function LC_Address_OnInitControl(self)
	--self:InsertColumn("address", 330, "通信地址", "left", "left", 5, true, 200)
end

function LC_Pay_OnInitControl(self)
	--self:InsertColumn("payinfo", 330, "缴费账号", "left", "left", 5, true, 200)
end

function PanelInit(self)
	for i=1, #GlobalObj do
		local obj = GlobalObj[i]
		if obj:GetClass() == "WHome.Button" then obj:SetVisible(false) end
		if obj:GetClass() == "WHome.Edit" or obj:GetClass() == "CoolJ.Telphone.ListView" then
			obj:SetBorder(false)
			obj:SetReadOnly(true)
		end
	end
	
	self:GetControlObject("btn.edit.info"):SetText("编辑")
end

function Get_PropertyServiceInfo(self)
	PanelInit(self)
	
	local httpclient = XLGetObject("Whome.HttpCore.Factory"):CreateInstance()
	httpclient:AttachResultListener(
		function(result) 
			local response = json.decode(result)
			if response['ret'] == 0 then
				GlobalDataTable = response['result']['service']
				operation.LoadData()
			end
		end
	)
	url = "/service/community?action=get_estate_contact_list"
	httpclient:Perform(url, "GET", "")		
end

function Set_PropertyServiceInfo(self)
	local httpclient = XLGetObject("Whome.HttpCore.Factory"):CreateInstance()
	httpclient:AttachResultListener(
		function(result) 
			local response = json.decode(result)
			if response['ret'] == 0 then
				--GlobalDataTable = response['result']['service']
				--operation.LoadData()
				--XLMessageBox("OK")
			end
		end
	)
	local param = "action=estate_contact_info&service="..httpclient:EscapeParam(json.encode(GlobalDataTable))
	local url = "/service/community"
	httpclient:Perform(url, "POST", param)		
end

function OnInitControl_ListView(self)
	GlobalListView = self
	
	local itemFactoryUserData, itemFactoryCallbackTable = GetItemFactory()
	self:SetItemFactory(itemFactoryUserData, nil, itemFactoryCallbackTable)
	
	local dataModelUserData, dataModelCallbackTable = GetDataModelObject()
	self:SetDataModel(dataModelUserData, dataModelCallbackTable)	
end

function OnDestroy_ListView(self)

end

function EDIT_OnClick(self)
	--XLMessageBox(self:GetText())
	if self:GetText() == "编辑" then
		for i=1, #GlobalObj do
			local obj = GlobalObj[i]
			if obj:GetClass() == "WHome.Button" then obj:SetVisible(true) end
			if obj:GetClass() == "WHome.Edit" or obj:GetClass() == "CoolJ.Telphone.ListView" then
				obj:SetBorder(true)
				obj:SetReadOnly(false)
			end
		end
		self:SetText("保存")
		
		-- edit
		operation.Edit()
	elseif self:GetText() == "保存" then
		for i=1, #GlobalObj do
			local obj = GlobalObj[i]
			if obj:GetClass() == "WHome.Button" then obj:SetVisible(false) end
			if obj:GetClass() == "WHome.Edit" or obj:GetClass() == "CoolJ.Telphone.ListView" then
				obj:SetBorder(false)
				obj:SetReadOnly(true)
			end
		end
		self:SetText("编辑")
		
		-- save
		operation.Save()
		
		Set_PropertyServiceInfo(self:GetOwnerControl())
	end
end