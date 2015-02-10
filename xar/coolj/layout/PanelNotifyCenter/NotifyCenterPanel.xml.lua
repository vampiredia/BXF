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
	
	self:AddTabItem("TabItem_Box", "消息盒子", "")
	self:AddTabItem("TabItem_Public", "官方消息", "")
	self:AddTabItem("TabItem_About", "软件信息", "")
end

function OnActiveTabChanged(self, eventName, newid, oldid)
	local ownerTree = self:GetOwner()

	local notifyCenterChildPanelForBox = ownerTree:GetUIObject("app.bkg:NotifyCenterPanel:NotifyCenterChildPanelForBox")
	local notifyCenterChildPanelForPublic = ownerTree:GetUIObject("app.bkg:NotifyCenterPanel:NotifyCenterChildPanelForPublic")
	local notifyCenterChildPanelForAbout = ownerTree:GetUIObject("app.bkg:NotifyCenterPanel:NotifyCenterChildPanelForAbout")
	
	notifyCenterChildPanelForBox:SetVisible(false)
	notifyCenterChildPanelForBox:SetChildrenVisible(false)
	
	notifyCenterChildPanelForPublic:SetVisible(false)
    notifyCenterChildPanelForPublic:SetChildrenVisible(false)
	
	notifyCenterChildPanelForAbout:SetVisible(false)
    notifyCenterChildPanelForAbout:SetChildrenVisible(false)
	
	if newid == "TabItem_Box" then
		notifyCenterChildPanelForBox:SetVisible(true)
		notifyCenterChildPanelForBox:SetChildrenVisible(true)
	elseif newid == "TabItem_Public" then
		notifyCenterChildPanelForPublic:SetVisible(true)
		notifyCenterChildPanelForPublic:SetChildrenVisible(true)
		notifyCenterChildPanelForPublic:Get_NoticePublicInfo()
	elseif newid == "TabItem_About" then
		notifyCenterChildPanelForAbout:SetVisible(true)
		notifyCenterChildPanelForAbout:SetChildrenVisible(true)
	end

end