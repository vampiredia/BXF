
----------------------------------------------------------
function CN_OnClose(self)
	self:GetOwnerControl():UpdateUI("hide_ani")
end

function CN_OnInitControl(self)
	--self:FireExtEvent("Update")
end

function CN_OnBind(self)
	--self:FireExtEvent("Update")
end

function CN_NotifyUpdate(self, status)
	local attr = self:GetAttribute()
	if attr.Status == status then return end
	
	if status == "show" then
		self:GetControlObject("bkgcolor"):SetAlpha(255)
		self:SetObjPos(self:GetOwnerControl():GetObjPos())
	elseif status == "hide" then
		self:GetControlObject("bkgcolor"):SetAlpha(0)
		local l,t,r,b = self:GetOwnerControl():GetObjPos()
		self:SetObjPos(0, b-t, r-l, (b-t)*1.8)
	elseif status == "show_ani" then
		self:GetControlObject("bkgcolor"):SetAlpha(255)
		local l,t,r,b = self:GetOwnerControl():GetObjPos()
		self:SetObjPos(0, b-t, r-l, (b-t)*1.8)
		local aniFactory = XLGetObject("Xunlei.UIEngine.AnimationFactory")
		local posAni = aniFactory:CreateAnimation("PosChangeAnimation")
		posAni:SetTotalTime(600)
		posAni:BindLayoutObj(self)
		
		posAni:SetKeyFrameRect(0, b-t, r-l, (b-t)*1.8, 0, 0, r-l, b-t)
		local owner = self:GetOwner()
		owner:AddAnimation(posAni)
		posAni:Resume()		
	elseif status == "hide_ani" then
		local l,t,r,b = self:GetOwnerControl():GetObjPos()
		local owner = self:GetOwner()
	
		local aniFactory = XLGetObject("Xunlei.UIEngine.AnimationFactory")
	
		local posAni = aniFactory:CreateAnimation("PosChangeAnimation")
		posAni:SetTotalTime(600)
		posAni:BindLayoutObj(self)
		posAni:SetKeyFramePos(0, 0, 0, b-t)
		owner:AddAnimation(posAni)
		posAni:Resume()	
	
		local alphaAni = aniFactory:CreateAnimation("AlphaChangeAnimation")
		alphaAni:SetTotalTime(400)
		alphaAni:BindObj(self:GetControlObject("bkgcolor"))
		alphaAni:SetKeyFrameAlpha(255, 0)
		owner:AddAnimation(alphaAni)
		alphaAni:Resume()			
	else
		return
	end
	attr.Status = status
end

function AddNotify(self, text)
	local attr = self:GetAttribute()
	
	local obj = self:GetControlObject("item.notify")
	if obj == nil then 
		local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
		obj = objFactory:CreateUIObject("item.notify", "CoolJ.Notify")
		self:AddChild(obj)
	end
	obj:SetText(text)
	self:UpdateUI("show_ani")
	
	local timerManager = XLGetObject("Xunlei.UIEngine.TimerManager")
	if attr.NotifyTimerID ~= nil then timerManager:KillTimer(attr.NotifyTimerID) end
	attr.NotifyTimerID = timerManager:SetTimer(function() UpdateUI(self, "hide_ani", true) end, 5000)
end

function RemoveNotify(self)
	local obj = self:GetControlObject("item.notify")
	if obj == nil then return end
	obj:UpdateUI("hide")	
end

function RemoveAllNotify(self)
	local obj = self:GetControlObject("item.notify")
	if obj == nil then return end
	obj:UpdateUI("hide")	
end

function CNC_OnInitControl(self)
	local attr = self:GetAttribute()
end

function UpdateUI(self, status, isTimer)
	local obj = self:GetControlObject("item.notify")
	if obj == nil then return end
	obj:UpdateUI(status)	
	if isTimer then 
		local attr = self:GetAttribute()
		if attr.NotifyTimerID then 
			local timerManager = XLGetObject("Xunlei.UIEngine.TimerManager")
			timerManager:KillTimer(attr.NotifyTimerID)
			attr.NotifyTimerID = nil
		end
	end
end

function SetText(self, text)
	local message = self:GetControlObject("message")
	message:SetText(text)
end

function GetText(self)
	local message = self:GetControlObject("message")
	return message:GetText()
end

