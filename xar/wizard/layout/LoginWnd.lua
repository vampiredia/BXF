function OnClose(self)
	local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local hostwnd = hostwndManager:GetHostWnd("Wizard.LoginWnd.Instance")
	
	hostwndManager:RemoveHostWnd("Wizard.LoginWnd.Instance")
	
	local objtreeManager = XLGetObject("Xunlei.UIEngine.TreeManager")	
	objtreeManager:DestroyTree("Wizard.LoginObjTree.Instance")
	
	hostwnd = hostwndManager:GetHostWnd("Wizard.MainWnd.Instance")
	if hostwnd ~= nil then 
		hostwndManager:RemoveHostWnd("Wizard.MainWnd.Instance")
		objtreeManager:DestroyTree("Wizard.MainObjTree.Instance")
	end
		
	local app = XLGetObject("Wizard.App")
	app:Quit(0)
end

function OnSysBtnInitControl(self)

end

function OnMinisize(self)
	local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local hostwnd = hostwndManager:GetHostWnd("Wizard.LoginWnd.Instance")
	hostwnd:Min() 
end

function OnClick()
	local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local hostwnd = hostwndManager:GetHostWnd("Wizard.LoginWnd.Instance")
	
	hostwndManager:RemoveHostWnd("Wizard.LoginWnd.Instance")
	
	local objtreeManager = XLGetObject("Xunlei.UIEngine.TreeManager")	
	objtreeManager:DestroyTree("Wizard.LoginObjTree.Instance")
	
	hostwnd = hostwndManager:GetHostWnd("Wizard.MainWnd.Instance")
	hostwnd:SetVisible(true)
end