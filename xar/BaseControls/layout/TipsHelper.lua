local function AddWindowedTip(self, tippedObj, text, sessionName, type_, isMultiLine, MaxWidth, x, y, OnWndCreateFunc, hAlignMode)
	if not type_ then
        type_ = 1
    end
	
	if self.wndTipId == nil then
		self.wndTipId = 0
	else
		self.wndTipId = self.wndTipId + 1
	end
	
	self:RemoveWindowedTip(tippedObj)
	local xarManager = XLGetObject("Xunlei.UIEngine.XARManager")
	local xarFactory = xarManager:GetXARFactory()
	local tip = xarFactory:CreateUIObject(tippedObj:GetID()..".windowed.tip","WHome.CommonTips")
	if hAlignMode ~= nil then
		tip:GetAttribute().TextHAlign = hAlignMode
	end
	tip:SetTipId(self.wndTipId)
	local tipAttr = tip:GetAttribute()
	tipAttr.OnWndCreateFunc = OnWndCreateFunc
	
	tip:SetText(text)
	tip:SetType(type_)
	if isMultiLine and MaxWidth then
		tip:SetMultilineParam(isMultiLine, MaxWidth)
	end
    local left, top, right, buttom = tippedObj:GetObjPos()
    local width, height = right - left, buttom - top
    
	local tipwidth, tipheight = tip:GetSize(44, 35)
	
	tip:SetZorder(500000)
    tippedObj:AddChild(tip)
    local offsetX = 2
    local offsetY = 10
    if x ~= nil then
        offsetX = x
    end
    if y ~= nil then
        offsetY = y
    end
	if type_ == 1 then
        tip:SetObjPos(offsetX, -tipheight, tipwidth + offsetX, 0)
    elseif type_ == 2 then
        tip:SetObjPos(offsetX, height - offsetY, tipwidth + offsetX, height + tipheight - offsetY)
    elseif type_ == 3 then
        tip:SetObjPos(width - tipwidth - offsetX, -height - offsetY, width - offsetX, -height + tipheight - offsetY)
    elseif type_ == 4 then
        tip:SetObjPos(width - tipwidth - offsetX, height - offsetY, width - offsetX, height + tipheight - offsetY)
    end
end

local function RemoveWindowedTip(self, tippedObj)
	local tip = tippedObj:GetObject(tippedObj:GetID()..".windowed.tip")
	if tip then
		local hostWndMgr = XLGetObject("Xunlei.UIEngine.HostWndManager")
		hostWndMgr:RemoveHostWnd(tip:GetAttribute().tipHostWndId)
		tippedObj:RemoveChild(tip)
	end
end

local function AddTip(self, tippedObj, text, sessionName, type_, isMultiLine, MaxWidth)
    if not type_ then
        type_ = 1
    end
	if sessionName then
		self:RemoveTip(sessionName)
		self.sessions[sessionName] = {["tippedObj"]=tippedObj}
	end
	
    local left, top, right, buttom = tippedObj:GetObjPos()
    local width, height = right - left, buttom - top
    local tipid = self:RemoveTip(tippedObj)
	local templateMgr = XLGetObject("Xunlei.UIEngine.TemplateManager")
	local tipTemplate = templateMgr:GetTemplate("WHome.Windowless.Tip.AutoFocus", "ObjectTemplate")
	local tip = tipTemplate:CreateInstance(tipid)
    --local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
    --local tip = objFactory:CreateUIObject(tipid,"WHome.Windowless.Tip")
    tip:SetText(text)
    tip:SetType(type_)
	if isMultiLine and MaxWidth then
		tip:SetMultilineParam(isMultiLine, MaxWidth)
	end
    local tipwidth, tipheight = tip:GetSize(44, 35)
	tip:SetZorder(500000)
    tippedObj:AddChild(tip)
	if type_ == 1 then
        tip:SetObjPos(2, -tipheight, tipwidth + 2, 0)
    elseif type_ == 2 then
        tip:SetObjPos(2, height - 10, tipwidth + 2, height + tipheight - 10)
    elseif type_ == 3 then
        tip:SetObjPos(width - tipwidth - 2, -tipheight + 6, width - 2, 6)
    elseif type_ == 4 then
        tip:SetObjPos(width - tipwidth - 2, height - 10, width - 2, height + tipheight - 10)
    end
	
	return tip
end

--- RemoveTip(tippedObj)
--- RemoveTip(sessionName)

