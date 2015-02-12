function login_success(result)
	local app = XLGetObject("CoolJ.App")
	app:SetString("Community", "Community_Caption", result["user_info"]["community"])
	app:SetString("Community", "Community_Ak", result["user_info"]["ak"])
	app:SetString("Community", "Community_Cid", result["user_info"]["cid"])
	app:SetString("Community", "Community_Nick", result["user_info"]["nick"])
	app:SetString("Community", "Community_State", "ok")
end

function login_failed()
	local app = XLGetObject("CoolJ.App")
	app:SetString("Community", "Community_State" ,"")
	app:SetString("Community", "Community_Ak" ,"")
end

function OnLogin(self)
	local owner = self:GetOwnerControl()
	--owner:GetControlObject("text.tips"):SetText("帐号或密码错误")
	
	local name = owner:GetControlObject("edit.name"):GetText()
	local passwd = owner:GetControlObject("edit.password"):GetText()
	if name == '' then 
		owner:GetControlObject("text.tips"):SetText("帐号不能为空")
		return
	elseif passwd == '' then
		owner:GetControlObject("text.tips"):SetText("密码不能为空")
		return
	else
		local request = function(ret, msg, result)
			if ret == 0 then
				login_success(result)	
				local attr = owner:GetAttribute()
				if attr.CallBack ~= nil then 
					attr.CallBack()
				end				
				local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
				hostwndManager:RemoveHostWnd("CoolJ.LoginWnd.Instance")
				local objtreeManager = XLGetObject("Xunlei.UIEngine.TreeManager")	
				objtreeManager:DestroyTree("CoolJ.LoginWnd.Instance")
			else
				owner:GetControlObject("text.tips"):SetText(msg)
			end
		end
		local param = "action=login&name="..name.."&passwd="..passwd
		HttpRequest("/api/user", "POST", param, request)
	end
end

function OnClose(self)
	local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	hostwndManager:RemoveHostWnd("CoolJ.LoginWnd.Instance")
	local objtreeManager = XLGetObject("Xunlei.UIEngine.TreeManager")	
	objtreeManager:DestroyTree("CoolJ.LoginWnd.Instance")
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