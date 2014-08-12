-------------------------------------------------------------------------------
-- global values for table list view
-------------------------------------------------------------------------------
--local json_data = '{ "error_msg": "成功", "result": { "service_list": [ { "id": 2, "name": "蔬菜水果", "service": [] }, { "id": 1, "name": "家电维修", "service": [ { "area_code": null, "content": "50元/台", "id": 8, "name": "空调加氟", "pid": 1, "telphone": "13810030293" }, { "area_code": "010", "content": "30元/个", "id": 9, "name": "电脑维修", "pid": 1, "telphone": "8222222" }, { "area_code": null, "content": "无上门费", "id": 5, "name": "电视", "pid": 1, "telphone": "18601082187" }, { "area_code": null, "content": "无上门费", "id": 6, "name": "电冰箱", "pid": 1, "telphone": "13898712120" }, { "area_code": null, "content": "无上们分", "id": 7, "name": "空调移机", "pid": 1, "telphone": "13827362819" } ] }, { "id": 11, "name": "烟酒饮料", "service": [] }, { "id": 10, "name": "宽带服务", "service": [] }, { "id": 4, "name": "饮用水", "service": [] }, { "id": 2, "name": "蔬菜水果", "service": [] } ], "stime": 1405328297 }, "ret": 0 }'
local table_service = nil
local json = require('json')

local operation = {}

local GlobalObj = {}
local GlobalDataTable = {}
local GlobalReadOnly = true
local GlobalControl = nil
--GlobalDataTable = json.decode(json_data).result.service_list

-- operation
operation.Edit = 
	function ()
		for i=1, #GlobalObj do
			local obj = GlobalObj[i]
			if obj:GetClass() == "WHome.Edit" then
				obj:SetBorder(true)
				obj:SetReadOnly(false)					
			end
			if obj:GetClass() == "WHome.Button" then 
				obj:SetText("删")
				obj:SetVisible(true) 
			end
		end
	end

operation.Save = 
	function ()
		for i=1, #GlobalObj do
			local obj = GlobalObj[i]
			if obj:GetClass() == "WHome.Edit" then
				obj:SetBorder(false)
				obj:SetReadOnly(true)					
			end

			if obj:GetClass() == "WHome.Button" and obj:GetAttribute().service == "main" then 
				obj:SetText("查") 
			end
			if obj:GetClass() == "WHome.Button" and obj:GetAttribute().service == "sub" then 
				obj:SetVisible(false)
			end
		end
		
		operation.MainSave()
		operation.SubSave()
		--XLMessageBox(json.encode(GlobalDataTable))
		operation.Check()
	end
	
operation.Check = 
	function ()
		for i=1, #GlobalDataTable do
			GlobalDataTable[i]['id'] = i
			for j=1, #GlobalDataTable[i]['service'] do
				GlobalDataTable[i]['service'][j]['id'] = j
				GlobalDataTable[i]['service'][j]['pid'] = i
			end
		end
	end

-------------------------------------------------------------------------------
-- list view for first service
-------------------------------------------------------------------------------
local GlobalMainListView = nil 

