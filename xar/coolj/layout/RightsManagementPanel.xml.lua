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
	
	self:AddTabItem("TabItem_PreView", "权限预览", "")
	self:AddTabItem("TabItem_Managerment", "权限组管理", "")
end

function OnActiveTabChanged(self, eventName, newid, oldid)
	local ownerTree = self:GetOwner()

	local rightsManagementChildPanelForPreView = ownerTree:GetUIObject("app.bkg:RightsManagementPanel:RightsManagementChildPanelForPreView")
	local rightsManagementChildPanelForManagerment = ownerTree:GetUIObject("app.bkg:RightsManagementPanel:RightsManagementChildPanelForManagerment")
	
	rightsManagementChildPanelForPreView:SetVisible(false)
    rightsManagementChildPanelForPreView:SetChildrenVisible(false)
	
	rightsManagementChildPanelForManagerment:SetVisible(false)
    rightsManagementChildPanelForManagerment:SetChildrenVisible(false)
	
	if newid =="TabItem_PreView" then
		rightsManagementChildPanelForPreView:SetVisible(true)
		rightsManagementChildPanelForPreView:SetChildrenVisible(true)
	elseif newid == "TabItem_Managerment" then
		rightsManagementChildPanelForManagerment:SetVisible(true)
		rightsManagementChildPanelForManagerment:SetChildrenVisible(true)
	end

end