local function RemoveTip(self, ...)
	local args = {...}
	if type(args[1]) == "string" then
		local sessionName = args[1]
		local sessionTip = self.sessions[sessionName]
		self.sessions[sessionName] = nil
		if sessionTip then
			return self:RemoveTip(sessionTip.tippedObj)
		end
		return nil
	else
		local tippedObj = args[1]
		local id = tippedObj:GetID()
		local tipid = id..".tip"
		local tip = tippedObj:GetObject(tipid)
		if tip ~= nil then
			tippedObj:RemoveChild(tip)
		end
		return tipid
	end
end


--第二个参数表明是否为非窗口tip，如果为false，第三个参数需要传窗口对象进来
function RegisterMovAniTipObj(self, isWindowlessTip, tipObject, tipGroupName, oldObjPos)
	local aniFactory = XLGetObject("Xunlei.UIEngine.AnimationFactory")
	local function BindAlphaAni(obj, startValue, endValue, isOldMain)
		if obj:GetClass() == "TextObject" or obj:GetClass() == "ImageObject" or obj:GetClass() == "TextureObject" then
			--if isOldMain and obj:GetClass() ~= "TextObject" then
			--	return
			--end
			local aniAlpha = aniFactory:CreateAnimation("AlphaChangeAnimation")
			
			aniAlpha:BindObj(obj)
			aniAlpha:SetTotalTime(210)
			aniAlpha:SetKeyFrameAlpha(startValue, endValue)
			obj:GetOwner():AddAnimation(aniAlpha)
			--BindAlphaAni(childObj, startValue, endValue)
			aniAlpha:Resume()
			
			aniAlpha:AttachListener(true, function(ani, old, new)
				if new  == 4 then	
					obj:SetAlpha(endValue)
				end
			end)
		end	
			
			--return true
		local childCount = obj:GetChildCount()
		for i = 0, childCount - 1 do
			local childObj = obj:GetChildByIndex(i)
			if childObj ~= nil then
				BindAlphaAni(childObj, startValue, endValue, isOldMain)
			end
		end
	end
	
	if isWindowlessTip then
		local tipObj = tipObject
		if self[tipGroupName] == nil then
			self[tipGroupName] = {}
		end
		
		if self[tipGroupName]["CurrentShowTip"] == nil then
			self[tipGroupName]["CurrentShowTip"] = tipObj
			return
		end
		
		local oldObj = self[tipGroupName]["CurrentShowTip"]
		self.oldMovAniObj = oldObj
		local bL, bT, bR, bB = self[tipGroupName]["CurrentShowTip"]:GetAbsPos()
		if bL == nil then
			self[tipGroupName]["CurrentShowTip"] = tipObj
			return
		end
		local eL, eT, eR, eB = tipObj:GetAbsPos()
		
		local objPos = {}
		objPos.left, objPos.top, objPos.right, objPos.bottom = tipObj:GetObjPos()
		local orginL, orginT, orginR, orginB = tipObj:GetObjPosExp()
		local sL, sT, sR, sB = objPos.left - (eL - bL), objPos.top - (eT - bT), objPos.right - (eR - bR), objPos.bottom - (eB - bB)
        local posAni = aniFactory:CreateAnimation("PosChangeAnimation")
        posAni:SetTotalTime(210)
        posAni:BindLayoutObj(tipObj)
		if oldObj:GetID() == tipObj:GetID() and oldObjPos ~= nil then
			posAni:SetKeyFrameRect(oldObjPos.left, oldObjPos.top, oldObjPos.right, oldObjPos.bottom, objPos.left, objPos.top, objPos.right, objPos.bottom)
		else
			posAni:SetKeyFrameRect(sL, sT, sR, sB, objPos.left, objPos.top, objPos.right, objPos.bottom)
		end
		local owner = tipObj:GetOwner()
        owner:AddAnimation(posAni)
		posAni:AttachListener(true, function(ani, old, new)
			if new  == 4 then	
				tipObj:SetObjPos(objPos.left, objPos.top, objPos.right, objPos.bottom)	
				self[tipGroupName]["CurrentShowTip"] = tipObj
			end
		end)
		
		if oldObj:GetID() ~= tipObj:GetID() then
			local oldObjPosAni = aniFactory:CreateAnimation("PosChangeAnimation")
			local oldObjPos = {}
			oldObjPos.left, oldObjPos.top, oldObjPos.right, oldObjPos.bottom = oldObj:GetObjPos()
			local oldSL, oldST = oldObjPos.left + objPos.left - sL, oldObjPos.top + objPos.top - sT
			oldObjPosAni:SetTotalTime(210)
			oldObjPosAni:BindLayoutObj(oldObj)
			oldObjPosAni:SetKeyFrameRect(  oldObjPos.left, oldObjPos.top, oldObjPos.right, oldObjPos.bottom, 
										oldSL, oldST, oldSL + objPos.right - objPos.left, oldST + objPos.bottom - objPos.top)
			owner:AddAnimation(oldObjPosAni)
			oldObjPosAni:AttachListener(true, function(ani, old, new)
				if new  == 4 then	
					oldObj:SetVisible(false)
					oldObj:SetChildrenVisible(false)
				end
			end)
	
			BindAlphaAni(oldObj, 255, 0)
			BindAlphaAni(tipObj, 0, 255)
			oldObjPosAni:Resume()
		end	
		posAni:Resume()
	else
		if self[tipGroupName] == nil then
			self[tipGroupName] = {}
		end
		if self[tipGroupName]["CurrentShowTip"] == nil then
			self[tipGroupName]["CurrentShowTip"] = tipObject
			return
		end
		local oldObj = self[tipGroupName]["CurrentShowTip"]
		
		self.oldMovAniObj = oldObj
		local bL, bT, bR, bB = self[tipGroupName]["CurrentShowTip"]:GetWindowRect()
		if bL == nil then
			self[tipGroupName]["CurrentShowTip"] = tipObject
			return
		end
		-- s for start, e for end, d for distance , L,T,R,B for left,top,right,bottom
		local oldWndObj = self[tipGroupName]["CurrentShowTip"]
		local sL, sT, sR, sB = self[tipGroupName]["CurrentShowTip"]:GetWindowRect()
		if self[tipGroupName]["CurrentShowTip"]:GetBindUIObjectTree() ~= nil then
			local sRootL, sRootT, sRootR, sRootB = self[tipGroupName]["CurrentShowTip"]:GetBindUIObjectTree():GetRootObject():GetObjPos()
			sR = sL + sRootR - sRootL
			sB = sT + sRootB - sRootT
		end
		local eL, eT, eR, eB = tipObject:GetWindowRect()
	
		if tipObject:GetBindUIObjectTree() ~= nil then
			local sRootL, sRootT, sRootR, sRootB = tipObject:GetBindUIObjectTree():GetRootObject():GetObjPos()
			eR = eL + sRootR - sRootL
			eB = eT + sRootB - sRootT
		end
		
		local dL, dT, dR, dB = eL - sL, eT - sT, eR - sR, eB - sB
		local timeMgr = XLGetObject("Xunlei.UIEngine.TimerManager")
		local timePiece = 0	
		--闭合函数内部所使用到的变量在外函数中一定要在内联函数定义之前声明
		local moveWndTimerId = 0
		oldWndObj:Move(sL, sT, sR, sB)
		tipObject:Move(sL, sT, sR, sB)
		moveWndTimerId = timeMgr:SetTimer(
			function()
				local moveL, moveT, moveR, moveB = dL * timePiece / 6, dT * timePiece / 6, dR * timePiece / 6, dB * timePiece / 6	
				local newL, newT, newR, newB = sL + moveL - moveL % 1, sT + moveT - moveT % 1, sR + moveR - moveR % 1, sB + moveB - moveB % 1
				local newWidth, newHeight = newR - newL, newB - newT
				oldWndObj:Move(newL, newT, newWidth, newHeight)
				--[[if oldWndObj:GetBindUIObjectTree() ~= nil then
					oldWndObj:GetBindUIObjectTree():GetRootObject():SetObjPos(0, 0, newWidth, newHeight)
				end--]]
				
				tipObject:Move(newL, newT, newWidth, newHeight)
				--[[if tipObject:GetBindUIObjectTree() ~= nil then
					tipObject:GetBindUIObjectTree():GetRootObject():SetObjPos(0, 0, newWidth, newHeight)
				end--]]
				
				if timePiece == 6 then
					self[tipGroupName]["CurrentShowTip"] = tipObject
					AsynCall(
						function()
							timeMgr:KillTimer(moveWndTimerId)
						end
					)
				end
				
				timePiece = timePiece + 1
			end,
			30
		)
		if tipObject:GetBindUIObjectTree() ~= nil then
			BindAlphaAni(tipObject:GetBindUIObjectTree():GetRootObject(), 0, 255)
		end
		if oldWndObj:GetBindUIObjectTree() ~= nil then
			BindAlphaAni(oldWndObj:GetBindUIObjectTree():GetRootObject(), 255, 0, true)
		end		
	end
