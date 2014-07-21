function SetControlTabOrder(self, tabOrder)
	local attr = self:GetAttribute()
	attr.OrginTabOrder = tabOrder
	if attr.tabGroupArray[1] ~= nil and attr.tabGroupArray[1].needFocus then
		attr.tabGroupArray[1].tabbedObj:SetTabGroup(tabOrder)
		attr.tabGroupArray[1].tabbedObj:SetTabOrder(1)
	else
		self:GetControlObject("TabKeySupport.layout"):SetTabGroup(tabOrder)
		self:GetControlObject("TabKeySupport.layout"):SetTabOrder(1)
	end
end

function SetTabEnable(self, bEnable)
	local attr = self:GetAttribute()
	local needChangeObj = nil
	if attr.tabGroupArray[1].needFocus then
		needChangeObj = attr.tabGroupArray[1].tabbedObj
	else
		needChangeObj = self:GetControlObject("TabKeySupport.layout")
	end
	
	if bEnable then
		if needChangeObj:GetTabGroup() == -1 then
			needChangeObj:SetTabGroup(attr.OrginTabOrder)
			needChangeObj:SetTabOrder(1)
		end
	else
		if needChangeObj:GetTabGroup() ~= -1 then
			needChangeObj:SetTabGroup(-1)
			needChangeObj:SetTabOrder(-1)
		end
	end
end

function SetTabStop(self, bStop)
	local attr = self:GetAttribute()
	if attr.tabGroupArray[1].needFocus then
		attr.tabGroupArray[1].tabbedObj:SetTabStop(bStop)
	else
		self:GetControlObject("TabKeySupport.layout"):SetTabStop(bStop)
	end
end

local function DefaultTabbedStateChangeFunc(self, tabbedObj, bIsTabbed, rectangleObjPos)	
	if bIsTabbed then
		if tabbedObj:GetObject(tabbedObj:GetID() .. ".tabKeySupport.rect") ~= nil then
			return
		end
		local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
		local obj = objFactory:CreateUIObject(tabbedObj:GetID() .. ".tabKeySupport.rect", "RectangleObject")
		obj:SetLinePenResID("pen.dot")
		obj:SetLineColorResID("system.black")
		obj:SetRectangleBrushResID("brush.null")
		obj:SetRectanglePoint(0, 0, "width", "height")
		obj:SetZorder(1000000000)
		if rectangleObjPos ~= nil then
			obj:SetObjPos(rectangleObjPos.leftSpace, rectangleObjPos.topSpace, "father.width - " .. tostring(rectangleObjPos.rightSpace), "father.height - " .. tostring(rectangleObjPos.bottomSpace))
		else
			obj:SetObjPos(3, 3, "father.width - 3", "father.height - 3")
		end

		tabbedObj:AddChild(obj)
	else
		local rectObj = tabbedObj:GetObject(tabbedObj:GetID() .. ".tabKeySupport.rect")
		if rectObj ~= nil then
			tabbedObj:RemoveChild(rectObj)
		end
	end
