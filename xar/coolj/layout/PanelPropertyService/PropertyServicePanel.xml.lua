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
	
	self:AddTabItem("TabItem_PropertyService", "物业服务", "")
	self:AddTabItem("TabItem_PropertyInfo", "物业信息", "")
	
end

function OnActiveTabChanged(self, eventName, newid, oldid)
	local ownerTree = self:GetOwner()

	local propertyServiceChildPanelForService = ownerTree:GetUIObject("app.bkg:PropertyServicePanel:PropertyServiceChildPanelForService")
	local propertyServiceChildPanelForInfo = ownerTree:GetUIObject("app.bkg:PropertyServicePanel:PropertyServiceChildPanelForInfo")
	
	propertyServiceChildPanelForService:SetVisible(false)
    propertyServiceChildPanelForService:SetChildrenVisible(false)
	
	propertyServiceChildPanelForInfo:SetVisible(false)
    propertyServiceChildPanelForInfo:SetChildrenVisible(false)
	
	if newid =="TabItem_PropertyService" then
		propertyServiceChildPanelForService:SetVisible(true)
		propertyServiceChildPanelForService:SetChildrenVisible(true)
		--propertyServiceChildPanelForService:Get_PropertyServiceInfo()
	elseif newid == "TabItem_PropertyInfo" then
		propertyServiceChildPanelForInfo:SetVisible(true)
		propertyServiceChildPanelForInfo:SetChildrenVisible(true)
		AsynCall(function() propertyServiceChildPanelForInfo:Get_PropertyServiceInfo() end)
	end

end

function LB_OnInitControl(self)
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	--[[
	local headeritem = objFactory:CreateUIObject(1, "WHome.ListBox.HeaderItem")
	local attrHeaderItem = headeritem:GetAttribute()
	attrHeaderItem.Text = "sads"
	attrHeaderItem.ItemWidth = 80
	attrHeaderItem.ItemHeight = 40
	attrHeaderItem.TextHalign = "center"
	
	local headeritem2 = objFactory:CreateUIObject(2, "WHome.ListBox.HeaderItem")
	local attrHeaderItem1 = headeritem2:GetAttribute()
	attrHeaderItem1.Text = "2222222"
	attrHeaderItem1.ItemWidth = 180
	attrHeaderItem1.ItemHeight = 40
	
	local headerObj = self:GetControlObject("listbox.header")
	headerObj:AppendItem(headeritem)
	headerObj:AppendItem(headeritem2)
	]]
	local headerItemInfo = {
		HeaderItemId=1,
		ItemWidth=180,
		Text="服务类型",
		TextLeftOffSet=2,
		TextHalign="center",
		SubItem=false,
		MaxSize=300,
		MiniSize=40,
		ShowSplitter=true,
		ShowSortIcon=false,
		IncludeNext=false,
		SortProperty=1
	}
	self:InsertColumn(headerItemInfo)
	
--[[	local headerItemInfo1 = {
		HeaderItemId=2,
		ItemWidth=180,
		Text="服务类型",
		TextLeftOffSet=2,
		TextHalign="center",
		SubItem=false,
		MaxSize=300,
		MiniSize=40,
		ShowSplitter=true,
		ShowSortIcon=false,
		IncludeNext=false,
		SortProperty=1
	}
	self:InsertColumn(headerItemInfo1)]]
	self:ReloadHeader()
	
	local datasource = objFactory:CreateUIObject(1, "WHome.DataSource")
	datasource:InitControl()
	local dataconverter = objFactory:CreateUIObject(2, "WHome.DataConverter")
	self:SetDataSourceAndDataConverter(datasource, dataconverter)
end