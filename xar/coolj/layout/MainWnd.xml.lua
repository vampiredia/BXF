local function ChangeColor(hBitmap)
    local SkinManager = XLGetObject("CoolJ.SkinManager")
	if SkinManager then
	    if hBitmap then
	        local function ModifyWith(h,s,v,bepaint)
                local function Pretreat(resId,resObj)               
                    resObj:ModifyColor(h,s,v,bepaint)
                end
                return Pretreat
            end
    
	        local xarManager = XLGetObject("Xunlei.UIEngine.XARManager")
	        local h,s,v = SkinManager:GetBitmapHSLColor(hBitmap)
	        local resID
	        
	        count = SkinManager:GetColorableBitmapCount()
            for index = 0, count - 1 do
                resID = SkinManager:GetBitmapIdByIndex(index)
                xarManager:SetBitmapPretreater(resID,ModifyWith(h,s,v,1))
            end
            
            count = SkinManager:GetColorableColorCount()
            for index = 0, count - 1 do
                resID = SkinManager:GetColorIdByIndex(index)
                xarManager:SetColorPretreater(resID,ModifyWith(h,s,v,1))
            end
            
            count = SkinManager:GetColorableTextureCount()
            for index = 0, count - 1 do
                resID = SkinManager:GetTextureIdByIndex(index)
                xarManager:SetTexturePretreater(resID,ModifyWith(h,s,v,1))
            end
            
            xarManager:CommitPretreat()
	    end
	end
end

function OnSize(self, sizetype, width, height)

	if type_ == "min" then
		return
	elseif type_ == "max" then
		local tree = self:GetBindUIObjectTree()
		if tree ~= nil then
			local button = tree:GetUIObject( "mainwnd.bkg:mainwnd.sysbtn" )
			if button ~= nil then
				--button:SetMaxState( false )
			end
		end
	elseif type_ == "restored" then
		local tree = self:GetBindUIObjectTree()
		if tree ~= nil then
			local button = tree:GetUIObject( "mainwnd.bkg:mainwnd.sysbtn" )
			if button ~= nil then
				--button:SetMaxState( true )
			end
		end
	end
	
	local objectTree = self:GetBindUIObjectTree()
	local rootObject = objectTree:GetRootObject()
	rootObject:SetObjPos(0, 0, width, height)
	
end

function OnDragQuery(self, dataObject, keyState, x, y)

	local imageCore = XLGetObject("CoolJ.ImageCore")
	local ret, file = imageCore:ParseDataObject(dataObject)
	if not ret then
		return 0, true
	end
	
	return 1, true
end

local effect

function OnDragEnter(self, dataObject, keyState, x, y)
	
	effect = 0
	
	local imageCore = XLGetObject("CoolJ.ImageCore")
	local ret, file = imageCore:ParseDataObject(dataObject)
	if not ret then
		return effect, true
	end
	
	effect = 1 --DROPEFFECT_COPY
	return effect, true
end

function OnDragOver(self)
	return effect, true
end

function OnDrop(self, dataObject, keyState, x, y)
	
	local imageCore = XLGetObject("CoolJ.ImageCore")
	local ret, file = imageCore:ParseDataObject(dataObject)
	if not ret then
		return 0, true
	end
	
	local app = XLGetObject("CoolJ.App")
	app:SetString("ConfigGraphics", "ConfigGraphics_BkgFile", file)
	
	return effect, true
end

function OnClose(self)
	-- user state logout
	Logout(nil)
	
	local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local hostwnd = hostwndManager:GetHostWnd("CoolJ.MainWnd.Instance")
	
	hostwndManager:RemoveHostWnd("CoolJ.MainWnd.Instance")
	
	local objtreeManager = XLGetObject("Xunlei.UIEngine.TreeManager")	
	objtreeManager:DestroyTree("CoolJ.MainObjTree.Instance")
	
	local app = XLGetObject("CoolJ.App")
	app:Quit(0)
end

function OnSysBtnInitControl(self)

end

function OnMinisize(self)
	local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local hostwnd = hostwndManager:GetHostWnd("CoolJ.MainWnd.Instance")
	hostwnd:Min() 
end

function OnMaxBtnClick(self)
	local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local hostwnd = hostwndManager:GetHostWnd("CoolJ.MainWnd.Instance")
	local state = hostwnd:GetWindowState()
	if state == "max" then
		if start_max then
			hostwnd:Restore()
			local defaultWidth, defaultHeight = GetDefaultWindowSize()
			hostwnd:Move(0, 0, defaultWidth, defaultHeight)
			hostwnd:Center()
			start_max = false
		else
			hostwnd:Restore()
		end
		self:SetMaxState( true )
	else
		hostwnd:Max()
		self:SetMaxState( false )
	end
