function OnInitControl(self)
	local attr = self:GetAttribute()
	local bkg = self:GetControlObject("bkg")
	--bkg:SetTextureID(attr.BorderTexture)
end

local funcItemCallBack = 
	function (itemObj)
		local attr = itemObj:GetAttribute()
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
	
	self:AddTabItem("TabItem_Notice", "社区通知", "")
	self:AddTabItem("TabItem_Announcement", "社区公告", "")
	self:AddTabItem("TabItem_QA", "问题解答", "")
end

function OnActiveTabChanged(self, eventName, newid, oldid)
	local ownerTree = self:GetOwner()

	local publishCenterChildPanelForNotice = ownerTree:GetUIObject("app.bkg:PublishCenterPanel:PublishCenterChildPanelForNotice")

	local publishCenterChildPanelForAnnouncement = ownerTree:GetUIObject("app.bkg:PublishCenterPanel:PublishCenterChildPanelForAnnouncement")
	local publishCenterChildPanelForQA = ownerTree:GetUIObject("app.bkg:PublishCenterPanel:PublishCenterChildPanelForQA")
	
	publishCenterChildPanelForNotice:SetVisible(false)
    publishCenterChildPanelForNotice:SetChildrenVisible(false)
	
	publishCenterChildPanelForAnnouncement:SetVisible(false)
    publishCenterChildPanelForAnnouncement:SetChildrenVisible(false)
    
    publishCenterChildPanelForQA:SetVisible(false)
    publishCenterChildPanelForQA:SetChildrenVisible(false)
	
	if newid =="TabItem_Notice" then
		publishCenterChildPanelForNotice:SetVisible(true)
		publishCenterChildPanelForNotice:SetChildrenVisible(true)
	elseif newid == "TabItem_Announcement" then
		publishCenterChildPanelForAnnouncement:SetVisible(true)
		publishCenterChildPanelForAnnouncement:SetChildrenVisible(true)
	elseif newid == "TabItem_QA" then
	    publishCenterChildPanelForQA:SetVisible(true)
        publishCenterChildPanelForQA:SetChildrenVisible(true)
		AsynCall(function() publishCenterChildPanelForQA:Get_QAData() end)
	end

end