end

function UnRegisterMovAniTipObj(self, tipObj, tipGroupName)
	if self[tipGroupName]["CurrentShowTip"] == tipObj then	
		self[tipGroupName] = {}
	end
end

function GetNewWindowTipId(self)
	if self.wndTipId == nil then
		self.wndTipId = 0
	else
		self.wndTipId = self.wndTipId + 1
	end
	
	return self.wndTipId
end

function QueryObjIsInMovAni(self, obj)
	return obj == self.oldMovAniObj
end

function GetTipMovAniTime(self, obj)
	return self.tipMovAniTime
end

local function BindAlphaAni(obj, startValue, endValue)
	local aniFactory = XLGetObject("Xunlei.UIEngine.AnimationFactory")
	if obj:GetClass() == "TextObject" then
		local aniAlpha = aniFactory:CreateAnimation("AlphaChangeAnimation")
		aniAlpha:BindObj(obj)
		aniAlpha:SetTotalTime(120)
		aniAlpha:SetKeyFrameAlpha(startValue, endValue)
		obj:GetOwner():AddAnimation(aniAlpha)
		aniAlpha:Resume()
		
		aniAlpha:AttachListener(true, function(ani, old, new)
			if new  == 4 then	
				obj:SetAlpha(endValue)
			end
		end)
	end	
		
	local childCount = obj:GetChildCount()
	for i = 0, childCount - 1 do
		local childObj = obj:GetChildByIndex(i)
		if childObj ~= nil then
			BindAlphaAni(childObj, startValue, endValue)
		end
	end