end
--onTabbedStateChangeFunc不需要焦点的obj默认处理虚框
function RegisterTabObj(self, tabbedObj, onEnterKeyClickFunc, onTabbedStateChangeFunc, userHandlerCharMsg, needFocus, rectangleObjPos)
	local attr = self:GetAttribute()
	local newId = #attr.tabGroupArray + 1
	attr.tabGroupArray[newId] = {}
	attr.tabGroupArray[newId].tabbedObj = tabbedObj
	attr.tabGroupArray[newId].onEnterKeyClickFunc = onEnterKeyClickFunc
	if onTabbedStateChangeFunc == nil and not needFocus then
		attr.tabGroupArray[newId].onTabbedStateChangeFunc = DefaultTabbedStateChangeFunc
	else
		local function OnTabbedStateChange(tabKeyObj, tabbedObj, bStatus, rect)
			if onTabbedStateChangeFunc ~= nil then
				if onTabbedStateChangeFunc(tabKeyObj, tabbedObj, bStatus, rect) then
					DefaultTabbedStateChangeFunc(tabKeyObj, tabbedObj, bStatus, rect)
				end
			end
		end
		attr.tabGroupArray[newId].onTabbedStateChangeFunc = OnTabbedStateChange
	end
	
	attr.tabGroupArray[newId].rectangleObjPos = rectangleObjPos
	
	attr.tabGroupArray[newId].userHandlerCharMsg = userHandlerCharMsg
	attr.tabGroupArray[newId].needFocus = needFocus
	
	if needFocus then
		local onTabbedStateChangeFunc = attr.tabGroupArray[newId].onTabbedStateChangeFunc
		local tabGroup = self:GetControlObject("TabKeySupport.layout"):GetTabGroup()
		if tabGroup ~= -1 then
			self:GetControlObject("TabKeySupport.layout"):SetTabGroup(-1)
			self:GetControlObject("TabKeySupport.layout"):SetTabOrder(-1)
			self:GetControlObject("TabKeySupport.layout"):SetTabStop(false)
			tabbedObj:SetTabGroup(tabGroup)
			tabbedObj:SetTabOrder(1)
		end
		
		tabbedObj:AttachListener("OnTabbedEvent", true, 
								function(obj, funcName, bIsTabbed)	
									if bIsTabbed then
										XLSetGlobal("WHome.TabKeySupport.TabbedObj", obj)
									else
										XLSetGlobal("WHome.TabKeySupport.TabbedObj", "nil")
									end
									if onTabbedStateChangeFunc ~= nil then
										onTabbedStateChangeFunc(self, tabbedObj, bIsTabbed, rectangleObjPos)
									end
								end					
								)
	end
end

function UnRegisterTabObj(self, tabbedObj)
	local attr = self:GetAttribute()
	if attr.CurrentShowIndex ~= nil then
		local iIndex = attr.CurrentShowIndex
		attr.CurrentShowIndex = nil
		local tabbedObjArray = attr.tabGroupArray
		tabbedObjArray[iIndex].onTabbedStateChangeFunc(self:GetOwnerControl(), tabbedObjArray[iIndex].tabbedObj, false)
	end


	for i = 1, #attr.tabGroupArray do
		if attr.tabGroupArray[i].tabbedObj:GetHandle() == tabbedObj:GetHandle() then
			table.remove(attr.tabGroupArray, i)
			break
		end
	end
	
	
end

function OnTabGroupObjKeyUp(self, keyChar, repeatCount, flags)
--tab:9  enter:13 左上右下：37 38 39 40
	local attr = self:GetOwnerControl():GetAttribute()
	local tabbedObjArray = attr.tabGroupArray
	if #tabbedObjArray == 0 then
		return 0, true, true
	end
	
	if attr.CurrentShowIndex ~= nil then
		if attr.CurrentShowIndex > #tabbedObjArray then
			for i = 1, #tabbedObjArray do
				tabbedObjArray[i].onTabbedStateChangeFunc(self:GetOwnerControl(), tabbedObjArray[i].tabbedObj, false)
				attr.CurrentShowIndex = nil
			end
			
			
			return 
		end
		if tabbedObjArray[attr.CurrentShowIndex].userHandlerCharMsg ~= nil then
			if tabbedObjArray[attr.CurrentShowIndex].userHandlerCharMsg(tabbedObjArray[attr.CurrentShowIndex].tabbedObj, keyChar) then
				--用户自己处理了该消息
				return
			end
		end
	end
	
	if keyChar == 9 then
		self:GetOwnerControl():FireExtEvent("OnControlTabbed", true)
		XLSetGlobal("WHome.TabKeySupport.TabbedObj", self)	
		if attr.CurrentShowIndex == nil then
			for i = 1, #tabbedObjArray do
				if tabbedObjArray[i].tabbedObj:GetVisible() and tabbedObjArray[i].tabbedObj:GetEnable() then
					tabbedObjArray[i].onTabbedStateChangeFunc(self:GetOwnerControl(), tabbedObjArray[i].tabbedObj, true, tabbedObjArray[i].rectangleObjPos)
					attr.CurrentShowIndex = i
					return 0, true, true
				end
			end
		end
	elseif keyChar == 39 or keyChar == 40 then
		if attr.CurrentShowIndex == nil then
			return 0, true, true
		end
		
		local nextShowIndex = nil	
		for i = attr.CurrentShowIndex, #tabbedObjArray + attr.CurrentShowIndex - 1 do
	
			local j = i 
			j = j % #tabbedObjArray + 1			
			if tabbedObjArray[j].tabbedObj:GetVisible() and tabbedObjArray[j].tabbedObj:GetEnable() then
				nextShowIndex = j
				break
			end
		end
		
		if attr.CurrentShowIndex ~= nextShowIndex then
			tabbedObjArray[attr.CurrentShowIndex].onTabbedStateChangeFunc(self:GetOwnerControl(), tabbedObjArray[attr.CurrentShowIndex].tabbedObj, false)
			tabbedObjArray[nextShowIndex].onTabbedStateChangeFunc(self:GetOwnerControl(), tabbedObjArray[nextShowIndex].tabbedObj, true, tabbedObjArray[nextShowIndex].rectangleObjPos)
			attr.CurrentShowIndex = nextShowIndex
		end
	elseif keyChar == 37 or keyChar == 38 then
		if attr.CurrentShowIndex == nil then
			return 0, true, true
		end
		
		local nextShowIndex = nil
		for i = #tabbedObjArray + attr.CurrentShowIndex - 2, attr.CurrentShowIndex - 1, -1 do
			local j = i
			j = j % #tabbedObjArray + 1
			if tabbedObjArray[j].tabbedObj:GetVisible() and tabbedObjArray[j].tabbedObj:GetEnable() then
				nextShowIndex = j
				break
			end
		end
		
		if attr.CurrentShowIndex ~= nextShowIndex then
			tabbedObjArray[attr.CurrentShowIndex].onTabbedStateChangeFunc(self:GetOwnerControl(), tabbedObjArray[attr.CurrentShowIndex].tabbedObj, false)
			tabbedObjArray[nextShowIndex].onTabbedStateChangeFunc(self:GetOwnerControl(), tabbedObjArray[nextShowIndex].tabbedObj, true, tabbedObjArray[nextShowIndex].rectangleObjPos)
			attr.CurrentShowIndex = nextShowIndex
		end
	elseif keyChar == 13 then
		if attr.CurrentShowIndex ~= nil then
			tabbedObjArray[attr.CurrentShowIndex].onEnterKeyClickFunc(tabbedObjArray[attr.CurrentShowIndex].tabbedObj)
			--self:SetFocus(false)
		end
	end
	
	return 0, true, true	
