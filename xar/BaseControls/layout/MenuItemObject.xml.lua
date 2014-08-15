function CreateSubMenu( self )
	local attr = self:GetAttribute()
	if attr == nil then
		return
	end
	if attr.SubMenuID ~= nil then	
		local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")
		local menuTemplate = templateMananger:GetTemplate(attr.SubMenuID,"ObjectTemplate")
		if menuTemplate == nil then
			return
		end
		local sub_menu = menuTemplate:CreateInstance( attr.SubMenuID.."instance" )
		if sub_menu == nil then
			return
		end
		local attr = self:GetAttribute()
		sub_menu:SetVisible( false )
		self:AddChild( sub_menu )
	end
end

function SetShowType( self )
	local attr = self:GetAttribute()
	if attr == nil then
		return
	end
	if attr.Type == 0 then
		if attr.Text ~= nil then
			self:SetText(attr.Text)
		end
		if attr.Icon ~= nil then
			self:SetIconID(attr.Icon)
		elseif attr.Bitmap ~= nil then
			self:SetBitmap(attr.Bitmap)
		end
		self:SetGlobalHotKey( attr.GlobalHotKey )
		
		if attr.SubMenuID ~= nil then
			local uiFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
			local xarManager = XLGetObject("Xunlei.UIEngine.XARManager")
			local arrow = self:GetControlObject("menu_arrow")
			if arrow == nil then
				arrow = uiFactory:CreateUIObject("menu_arrow", "ImageObject")
				self:AddChild(arrow)
			end
			if arrow ~= nil then
				arrow:SetResProvider(xarManager)
				arrow:SetResID( attr.NormalArrow )
				arrow:SetObjPos( "father.width - 13", "(father.height-9)/2", "father.width - 7", "(father.height-9)/2 + 9" )
			end
		end
		
		OnEnableChange(self, self:GetEnable())

		OnVisibleChange(self, self:GetVisible())
	else
		self:SetEnable( false )
		local separator = self:GetControlObject( "separator" )
		if separator == nil then
			local uiFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
			local xarManager = XLGetObject("Xunlei.UIEngine.XARManager")
			separator = uiFactory:CreateUIObject("separator", "TextureObject")
			if separator ~= nil then
				separator:SetResProvider(xarManager)
				self:AddChild( separator )
				separator:SetObjPos( ""..attr.SeparatorLeftPos, "(father.height - "..attr.SeparatorHeight..")/2", "father.width", "(father.height + "..attr.SeparatorHeight..")/2" )
			end
		end
		if attr.Icon ~= nil then
			separator:SetTextureID( attr.Icon )
		elseif attr.Bitmap ~= nil then
			self:SetBitmap(attr.Bitmap)
		end
    end
end

function OnInitControl(self)
	local attr = self:GetAttribute()
	if attr == nil then
		return
	end
	attr.show_sub_menu = false
	
	SetShowType( self )
		
	self:FireExtEvent( "OnInit" )
end

function SetGlobalHotKey( self, key )
	local attr = self:GetAttribute()
	if attr == nil then
		return
	end
	attr.GlobalHotKey = key
	if attr.GlobalHotKey ~= nil and attr.GlobalHotKey ~= "" then
		if attr.Type == 0 then
			local item = self:GetControlObject( "GlobalHotKey" )
			if item == nil then
				local xarManager = XLGetObject("Xunlei.UIEngine.XARManager")
				local templateManager = XLGetObject("Xunlei.UIEngine.TemplateManager")
				local text_template = templateManager:GetTemplate( "global.hotkey.text", "ObjectTemplate" )
				item = text_template:CreateInstance( "GlobalHotKey" )
				self:AddChild( item )
				item:SetResProvider(xarManager)
				item:SetObjPos( "father.width - 118", "0", "father.width - 18", "father.height" )
				if attr.Font ~= nil and attr.Font ~= "" then
					item:SetTextFontResID( attr.Font )
				end
			end
			item:SetText( attr.GlobalHotKey )

			local gx, gy = item:GetTextExtent()
			if attr.TextRightWidth < gx + 20 then
				attr.TextRightWidth = gx + 20
				local textitem = self:GetControlObject("text")
				if textitem ~= nil then
					textitem:SetObjPos( ""..attr.TextPos, "0", "father.width-" .. attr.TextRightWidth, "father.height" )
				end
			end
		end
	end
