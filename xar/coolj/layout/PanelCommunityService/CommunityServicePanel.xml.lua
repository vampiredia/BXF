function OnInitControl(self)
	local attr = self:GetAttribute()
	local bkg = self:GetControlObject("bkg")
	--bkg:SetTextureID(attr.BorderTexture)
end

function TabHeader_OnInitControl(self)
	local attr = self:GetAttribute()
	attr.ItemClass = "Head.TabButton"
	attr.ButtonWidth = 138
	attr.ButtonHeight = 55
	attr.TextFontID = "btText.Tab.title.font"
	attr.ButtonInternalSpace = 0
	attr.FuncItemCallBack = funcItemCallBack
	attr.BtnBkgNormal = "text.tab.btn.normal"
	attr.BtnBkgHover = "text.tab.btn.hover"
	attr.BtnBkgDown = "text.tab.btn.down"
	attr.TextValign = "center"
	
	self:AddTabItem("TabItem_CommunityService", "社区服务", "")
	self:AddTabItem("TabItem_Complain", "投诉", "")
end

function OnActiveTabChanged(self, eventName, newid, oldid)
	local ownerTree = self:GetOwner()

	local communityServiceChildPanelForService = ownerTree:GetUIObject("app.bkg:CommunityServicePanel:CommunityServiceChildPanelForService")
	local communityServiceChildPanelForComplain = ownerTree:GetUIObject("app.bkg:CommunityServicePanel:CommunityServiceChildPanelForComplain")
	
	communityServiceChildPanelForService:SetVisible(false)
    communityServiceChildPanelForService:SetChildrenVisible(false)
	
	communityServiceChildPanelForComplain:SetVisible(false)
    communityServiceChildPanelForComplain:SetChildrenVisible(false)
	
	if newid =="TabItem_CommunityService" then
		communityServiceChildPanelForService:SetVisible(true)
		communityServiceChildPanelForService:SetChildrenVisible(true)
	elseif newid == "TabItem_Complain" then
		communityServiceChildPanelForComplain:SetVisible(true)
		communityServiceChildPanelForComplain:SetChildrenVisible(true)
	end
end