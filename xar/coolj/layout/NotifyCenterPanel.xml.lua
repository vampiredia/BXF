function OnInitControl(self)
	local attr = self:GetAttribute()
	local bkg = self:GetControlObject("bkg")
	--bkg:SetTextureID(attr.BorderTexture)
end

function TabHeader_OnInitControl(self)
	self:AddTabItem("TabItem_Public", "官方消息", "tab.icon.publish.center")
	self:AddTabItem("TabItem_About", "软件信息", "tab.icon.property.service")
end

function OnActiveTabChanged(self, eventName, newid, oldid)
	local ownerTree = self:GetOwner()

	local notifyCenterChildPanelForPublic = ownerTree:GetUIObject("app.bkg:NotifyCenterPanel:NotifyCenterChildPanelForPublic")
	local notifyCenterChildPanelForAbout = ownerTree:GetUIObject("app.bkg:NotifyCenterPanel:NotifyCenterChildPanelForAbout")
	
	notifyCenterChildPanelForPublic:SetVisible(false)
    notifyCenterChildPanelForPublic:SetChildrenVisible(false)
	
	notifyCenterChildPanelForAbout:SetVisible(false)
    notifyCenterChildPanelForAbout:SetChildrenVisible(false)
	
	if newid =="TabItem_Public" then
		notifyCenterChildPanelForPublic:SetVisible(true)
		notifyCenterChildPanelForPublic:SetChildrenVisible(true)
	elseif newid == "TabItem_About" then
		notifyCenterChildPanelForAbout:SetVisible(true)
		notifyCenterChildPanelForAbout:SetChildrenVisible(true)
	end

end