end

function OnTabGroupObjFocusChange(self,isFocus,lastFocusObj)
	if not isFocus then
		XLSetGlobal("WHome.TabKeySupport.TabbedObj", "nil")
		XLPrint("TabKeySupport:SetGlobalnil:")
		self:GetOwnerControl():FireExtEvent("OnControlTabbed", false)
	end
	local attr = self:GetOwnerControl():GetAttribute()
	if not isFocus and attr.CurrentShowIndex ~= nil then
		local tabbedObjArray = attr.tabGroupArray
		for i = 1, #tabbedObjArray do
			local tabbedObj = tabbedObjArray[i].tabbedObj
			if tabbedObj:GetID() ~= nil then
				tabbedObjArray[i].onTabbedStateChangeFunc(self:GetOwnerControl(), tabbedObjArray[i].tabbedObj, false)
			end
			attr.CurrentShowIndex = nil
		end
	end
	
end

function OnTabGroupObjInitControl(self)
	local attr = self:GetOwnerControl():GetAttribute()
	attr.tabGroupArray = {}
end

function GetTabbedObj(self)
	local tabbedObj = XLGetGlobal("WHome.TabKeySupport.TabbedObj")
	if tostring(tabbedObj) == "nil" then
		return nil
	end
	
	if tabbedObj:GetOwner():GetID() == self:GetOwner():GetID() then
		return tabbedObj
	end
	
	return nil
end

function SetCurrentTabbedObj(self, obj)
	local attr = self:GetAttribute()
	--if attr.CurrentShowIndex ~= nil then
	attr.CurrentShowIndex = nil
	local tabbedObjArray = attr.tabGroupArray
	if tabbedObjArray ~= nil then
		for i = 1, #tabbedObjArray do
			if tabbedObjArray[i].tabbedObj:GetHandle() == obj:GetHandle() then
				tabbedObjArray[i].onTabbedStateChangeFunc(self:GetOwnerControl(), tabbedObjArray[i].tabbedObj, true)
				attr.CurrentShowIndex = i
			else
				tabbedObjArray[i].onTabbedStateChangeFunc(self:GetOwnerControl(), tabbedObjArray[i].tabbedObj, false)
			end
		end
	end
	--end
end