function GetMainItemFactory()
	local callbackTable = {}
	local userdata = nil
	
	callbackTable.CreateObject = 
		function (userdata, column)
			local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
			local itemObj = nil
			if column == 1 then 
				itemObj = objFactory:CreateUIObject(nil, "TextObject") 
			end
			if column == 2 then 
				itemObj = objFactory:CreateUIObject(nil,"WHome.Edit")
				itemObj:SetBorder(not GlobalReadOnly)
				itemObj:SetReadOnly(GlobalReadOnly)
				local cookie, ret = itemObj:AttachListener("OnEditChange", true, OnEditChange)
				table.insert(GlobalObj, itemObj)
			end
			if column == 3 then 
				itemObj = objFactory:CreateUIObject(nil, "WHome.Button")
				itemObj:GetAttribute().NormalBkgID = "blue.big.button.normal"
				itemObj:GetAttribute().DownBkgID = "blue.big.button.down"
				itemObj:GetAttribute().HoverBkgID = "blue.big.button.hover"
				itemObj:SetText("查")
				local cookie, ret = itemObj:AttachListener("OnClick", true, MLV_OnClick)
				table.insert(GlobalObj, itemObj)
			end
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
			local colWidth = {5, 110, 25}
			return colWidth[column]
		end
		
	callbackTable.SetItemData = 
		function(userdata, itemObj, data, row, column)
			if itemObj == nil then return end
			
			if column == 1 then 
				itemObj:SetText(data)
				itemObj:SetVisible(false)
				return 
			elseif column == 2 then
				itemObj:SetText(data)
			end
			
			itemObj:GetAttribute().service = "main"
			itemObj:GetAttribute().row = row
			itemObj:GetAttribute().column = column
		end
		
	callbackTable.SetItemPos2 = 
		function (userdata, itemObj, left, top, width, height)
			if itemObj~=nil and itemObj:GetClass()=="WHome.Button" then
				itemObj:SetObjPos2(left, top, 25, 26)
			end
			if itemObj~=nil and itemObj:GetClass()=="WHome.Edit" then
				itemObj:SetObjPos2(left, top, width, height) 
			end
			if itemObj~=nil and itemObj:GetClass()=="TextObject" then
				itemObj:SetObjPos2(left, top, width, height) 
			end
		end
	
	return userdata, callbackTable
end

