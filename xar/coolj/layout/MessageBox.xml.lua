

function OnNcActivate(self, activate)
	local ownerTree = self:GetOwner()
	local flashObj = ownerTree:GetUIObject("app.bkg:bkg.flash")
			
	if activate then
		flashObj:SetVisible(false)
	else
		flashObj:SetVisible(true)
	end
	
	return 10, true, false
end

function OnClick(self)
	local owner = self:GetOwner()
	local hostwnd = owner:GetBindHostWnd()
	
	ret = 0
	if self:GetID() == "ok" then
		ret = 1
	end
	hostwnd:EndDialog(ret)
end

function OnCreate(self)
	local hostWndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local mainWnd = hostWndManager:GetHostWnd("CoolJ.MainWnd.Instance")
	self:Center(mainWnd)
end

function OnSize(self)
	local objectTree = self:GetBindUIObjectTree()
	local rootObject = objectTree:GetRootObject()
	--rootObject:SetObjPos(0, 0, width, height)
end

function OnClose(self)
	local owner = self:GetOwner()
	local hostwnd = owner:GetBindHostWnd()
	
	hostwnd:EndDialog(0)
end