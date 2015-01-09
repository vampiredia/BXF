function login_success()
	local app = XLGetObject("CoolJ.App")
	app:SetString("Community", "Community_Caption" ,"远洋山水吧")
	app:SetString("Community", "Community_Ak" ,"@#￥%……&×（")
	app:SetString("Community", "Community_Cid" ,"2")
	app:SetString("Community", "Community_Nick" ,"Lydia")
	app:SetString("Community", "Community_State" ,"ok")
end

function login_failed()
	local app = XLGetObject("CoolJ.App")
	app:SetString("Community", "Community_State" ,"")
	app:SetString("Community", "Community_Ak" ,"")
end

function OnLogin(self)
	local owner = self:GetOwnerControl()
	owner:GetControlObject("text.tips"):SetText("帐号或密码错误")
	
	local name = owner:GetControlObject("edit.name"):GetText()
	local passwd = owner:GetControlObject("edit.password"):GetText()
	if name == '' then 
		owner:GetControlObject("text.tips"):SetText("帐号不能为空")
		return
	elseif passwd == '' then
		owner:GetControlObject("text.tips"):SetText("密码不能为空")
		return
	else
		login_success()
		local owner = self:GetOwner()
		local hostwnd = owner:GetBindHostWnd()
		hostwnd:EndDialog(1)
	end
end

function OnClose(self)
	local owner = self:GetOwner()
	local hostwnd = owner:GetBindHostWnd()
	
	hostwnd:EndDialog(0)
end

function OnMinisize(self)
	local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local hostwnd = hostwndManager:GetHostWnd("CoolJ.LoginWnd.Instance")
	hostwnd:Min() 
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