end

function SetText(self, text_)
	local attr = self:GetAttribute()
	if attr == nil then
		return
	end
	attr.Text = text_
	if attr.Type == 0 then
		local item = self:GetControlObject("text")
		if item == nil then
			local xarManager = XLGetObject("Xunlei.UIEngine.XARManager")
			local templateManager = XLGetObject("Xunlei.UIEngine.TemplateManager")
			local text_template = templateManager:GetTemplate( "menu.text", "ObjectTemplate" )
			item = text_template:CreateInstance( "text" )
			self:AddChild( item )
			item:SetResProvider(xarManager)
			item:SetObjPos( ""..attr.TextPos, "0", "father.width-" .. attr.TextRightWidth, "father.height" )
			if attr.Font ~= nil and attr.Font ~= "" then
				item:SetTextFontResID( attr.Font )
			end
		end
		item:SetText(text_)
	end
end

function GetText( self )	
	local attr = self:GetAttribute()
	if attr == nil then
		return
	end
	return attr.Text
end

function SetIconID( self, iconID )
	local attr = self:GetAttribute()
	if attr == nil then
		return
	end
	attr.Icon = iconID
	if attr.Type == 0 then
		if attr.Icon ~= nil then
			local icon = self:GetControlObject( "icon" )
			if icon == nil then
				local uiFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
				local xarManager = XLGetObject("Xunlei.UIEngine.XARManager")
				icon = uiFactory:CreateUIObject("icon", "ImageObject")
				if icon ~= nil then
					icon:SetResProvider(xarManager)
					icon:SetDrawMode( 1 )
					self:AddChild( icon )
					icon:SetObjPos( ""..attr.IconPos, "(father.height-"..attr.IconHeight.."+1)/2", ""..attr.IconPos.."+"..attr.IconWidth, "(father.height+"..attr.IconHeight.."+1)/2" )
				end
			end
			icon:SetResID( iconID )
		else
			local icon = self:GetControlObject( "icon" )
			if icon ~= nil then
				self:RemoveChild( icon )
			end
		end
	else
		self:SetEnable( false )
		local separator = self:GetControlObject( "separator" )
		if separator ~= nil then
			separator:SetTextureID( attr.Icon )
		end
	end
end

function InitMenu(self)
	local attr = self:GetAttribute()
			
	local iconObj = self:GetControlObject("icon")
	if attr.Icon ~= nil then
		iconObj:SetBitmapResID(attr.Icon)
	end
			
	local textObj = self:GetControlObject("text")
	if attr.Icon ~= nil then
		textObj:SetText(attr.Text)
	end
	
	local size = iconObj:GetSize()
	iconObj:SetObjPos(attr.IconPos, 0, attr.IconPos + size.cx, "father.height")
	textObj:SetObjPos(attr.TextPos, 0, "father.width -"..(father.width - attr.TextPos),"father.height")		
end

function GetMinWidth(self)
	local attr = self:GetAttribute()
	if attr.Type == 0 then
		local textObj = self:GetControlObject("text")
		local globalKeyObj = self:GetControlObject( "GlobalHotKey" )
		local gx = 0
		local gy = 0
		if globalKeyObj ~= nil then
			gx, gy = globalKeyObj:GetTextExtent()
		end
		local cx, cy = textObj:GetTextExtent()
		
		if attr.TextRightWidth - gx < 20 then
			attr.TextRightWidth = gx + 20
			return attr.TextPos + cx + gx + 20
		else
			return attr.TextPos + cx + attr.TextRightWidth
		end
	end
