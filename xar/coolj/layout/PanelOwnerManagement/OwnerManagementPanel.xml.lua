function OnInitControl(self)
	local attr = self:GetAttribute()
	local bkg = self:GetControlObject("bkg")
	--bkg:SetTextureID(attr.BorderTexture)
end

function TabHeader_OnInitControl(self)
	local attr = self:GetAttribute()
	attr.ItemClass = "Head.TabButton"
	attr.ButtonWidth = 138
	attr.ButtonHeight = 33
	attr.TextFontID = "btText.Tab.title.font"
	attr.ButtonInternalSpace = 0
	attr.FuncItemCallBack = funcItemCallBack
	attr.BtnBkgNormal = "text.tab.btn.normal"
	attr.BtnBkgHover = "text.tab.btn.hover"
	attr.BtnBkgDown = "text.tab.btn.down"
	attr.TextValign = "center"
	
	self:AddTabItem("TabItem_OwnerManagerment", "业主管理", "")
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