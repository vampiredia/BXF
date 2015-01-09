function RouteToFather__OnChar(self, char)
    if char == 9 then
        self:RouteToFather()
    end
end

function CB_OnChar(self, char, counts, flag)
	if char == 9 then
		-- Tab 键
		self:FireExtEvent("OnTabbedEvent", true)
		self:GetControlObject("combo.edit"):SetFocus(true)
	end
end

function CB__Edit__OnRButtonUp( self, x, y, flag )
	local attr = self:GetOwnerControl():GetAttribute()
	if attr.ShowMenu then
		local wnd_handle = self:GetOwner():GetBindHostWnd():GetWndHandle()
		local obj = XLGetGlobal("xunlei.MenuHelper")
		XLSetGlobal( "xunlei.cur.edit", self )
		obj:ShowMenu("single.menu", attr.MenuTreeID, attr.MenuID, wnd_handle)
	end
end

function ComboBox__OnKeyUp( self, char )
	local attr = self:GetAttribute()
	attr.OnTab = true
    if char == 9 then
        self:RouteToFather()
    end
end

function ComboBox__OnKeyDown( self, char )
	if char == 13 then
		local edit = self:GetControlObject( "combo.edit" )
		self:FireExtEvent( "OnEnterContent", edit:GetText() )
	end
end

function CB__GetListHeight(self)
    local attr = self:GetAttribute()
    return attr.cur_list_height
end

function CB__GetListShown(self)
	local attr = self:GetAttribute()
    return attr.ShowList
end

function CB__SetHostWndID(self, id)
    local attr = self:GetAttribute()
    attr.HostWndID = id
end

function CLB__OnScrollBarMouseWheel(self, name, x, y, distance)
    local owner = self:GetOwnerControl()
    owner:MouseWheel(distance / 10)
end

function CB__Edit__OnMouseWheel(self, x, y, distance)
    local owner = self:GetOwnerControl()
    local listbox = owner:GetControlObject("listbox")
    if listbox ~= nil then
        listbox:MouseWheel(distance / 10)
    end
end

function CB__SetFocus(self, focus)
    local edit = self:GetControlObject("combo.edit")
    edit:SetFocus(true)
end

function CB_OnFocusChange( self, focus )
	if focus then
		CB__SetFocus( self, focus )
	end
end

function CB__Undo(self)
    local edit = self:GetControlObject("combo.edit")
    edit:Undo()
end

function CB__SetState(self, state)
    local attr = self:GetAttribute()
    if attr.NowState ~= state then
        local bkg = self:GetControlObject("combo.bkg")
		local edit = self:GetControlObject("combo.edit")
        attr.NowState = state
        if attr.NowState == 0 then
            bkg:SetTextureID(attr.NormalBkgID)
			edit:SetTextColorID(attr.NormalTextColor)
        elseif attr.NowState == 1 then
            bkg:SetTextureID(attr.HoverBkgID)
			edit:SetTextColorID(attr.HoverTextColor)
        elseif attr.NowState == 2 then
            bkg:SetTextureID(attr.DisableBkgID)
			edit:SetTextColorID(attr.DisableTextColor)
        end
    end
end

function CB__GetText(self)
    local edit = self:GetControlObject("combo.edit")
    return edit:GetText()
end

function CB__SetText(self, text)
    local attr = self:GetAttribute()
    attr.editbysystem = true
    local edit = self:GetControlObject("combo.edit")
    edit:SetText(text)
    attr.editbysystem = false
end

function CB__SetIcon(self, resID)
	local attr = self:GetAttribute()
	attr.IconResID = resID
	local icon = self:GetControlObject("combo.icon")
	icon:SetResID(resID)
end

function CB__AddItem(self, IconResID, IconWidth, LeftMargin, TopMargin, Text, Custom, Func)
    local listbox = self:GetControlObject("listbox")
    local num = listbox:GetItemCount()
    if num == nil then
        num = 0
    end
    num = num + 1
    local attr = self:GetAttribute()
    local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
    local comboitem = objFactory:CreateUIObject("item"..num,"WHome.ComboItem")
    local itemattr = comboitem:GetAttribute()
    itemattr.NormalBkgID = attr.ItemNormalBkgID
    itemattr.HoverBkgID = attr.ItemHoverBkgID
    itemattr.LeftMargin = LeftMargin
    itemattr.TopMargin = TopMargin
    itemattr.IconResID = IconResID
    itemattr.IconWidth = IconWidth
    itemattr.ItemText = Text
    itemattr.ItemID = num
	itemattr.CanRemove = attr.CanRemove
    itemattr.Custom = Custom
    itemattr.Func = Func
    listbox:AddItem(comboitem)
end

function CB__InsertItem(self, nindex, IconResID, IconWidth, LeftMargin, TopMargin, Text)
    local listbox = self:GetControlObject("listbox")
    local num = listbox:GetItemCount()
    if num == nil then
        num = 0
    end
    num = num + 1
    local attr = self:GetAttribute()
    local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
    local comboitem = objFactory:CreateUIObject("item"..num,"WHome.ComboItem")
    local itemattr = comboitem:GetAttribute()
    itemattr.NormalBkgID = attr.ItemNormalBkgID
    itemattr.HoverBkgID = attr.ItemHoverBkgID
    itemattr.LeftMargin = LeftMargin
    itemattr.TopMargin = TopMargin
    itemattr.IconResID = IconResID
    itemattr.IconWidth = IconWidth
    itemattr.ItemText = Text
    itemattr.ItemID = num
    listbox:InsertItem(comboitem, nindex)
end

function CB__RemoveItem(self, nindex)
    local listbox = self:GetControlObject("listbox")
    listbox:DeleteItem(nindex)
end