end

function GetScreenPos(menuRoot, x, y)
	local left,top,right,bottom = menuRoot:GetObjPos()
	
	local width = right - left
	local height = bottom - top
	
	local menuTree = menuRoot:GetOwner()
	local menuHostWnd = menuTree:GetBindHostWnd()
	
	local sleft, stop, sright, sbottom = menuHostWnd:GetMonitorRect(x, y)
	if x + width > sright then
		x = x - width
	end
	
	if y + height > sbottom then
		y = y - height
	end
	
	return x, y, width, height
end	

function OnMainWndRButtonUp(self, x, y)
		
	local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")				
	local menuTreeTemplate = templateMananger:GetTemplate("CoolJ.Menu","ObjectTreeTemplate")
	local menuTree = menuTreeTemplate:CreateInstance("CoolJ.Menu.Instance")
	
	local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local parent = hostwndManager:GetHostWnd("CoolJ.MainWnd.Instance")
	local parentHandle = parent:GetWndHandle()

	local menuHostWndTemplate = templateMananger:GetTemplate("CoolJ.Menu", "HostWndTemplate")
	local menuHostWnd = menuHostWndTemplate:CreateInstance("CoolJ.Menu.Instance")
	
	menuHostWnd:BindUIObjectTree(menuTree)
	local menuContext = menuTree:GetUIObject("menu.root")
	
	x, y = parent:ClientPtToScreenPt(x,y)
	local left, top, width, height = GetScreenPos(menuContext, x, y)
	
	menuHostWnd:TrackPopupMenu(parentHandle, left, top, width, height)
	
	local objtreeManager = XLGetObject("Xunlei.UIEngine.TreeManager")	
	objtreeManager:DestroyTree("CoolJ.Menu.Instance")
	hostwndManager:RemoveHostWnd("CoolJ.Menu.Instance")
end

function TabHeader_OnInitControl(self)
	local attr = self:GetAttribute()
	attr.TextFontID = "btTask.title.font"
	attr.ItemClass = "Head.TabButton"
	
	self:AddTabItem("TabItem_PublishCenter", "", "tab.icon.publish.center", "tab.icon.publish.center.select")
	self:AddTabItem("TabItem_PropertyService", "", "tab.icon.property.service", "tab.icon.property.service.select")
	self:AddTabItem("TabItem_CommunityService", "", "tab.icon.community.service", "tab.icon.community.service.select")
	self:AddTabItem("TabItem_OwnerManagement", "", "tab.icon.owner.managerment", "tab.icon.owner.managerment.select")
	self:AddTabItem("TabItem_RightsManagement", "", "tab.icon.rights.management", "tab.icon.rights.management.select")
	self:AddTabItem("TabItem_LogQuery", "", "tab.icon.log.query", "tab.icon.log.query.select")
	self:AddTabItem("TabItem_NotifyCenter", "", "tab.icon.notify.center", "tab.icon.notify.center.select")
end