end

function ChangeState(self,newState)		
	local attr = self:GetAttribute()
	if attr.State == newState then
		return
	end
	
	if not self:GetEnable() then
	    return
	end
	
	attr.State = newState
	
	if attr.Type == 0 then
		if not self:GetEnable() then
			return
		end
		
		local arrow = self:GetControlObject( "menu_arrow" )
		if arrow ~= nil then
			if newState == 0 then
				arrow:SetResID( attr.NormalArrow )
			else
				arrow:SetResID( attr.HoverArrow )
			end
		end
		local item = self:GetControlObject("text")
		if item ~= nil then
			if newState == 0 then
				item:SetTextColorResID( attr.FontColorNormal )
			else
				item:SetTextColorResID( attr.FontColorHover )
			end
		end
	end
end

function SelectItem(self)
	local sub_menu = self:GetSubMenu()
	if sub_menu == nil then
		local menuObj = self:GetFather()
		menuObj:EndMenu()
				
		local id = self:GetID()
		self:FireExtEvent("OnSelect", id)
	end
end

function CancelItem(self)	
	local menuObj = self:GetFather()
	menuObj:EndMenu()
end

function OnLButtonUp(self, x, y)
	local attr = self:GetAttribute()
	if not attr.Visible then
	    return
	end

	
--	self:SetCaptureMouse(false)
	local left,top,right,bottom = self:GetObjPos()
	local width,height = right - left, bottom - top
		
	if (x >= 0) and (x < width) and (y >= 0) and (y < height) then
		--XLMessageBox("Sel")
		self:SelectItem()
	else 
		self:CancelItem()
	end
	
	return 0, false
end

function GetSubMenu(self)
	local attr = self:GetAttribute()
	if attr.SubMenuID ~= nil then
		local sub_menu = self:GetControlObject( attr.SubMenuID.."instance" )
		if sub_menu == nil then
			if attr.SubMenuID ~= nil then
				CreateSubMenu( self )
			end
			sub_menu = self:GetControlObject( attr.SubMenuID.."instance" )
		end
		return sub_menu
	end
end

function OnMouseHover(self)
			
	local submenu = self:GetSubMenu()
	if submenu == nil then
		return
	end
	
	--try show submenu
end

function OnMouseMove(self, x, y, flags) -- If want Pressed effect: we can test if lbutton is pressed here (flags & 0x0001), and tell SetHoverItem
	local attr = self:GetAttribute()
	if  attr.Type == 0 then
		if attr.State == 1 then
			return
		end
		
		if not attr.Visible then
			return
		end
		local menu = self:GetFather()
		local oldItem = menu:GetAttribute().HoverItem
		menu:SetHoverItem(self)
		self:SetFocus( true )
	end
end

function OnMouseLeave(self)
	local attr = self:GetAttribute()
	if attr.Type == 0 then
		if attr.State == 0 then
			return
		end
		
		if not attr.Visible then
			return
		end
		local menu = self:GetFather()
		local oldItem = menu:GetAttribute().HoverItem
		menu:SetHoverItem(nil)
	end
end

function OnLButtonDown(self)
	local attr = self:GetAttribute()
	if not attr.Visible then
	    return
	end
end

function SetSubMenu( self, menuid )
	local attr = self:GetAttribute()
	attr.SubMenuID = menuid
	local arrow = self:GetControlObject( "menu_arrow" )
	if attr.SubMenuID ~= nil then
		if arrow == nil then
			local uiFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
			local xarManager = XLGetObject("Xunlei.UIEngine.XARManager")			
			local arrow = uiFactory:CreateUIObject("menu_arrow", "ImageObject")
			if arrow ~= nil then
				arrow:SetResProvider(xarManager)
				arrow:SetResID( attr.NormalArrow )
				self:AddChild( arrow )
				arrow:SetObjPos( "father.width - 13", "(father.height-9)/2", "father.width - 7", "(father.height-9)/2 + 9" )
			end
		end
	else
		self:RemoveChild( arrow )
	end