function CB__RemoveTip(self)
    return XLGetGlobal("xunlei.TipsHelper"):RemoveTip(self)
end

function CB__AddTip(self, text, sessionName, type_)
    XLGetGlobal("xunlei.TipsHelper"):AddTip(self, text, sessionName, type_)
end

function CB__OnInitControl(self)
    local attr = self:GetAttribute()
    local left, top, right, bottom = self:GetObjPos()
    local width = right - left
    local height = bottom - top
    local bkg = self:GetControlObject("combo.bkg")
    bkg:SetTextureID(attr.NormalBkgID)
    local icon = self:GetControlObject("combo.icon")
    local text = self:GetControlObject("combo.text")
    local edit = self:GetControlObject("combo.edit")
    local btn = self:GetControlObject("combo.btn")
    edit:SetReadOnly(not attr.EnableEdit)
    edit:SetNoCaret(not attr.EnableEdit)
    edit:SetMultiline(attr.Multiline)
    local nowLeft = attr.LeftMargin
    if attr.IconVisible then
        icon:SetResID(attr.IconResID)
        icon:SetVisible(true)
        icon:SetObjPos(nowLeft, attr.TopMargin+2, nowLeft + attr.IconWidth, height+2)
        nowLeft = nowLeft + attr.IconWidth+6
    end
    if attr.DesVisible then
        text:SetText(attr.DesText)
        text:SetObjPos(nowLeft + 2, 2, nowLeft + attr.DesWidth, height - 2)
        nowLeft = nowLeft + attr.DesWidth + 2
	end
	local right = "father.width - " .. tostring(attr.EditRight) .. " - "..attr.EditRightMargin
    edit:SetObjPos( ""..nowLeft.."+" .. tostring(attr.EditLeftMargin), tostring(attr.EditTopMargin), right, "father.height - " .. tostring(attr.EditBottomMargin) )
    btn:SetObjPos("father.width - " .. tostring(attr.ExpandIconLeft), "0", "father.width - " .. tostring(attr.ExpandIconLeft) .. " + " .. tostring(attr.ExpandIconWidth), "father.height")
--    btn:SetObjPos(width - 2 - 22, 0, width - 2, height)
    local lblayout = self:GetControlObject("listbox.layout")
    lblayout:SetVisible(false, true)

	CB_OnEnableChange(self, self:GetEnable())
	
	-- TODO lydia
	-- 第一次展开ComboBox时，不能触发OnSelect事件，提前AttachListener一次
	-- 先这样子
	CB_InitControl(self)
end

function CB__Edit__OnChange(self)
    local control = self:GetOwnerControl()
    local text = self:GetText()
    local attr = control:GetAttribute()
    if attr.OnlyNumber then
        if not tonumber(text) and text ~= "" then
            self:Undo()
            return
        end
    end
    if attr.MaxLength then
        if text:len() > attr.MaxLength then
            self:Undo()
            return
        end
    end
    if not attr.editbyuser then
        if not attr.editbysystem then
            attr.editbyuser = true
        end
    end
    control:FireExtEvent("OnEditChange", text)
	return true
end

function CB__Edit__OnFocusChange(self, focus, dest)
    local control = self:GetOwnerControl()
    if focus then
        control:RemoveTip()		
    else	
		--Tab事件
		self:GetOwnerControl():FireExtEvent("OnTabbedEvent", false)
		if dest then 
			local dest_control = dest:GetOwnerControl()
			if not control:IsChild(dest) and not control:IsChild(dest_control) then
				CB__OnFocusChange(control, focus, dest)
			end
		else
			CB__OnFocusChange(control, focus, dest)
		end
    end	
	
    control:FireExtEvent("OnEditFocusChange", focus)
end

function RouteToFather__OnKeyDown( self, char )
	if char == 13 then
		self:RouteToFather()
	end
end

function CB__Edit__OnChar2(self)
    local owner = self:GetOwnerControl()
    owner:FireExtEvent("OnEditChar")
end

function CB__Edit__OnChar(self, char)
    local owner = self:GetOwnerControl()
    local ownerattr = owner:GetAttribute()
    ownerattr.editbyuser = true
    local listbox = owner:GetControlObject("listbox")
    if char == 9 then
        self:RouteToFather()
    elseif char == 40 then
        if not listbox then
            owner:ExpandList()
        end
        listbox = owner:GetControlObject("listbox")
        if listbox then
            local listboxattr = listbox:GetAttribute()
            if listboxattr.AvalibleItemIndex == nil then
                listboxattr.AvalibleItemIndex = 0
            end
            local count = listbox:GetItemCount()
            if listboxattr.AvalibleItemIndex >= count then
                return
            end
            local olditem = listbox:GetItem(listboxattr.AvalibleItemIndex)
            listboxattr.AvalibleItemIndex = listboxattr.AvalibleItemIndex + 1
            local newitem = listbox:GetItem(listboxattr.AvalibleItemIndex)
            listbox:CancelAllSelect()
            if newitem then
                newitem:SetState(3)
            end
            listbox:AdjustAvalibleItemPos(1)
        end
    elseif char == 38 then
        if not listbox then
            owner:ExpandList()
        end
        listbox = owner:GetControlObject("listbox")
        if listbox then
            local listboxattr = listbox:GetAttribute()
            if listboxattr.AvalibleItemIndex == nil then
                listboxattr.AvalibleItemIndex = 0
            end
            local count = listbox:GetItemCount()
            if listboxattr.AvalibleItemIndex <= 1 then
                return
            end
            local olditem = listbox:GetItem(listboxattr.AvalibleItemIndex)
            listboxattr.AvalibleItemIndex = listboxattr.AvalibleItemIndex - 1
            local newitem = listbox:GetItem(listboxattr.AvalibleItemIndex)
            if olditem then
                olditem:SetState(0)
            end
            if newitem then
                newitem:SetState(3)
            end
            listbox:AdjustAvalibleItemPos(-1)
        end
    elseif char == 13 then
        if listbox then
            local listboxattr = listbox:GetAttribute()
            if listboxattr.AvalibleItemIndex then
                if listboxattr.AvalibleItemIndex ~= 0 then
					local item = listbox:GetItem(listboxattr.AvalibleItemIndex)
					local iAttr = item:GetAttribute()
					if iAttr.Custom then
						iAttr.Func()
					end
					
					listbox:FireExtEvent("OnSelect", listboxattr.AvalibleItemIndex)
					--[[local item = listboxattr.s_itemtable[listboxattr.AvalibleItemIndex]
					local id = item:GetID()
					local iattr = item:GetAttribute()
					local parent = listboxattr.parent
					if iattr.Custom then
						iattr.Func()
					end--]]
					
					
					--listbox:FireExtEvent("OnSelect", id)
                end
            end
        else
            owner:ExpandList()
        end
    end
