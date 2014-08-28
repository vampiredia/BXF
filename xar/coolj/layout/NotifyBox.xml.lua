function NotifyBoxPositionChange()
	local osShell = XLGetObject("CoolJ.OSShell")
	local l,t,r,b = osShell:GetWorkArea()
	
	local hostWndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local oncallHandleID = "CoolJ.NotifyBox.OnCall.Instance"
	local oncallHwnd = hostWndManager:GetHostWnd(oncallHandleID)
	if oncallHwnd ~= nil then
		local cl,ct,cr,cb = oncallHwnd:GetWindowRect()
		local cWidth = cr-cl
		local cHeight = cb-ct

		oncallHwnd:Move(r-cWidth,b-cHeight,cWidth,cHeight)
		b = b - cHeight
	end
	
	local ownerHandleID = "CoolJ.NotifyBox.Owner.Instance"
	local ownerHwnd = hostWndManager:GetHostWnd(ownerHandleID)
	if ownerHwnd ~= nil then
		local cl,ct,cr,cb = ownerHwnd:GetWindowRect()
		local cWidth = cr-cl
		local cHeight = cb-ct
			
		ownerHwnd:Move(r-cWidth,b-cHeight,cWidth,cHeight)
	end
end

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
	AniShow(self)
--[[

	NotifyBoxPositionChange()
]]
end

function AniShow(self)
	local owner = self:GetOwner()
	local root = owner:GetRootObject()
	local attr = root:GetAttribute()
	local handleID = "CoolJ.NotifyBox."..attr.Type..".Instance"
	local hostWndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local ownerHwnd = hostWndManager:GetHostWnd(handleID)
	local l,t,r,b = ownerHwnd:GetWindowRect()
	
	local aniFactory = XLGetObject("Xunlei.UIEngine.AnimationFactory")
	local posAni = aniFactory:CreateAnimation("PosChangeAnimation")
	posAni:SetTotalTime(110)
	posAni:BindLayoutObj(root)
	posAni:SetKeyFramePos(0, 0, 0, 5)
	owner:AddAnimation(posAni)
	posAni:Resume()

	local alphaAni = aniFactory:CreateAnimation("AlphaChangeAnimation")
	alphaAni:SetTotalTime(110)
	alphaAni:BindObj(root:GetControlObject("texture.caption.mainwnd.bkg"))
	alphaAni:SetKeyFrameAlpha(255, 100)
	owner:AddAnimation(alphaAni)
	alphaAni:Resume()
	
	local onAniFinish = 
		function (ani)
			local attr = self:GetOwner():GetRootObject():GetAttribute()
			--XLMessageBox(attr.Type)
	
			local handleID = "CoolJ.NotifyBox."..attr.Type..".Instance"
			local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
			hostwndManager:RemoveHostWnd(handleID)
	
			local objtreeManager = XLGetObject("Xunlei.UIEngine.TreeManager")	
			objtreeManager:DestroyTree(handleID)			
		end
	posAni:AttachListener(true,onAniFinish)
	
end

function AniHide()

end