end

function EndSubMenu( self )
	local submenu = self:GetSubMenu()
	if submenu ~= nil then
		--submenu:SetChildrenVisible( false )
		self:RemoveChild( submenu )
		local attr = self:GetAttribute()
		attr.show_sub_menu = false		
	end
end

function ShowSubMenu( self, is_keyboard )
	local submenu = self:GetSubMenu()
	if submenu ~= nil then
	    self:FireExtEvent("OnShowSubMenu", submenu)
		local shell = XLGetObject( "CoolJ.OSShell" )
		local left, top, right, bottom = self:GetObjPos()
		local abs_left, abs_top, abs_right, abs_bottom = self:GetAbsPos()
		local sub_left, sub_top, sub_right, sub_bottom = submenu:GetObjPos()
		
		local father_menu = self:GetFather()
		local father_abs_left, father_abs_top, father_abs_right, father_abs_bottom = father_menu:GetAbsPos()
		
		local menuTree = submenu:GetOwner()
		local menuHostWnd = menuTree:GetBindHostWnd()		
		abs_left, abs_top = menuHostWnd:ClientPtToScreenPt( abs_left, abs_top )
		abs_right, abs_bottom = menuHostWnd:ClientPtToScreenPt( abs_right, abs_bottom )
		father_abs_left, father_abs_top = menuHostWnd:ClientPtToScreenPt( father_abs_left, father_abs_top )
		father_abs_right, father_abs_bottom = menuHostWnd:ClientPtToScreenPt( father_abs_right, father_abs_bottom )
		--local sleft, stop, sright, sbottom = menuHostWnd:GetMonitorRect(x, y)
		local sleft, stop, sright, sbottom = shell:GetWorkArea()
		
		--???????????????????????????????
		if father_abs_right + sub_right - sub_left > sright and abs_top + sub_bottom - sub_top <= sbottom then--????
			submenu:SetObjPos( sub_left - sub_right + father_abs_left - abs_left+10, 0, father_abs_left - abs_left+10, sub_bottom - sub_top )
			submenu:SetPopStatus( 1, 2 )
		elseif father_abs_right + sub_right - sub_left > sright and abs_top + sub_bottom - sub_top > sbottom then--????
			if sub_bottom - sub_top > sbottom - stop then --???????????????????????????????????????
				submenu:SetObjPos( sub_left - sub_right + father_abs_left - abs_left+10, 0-abs_top, father_abs_left - abs_left+10, sbottom - abs_top )
			elseif sub_top - sub_bottom + bottom - top + abs_top < 0 then --????????topλ?ó???????????????????????top??λ?????????bottom??λ??
				if sub_top - sub_bottom + bottom - top < sbottom - stop then
					submenu:SetObjPos( sub_left - sub_right + father_abs_left - abs_left+10, 0-abs_top + bottom - top, father_abs_left - abs_left+10, sub_bottom - sub_top - abs_top + bottom - top )
				else
					submenu:SetObjPos( sub_left - sub_right + father_abs_left - abs_left+10, 0-abs_top, father_abs_left - abs_left+10, sub_bottom - sub_top - abs_top )
				end
			else   --?????topλ????г?????????????bottomλ?y?????
				submenu:SetObjPos( sub_left - sub_right + father_abs_left - abs_left+10, sub_top - sub_bottom + bottom - top, father_abs_left - abs_left+10, bottom - top )
			end
			submenu:SetPopStatus( 2, 2 )
		elseif father_abs_right + sub_right - sub_left <= sright and abs_top + sub_bottom - sub_top > sbottom then--????
			if sub_bottom - sub_top > sbottom - stop then --???????????????????????????????????????
				submenu:SetObjPos( father_abs_right - abs_left, 0-abs_top, father_abs_right - abs_left + sub_right - sub_left, sbottom - abs_top )
			elseif sub_top - sub_bottom + bottom - top + abs_top < 0 then --????????topλ?ó???????????????????????top??λ?????????bottom??λ??
				if sub_top - sub_bottom + bottom - top < sbottom - stop then
					submenu:SetObjPos( father_abs_right - abs_left-10, 0-abs_top + bottom - top, father_abs_right - abs_left + sub_right - sub_left-10, sub_bottom - sub_top - abs_top + bottom - top )
				else
					submenu:SetObjPos( father_abs_right - abs_left-10, 0-abs_top, father_abs_right - abs_left + sub_right - sub_left-10, sub_bottom - sub_top - abs_top )
				end
			else  --?????topλ????г?????????????bottomλ?y?????
				submenu:SetObjPos( father_abs_right - abs_left-10, sub_top - sub_bottom + bottom - top, father_abs_right - abs_left + sub_right - sub_left-10, bottom - top )
			end
			submenu:SetPopStatus( 2, 1 )
		elseif father_abs_right + sub_right - sub_left <= sright and abs_top + sub_bottom - sub_top <= sbottom then--????
			submenu:SetObjPos( father_abs_right - abs_left-10, 0, father_abs_right - abs_left + sub_right - sub_left-10, sub_bottom - sub_top )
			submenu:SetPopStatus( 1, 1 )
		end
		if is_keyboard ~= nil and is_keyboard then
			submenu:MoveNextItem()
			submenu:SetFocus( true )
		end
		submenu:AnimateShow()
		submenu:SetVisible( true )
		submenu:SetChildrenVisible(true)
		local attr = self:GetAttribute()
		attr.show_sub_menu = true
	end