end



function CB__BtnOnFocusChange(self, focus, dest)	
	local control = self:GetOwnerControl()
	if dest then
		local dest_control = dest:GetOwnerControl()
		
		local test1 = control:IsChild(dest)
		local test2 = control:IsChild(dest_control)
		if not test1 and not test2 then
			CB__OnFocusChange(self:GetOwnerControl(), focus, dest)
		end
	else
		CB__OnFocusChange(self:GetOwnerControl(), focus, dest)
	end
end

function CB__OnFocusChange( combo, focus, dest )
	local attr = combo:GetAttribute()
	local control = combo
			
	if focus then		
        return
    end
			
    if attr.OnListItem then				
        return
    end
    
    if not combo:GetEnable() then				
        return
    end
    
    if not attr.ShowList then				
        return
    end
    if not attr.OnTab then
        local left, top, right, bottom = control:GetAbsPos()
        local osShell = XLGetObject("CoolJ.OSShell")
        local x, y = osShell:GetCursorPos()
        
        local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
        local newtaskdlg = hostwndManager:GetHostWnd(attr.HostWndID)
		if newtaskdlg then
			local nleft, ntop, nright, nbottom = newtaskdlg:GetWindowRect()
			local absleft, abstop, absright, absbottom = left + nleft, top + ntop, right + nleft, bottom + ntop + attr.cur_list_height 
			if (x > absleft) and (x < absright) and (y > abstop) and (y < absbottom-4) then			
				return
			end
		end
    end
    attr.OnTab = false
	attr.ShowList = false
	local btnlayout = control:GetControlObject("btn.layout")
	btnlayout:SetZorder( 0 )
    local lblayout = control:GetControlObject("listbox.layout")
    local listbox = control:GetControlObject("listbox")
    lblayout:RemoveChild(listbox)
    lblayout.SetVisible(false, true)
    local left, top, right, bottom = control:GetObjPos()
	attr.ShowList = false
    control:FireExtEvent("OnListExpandChange", false, right - left, bottom - top)	
end

function CB__SetEditSel(self, spos, epos)	
    local attr = self:GetAttribute()	
	
	local edit = self:GetControlObject("combo.edit")
	if edit then
		edit:SetSel(spos, epos)
	end	
end

function CB__GetSelectItemName(self)
    local attr = self:GetAttribute()
    return attr.data[attr.select].Text
end

function CB__SelectItemByText(self, text)
    if text == nil then
        return false
    end
    local attr = self:GetAttribute()
    local i = 0
    for i = 1, #attr.data do
        if attr.data[i].Text == text then
            self:SelectItem(nil, i)
            return true
        end
    end
    return false
end

function CLB_SelectItem( self, name, id )
    local class = self:GetClass()
    local parent, listbox
	parent = self:GetOwnerControl()
	listbox = self
    local attr = parent:GetAttribute()
    attr.select = id
    local edit = parent:GetControlObject("combo.edit")
    local item = attr.data[id]
    if not item.Custom then
        edit:SetText(attr.data[id].Text)
        parent:FireExtEvent("OnSelectItemChanged", id)
		parent:FireExtEvent("OnEnterContent",attr.data[id].Text)
		edit:SetFocus(true)
    end
    local left, top, right, bottom = parent:GetObjPos()
    local lblayout = parent:GetControlObject("listbox.layout")
    attr.ShowList = false
	local btnlayout = parent:GetControlObject("btn.layout")
	btnlayout:SetZorder( 0 )
    lblayout:RemoveChild(listbox)
    if listbox then
        parent:FireExtEvent("OnListExpandChange", false, right - left, bottom - top)
    end
end

function CB__SelectItem(self, name, id)
    local class = self:GetClass()
    local parent, listbox
	parent = self
	listbox = parent:GetControlObject("listbox")
    local attr = parent:GetAttribute()
    attr.select = id
    local edit = parent:GetControlObject("combo.edit")
    local item = attr.data[id]
    if not item.Custom then
        edit:SetText(attr.data[id].Text)
        parent:FireExtEvent("OnSelectItemChanged", id)
		parent:FireExtEvent("OnEnterContent",attr.data[id].Text)
		edit:SetFocus(true)
    end
    local left, top, right, bottom = parent:GetObjPos()
    local lblayout = parent:GetControlObject("listbox.layout")
    attr.ShowList = false
	local btnlayout = parent:GetControlObject("btn.layout")
	btnlayout:SetZorder( 0 )
    lblayout:RemoveChild(listbox)
    if listbox then
        parent:FireExtEvent("OnListExpandChange", false, right - left, bottom - top)
    end
end

