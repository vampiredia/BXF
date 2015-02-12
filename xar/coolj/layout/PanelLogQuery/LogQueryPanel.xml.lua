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
	
	self:AddTabItem("TabItem_Login", "登录日志", "")
	self:AddTabItem("TabItem_Operate", "操作日志", "")
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
		logQueryChildPanelForLogin:GetLogInfo()
	elseif newid == "TabItem_Operate" then
		logQueryChildPanelForOperate:SetVisible(true)
		logQueryChildPanelForOperate:SetChildrenVisible(true)
		logQueryChildPanelForOperate:GetLogInfo()
	end
end