end 

--几个函数的声明
local function CalculateTipPos(self, tippedObj, tipType, tipWidth, tipHeight, curTipObj)
	local attr = self:GetTippedObjAttribute(tippedObj)
	if attr == nil then
		return 0, 0, 0, 0
	end
	local osShell = XLGetObject( "Xunlei.UIEngine.OSShell" )
	local ownerTree = tippedObj:GetOwner()
	local ownerHostWnd = ownerTree:GetBindHostWnd()
	local aniFactory = XLGetObject("Xunlei.UIEngine.AnimationFactory")
	if attr.CalculateTipPosFunc ~= nil then
		local posL, posT, posR, posB, tipType = attr.CalculateTipPosFunc(tippedObj, curTipObj)
		if tipType ~= nil then
			curTipObj:SetType(tipType)
		end
		
		if posR == nil then
			local w, h = curTipObj:GetTipSize()
			posR = posL + w
			posB = posT + h
		end
		
		local tippedObjL, tippedObjT, tippedObjR, tippedObjB = tippedObj:GetAbsPos()
		
		return tippedObjL + posL, tippedObjT + posT, tippedObjL + posR, tippedObjT + posB
	else
		local x, y = osShell:GetCursorPos()
		local sl,st, sr, sb = osShell:GetScreenArea()
		
		local maxWidth = sr - x - 5

		if ownerHostWnd == nil then
			ownerHostWnd = ownerTree:GetBindHostWnd()
		end
		x, y = ownerHostWnd:ScreenPtToHostWndPt(x, y)
		--tipType:0,1,2,3 上，下，左，右
		if tipType == 0 then
			if tipWidth > maxWidth then
				return x + maxWidth - tipWidth, y - tipHeight -2, x + maxWidth, y - 2
			end
			return x, y - tipHeight -2, x + tipWidth, y - 2
		elseif tipType == 1 then
			if tipWidth > maxWidth then
				return x + maxWidth - tipWidth,  y + 20, x + maxWidth,  y + 20 + tipHeight
			end
			return x + 5, y + 20, x + tipWidth + 5, y + 20 + tipHeight
		elseif tipType == 2 then
		elseif tipType == 3 then
		end
	end
	
	return 0, 0, 0, 0
end