function HighlightFocus(self, boolean)
	local comboedit = self:GetControlObject("combo.edit")
	local content = comboedit:GetText()
	local attr = self:GetAttribute()
	
	if boolean then
		local index = 1
		for i = 1, #attr.data do
			if content == attr.data[i].Text or (content .. '\\') == attr.data[i].Text then
				index = i
				break
			end
		end
	
		local item = listbox:GetItem(index)
		local listboxattr = listbox:GetAttribute()
		if item then
			item:SetState(3)
			listboxattr.AvalibleItemIndex = index
		end
	end
end

function CB_InitControl(self)
	local control = self
    local attr = control:GetAttribute()
    if not control:GetEnable() then
        return
    end
    local lblayout = control:GetControlObject("listbox.layout")
	
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
    listbox = objFactory:CreateUIObject("listbox","WHome.ComboListBox")
	
	listbox:AttachListener("OnSelect", true, CLB_SelectItem)
	lblayout:AddChild(listbox)
	lblayout:RemoveChild(listbox)
end

function ExpandList( self )
    local control = self
    local attr = control:GetAttribute()
    if not control:GetEnable() then
        return
    end
    local left, top, right, bottom = control:GetObjPos()
    local width, height = right - left, bottom - top
    local lblayout = control:GetControlObject("listbox.layout")
	local btnlayout = control:GetControlObject("btn.layout")
    
    if not attr.ShowList then
        control:FireExtEvent("BeforeExpand")
        if attr.data == nil or #attr.data == 0 then			
            return
        end
        local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
        listbox = objFactory:CreateUIObject("listbox","WHome.ComboListBox")
    
        local listattr = listbox:GetAttribute()
        listattr.parent = control
        if attr.EnableHScroll ~= nil then
            listattr.EnableHScroll = attr.EnableHScroll
        end
        if attr.EnableVScroll ~= nil then
            listattr.EnableVScroll = attr.EnableVScroll
        end
        if attr.NoScroll then
            listattr.NoScroll = attr.NoScroll
        end
        
        
        attr.Cookie = listbox:AttachListener("OnSelect", true, CLB_SelectItem)
		--XLMessageBox(attr.Cookie)
        local lbleft, lbtop, lbright, lbbottom = lblayout:GetObjPos()
        lblayout:SetObjPos(0, height, width, attr.ListHeight)
        lblayout:AddChild(listbox)
		attr.ShowList = true
        listbox:SetZorder(1000)
		btnlayout:SetZorder( 2000 )
        for i=1, #attr.data do
            control:AddItem(attr.data[i].IconResID, attr.data[i].IconWidth, attr.data[i].LeftMargin, attr.data[i].TopMargin, attr.data[i].Text, attr.data[i].Custom, attr.data[i].Func)
        end
		local list_width, list_height = listbox:GetSize()
		local offset = 0
		if list_width > width then
			if list_height < attr.ListHeight - 12 then
				offset = 12
			end
		elseif list_width < width and list_width > width - 12 then
			if list_height > attr.ListHeight - 12 then
				offset = 12
			else
				offset = 0
			end
		elseif list_width < width - 12 then
			offset = 0
		end
		if list_height < attr.ListHeight - offset then
			listbox:SetObjPos(2, -4, width-2, list_height+offset)
			local l,t,r,b = listbox:GetObjPos()
			attr.cur_list_height = list_height+4
			attr.ShowList = true
			control:FireExtEvent("OnListExpandChange", true, right - left, bottom - top + list_height - 1 + offset )
		else
			listbox:SetObjPos(2, -4, width-2, attr.ListHeight)
			attr.cur_list_height = attr.ListHeight + 4
			attr.ShowList = true
			control:FireExtEvent("OnListExpandChange", true, right - left, bottom - top + attr.ListHeight - 1 )
		end
		
		if attr.HighlightSelected then
			HighlightFocus(self, true)
		end
		
        local aniFactory = XLGetObject("Xunlei.UIEngine.AnimationFactory")
        local posAni = aniFactory:CreateAnimation("PosChangeAnimation")
        posAni:SetTotalTime(200)
        posAni:BindLayoutObj(listbox)
		if list_height < attr.ListHeight then
			listattr.EnableVScroll = false
			posAni:SetKeyFrameRect(2, -4, width-2, 0, 2, -4, width-2, list_height+offset)
		else
			posAni:SetKeyFrameRect(2, -4, width-2, 0, 2, -4, width-2, attr.ListHeight)
		end
        local owner = control:GetOwner()
        owner:AddAnimation(posAni)
        posAni:Resume()
    else
        local listbox = control:GetControlObject("listbox")
        if not listbox then
            return
        end
        function onAniFinish(self, old, new)
            if new == 4 then
				listbox:RemoveListener("OnSelect", attr.Cookie)
                lblayout:RemoveChild(listbox)
				
				attr.ShowList = false
                lblayout:SetVisible(false, true)
            end
        end		
		btnlayout:SetZorder( 0 )
        local lbleft, lbtop, lbright, lbbottom = listbox:GetObjPos()
        local aniFactory = XLGetObject("Xunlei.UIEngine.AnimationFactory")
        local posAni = aniFactory:CreateAnimation("PosChangeAnimation")
        posAni:SetTotalTime(200)
        posAni:BindLayoutObj(listbox)
        posAni:SetKeyFrameRect(lbleft, lbtop, lbright, lbbottom, 2, -4, width-2, 0)
        posAni:AttachListener(true,onAniFinish)
        local owner = control:GetOwner()
        owner:AddAnimation(posAni)
        posAni:Resume()
		attr.ShowList = false
        control:FireExtEvent("OnListExpandChange", false, right - left, bottom - top)
	end
	-- 由于不能触发CB__BtnOnFocusChange(false)事件，导致新建面板那边焦点动画异常，使用以下方法并未导致什么异常，所以就这样做，Mark By Sqh
	local comboEdit = self:GetControlObject("combo.edit")
	comboEdit:SetFocus(true)