function OnActiveTabChanged(self, eventName, newid, oldid)
	local ownerTree = self:GetOwner()
	local publishCenterPanel = ownerTree:GetUIObject("app.bkg:PublishCenterPanel")
	local propertyServicePanel = ownerTree:GetUIObject("app.bkg:PropertyServicePanel")
	local communityServicehPanel = ownerTree:GetUIObject("app.bkg:CommunityServicePanel")
	local ownerManagementPanel = ownerTree:GetUIObject("app.bkg:OwnerManagementPanel")
	local rightsManagementPanel = ownerTree:GetUIObject("app.bkg:RightsManagementPanel")
	local logQueryPanel = ownerTree:GetUIObject("app.bkg:LogQueryPanel")
	local notifyCenterPanel = ownerTree:GetUIObject("app.bkg:NotifyCenterPanel")
	
	publishCenterPanel:SetVisible(false)
    publishCenterPanel:SetChildrenVisible(false)
	
	propertyServicePanel:SetVisible(false)
    propertyServicePanel:SetChildrenVisible(false)
    
    communityServicehPanel:SetVisible(false)
    communityServicehPanel:SetChildrenVisible(false)
    
    ownerManagementPanel:SetVisible(false)
    ownerManagementPanel:SetChildrenVisible(false)
    
    rightsManagementPanel:SetVisible(false)
    rightsManagementPanel:SetChildrenVisible(false)
    
    logQueryPanel:SetVisible(false)
    logQueryPanel:SetChildrenVisible(false)
	
	notifyCenterPanel:SetVisible(false)
	notifyCenterPanel:SetChildrenVisible(false)
	
	if newid =="TabItem_PublishCenter" then
		publishCenterPanel:SetVisible(true)
		publishCenterPanel:SetChildrenVisible(true)
	elseif newid == "TabItem_PropertyService" then	
		propertyServicePanel:SetVisible(true)
		propertyServicePanel:SetChildrenVisible(true)
		-- get data from web
		local obj = propertyServicePanel:GetControlObject("PropertyServiceChildPanelForService")
		AsynCall(function() obj:Get_PropertyServiceInfo() end)
	elseif newid == "TabItem_CommunityService" then
		communityServicehPanel:SetVisible(true)
		communityServicehPanel:SetChildrenVisible(true)
		-- get data from web
		local obj = communityServicehPanel:GetControlObject("CommunityServiceChildPanelForService")
		AsynCall(function() obj:Get_CommunityServiceInfo() end)
	elseif newid == "TabItem_OwnerManagement" then
		ownerManagementPanel:SetVisible(true)
		ownerManagementPanel:SetChildrenVisible(true)
	elseif newid == "TabItem_RightsManagement" then
		rightsManagementPanel:SetVisible(true)
		rightsManagementPanel:SetChildrenVisible(true)
	elseif newid =="TabItem_LogQuery" then
		logQueryPanel:SetVisible(true)
		logQueryPanel:SetChildrenVisible(true)
	elseif newid == "TabItem_NotifyCenter" then
	    notifyCenterPanel:SetVisible(true)
        notifyCenterPanel:SetChildrenVisible(true)
	end

end

function test(self)
	self:SetIcon('tab.icon.publish.center')
end

function Login(self)
	local app = XLGetObject("CoolJ.App")
	local ret, status = app:GetString("Community", "Community_State", "")
	if status == 'ok' then
		local communityCaptionObj = self:GetControlObject("community.text")
		local ret, caption = app:GetString("Community", "Community_Caption", "")
		communityCaptionObj:SetVisible(true)
		communityCaptionObj:SetText(caption)
		
		local loginObj = self:GetControlObject("login.text")
		loginObj:SetVisible(false)
		
		local userInfoObj = self:GetControlObject("UserInfo")
		userInfoObj:SetVisible(true)
		userInfoObj:SetChildrenVisible(true)
		local ret, nick = app:GetString("Community", "Community_Nick", "")
		local nickObj = self:GetControlObject("UserName")
		nickObj:SetText(nick)
	else
		local communityCaptionObj = self:GetControlObject("community.text")
		if communityCaptionObj ~= nil then communityCaptionObj:SetVisible(false) end
		local loginObj = self:GetControlObject("login.text")
		if loginObj ~= nil then loginObj:SetVisible(true) end
		local userInfoObj = self:GetControlObject("UserInfo")
		if userInfoObj ~= nil then
			userInfoObj:SetVisible(false)
			userInfoObj:SetChildrenVisible(false)
		end
	end
end

function Logout(self)
	local app = XLGetObject("CoolJ.App")
	app:SetString("Community", "Community_State" ,"")
	app:SetString("Community", "Community_Ak" ,"")
	
	if self == nil then return end
	local communityCaptionObj = self:GetControlObject("community.text")
	if communityCaptionObj ~= nil then communityCaptionObj:SetVisible(false) end
	local loginObj = self:GetControlObject("login.text")
	if loginObj ~= nil then loginObj:SetVisible(true) end
	local userInfoObj = self:GetControlObject("UserInfo")
	if userInfoObj ~= nil then
		userInfoObj:SetVisible(false)
		userInfoObj:SetChildrenVisible(false)
	end
end

function OnInitControl(self)
	Login(self)
	self:SetBkgType(1)
end

function OnModalLButtonUp(self)
	MessageBox(nil, "物管", "这只是一个测试用的文本列表，hello lydia！话有点短，我在多说点，再多说点。。。\
								这只是一个测试用的文本列表，hello lydia！话有点短，我在多说点，再多说点。。。\
								这只是一个测试用的文本列表，hello lydia！话有点短，我在多说点，再多说点。。。\
								这只是一个测试用的文本列表，hello lydia！话有点短，我在多说点，再多说点。。。")
end

function Tray_OnMouseEnter(self)
	XLMessageBox(44)
end

function OnLogin(self)
	local app = XLGetObject("CoolJ.App")
	local cb = function()
		Login(self:GetOwnerControl())
	end
	ret = LoginWnd(nil, cb)
end

function OnLogout(self)
	Logout(self:GetOwnerControl())
end