function OnInitControl(self)
	local attr = self:GetAttribute()
	local bkg = self:GetControlObject("bkg")
	bkg:SetTextureID(attr.BorderTexture)
end

function TabHeader_OnInitControl(self)
	self:AddTabItem("TabItem_OwnerManagerment", "业主管理", "tab.icon.publish.center")
end

function OnActiveTabChanged(self, eventName, newid, oldid)
	local ownerTree = self:GetOwner()

	local ownerManagementChildPanelForOwnerManagement = ownerTree:GetUIObject("app.bkg:OwnerManagementPanel:OwnerManagementChildPanelForOwnerManagement")
	
	ownerManagementChildPanelForOwnerManagement:SetVisible(false)
    ownerManagementChildPanelForOwnerManagement:SetChildrenVisible(false)
	
	if newid =="TabItem_OwnerManagerment" then
		ownerManagementChildPanelForOwnerManagement:SetVisible(true)
		ownerManagementChildPanelForOwnerManagement:SetChildrenVisible(true)
	end

end