end

function CB__Btn__OnClick(self)
	ExpandList( self:GetOwnerControl() )
end

function CB__Btn__Down(self)
	local control = self:GetOwnerControl()
	local attr = control:GetAttribute()
    if attr.CanExpand then
        ExpandList( self:GetOwnerControl() )
    end
end

function CLB__Bkg__OnFocusChange(self, focus, dest)
    if focus then
		local combobox = self:GetOwnerControl()
        local edit = combobox:GetControlObject("combo.edit")
        edit:SetFocus(true) 
    end	
end

function CLB__ScrollBar__OnFocusChange(self, name, focus)
    if focus then
        return
    end
    local list = self:GetOwnerControl()
    local combobox = list:GetOwnerControl()
    combobox:CBOnFocusChange(focus)
end

function CLB__MouseWheel(self, distance)
    local vsb = self:GetControlObject("listbox.vscroll")
	local visible = vsb:GetVisible()
    if visible then
        local ThumbPos = vsb:GetThumbPos()
        vsb:SetThumbPos(ThumbPos - distance)
    end
end

function CLB__UpdateItemPos(self)
    local attr = self:GetAttribute()    
    local allheight = 4
	
    for i=1,#attr.s_itemtable do
        local itemwidth, itemheight = attr.s_itemtable[i]:GetSize()
		
		attr.s_itemtable[i]:SetObjPos( 0, allheight, attr.s_maxwidth, allheight + itemheight )
		attr.s_itemtable[i]:SetVisible(true)
			
        allheight = allheight + itemheight
    end
    local bkg=self:GetControlObject("item.layout")
	local bkg_left, bkg_top, bkg_right, bkg_bottom = bkg:GetObjPos()
	bkg:SetObjPos( bkg_left, bkg_top, bkg_left + attr.s_maxwidth, bkg_bottom + attr.s_maxheight )
	
    self:AdjustItemPos()
end

function CLB__InsertItem(self, obj, index)
    local left, top, right, bottom = self:GetObjPos()
    local width, height = right - left, bottom - top
    obj:SetParentObj(self)
    local attr = self:GetAttribute()
    local itemwidth, itemheight = obj:GetSize()
    
    if attr.s_itemtable == nil then
        attr.s_itemtable = {}
        attr.s_itempos = {}
    end
    
    if #attr.s_itemtable == 0 then
        attr.s_id = 0
        attr.s_maxwidth = right - left
        attr.s_maxheight = 0
        attr.s_top = 0
        attr.s_left = 0
		attr.item_maxwidth = 0
    end
    
    obj:SetID(attr.s_id+1)
    attr.s_id = attr.s_id + 1
    
    if index==-1 then
        table.insert(attr.s_itemtable, obj)
        if #attr.s_itempos==0 then
            table.insert(attr.s_itempos, 0)
        else
            local itemcount = #attr.s_itempos
            local item = attr.s_itemtable[itemcount]
            local tmpwidth, tmpheight = item:GetSize()
            table.insert(attr.s_itempos, tmpheight+attr.s_itempos[itemcount])
        end
    else
        table.insert(attr.s_itemtable, index+1, obj)
        if index+1==1 then
            table.insert(attr.s_itempos, index+1, 0)						
        else
            table.insert(attr.s_itempos, index+1, attr.s_itempos[index]+itemheight)
        end

        for i=index+2, #attr.s_itempos do
            attr.s_itempos[i] = attr.s_itempos[i] + itemheight
        end
    end
    
    attr.s_maxheight = attr.s_maxheight + itemheight
	
    if itemwidth > attr.s_maxwidth then
        attr.s_maxwidth = itemwidth
    end
    if itemwidth > attr.item_maxwidth then
		attr.item_maxwidth = itemwidth
	end
    
    obj:SetVisible(false)
    local bkg=self:GetControlObject("item.layout")
    bkg:AddChild(obj)
    
    if attr.NoScroll then
        local ctrl = self:GetOwnerControl()
        local cattr = ctrl:GetAttribute()
        cattr.ListHeight = attr.s_maxheight
        self:SetObjPos(left, top, right, attr.s_maxheight)
    end
    
    obj:AttachListener("OnLButtonUp", true, CLB__OnClickItem)
   
    if attr.s_itempos~=nil then
        self:UpdateItemPos()
    end	
end

function CLB_GetSize( self )
	local attr = self:GetAttribute()
	return attr.item_maxwidth, attr.s_maxheight
end

function CLB__AddItem(self, obj)
    self:InsertItem(obj, -1)
end

