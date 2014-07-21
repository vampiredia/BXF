function OnClose(self)
	local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local hostwnd = hostwndManager:GetHostWnd("CoolJ.LoginWnd.Instance")
	
	hostwndManager:RemoveHostWnd("CoolJ.LoginWnd.Instance")
	
	local objtreeManager = XLGetObject("Xunlei.UIEngine.TreeManager")	
	objtreeManager:DestroyTree("CoolJ.LoginObjTree.Instance")
	
	hostwnd = hostwndManager:GetHostWnd("CoolJ.MainWnd.Instance")
	if hostwnd ~= nil then 
		hostwndManager:RemoveHostWnd("CoolJ.MainWnd.Instance")
		objtreeManager:DestroyTree("CoolJ.MainObjTree.Instance")
	end
		
	local app = XLGetObject("CoolJ.App")
	app:Quit(0)
end

function OnSysBtnInitControl(self)

end

function OnMinisize(self)
	local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local hostwnd = hostwndManager:GetHostWnd("CoolJ.LoginWnd.Instance")
	hostwnd:Min() 
end

function OnClick()
	local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local hostwnd = hostwndManager:GetHostWnd("CoolJ.LoginWnd.Instance")
	
	hostwndManager:RemoveHostWnd("CoolJ.LoginWnd.Instance")
	
	local objtreeManager = XLGetObject("Xunlei.UIEngine.TreeManager")	
	objtreeManager:DestroyTree("CoolJ.LoginObjTree.Instance")
	
	hostwnd = hostwndManager:GetHostWnd("CoolJ.MainWnd.Instance")
	hostwnd:SetVisible(true)
end