function GetMainDataModelObject()
	local callbackTable = {}
	local nameList = {"", "服务类型", ""}
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
			end
			return nil
		end
	callbackTable.SetDataChangeListener = 
		function (userdata, dataChangedListener)
			callbackTable.DataChangeListener = dataChangedListener
		end

	operation.MainAdd = 
		function (row, data)
			if row == nil then row = #GlobalDataTable + 1 end
			local count = #GlobalDataTable
			for r=row+1, count+1 do
				GlobalDataTable[r] = GlobalDataTable[r-1]
			end
			GlobalDataTable[row]={id="new", name=data, service={}}
			if callbackTable.DataChangeListener ~= nil then
				callbackTable.DataChangeListener(row, count+1)
			end
			--XLMessageBox(json.encode(GlobalDataTable))
		end
	
	operation.MainDel = 
		function (row)
			local count = #GlobalDataTable
			if count > 0 then
				for r=row,count do
					GlobalDataTable[r] = GlobalDataTable[r+1]
				end
			end
			if callbackTable.DataChangeListener ~= nil then
				callbackTable.DataChangeListener(row, count)
			end
			
			-- 删除二级页面
			operation.SubLoadData(math.min(#GlobalDataTable, row))
			--XLMessageBox(json.encode(GlobalDataTable))
		end
	
	operation.MainChange = 
		function (row, column, text)
			GlobalDataTable[row]['name'] = text
			if callbackTable.DataChangeListener ~= nil then
				callbackTable.DataChangeListener(row, row)
			end
		end
		
	operation.MainSave = 
		function ()
			data_unsafe = {}
			for i=1, #GlobalDataTable do
				if GlobalDataTable[i]['name'] == "" then table.insert(data_unsafe, i) end
			end
			for i=#data_unsafe, 1, -1 do
				operation.MainDel(data_unsafe[i])
			end
		end
	
	-- 加载动态数据
	operation.MainLoadData = 
		function ()
			if #GlobalDataTable > 0 then
				if callbackTable.DataChangeListener ~= nil then callbackTable.DataChangeListener(1, #GlobalDataTable) end				
			end
		end
	
	return nil, callbackTable
end

-------------------------------------------------------------------------------
-- list view for sub service
-------------------------------------------------------------------------------
local GlobalSubListView = nil 

function GetSubItemFactory()
	local callbackTable = {}
	local userdata = nil
	callbackTable.CreateObject = 
		function (userdata, column)
			local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
			local itemObj = nil
			if column == 1 then return objFactory:CreateUIObject(nil, "TextObject") end
			if column == 5 then 
				local itemObj = objFactory:CreateUIObject(nil, "WHome.Button")
				local attr = itemObj:GetAttribute()
				attr.NormalBkgID = "blue.big.button.normal"
				attr.DownBkgID = "blue.big.button.down"
				attr.HoverBkgID = "blue.big.button.hover"
				itemObj:SetVisible(false)
				table.insert(GlobalObj, itemObj)
				itemObj:SetText("删")
				local cookie, ret = itemObj:AttachListener("OnClick", true, SLV_OnClick)
				return itemObj
			end
			
			local itemObj = objFactory:CreateUIObject(nil,"WHome.Edit")
			itemObj:SetBorder(not GlobalReadOnly)
			itemObj:SetReadOnly(GlobalReadOnly)
			local cookie, ret = itemObj:AttachListener("OnEditChange", true, OnEditChange)
			table.insert(GlobalObj, itemObj)
			
			return itemObj
		end
		
	callbackTable.GetRowHeight = 
		function (userdata)
			return 26
		end
		
	callbackTable.GetColumnWidth = 
		function (userdata, column, widthInAll)
			-- first column is nil, just for space
			local colWidth = {5, 100, 249, 110, 25}
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
			
			itemObj:GetAttribute().service = "sub"
			itemObj:GetAttribute().row = row
			itemObj:GetAttribute().column = column
		end
		
	callbackTable.SetItemPos2 = 
		function (userdata, itemObj, left, top, width, height)
			if itemObj~=nil and itemObj:GetClass()=="WHome.Button" then
				itemObj:SetObjPos2(left, top, 25, 26)
			end
			if itemObj~=nil and itemObj:GetClass()=="WHome.Edit" then
				itemObj:SetObjPos2(left, top, width, height) 
			end
		end
		
	return userdata, callbackTable
end

function GetSubDataModelObject()
	local index = 1
	local dataTable = {}
	local objTable = {}
	local callbackTable = {}
	local colCount = nil
	local nameList = {"", "详细分类", "收费标准", "联系电话", ""}
	
	if GlobalDataTable[index] ~= nil then dataTable = GlobalDataTable[index]['service'] end
	
	callbackTable.GetCount = 
		function (userdata)
			return #dataTable
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
			if dataTable[row] ~= nil then
				if column == 1 then return dataTable[row]['id'] end
				if column == 2 then return dataTable[row]['name'] end
				if column == 3 then return dataTable[row]['content'] end
				if column == 4 then return dataTable[row]['telphone'] end
			end
			return nil
		end
	callbackTable.SetDataChangeListener = 
		function (userdata, dataChangedListener)
			callbackTable.DataChangeListener = dataChangedListener
		end	
		
	operation.SubAdd = 
		function (row, data)
			if row == nil then row = #dataTable + 1 end
			local count = #dataTable
			for r=row+1, count+1 do
				dataTable[r] = dataTable[r-1]
			end
			dataTable[row]= data
			if callbackTable.DataChangeListener ~= nil then
				callbackTable.DataChangeListener(row, count+1)
			end		
		end
		
	operation.SubSave = 
		function ()
			if GlobalDataTable[index] == nil then return end
			
			local tempTable = {}
			for i=1, #dataTable do
				if dataTable[i]['name'] == "" or dataTable[i]['telphone'] == "" then
				
				else 
					table.insert(tempTable, dataTable[i])
				end
			end
			dataTable = tempTable
			GlobalDataTable[index]['service'] = dataTable
			if callbackTable.DataChangeListener ~= nil then
				callbackTable.DataChangeListener(1, #dataTable)
			end	
		end
	
	-- 动态加载数据
	operation.SubLoadData = 
		function (i)
			index = i
			if GlobalDataTable[index] ~= nil then 
				dataTable = GlobalDataTable[index]['service']
				-- 修改标题
				GlobalControl:GetControlObject("text.tip.sub.header"):SetText(GlobalDataTable[i]['name'])
			else
				dataTable = {}
				-- 修改标题
				GlobalControl:GetControlObject("text.tip.sub.header"):SetText("详细信息")
			end
			
			if callbackTable.DataChangeListener ~= nil then
				callbackTable.DataChangeListener(1, #dataTable)
			end		
		end
	
	operation.SubEditChange = 
		function (row, column, text)
			if column == 1 then dataTable[row]['id'] = text end
			if column == 2 then dataTable[row]['name'] = text end	
			if column == 3 then dataTable[row]['content'] = text end
			if column == 4 then dataTable[row]['telphone'] = text end
			
			if callbackTable.DataChangeListener ~= nil then
				callbackTable.DataChangeListener(row, row)
			end	
			--
			--operation.SubSave()
		end
		
	operation.SubDel = 
		function (row) 
			local count = #dataTable
			if count > 0 then
				for r=row,count do
					dataTable[r] = dataTable[r+1]
				end
			end
			if callbackTable.DataChangeListener ~= nil then
				callbackTable.DataChangeListener(row, count)
			end
			--XLMessageBox(json.encode(GlobalDataTable))			
		end

	return nil, callbackTable
end

-------------------------------------------------------------------------------
function OnInitControl(self)
	local attr = self:GetAttribute()
	local bkg = self:GetControlObject("bkg")
	GlobalControl = self
	--bkg:SetTextureID(attr.BorderTexture)
end

function MLV_OnClick(self)
	local row = self:GetAttribute().row
	
	if GlobalReadOnly then
		operation.SubLoadData(row)
	else
		operation.MainDel(row)
	end
end

function SLV_OnClick(self)
	local row = self:GetAttribute().row
	
	operation.SubDel(row)
end

function OnEditChange(self)
	if self:GetClass() ~= "WHome.Edit" then return end
	
	local row = self:GetAttribute().row
	local column = self:GetAttribute().column
	local service = self:GetAttribute().service
	local text = self:GetText()
	
	if service == "main" then
		operation.MainChange(row, column, text)
	end
	if service == "sub" then
		operation.SubEditChange(row, column, text)
	end
end

function BES_OnClick(self)
	if self:GetText() == "编辑" then
		self:SetText("保存")
		operation.Edit()
		GlobalReadOnly = false
		self:GetOwnerControl():GetControlObject("btn.main.add"):SetVisible(true)
		self:GetOwnerControl():GetControlObject("btn.sub.add"):SetVisible(true)
	else
		self:SetText("编辑")
		operation.Save()
		GlobalReadOnly = true
		self:GetOwnerControl():GetControlObject("btn.main.add"):SetVisible(false)
		self:GetOwnerControl():GetControlObject("btn.sub.add"):SetVisible(false)
		
		--XLMessageBox(json.encode(GlobalDataTable))
		Set_PropertyServiceInfo(self:GetOwnerControl())
	end	
end

-- 加载信息
function Get_PropertyServiceInfo(self)

end

function OnInitControl_Main_ListView(self)
	GlobalMainListView = self
	
	local itemFactoryUserData, itemFactoryCallbackTable = GetMainItemFactory()
	self:SetItemFactory(itemFactoryUserData, nil, itemFactoryCallbackTable)
	
	local dataModelUserData, dataModelCallbackTable = GetMainDataModelObject()
	self:SetDataModel(dataModelUserData, dataModelCallbackTable)
end

function Get_PropertyServiceInfo(self)
	local httpclient = XLGetObject("Whome.HttpCore.Factory"):CreateInstance()
	httpclient:AttachResultListener(
		function(result) 
			local response = json.decode(result)
			if response['ret'] == 0 then
				GlobalDataTable = response['result']['service_list']
				--XLMessageBox(json.encode(GlobalDataTable))
				for i=1, #GlobalDataTable do
					operation.MainLoadData()
					operation.SubLoadData(1)
				end
			end
		end
	)
	url = "/service/life?action=get_life_list"
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
	local param = "action=life_list&service="..httpclient:EscapeParam(json.encode(GlobalDataTable))
	local url = "/service/life"
	httpclient:Perform(url, "POST", param)	
end

function OnDestroy_Main_ListView(self)

end

function OnInitControl_Sub_ListView(self)
	GlobalSubListView = self
	
	local itemFactoryUserData, itemFactoryCallbackTable = GetSubItemFactory()
	self:SetItemFactory(itemFactoryUserData, nil, itemFactoryCallbackTable)
	
	local dataModelUserData, dataModelCallbackTable = GetSubDataModelObject()
	self:SetDataModel(dataModelUserData, dataModelCallbackTable)
end

function OnDestroy_Sub_ListView(self)
	
end

function HttpRequest(self)

end

function BTN_Main_Add(self)
	local row = #GlobalDataTable + 1
	operation.MainAdd(row, "")
end

function BTN_Sub_Add(self)
	operation.SubAdd(nil, {id="new", name="", content="", telphone="", area_code="010", pid=0})
end