end

function GetItemSize( self )
	local left, top, right, bottom = self:GetObjPos()
	return right - left, bottom - top
end

function SetType( self, type_ )
	local attr = self:GetAttribute()
	if attr.Type ~= type_ then
		if attr.Type == 0 then
			local text = self:GetControlObject( "text" )
			self:RemoveChild( text )
			local icon = self:GetControlObject( "icon" )
			self:RemoveChild( icon )
			local arrow = self:GetControlObject( "menu_arrow" )
			self:RemoveChild( arrow )
		elseif attr.Type == 1 then
			local separator = self:GetControlObject( "separator" )
			self:RemoveChild( separator )
		end
	end
	attr.Type = type_
	SetShowType( self )
end

function OnKeyDown( self, char )
	self:RouteToFather()
end

function HasSubMenu( self )
	local attr = self:GetAttribute()
	if attr.SubMenuID ~= nil then
		return true
	end
	return false
end

function SetHotKey( self, key )
	local attr = self:GetAttribute()
	attr.HotKey = key
end

function IsShowSubMenu( self )
	local attr = self:GetAttribute()
	return attr.show_sub_menu
end

function SetMargin( self, left, top, right, bottom)
	local attr = self:GetAttribute()
	
	attr.IconPos = attr.IconPos+left
	attr.TextPos = attr.TextPos+left
end

function SetBitmap( self, bitmap)
	local attr = self:GetAttribute()
	if attr == nil then
		return
	end
	attr.Bitmap = bitmap
	if attr.Type == 0 then
		if attr.Bitmap ~= nil then
			local icon = self:GetControlObject( "icon" )
			if icon == nil then
				local uiFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
				local xarManager = XLGetObject("Xunlei.UIEngine.XARManager")
				icon = uiFactory:CreateUIObject("icon", "ImageObject")
				if icon ~= nil then
					icon:SetResProvider(xarManager)
					icon:SetDrawMode( 1 )
					self:AddChild( icon )
					icon:SetObjPos( ""..attr.IconPos, "(father.height-"..attr.IconHeight..")/2", ""..attr.IconPos.."+"..attr.IconWidth, "(father.height+"..attr.IconHeight..")/2" )
				end
			end
			icon:SetBitmap(bitmap)
		else
			local icon = self:GetControlObject( "icon" )
			if icon ~= nil then
				self:RemoveChild( icon )
			end
		end
	else
		self:SetEnable( false )
		local separator = self:GetControlObject( "separator" )
		if separator ~= nil then
			separator:SetTexture( attr.Bitmap )
		end
	end