local function AddRelatedGroupTip(self, groupName, tippedObj, bUseWindow, tipCtrlTemplateName, tipData, tipType, showEventName, removeEventName, CalculateTipPosFunc)
	if self.AllGroupTip[groupName] == nil then
		self.AllGroupTip[groupName] = {}
	end
	
	if self.AllGroupTip[groupName].tippedObjArray == nil then
		self.AllGroupTip[groupName].tippedObjArray = {}
	end
	
	self.AllGroupTip[groupName].tippedObjArray[#self.AllGroupTip[groupName].tippedObjArray + 1] = tippedObj
	
	
	local timeMgr = XLGetObject("Xunlei.UIEngine.TimerManager")
	local osShell = XLGetObject( "Xunlei.UIEngine.OSShell" )
	local xarManager = XLGetObject("Xunlei.UIEngine.XARManager")
	local xarFactory = xarManager:GetXARFactory()
	local ownerTree = tippedObj:GetOwner()
	local rootObj = ownerTree:GetRootObject()
	local ownerHostWnd = ownerTree:GetBindHostWnd()
	local aniFactory = XLGetObject("Xunlei.UIEngine.AnimationFactory")
	local newTipObjId = self:GetNewWindowTipId()
	if tippedObj.GetAttribute ~= nil then
		local tippedObjAttr = tippedObj:GetAttribute()
		tippedObjAttr.newTipObjId = newTipObjId
	else
		tippedObj:GetOwnerControl():GetAttribute()["newTipObjId" .. tippedObj:GetID()] = newTipObjId
	end
	
	--默认参数设置
	if tipCtrlTemplateName == nil then
		tipCtrlTemplateName = "WHome.CommonGroupTip"
	end
	if tipType == nil then
		tipType = 1
	end
	if showEventName == nil then
		showEventName = "OnMouseMove"
	end
	if removeEventName == nil then
		removeEventName = "OnMouseLeave"
	end
	
	
	--将传进来的参数做一个缓存
	local newTipAttr = self:GetTippedObjAttribute(tippedObj)
	newTipAttr.groupName = groupName
	newTipAttr.bUseWindow = bUseWindow
	newTipAttr.tipCtrlTemplateName = tipCtrlTemplateName
	newTipAttr.tipData = tipData
	newTipAttr.tipType = tipType
	newTipAttr.CalculateTipPosFunc = CalculateTipPosFunc
	
	local function OnShowTipEvent(tippedObj)
		
		local attr = self:GetTippedObjAttribute(tippedObj)
		if attr.bEnable == nil then
			attr.bEnable = true
		end
		
		if self.AllGroupTip[groupName].bEnable == nil then
			self.AllGroupTip[groupName].bEnable = true
		end
		
		if not attr.bEnable then
			return
		end
		if not self.AllGroupTip[groupName].bEnable then
			return
		end
		if attr.isShowTip then
			return
		end
		
		attr.isShowTip = true
		attr.showTipTimerID = timeMgr:SetOnceTimer(
			function()
				if not attr.isShowTip then
					return
				end
				self:ShowRelatedGroupTip(tippedObj)
			end
		,300)
	
	
	end
	
	local function OnHideTipeEvent(tippedObj)
		local attr = self:GetTippedObjAttribute(tippedObj)
		if not attr.isShowTip then
			return
		end
		attr.isShowTip = false
		if attr.showTipObj == nil then
			return
		end
		
		if attr.showTipTimerID ~= nil then
			timeMgr:KillTimer(attr.showTipTimerID)
			attr.showTipTimerID = nil
		end
		
		attr.destoryTipTimerID = timeMgr:SetOnceTimer(
			function()
				self:HideRelatedGroupTip(tippedObj)
			end
		,500)
		
		
	end
	
	--真正开始的逻辑
	local attr = self:GetTippedObjAttribute(tippedObj)
	attr.removeTipEventName = removeEventName
	attr.useWindow = bUseWindow
	attr.showTipEventName = showEventName
	
	attr.showTipEventCookier = tippedObj:AttachListener(showEventName, true, OnShowTipEvent)
	attr.removeTipEventCookier = tippedObj:AttachListener(removeEventName, true, OnHideTipeEvent)
end

local function RemoveRelatedGroupTip(self, groupName, tippedObj)
	self:HideRelatedGroupTip(tippedObj)
	if tippedObj ~= nil then
		for k, v in ipairs(self.AllGroupTip[groupName].tippedObjArray) do
			if tostring(v) == tostring(tippedObj) then
				self.AllGroupTip[groupName].tippedObjArray[k] = "nil"
				break
			end
		end
		local attr = self:GetTippedObjAttribute(tippedObj)
		tippedObj:RemoveListener(attr.showTipEventName, attr.showTipEventCookier)
		tippedObj:RemoveListener(attr.removeTipEventName, attr.removeTipEventCookier)

	end
end

local function ShowRelatedGroupTip(self, tippedObj)
	local osShell = XLGetObject( "Xunlei.UIEngine.OSShell" )
	local ownerTree = tippedObj:GetOwner()
	local ownerHostWnd = ownerTree:GetBindHostWnd()
	local x, y = osShell:GetCursorPos()
	x, y = ownerHostWnd:ScreenPtToHostWndPt(x, y)
	local tl, tt, tr, tb = tippedObj:GetAbsPos()
	--鼠标不在控件上，尽管有ShowEvent，仍然屏蔽
	if x < tl or x > tr or y < tt or y > tb then
		return
	end
	
	
	
	local timeMgr = XLGetObject("Xunlei.UIEngine.TimerManager")
	local attr = self:GetTippedObjAttribute(tippedObj)
	local osShell = XLGetObject( "Xunlei.UIEngine.OSShell" )
	local xarManager = XLGetObject("Xunlei.UIEngine.XARManager")
	local xarFactory = xarManager:GetXARFactory()
	local ownerTree = tippedObj:GetOwner()
	local rootObj = ownerTree:GetRootObject()
	local ownerHostWnd = ownerTree:GetBindHostWnd()
	local aniFactory = XLGetObject("Xunlei.UIEngine.AnimationFactory")
	--if attr.isShowTip then
	--	return
	--end
	
	local newTipObjId = attr.tipId
	local groupName = attr.groupName
	
	--attr.isShowTip = true
	--if attr.showTipTimerID ~= nil then
		--timeMgr:KillTimer(attr.showTipTimerID)
	--end
		
	if attr.bUseWindow then
		--CreateWindowTip
		local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")
		local tipsHostWndTemplate = templateMananger:GetTemplate("WHome.grouptips","HostWndTemplate")
		local hostWndMgr = XLGetObject("Xunlei.UIEngine.HostWndManager")
		if hostWndMgr:GetHostWnd("Tips.HostWnd" .. newTipObjId) ~= nil then
			hostWndMgr:RemoveHostWnd("Tips.HostWnd" .. newTipObjId)
		end
		local tipsHostWnd = tipsHostWndTemplate:CreateInstance("Tips.HostWnd" .. newTipObjId)
		attr.tipHostWndId = "Tips.HostWnd" .. newTipObjId

		
		tipsHostWnd:SetTipTemplate("groupTips.template")
		
		local function OnTipWndCreate(hostwnd)				
			local objTree = hostwnd:GetBindUIObjectTree()
			if objTree ~= nil then
				local groupTipLayout = objTree:GetUIObject("groupTip.layout")
				local tip = xarFactory:CreateUIObject(newTipObjId..".tip", attr.tipCtrlTemplateName)
				tip:FillTipData(attr.tipData)
				local tipWidth, tipHeight = tip:GetTipSize()
				local l, t, r, b = self:CalculateTipPos(tippedObj, attr.tipType, tipWidth, tipHeight)
				local hl, ht, hr, hb = ownerHostWnd:GetWindowRect()
				tip:SetObjPos(0, 0, "father.width", "father.height")
				tip:SetZorder(1000000)
				groupTipLayout:AddChild(tip)
				groupTipLayout:SetObjPos(0, 0, r - l, b - t)
				hostwnd:Move(hl + l, ht + t, r - l, b - t)
				attr.showTipObj = tip
				attr.showTipTimerID = nil
				
				if self.currentShowTipObj[groupName] ~= nil then
					--Need to start mov ani
					local oldTipObj = self.currentShowTipObj[groupName]
					if oldTipObj:GetAttribute() ~= nil then
						oldTipObj:SetVisible(false)
						oldTipObj:SetChildrenVisible(false)
						local eL, eT, eR, eB = l, t, r, b
						local sL, sT, sR, sB = self.currentShowTipObj[groupName .. "l"], self.currentShowTipObj[groupName .. "t"], self.currentShowTipObj[groupName .. "r"], self.currentShowTipObj[groupName .. "b"]
						local oldTipData = oldTipObj:GetTipData()
						local oldObjControl = xarFactory:CreateUIObject(newTipObjId..".oldGhostObj.tip", attr.tipCtrlTemplateName)
						oldObjControl:SetZorder(1000000)
						oldObjControl:ClearTipBkg()
						oldObjControl:FillTipData(oldTipData)
						oldObjControl:SetObjPos(0, 0, "father.width", "father.height")
						BindAlphaAni(tip, 0, 255)
						tip:AddChild(oldObjControl)
						BindAlphaAni(oldObjControl, 255, 0)
						
						local distanceL, distanceT, distanceR, distanceB = eL - sL, eT - sT, eR - sR, eB - sB
						local tipL, tipT, tipR, tipB = tipsHostWnd:GetWindowRect()
						tipL, tipT, tipR, tipB = tipL - distanceL, tipT - distanceT, tipR - distanceR, tipB - distanceB
						tipsHostWnd:Move(tipL, tipT, tipR, tipB)
						attr.showTimepiece = 1
						attr.showMoveWndTimerId = timeMgr:SetTimer(
							function()
								local moveL, moveR, moveT, moveB = distanceL * attr.showTimepiece / 4, distanceR * attr.showTimepiece / 4, distanceT * attr.showTimepiece / 4, distanceB * attr.showTimepiece / 4	
								local tipEL, tipER, tipET, tipEB = tipL + moveL, tipR + moveR, tipT + moveT, tipB +moveB									
								tipsHostWnd:Move(tipEL, tipET, tipER - tipEL, tipEB - tipET)									
								if attr.showTimepiece == 4 then
									AsynCall(
										function()
											timeMgr:KillTimer(attr.showMoveWndTimerId)
										end
									)
								end
								attr.showTimepiece = attr.showTimepiece + 1
							end,
							30
						)
					end
				end	
				
				self.currentShowTipObj[groupName] = tip
				self.currentShowTipObj[groupName .. "l"] = l
				self.currentShowTipObj[groupName .. "t"] = t
				self.currentShowTipObj[groupName .. "r"] = r
				self.currentShowTipObj[groupName .. "b"] = b
			end
		end
		
		tipsHostWnd:DelayPopup(0)
		tipsHostWnd:AttachListener("OnCreate", false, OnTipWndCreate)			
	else
		--CreateTip
		local tip = xarFactory:CreateUIObject(newTipObjId..".tip", attr.tipCtrlTemplateName)
		tip:FillTipData(attr.tipData)
		local tipWidth, tipHeight = tip:GetTipSize()
		local l, t, r, b = self:CalculateTipPos(tippedObj, attr.tipType, tipWidth, tipHeight, tip)
		tip:SetObjPos(l, t, r, b)
		tip:SetZorder(1000000)
		local isoldTip = rootObj:GetOwner():GetUIObject(newTipObjId..".tip")
		if isoldTip ~= nil then
			rootObj:RemoveChild(isoldTip)
		end
		rootObj:AddChild(tip)
		attr.showTipObj = tip
		attr.showTipTimerID = nil
			
		if self.currentShowTipObj[groupName] ~= nil then
			--Need to start mov ani
			local oldTipObj = self.currentShowTipObj[groupName]
			if oldTipObj:GetAttribute() ~= nil then
				oldTipObj:SetVisible(false)
				oldTipObj:SetChildrenVisible(false)
				local sL, sT, sR, sB = oldTipObj:GetObjPos()
				local eL, eT, eR, eB = tip:GetObjPos()
				
				local oldTipData = oldTipObj:GetTipData()
				local oldObjControl = xarFactory:CreateUIObject(newTipObjId..".oldGhostObj.tip", attr.tipCtrlTemplateName)
				oldObjControl:SetZorder(1000000)
				oldObjControl:FillTipData(oldTipData)
				if oldTipObj.GetType ~= nil then
					oldObjControl:SetType(oldTipObj:GetType())										
				end
				oldObjControl:ClearTipBkg()
				oldObjControl:SetObjPos(0, 0, "father.width", "father.height")
				BindAlphaAni(tip, 0, 255)
				tip:AddChild(oldObjControl)
				BindAlphaAni(oldObjControl, 255, 0)
				
				local posAni = aniFactory:CreateAnimation("PosChangeAnimation")
				posAni:SetTotalTime(210)
				posAni:BindLayoutObj(tip)
				posAni:SetKeyFrameRect(sL, sT, sR, sB, eL, eT, eR, eB)
				ownerTree:AddAnimation(posAni)
				posAni:AttachListener(true, function(ani, old, new)
					if new  == 4 then	
						--tip:SetVisible(false)
						--tip:SetChildrenVisible(false)
					end
				end)
		
				posAni:Resume()
			end
		end
		
		self.currentShowTipObj[groupName] = tip
	end
end

local function HideRelatedGroupTip(self, tippedObj)
	local timeMgr = XLGetObject("Xunlei.UIEngine.TimerManager")
	local attr = self:GetTippedObjAttribute(tippedObj)
	if attr == nil then
		return
	end
	local ownerTree = tippedObj:GetOwner()
	local rootObj = ownerTree:GetRootObject()
	
	--if not attr.isShowTip then
	--	return
	--end
	--attr.isShowTip = false
	if attr.showTipObj == nil then
		return
	end
	
	if attr.showTipTimerID ~= nil then
		timeMgr:KillTimer(attr.showTipTimerID)
		attr.showTipTimerID = nil
	end
	
	if attr.bUseWindow then
		if self.currentShowTipObj[attr.groupName] == attr.showTipObj then
			self.currentShowTipObj[attr.groupName] = nil
		end
		
		local hostWndMgr = XLGetObject("Xunlei.UIEngine.HostWndManager")
		if hostWndMgr:GetHostWnd(attr.tipHostWndId) ~= nil then
			hostWndMgr:RemoveHostWnd(attr.tipHostWndId)
		end
	else
		if self.currentShowTipObj[attr.groupName] == attr.showTipObj then
			self.currentShowTipObj[attr.groupName] = nil
		end
		
		rootObj:RemoveChild(attr.showTipObj)
	end
end

local function SetGroupTipEnable(self, tippedObj, bEnable)
	local attr = self:GetTippedObjAttribute(tippedObj)
	attr.bEnable = bEnable
end

local function QueryGroupTipObjIsInMovAni(self, tipObj)
	return false
end

local function GetTippedObjAttribute(self, tippedObj)
	local newTipId = nil
	
	if tippedObj.GetAttribute ~= nil then
		local tippedObjAttr = tippedObj:GetAttribute()
		if tippedObjAttr == nil then
			return nil
		end
		newTipId = tippedObjAttr.newTipObjId
	else
		if tippedObj:GetOwnerControl() == nil then
			return nil
		end
		newTipId = tippedObj:GetOwnerControl():GetAttribute()["newTipObjId" .. tippedObj:GetID()]
	end

	if self.tippedObjAttr[tippedObj:GetID() .. newTipId] == nil then
		self.tippedObjAttr[tippedObj:GetID() .. newTipId] = {}
		self.tippedObjAttr[tippedObj:GetID() .. newTipId]["tipId"] = newTipId
	end
	
	return self.tippedObjAttr[tippedObj:GetID() .. newTipId]
end

local function SetAllGroupTipEnable(self, groupName, bEnable)
	if groupName == nil then
		return
	end
	if self.AllGroupTip[groupName] == nil then
		return
	end
	self.AllGroupTip[groupName].bEnable = bEnable
end

local function HideAllGroupTip(self, groupName)
	if self.AllGroupTip[groupName] == nil then
		return
	end
	for k, v in pairs(self.AllGroupTip[groupName].tippedObjArray) do
		if v ~= nil and v ~= "nil" then			self:HideRelatedGroupTip(v)
		end
	end
end

function RegisterObject(self)
	local obj = {}
	obj.tipMovAniTime = 210
	obj.AddTip = AddTip
	obj.RemoveTip = RemoveTip
	
	obj.AddWindowedTip = AddWindowedTip
	obj.RemoveWindowedTip = RemoveWindowedTip
	
	obj.RegisterMovAniTipObj = RegisterMovAniTipObj
	obj.UnRegisterMovAniTipObj = UnRegisterMovAniTipObj
	
	obj.QueryObjIsInMovAni = QueryObjIsInMovAni
	obj.GetTipMovAniTime = GetTipMovAniTime
	
	obj.GetNewWindowTipId = GetNewWindowTipId
	
	obj.sessions = {}
	
	--GroupTip
	obj.RemoveRelatedGroupTip = RemoveRelatedGroupTip
	obj.AddRelatedGroupTip = AddRelatedGroupTip
	obj.ShowRelatedGroupTip = ShowRelatedGroupTip
	obj.HideRelatedGroupTip = HideRelatedGroupTip
	obj.SetGroupTipEnable = SetGroupTipEnable
	obj.SetAllGroupTipEnable = SetAllGroupTipEnable
	obj.HideAllGroupTip = HideAllGroupTip
	--private
	obj.CalculateTipPos = CalculateTipPos
	obj.QueryGroupTipObjIsInMovAni = QueryGroupTipObjIsInMovAni
	obj.groupTip = {}
	obj.tippedObjAttr = {}
	obj.GetTippedObjAttribute = GetTippedObjAttribute
	obj.currentShowTipObj = {}
	obj.AllGroupTip = {}
	
	
	XLSetGlobal("xunlei.TipsHelper", obj)
end