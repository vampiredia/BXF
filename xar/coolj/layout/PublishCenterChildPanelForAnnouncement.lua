--------------------------------------------------------------------------------------
-- ListView
local operation = {}

function GetTextItemFactory()
	local callbackTable = {}
	local userdata = nil
	callbackTable.CreateObject = 
		function (userdata, column)
			local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
			--[[
			if column == 6 then 
				local button = objFactory:CreateUIObject(nil,"BaseUI.Button")
				local cookie, ret = button:AttachListener("OnClick", true, OnButtonClicked)
				return button
			else return objFactory:CreateUIObject(nil,"TextObject") end
			]]
			return objFactory:CreateUIObject(nil,"WHome.Edit")
		end
	callbackTable.GetRowHeight = 
		function (userdata)
			return 26
		end
	callbackTable.GetColumnWidth = 
		function (userdata, column, widthInAll)
			local colWidth = {120, 120, 120, 120, 40}
			return colWidth[column]
		end
	callbackTable.SetItemData = 
		function(userdata, itemObj, data, row, column)
			if itemObj == nil then return end
			if data ~= nil then
				itemObj:SetText(data)
				itemObj:SetBorder(false)
				itemObj:SetReadOnly(true)
			end
		end
	callbackTable.SetItemPos2 = 
		function (userdata, itemObj, left, top, width, height)
			if itemObj~=nil and itemObj:GetClass()=="WHome.Button" then
				itemObj:SetObjPos2(left+10, top, 30, 30)
				end
			if itemObj~=nil and itemObj:GetClass()=="WHome.Edit" then
				itemObj:SetObjPos2(left, top, width, height) end
		end
	return userdata, callbackTable
end

function OnButtonClicked(button)
	if button:GetClass() == "WHome.Button" then
		local opr = button:GetText()
		local row = button:GetAttribute().row
		if opr == "加" then
			operation.Add(row, "变", os.date())
		elseif opr == "减" then
			operation.Sub(row)
		elseif opr == "变" then
			operation.Change(row, "减", os.date())
		end
	end
end

function GetSimpleDataModelObject()
	local dataTable = {{"加", os.date(), os.date(), os.date(), os.date()},
					   {"加", os.date(), os.date(), os.date(), os.date()},
					   {"加", os.date(), os.date(), os.date(), os.date()},
					   {"加", os.date(), os.date(), os.date(), os.date()},
					   {"加", os.date(), os.date(), os.date(), os.date()},
					   {"加", os.date(), os.date(), os.date(), os.date()},
					   {"加", os.date(), os.date(), os.date(), os.date()},
					   {"加", os.date(), os.date(), os.date(), os.date()},
					   {"加", os.date(), os.date(), os.date(), os.date()},
					   {"加", os.date(), os.date(), os.date(), os.date()},
					   {"加", os.date(), os.date(), os.date(), os.date()},
					   {"加", os.date(), os.date(), os.date(), os.date()},
					   {"加", os.date(), os.date(), os.date(), os.date()},
					   {"加", os.date(), os.date(), os.date(), os.date()},
					   {"加", os.date(), os.date(), os.date(), os.date()},
					   {"加", os.date(), os.date(), os.date(), os.date()},
					   {"加", os.date(), os.date(), os.date(), os.date()},
					   {"加", os.date(), os.date(), os.date(), os.date()},
					   {"加", os.date(), os.date(), os.date(), os.date()}}
	local callbackTable = {}
	local colCount = nil
	local nameList = {"服务类型", "详细分类", "收费标准", "联系电话", ""}
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
				local text = dataTable[row][column]
				return text
			else
				return nil
			end
		end
	callbackTable.SetDataChangeListener = 
		function (userdata, dataChangedListener)
			callbackTable.DataChangeListener = dataChangedListener
		end
	operation.Add = 
		function (row, sign, data)
			local count = #dataTable
			for r=row+1, count+1 do
				dataTable[r] = dataTable[r-1]
			end
			dataTable[row]={sign, data}
			if callbackTable.DataChangeListener ~= nil then
				callbackTable.DataChangeListener(row, count+1)
			end
		end
	
	operation.Sub = 
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
		end
	
	operation.Change = 
		function (row, sign, data)
			local count = #dataTable
			dataTable[row]= {sign, data}
			if callbackTable.DataChangeListener ~= nil then
				callbackTable.DataChangeListener(row, row)
			end
		end
	
	operation.Edit = 
		function ()
			return 
		end
		
	operation.Save = 
		function ()
			return 
		end
		
	return nil, callbackTable
end

--------------------------------------------------------------------------------------

function OnInitControl(self)
	local attr = self:GetAttribute()
	local bkg = self:GetControlObject("bkg")
	--bkg:SetTextureID(attr.BorderTexture)
end

local GlobalListView = nil 

function OnInitControl_ListView(self)
	GlobalListView = self
	
	local itemFactoryUserData, itemFactoryCallbackTable = GetTextItemFactory()
	self:SetItemFactory(itemFactoryUserData, nil, itemFactoryCallbackTable)
	
	local dataModelUserData, dataModelCallbackTable = GetSimpleDataModelObject()
	self:SetDataModel(dataModelUserData, dataModelCallbackTable)
end

function OnDestroy_ListView(self)

end