function CLB__DeleteItem(self, index)
    local attr = self:GetAttribute()
    local obj = attr.s_itemtable[index+1]
    
    if index+1==#attr.s_itemtable then
        table.remove(attr.s_itemtable, #attr.s_itemtable)
        table.remove(attr.s_itempos, #attr.s_itempos)
        
        local objwidth, objheight = obj:GetSize()
        attr.s_maxheight = attr.s_maxheight - objheight
    else
        local height = attr.s_itempos[index+2] - attr.s_itempos[index+1]
        table.remove(attr.s_itemtable, index+1)
        table.remove(attr.s_itempos, index+1)
        
        for i=index+1,#attr.s_itempos do
            attr.s_itempos[i] = attr.s_itempos[i] - height
        end
        
        attr.s_maxheight = attr.s_maxheight - height
    end
    
    attr.s_maxwidth = 0
    for i=1,#attr.s_itemtable do
        local objwidth, objheight = obj:GetSize()
        if objwidth > attr.s_maxwidth then
            attr.s_maxwidth = objwidth
        end
    end
        
    local bkg=self:GetControlObject("item.layout")
    bkg:RemoveChild(obj)
            
    if attr.NoScroll then
        local ctrl = self:GetOwnerControl()
        local cattr = ctrl:GetAttribute()
        cattr.ListHeight = attr.s_maxheight
        self:SetObjPos(left, top, right, attr.s_maxheight)
    end
    
    self:UpdateItemPos()
end

function CLB__DeleteAllItem(self)
    for i=1, self:GetItemCount() do
        self:DeleteItem(0)
    end
end

function CLB__GetItemCount(self)
    local attr = self:GetAttribute()
    return #attr.s_itemtable
end

function CLB__GetItem(self, index)
    local attr = self:GetAttribute()
    return attr.s_itemtable[index]
end

function CLB__GetItemIndexByObj(self, obj)
    local attr = self:GetAttribute()
    local id = obj:GetID()
    
    for i=1,#attr.s_itemtable do
        if attr.s_itemtable[i]:GetID()==id then
            return i-1
        end
    end
    
    return -1
end

function CLB__AdjustItemPos(self)
    local left, top, right, bottom = self:GetObjPos()
    local attr=self:GetAttribute()
    local width = right - left
    local height = bottom - top

    local hscroll = self:GetControlObject("listbox.hscroll")
    local vscroll = self:GetControlObject("listbox.vscroll")

    local listleft = left
    local listtop = top
    local listright = right
    local listbottom = bottom
    local bkg=self:GetControlObject("item.layout")
	local item_list = self:GetControlObject("item.list")
	local list_width = width
	local list_height = height
	local hsl_offset = 0
	local bkg_left, bkg_top, bkg_right, bkg_bottom = self:GetObjPos()
    if attr.EnableVScroll and (attr.s_maxheight > height) and (height ~= 0) then
        listright = listright
        vscroll:SetVisible(true)
        vscroll:SetObjPos(width-12, 0, width, listbottom - listtop)	
		list_width = width - 12
		hsl_offset = 12
    else
        vscroll:SetVisible(false)
    end

    if attr.EnableHScroll and (attr.s_maxwidth > width) and (height ~= 0) then
        listbottom = listbottom
        hscroll:SetVisible(true)
        hscroll:SetObjPos(0, height - 12, listright - listleft - hsl_offset, height)
		list_height = height - 12
    else
        hscroll:SetVisible(false)
    end
	
	if attr.EnableVScroll and attr.s_maxheight > list_height and list_height ~= 0 then
		vscroll:SetScrollRange( 0, attr.s_maxheight - list_height )
		vscroll:SetPageSize(list_height, true)		
	end

	if attr.EnableHScroll and attr.item_maxwidth > list_width and list_width ~= 0 then
		hscroll:SetScrollRange( 0, attr.item_maxwidth - list_width )
		hscroll:SetPageSize(list_width, true)
	end
	item_list:SetObjPos( 0, 0, width, list_height )
	
    local bkg=self:GetControlObject("listbox.bkg")
    bkg:SetObjPos(0, 0, width, height)
end

function CLB__GetItemIndexByPoint(self, point) 
    local attr = self:GetAttribute()  
    if #attr.s_itempos==0 then
        return 0
    elseif attr.s_itempos[#attr.s_itempos]>attr.s_maxheight then
        return 0
    elseif attr.s_itempos[#attr.s_itempos]<=point and point<attr.s_maxheight then
        return #attr.s_itempos
    end
    
    for i=1,#attr.s_itempos-1 do
        if attr.s_itempos[i]<=point and point<attr.s_itempos[i+1] then
            return i
        end
    end
    
    return 0
end

function CLB__OnClickItem(self, x, y)
    local listbox = self:GetOwnerControl()
    local attr = listbox:GetAttribute()
    local left,top,right,bottom = self:GetObjPos()
    local index=listbox:GetItemIndexByPoint(y + attr.s_top + top)

    if index==0 then
        return 
    end
    local item = attr.s_itemtable[index]
    local id = item:GetID()
    local iattr = item:GetAttribute()
    local parent = attr.parent
    if iattr.Custom then
        iattr.Func()
    end
	listbox:SetFocus(true)
    listbox:FireExtEvent("OnSelect", id)
end

function CLB_OnInitControl(self)
    local attr=self:GetAttribute()
    local left, top, right, bottom = self:GetObjPos()

    attr.s_id = 0
    attr.s_maxwidth = right - left
    attr.s_maxheight = 0
    attr.s_top = 0
    attr.s_left = 0
    attr.item_maxwidth = 0
	
    if attr.s_itemtable==nil then
        attr.s_itemtable = {}
        attr.s_itempos = {}
    end
    
    self:AdjustItemPos()
    if #attr.s_itemtable~=0 then
        self:UpdateItemPos(true)
    end
end

function CLB__OnPosChange(self)
    local left, top, right, bottom = self:GetObjPos()
    local width, height = right - left, bottom - top
	local attr = self:GetAttribute()
	if attr.s_maxwidth < width then
		attr.s_maxwidth = width
	end
    self:UpdateItemPos()
end

function CLB__AdjustAvalibleItemPos(self, offset)
    local left, top, right, bottom = self:GetObjPos()
    local width, height = right - left, bottom - top
    local attr = self:GetAttribute()
    local item = self:GetItem(attr.AvalibleItemIndex)
    if not item:GetVisible() then
        if offset == 1 then
            attr.s_top = attr.s_itempos[self:GetItemIndexByPoint(attr.s_itempos[attr.AvalibleItemIndex] - height) + 1]
        elseif offset == -1 then
            attr.s_top = attr.s_itempos[self:GetItemIndexByPoint(attr.s_itempos[attr.AvalibleItemIndex])]
        end
        local vsb = self:GetControlObject("listbox.vscroll")
        vsb:SetScrollPos(attr.s_top, true)
        self:UpdateItemPos()
        item:SetState(3)
    end
end

function CLB__OnVScroll(self, fun, type_, pos)
    local listbox = self:GetOwnerControl()
    local lattr = listbox:GetAttribute()
    local bkg=listbox:GetControlObject("item.layout")
    local left,top,right,bottom=bkg:GetObjPos()

	local pos = self:GetScrollPos()
    
    if type_==1 then
        self:SetScrollPos( pos - 15, true )
    elseif type_==2 then
		self:SetScrollPos( pos + 15, true )
    end
    
	local newpos = self:GetScrollPos()
	bkg:SetObjPos( left, -newpos, right, bottom - top - newpos )
	return true
end

function CLB__OnHScroll(self, fun, type_, pos)
    local listbox = self:GetOwnerControl()
    local lattr = listbox:GetAttribute()
    local bkg=listbox:GetControlObject("item.layout")
    local left,top,right,bottom=bkg:GetObjPos()

	local pos = self:GetScrollPos()
    
    if type_==1 then
        self:SetScrollPos( pos - 15, true )
    elseif type_==2 then
		self:SetScrollPos( pos + 15, true )
    end
    
	local newpos = self:GetScrollPos()
	bkg:SetObjPos( -newpos, top, right - left - newpos, bottom )
	return true
end

function CLB__CancelAllSelect(self)
    local attr = self:GetAttribute()
    for i=1,#attr.s_itemtable do
        attr.s_itemtable[i]:SetState(0)
    end
end

function CI__SetState(self, newState)
    local attr = self:GetAttribute()
    if newState ~= attr.NowState then
        local ownerTree = self:GetOwner()
        local bkg = self:GetControlObject("comboitem.bkg")
        local text = self:GetControlObject("comboitem.text")
		local itemremove = self:GetControlObject("comboitem.remove.icon")	    
        local owner = self:GetOwnerControl()
        local owner1 = owner:GetOwnerControl()
        local attr1 = owner1:GetAttribute()	
        if newState == 0 then
            bkg:SetTextureID(attr.NormalBkgID)
            text:SetTextColorResID("system.black")
			-- 为了不影响之前的功能，针对删除记录增加了一个开关CanRemove，CanRemove默认是false
			if attr1.CanRemove == true then    
			    itemremove:SetVisible(false)
			end
        elseif newState == 3 then
            bkg:SetTextureID(attr.HoverBkgID)
            text:SetTextColorResID("system.white")
			-- 为了不影响之前的功能，针对删除记录增加了一个开关CanRemove，CanRemove默认是false
			if attr1.CanRemove == true then
			    if attr.ItemText == "清除历史记录..." then
			        itemremove:SetVisible(false)
			    else
			        itemremove:SetVisible(true)			
			    end		
            end	
        end
       
        attr.NowState = newState		
    end
end

function CI__GetSize(self)
    local attr = self:GetAttribute()
    if attr.RealWidth == nil then
        local text = self:GetControlObject("comboitem.text")
        text:SetText(attr.ItemText)
        local cx, cy = text:GetTextExtent()
        attr.RealWidth = attr.LeftMargin + attr.IconWidth + cx
        attr.RealHeight = 22
    end
    return attr.RealWidth, attr.RealHeight
end

function CI__SetParentObj(self, obj)
    local attr = self:GetAttribute()
    attr.parent = obj
end

function CI__GetID(self)
    local attr = self:GetAttribute()
    return attr.ItemID
end

function CI__SetID(self, id)
    local attr = self:GetAttribute()
    attr.ItemID = id
end

function CI__GetText(self)
    local attr = self:GetAttribute()
    return attr.ItemText
end

function CI__OnBind(self)
    local attr = self:GetAttribute()
    attr.NowState = 0
    local width, height = self:GetSize()
    local bkg = self:GetControlObject("comboitem.bkg")
    local icon = self:GetControlObject("comboitem.icon")
    local text = self:GetControlObject("comboitem.text")	
    text:SetTextColorResID("system.black")
    bkg:SetTextureID(attr.NormalBkgID)
    bkg:SetObjPos(0, 0, width, height)	
    local nowleft = attr.LeftMargin    
    if attr.IconResID then
        icon:SetResID(attr.IconResID)
        icon:SetObjPos(nowleft, attr.TopMargin, nowleft + attr.IconWidth, height)
        nowleft = nowleft + attr.IconWidth
        icon:SetVisible(true)    
    end
	
	    
    local comboxObj = self:GetOwnerControl():GetOwnerControl()
	local l, t, r, b = comboxObj:GetObjPos()
	local comboxWidth = r - l
    text:SetObjPos(nowleft, 0, comboxWidth - nowleft, height)
end

function CI__OnPosChange(self)
    local attr = self:GetAttribute()
    local left, top, right, bottom = self:GetObjPos()
    local width = right - left
    local height = bottom - top
    local bkg = self:GetControlObject("comboitem.bkg")
    local icon = self:GetControlObject("comboitem.icon")
    local text = self:GetControlObject("comboitem.text")
    bkg:SetTextureID(attr.NormalBkgID)
    bkg:SetObjPos(0, 0, width, height)
    text:SetTextColorResID("system.black")
    local nowleft = attr.LeftMargin
    
    icon:SetResID(attr.IconResID)
    icon:SetObjPos(nowleft, attr.TopMargin, nowleft + attr.IconWidth, height)
    nowleft = nowleft + attr.IconWidth
    icon:SetVisible(true)
	local comboxObj = self:GetOwnerControl():GetOwnerControl()
	local l, t, r, b = comboxObj:GetObjPos()
	local comboxWidth = r - l
    text:SetObjPos(nowleft, 0, comboxWidth - nowleft, height)
end

function CI__OnFocusChange(self, focus)   
    if focus then
        self:SetState(3)
    else
        self:SetState(0)
    end
end

function CI__OnMouseMove(self)
    local owner = self:GetOwnerControl()
    local ownerattr = owner:GetAttribute()
    ownerattr.AvalibleItemIndex = self:GetID()
    local owner2 = owner:GetOwnerControl()
    local owner2attr = owner2:GetAttribute()
    owner2attr.OnListItem = true
    owner:CancelAllSelect()
    self:SetState(3)
end

function CI__OnMouseLeave(self)
    local owner = self:GetOwnerControl()
    local owner2 = owner:GetOwnerControl()
    local owner2attr = owner2:GetAttribute()
    owner2attr.OnListItem = false
    --self:SetState(0)
end


function CB_OnEnableChange(self, enable)
	local attr = self:GetAttribute()
    local edit = self:GetControlObject("combo.edit")
    if attr.EnableEdit then
        edit:SetReadOnly(not enable)
        edit:SetNoCaret(not enable)
    end
    local btn = self:GetControlObject("combo.btn")
    btn:SetEnable(enable)
    local bkg = self:GetControlObject("combo.bkg")
    if enable then
        self:SetState(0)
    else
        self:SetState(2)
    end
end

function CI__OnVisibleChange(self, visible)
    local bkg = self:GetControlObject("comboitem.bkg")
    bkg:SetVisible(visible)
    local icon = self:GetControlObject("comboitem.icon")
    local text = self:GetControlObject("comboitem.text")
    icon:SetVisible(visible)
    text:SetVisible(visible)
end

function GetEdit(self)
	return self:GetControlObject("combo.edit")
end

-- 登录框删除单个记录图标的事件
function CI__Icon__OnBtnDown(self)
    self:SetResID("bitmap.comboremove.down")
	
    local owner = self:GetOwnerControl()
	local owner1 = owner:GetOwnerControl()
	local owner2 = owner1:GetOwnerControl()
    local attr = owner2:GetAttribute()

    local attrItem = owner:GetAttribute()
	local Index = attrItem.ItemID
	attr.select = Index
	attr.ShowList = false
	owner2:RemoveItem(Index)
    local lblayout = owner2:GetControlObject("listbox.layout")
	local btnlayout = owner2:GetControlObject("btn.layout")
	local listbox = owner2:GetControlObject("listbox")
	local edit = owner2:GetControlObject("combo.edit")

	-- 设置显示的文字
    local boxText = ""
	if #attr.data == 2 then
	    boxText = "" 
	elseif 1 == Index then
	    boxText =  attr.data[Index + 1].Text
	else
	    boxText = attr.DesText
	end
	
    if not attr.data[Index].Custom then
        edit:SetText(boxText)
        owner2:FireExtEvent("OnSelectItemChanged", Index)
		owner2:FireExtEvent("OnEnterContent",attr.data[Index].Text)
		edit:SetFocus(true)
    end
	
	-- 收起list
	btnlayout:SetZorder( 0 )
    lblayout:RemoveChild(listbox)
    local left, top, right, bottom = owner2:GetObjPos()
    if listbox then
        owner2:FireExtEvent("OnListExpandChange", false, right - left, bottom - top)
    end	
	
	-- C++删除登录记录
	local CommunityFactory = XLGetObject("Xunlei.BaseCommunity.Factory")
	if nil == CommunityFactory then
	   return
	end	
	local objCommunity = CommunityFactory:CreateInstance()
	objCommunity:RemoveUserInfoByIndex(Index)	
end

function CI__Icon__OnMouseMove(self, x, y)
    AddTip(self, "删除登录记录")
    self:SetResID("bitmap.comboremove.hover")
end

function CI__Icon__OnMouseHover(self, x, y)
    AddTip(self, "删除登录记录")
    self:SetResID("bitmap.comboremove.hover") 
end

function CI__Icon__OnMouseLeave(self)
    RemoveTip(self)
    self:SetResID("bitmap.comboremove.normal")
end

-- 显示tip
function AddTip(self, text)
	local tree = self:GetOwner()
	local root = tree:GetRootObject()
    local tip = root:GetControlObject("combox.tip")
    if tip ~= nil then
        return
    end	
	
	local xarManager = XLGetObject("Xunlei.UIEngine.XARManager")
	local xarFactory = xarManager:GetXARFactory()
    local tipObj = xarFactory:CreateUIObject("combox.tip","WHome.CommonTips")
	local tipAttr = tipObj:GetAttribute()
	tipAttr.BkgTexture = "texture.mainwnd.tip.bkg"
	tipAttr.TextBeginH = 6
	tipAttr.TextBeginV = 6
	tipAttr.TrackMouse = false
	tipAttr.Multiline = true
	tipAttr.MultilineTextLimitWidth = 120
	tipObj:SetText(text)
	tipObj:SetType(4)
	tipObj:SetZorder(10000000)
	
	local tree = self:GetOwner()
	local root = tree:GetRootObject()
	root:AddChild(tipObj)
	local tipLeft,tipTop,tipRight,tipBottom = tipObj:GetTipRect(self)
	tipObj:SetObjPos(tipLeft+10, tipTop+10, tipRight+10,tipBottom+10)
end

-- 移除tip
function RemoveTip(self)
	local tree = self:GetOwner()
	local root = tree:GetRootObject()
    local tip = root:GetControlObject("combox.tip")
    if tip ~= nil then
        root:RemoveChild(tip)
    end
    return tipid
end