end

function OnMenuItemSelect(self, name, id)
    local taskOperation = XLGetGlobal("xunlei.LuaTaskOperationHelper")
    if id == "filemenu.allstart" then
        taskOperation:StartAllTask()
    elseif id == "filemenu.allstop" then
        taskOperation:StopAllTask()
    elseif id == "filemenu.alldelete" then
        taskOperation:RemoveAllTaskToRecycle()
    elseif id == "filemenu.clean" then
		local taskOperation = XLGetGlobal("xunlei.LuaTaskOperationHelper")
		function OnDestroy(hostWndTemplate, objectTree, ret)
			-- 0 取消
			-- 1 删除
			-- 2 删除同时删除文件
			if ret == 1 then
				taskOperation:ClearRecycle(false)
			elseif ret == 2 then
				taskOperation:ClearRecycle(true)
			end
		end
		local hostWndHelper = XLGetGlobal("xunlei.LuaHostWndHelper")
		hostWndHelper:DoModal("MsgBoxDlg", "CleanDlgTree", nil, nil, OnDestroy)
    elseif id == "filemenu.importlist" then
		local shell = XLGetObject("Xunlei.UIEngine.OSShell")
		local filePath = shell:FileDialog(true, "下载列表(*.downlist;*.lst)|*.downlist;*.lst||", "downlist", "", "")
		if filePath == nil or filePath == "" then
			return
		end
		
		local addinManagerhlp = XLGetGlobal("xunlei.AddinManagerHelper")
		addinManagerhlp.ExeCommand( "Thunder", "import.downlist", filePath )		
    elseif id == "helpmenu.helpcenter" then
        local shell = XLGetObject("CoolJ.OSShell")
        shell:OpenURL("")
    elseif id == "toolmenu.findtask" then
        --local thumbImageCreater = XLGetObject("Xunlei.WHome.ThumbImageCreater")
        --local hrthumb, thumb = thumbImageCreater:GetThumbFromFilePath(200, 200,"d:\\0dba6957.jpg")
        local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	    local mainFrame = hostwndManager:GetHostWnd("WHome.MainFrame")
	    local maintree = mainFrame:GetBindUIObjectTree()
	    local taskMgrWnd = maintree:GetUIObject("WHome.task_mgr_wnd")
	    local imageinfo = taskMgrWnd:GetControlObject("WHome.taskimageinfo")
	    imageinfo:SetPath("d:\\0dba6957.jpg")
	    --imageinfo:SetThumb(thumb)
	elseif id == "toolmenu.conf" then
		local obj = XLGetGlobal("xunlei.ConfigHelper")
		obj:ShowConfigTab("Thunderbolt")
    end
end

function OnEnableChange(self, enable)
	local attr = self:GetAttribute()
	if attr == nil then
		return
	end
	if attr.Type == 0 then
		local textitem = self:GetControlObject("text")
		if textitem == nil then
			return 
		end
		local globalKeyObj = self:GetControlObject( "GlobalHotKey" )
		
		if not enable then
			textitem:SetTextColorResID("menu.color.disable")
			if globalKeyObj ~= nil then
				globalKeyObj:SetTextColorResID("menu.color.disable")
			end
		else
			textitem:SetTextColorResID("menu.color.normal")
			if globalKeyObj ~= nil then
				globalKeyObj:SetTextColorResID("menu.color.normal")
			end
		end
	end
end

function OnVisibleChange(self, visible)
    self:SetChildrenVisible(visible)
end