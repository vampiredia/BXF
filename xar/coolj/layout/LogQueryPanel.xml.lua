function OnInitControl(self)
	local attr = self:GetAttribute()
	local bkg = self:GetControlObject("bkg")
	--bkg:SetTextureID(attr.BorderTexture)
end

function TabHeader_OnInitControl(self)
	self:AddTabItem("TabItem_Login", "登录日志", "tab.icon.publish.center")
	self:AddTabItem("TabItem_Operate", "操作日志", "tab.icon.property.service")
end

function OnActiveTabChanged(self, eventName, newid, oldid)
	local ownerTree = self:GetOwner()

	local logQueryChildPanelForLogin = ownerTree:GetUIObject("app.bkg:LogQueryPanel:LogQueryChildPanelForLogin")
	local logQueryChildPanelForOperate = ownerTree:GetUIObject("app.bkg:LogQueryPanel:LogQueryChildPanelForOperate")
	
	logQueryChildPanelForLogin:SetVisible(false)
    logQueryChildPanelForLogin:SetChildrenVisible(false)
	
	logQueryChildPanelForOperate:SetVisible(false)
    logQueryChildPanelForOperate:SetChildrenVisible(false)
	
	if newid =="TabItem_Login" then
		logQueryChildPanelForLogin:SetVisible(true)
		logQueryChildPanelForLogin:SetChildrenVisible(true)
	elseif newid == "TabItem_Operate" then
		logQueryChildPanelForOperate:SetVisible(true)
		logQueryChildPanelForOperate:SetChildrenVisible(true)
	end
end