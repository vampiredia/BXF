--
--
--
function SetRange(self, nMin, nMax)
	if nMin == nil then
		nMin = 0
	end
	
	if nMax == nil then
		nMax = 0
	end
	if nMin > nMax then
		local temp = nMin
		nMin = nMax
		nMax = nMin
	end
	local attr = self:GetAttribute()
	attr.Min = nMin
	attr.Max = nMax
end
function SetState(self, state)
    local attr = self:GetAttribute()
    if attr.NowState ~= state then
        local bkg = self:GetControlObject("newedit.bkg")
		local edit = self:GetControlObject("newedit.edit")
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

function SetFocus( self, focus )
    local edit = self:GetControlObject("newedit.edit")
	edit:SetFocus( focus )
end

function SetText(self, text)
    local edit = self:GetControlObject("newedit.edit")
	if edit then
		local attr = self:GetAttribute()
		if attr then
			if text ~= "" then
				attr.Text = text
				edit:SetText(text)
			elseif attr.TipText ~= nil then
				edit:SetTextColorID(attr.NormalTipTextColor)
				edit:SetIsPassword(false)
				edit:SetText(attr.TipText)
			end
		end
	end
end
-- 根据 width,height 居中
function SetEmptyBkgID(self, ID, width, height, voff)
	voff = voff or 0
	local bkg = self:GetControlObject("newedit.emptybkg")
	bkg:SetResID(ID)
	if width~=nil and height~=nil then
		local left,top = "(father.width - ".. width .." )/2", "(father.height - ".. height .." )/2+"..voff	
		bkg:SetObjPos(left,top,left.."+"..width,top.."+"..height)
	end
end

-- BkgBkg is background of background, which is a second image that has lower zorder
function SetEmptyBkgBkgID(self, ID, width, height, voff)
	voff = voff or 0
	local bkg = self:GetControlObject("newedit.emptybkgbkg")
	bkg:SetResID(ID)
	if width~=nil and height~=nil then
		local left,top = "(father.width - ".. width .." )/2", "(father.height - ".. height .." )/2+"..voff	
		bkg:SetObjPos(left,top,left.."+"..width,top.."+"..height)
	end
end

function SetEmptyBkgChild(self, classname, width, height)
	local parent = self:GetControlObject("edit.limit")
	bkg:SetResID(ID)
	if width~=nil and height~=nil then
		local left,top = "(father.width - ".. width .." )/2", "(father.height - ".. height .." )/2"	
		bkg:SetObjPos(left,top,left.."+"..width,top.."+"..height)
	end
end

function SetSel( self, start_pos, end_pos )
    local edit = self:GetControlObject("newedit.edit")
	edit:SetSel( start_pos, end_pos )
end

function GetSel( self )
    local edit = self:GetControlObject("newedit.edit")
	return edit:GetSel()
end

function GetText(self)
    local edit = self:GetControlObject("newedit.edit")
	local ownerattr = edit:GetOwnerControl():GetAttribute()
	local text = edit:GetText()
    return text
end

function SetReadOnly(self, enable)
    local edit = self:GetControlObject("newedit.edit")
    edit:SetReadOnly(enable)
	
	local attr = self:GetAttribute()
	attr.ReadOnly = enable
end

function SetMultiline(self, enable)
    local edit = self:GetControlObject("newedit.edit")
    edit:SetMultiline(enable)
end

function GetReadOnly(self, enable)
    local edit = self:GetControlObject("newedit.edit")
    return edit:GetReadOnly()
end

function GetMultiline(self, enable)
    local edit = self:GetControlObject("newedit.edit")
    return edit:GetMultiline()
end

function RemoveTip(self)
	local editBkn = self:GetControlObject("newedit.bkg")
	XLGetGlobal("xunlei.TipsHelper"):RemoveTip(editBkn)
end

function AddTip(self, text, sessionName, type_)
	local editBkn = self:GetControlObject("newedit.bkg")
	XLGetGlobal("xunlei.TipsHelper"):AddTip(editBkn, text, sessionName, type_)
end

function OnBind(self)
    local attr = self:GetAttribute()
    local left, top, right, bottom = self:GetObjPos()
    local width = right - left
    local height = bottom - top
    local bkg = self:GetControlObject("newedit.bkg")
    bkg:SetTextureID(attr.NormalBkgID)
    local edit = self:GetControlObject("newedit.edit")
    
	if attr.Text ~= nil and attr.Text ~= "" then
		edit:SetIsPassword(attr.Password)
		edit:SetText(attr.Text)
		edit:SetTextColorID(attr.NormalTextColor)
	elseif attr.TipText ~= nil and attr.TipText ~= "" then 
		edit:SetIsPassword(false)
		edit:SetText(attr.TipText)
		edit:SetTextColorID(attr.NormalTipTextColor)
	end
	
	if not attr.EditCustom then
		attr.EditLeft = 0
		attr.EditTop = 4
		attr.EditWidth = "father.width - 4"
		attr.EditHeight = "father.height - 7"
	end
    edit:SetObjPos(attr.EditLeft, attr.EditTop, ""..attr.EditLeft.."+"..attr.EditWidth, ""..attr.EditTop.."+"..attr.EditHeight)
end

function OnMouseMove(self)
    local control = self:GetOwnerControl()
    local attr = control:GetAttribute()

    if attr.NowState==0 then
        --self:SetState(1)
    end
end

function Edit__OnMouseLeave(self)
    local control = self:GetOwnerControl()
    local attr = control:GetAttribute()

    --control:SetState(0)
end

function Edit__OnMouseMove(self)
    local control = self:GetOwnerControl()
    local attr = control:GetAttribute()

    if attr.NowState==0 then
        --control:SetState(1)
    end
end

function OnMouseLeave(self)
    local control = self:GetOwnerControl()
    local attr = control:GetAttribute()

    --self:SetState(1)
end

function Edit__OnChange(self)
    local control = self:GetOwnerControl()
    local text = self:GetText()
	local ownerattr = control:GetAttribute()
	if not ownerattr.auto_set_text then 
		control:RemoveTip()
	end
	ownerattr.auto_set_text = false
	if ownerattr.Focus ~= true then
		return
	end
	if ownerattr.IsNumber then
	
		if text == "0" and ownerattr.Min > 0 then
			control:AddTip( "输入值必须大于等于"..ownerattr.Min ,nil, ownerattr.TipType)
			control:SetText("")
			return
		end

		if text ~= nil then
			for i = 1, string.len( text ) do
				if string.byte( text, i ) < string.byte( "0" ) or string.byte( text, i ) > string.byte( "9" ) then
					if i ~= 1 or string.byte( text, i ) ~= string.byte("-") then
						control:AddTip( "必须输入数字字符" , nil, ownerattr.TipType)
						self:SetText( ownerattr.Text )
						return
					end
				end
			end
			if string.byte(text, 1) == string.byte("-") and ownerattr.Min >= 0 then
				control:SetText("")
				control:AddTip("输入值必须大于等于"..ownerattr.Min, nil, ownerattr.TipType)
				return
			end
			if ownerattr.Min ~= 0 or ownerattr.Max ~= 0 then
				if ownerattr.Min < ownerattr.Max then
					if tonumber( text ) == nil or text == "" or tonumber( text ) < ownerattr.Min then
						control:AddTip( "输入值必须大于等于"..ownerattr.Min ,nil, ownerattr.TipType)
						return
					elseif  tonumber( text ) ~= nil and tonumber( text ) > ownerattr.Max then
						control:AddTip( "输入值必须小于等于"..ownerattr.Max ,nil, ownerattr.TipType)
						self:SetText( ownerattr.Text )
						return
					end
				end
			end
		end
	else
		if ownerattr.CharNumber > 0 then
			if string.len( text ) > ownerattr.CharNumber then
				control:AddTip( "最大输入字符个数为"..ownerattr.CharNumber ,nil, ownerattr.TipType)
				self:SetText( ownerattr.Text )
				return
			end
		end
	end
	
	if ownerattr.FilterBlock then
		local function CleanBlock(str)
			local temp = ""
			local len = string.len(str)
			local tempChar
			for i=1, len do
				tempChar = string.sub(str, i, i)
				if tempChar ~= " " then
					temp = temp .. tempChar
				end
			end
			return temp
		end
		
		local newText = CleanBlock(text)
		if string.len(newText) ~= string.len(text) then
			text = newText
			self:SetText(text)
		end
	end
	
	ownerattr.Text = text
    control:FireExtEvent("OnEditChange", text)
end

function Edit__OnFocusChange(self, focus)
    local owner = self:GetOwnerControl()
    local ownerattr = owner:GetAttribute()
    if focus then
        owner:RemoveTip()
		self:SetIsPassword(ownerattr.Password)
		if owner:GetEnable() and not ownerattr.ReadOnly and ownerattr.HitSelAll then
			AsynCall( function()
						self:SetSelAll()
					  end )
		end
		ownerattr.Focus = true
		if ownerattr.Text == nil or ownerattr.Text == "" then
			if ownerattr.TipText ~= nil and ownerattr.TipText ~= "" then
				self:SetText( "" )
				self:SetTextColorID(ownerattr.NormalTextColor)
			end
		end
		owner:SetState(1)
    else
		owner:FireExtEvent("OnTabbedEvent", false)
		ownerattr.Focus = false
        owner:RemoveTip()
		local text = self:GetText()
		if owner:GetEnable() then
			
			local ownerattr = owner:GetAttribute()
			if ownerattr.IsNumber then
				if text ~= nil and text ~= "" then
					if ownerattr.Min ~= 0 or ownerattr.Max ~= 0 then
						if ownerattr.Min < ownerattr.Max then
							if tonumber( text ) == nil or tonumber( text ) < ownerattr.Min then
								text = ""..ownerattr.Min
								self:SetText( text )
								ownerattr.auto_set_text = true
							elseif  tonumber( text ) > ownerattr.Max then
								text = ""..ownerattr.Max
								ownerattr.auto_set_text = true
								self:SetText( text )
							end
						end
					end
				end
			end
			
			owner:SetState(0)
		else
			owner:SetState(2)
		end
		
		ownerattr.Text = text
		if ownerattr.Text == nil or ownerattr.Text == "" then
			if ownerattr.TipText ~= nil and ownerattr.TipText ~= "" then
				self:SetIsPassword(false)
				self:SetText(ownerattr.TipText)
				self:SetTextColorID(ownerattr.NormalTipTextColor)
			end
		end
    end
    owner:FireExtEvent("OnEditFocusChange", focus)
end

function Edit__OnChar(self, char, counts, flag)
    local owner = self:GetOwnerControl()
	if char == 9 then
		--Tabbed
		owner:FireExtEvent("OnTabbedEvent", true)
	end
	owner:FireExtEvent("OnEditChar", char, counts, flag)
	
	if not self:GetMultiline() then
        return
	end
end

function Edit_OnKeyDown(self, uChar, uRepeatCount, uFlags)
	local owner = self:GetOwnerControl()
	owner:FireExtEvent("OnEditKeyDown", uChar, uRepeatCount, uFlags)
end

function Edit_OnKeyUp(self, uChar, uRepeatCount, uFlags)
	local owner = self:GetOwnerControl()
	owner:FireExtEvent("OnEditKeyUp", uChar, uRepeatCount, uFlags)
end

function OnInitControl(self)
    local attr = self:GetAttribute()
    local edit = self:GetControlObject("newedit.edit")
	edit:SetFontID( attr.Font )
    edit:SetMultiline(attr.Multiline)
	edit:SetReadOnly(not self:GetEnable() or attr.ReadOnly)
	edit:SetNoCaret(not self:GetEnable())
	edit:SetAllowHSB( attr.AllowHSB )
	edit:SetAllowVSB( attr.AllowVSB )
	attr.auto_set_text = false
	if self:GetEnable() then
        self:SetState(0)
	else
        self:SetState(2)
	end
	edit:SetWordWrap(attr.WordWrap)
	edit:SetAutoUrlDetect(attr.AutoUrlDetect)
	if attr.ViewinsetLeft ~= nil and attr.ViewinsetRight ~= nil and attr.ViewinsetTop ~= nil and attr.ViewinsetButtom ~= nil then
		edit:SetViewInset( attr.ViewinsetLeft, attr.ViewinsetTop, attr.ViewinsetRight, attr.ViewinsetButtom )
	end
	if attr.IsNumber then
		edit:SetIsNumber(true)
	end
	
	--全键盘支持初始化
	local tabKeyEdit = self:GetControlObject("tabKey.Edit")
	if tabKeyEdit ~= nil then
		local rectPos = {}
		rectPos.leftSpace = 3
		rectPos.rightSpace = 3
		rectPos.topSpace = 3
		rectPos.bottomSpace = 3
		tabKeyEdit:RegisterTabObj(self, nil, nil, nil, true, rectPos)
	end
	
	self:SetBorder(self:GetBorder())
end

function OnFocusChange( self, status )
	if status then
		local edit = self:GetOwnerControl():GetControlObject("newedit.edit")
		edit:SetFocus( true )
	end
end

function Control_OnFocusChange( self, status )
	if status then
		local edit = self:GetControlObject("newedit.edit")
		edit:SetFocus( true )
	end
end

function OnVScroll(self, int1 ,int2)	
	local edit = self:GetOwnerControl():GetControlObject("newedit.edit")
	local pos = self:GetScrollPos()
	if int2 == 1 then
		self:SetScrollPos( pos - 15, true )
	elseif int2 == 2 then
		self:SetScrollPos( pos + 15, true )
	end
	edit:SetScrollPos(true, self:GetScrollPos())
end

function OnHScroll( self, int1, int2)
	local edit = self:GetOwnerControl():GetControlObject("newedit.edit")
	local pos = self:GetScrollPos()
	if int2 == 1 then
		self:SetScrollPos( pos - 15, true )
	elseif int2 == 2 then
		self:SetScrollPos( pos + 15, true )
	end
	edit:SetScrollPos(false, self:GetScrollPos())
end

function OnGetSBIdealSize(self, vertical)
	
	if vertical then
		return 11,0
	else
		return 0,11
	end
	
end

function OnSetSBRect(self, vertical, left, top, right, bottom)
	if vertical then
		local var = self:GetOwnerControl():GetControlObject("vsb")
		if self:GetScrollVisible( false ) then
			var:SetObjPos(left+4,top,right+4,bottom+11)
		else
			var:SetObjPos(left+4,top,right+4,bottom)
		end
	else
		local var = self:GetOwnerControl():GetControlObject("hsb")
		if self:GetScrollVisible( true ) then
			var:SetObjPos(left,top,right + 5,bottom)
		else
			var:SetObjPos(left,top,right + 3,bottom)
		end
	end
end

function OnSetSBVisible(self, vertical, visible)
	if vertical then
		local var = self:GetOwnerControl():GetControlObject("vsb")	
		var:SetVisible(visible)
		if not visible then
			var:SetScrollRange( 0, 0 )
		end
	else
		local var = self:GetOwnerControl():GetControlObject("hsb")	
		var:SetVisible(visible)
		if not visible then
			var:SetScrollRange( 0, 0 )
		end
	end
end

function OnGetSBVisible(self, vertical)
	if vertical then
		local var = self:GetOwnerControl():GetControlObject("vsb")	
		return var:GetVisible()
	else
		local var = self:GetOwnerControl():GetControlObject("hsb")	
		return var:GetVisible()
	end
end

function OnGetSBEnable(self, vertical)
	if vertical then
		local var = self:GetOwnerControl():GetControlObject("vsb")	
		return var:GetEnable()
	else
		local var = self:GetOwnerControl():GetControlObject("hsb")	
		return var:GetEnable()
	end
end

function OnSetSBEnable(self, vertical, enable)
	if vertical then
		local var = self:GetOwnerControl():GetControlObject("vsb")
		var:SetEnable(enable)
	else
		local var = self:GetOwnerControl():GetControlObject("hsb")
		var:SetEnable(enable)
	end
end

function OnGetSBPageSize(self, vertical)
	if vertical then
		local var = self:GetOwnerControl():GetControlObject("vsb")	
		return var:GetPageSize()
	else
		local var = self:GetOwnerControl():GetControlObject("hsb")	
		return var:GetPageSize()
	end
end

function OnSetSBPageSize(self, vertical, pagesize)
	if vertical then
		local hsb = self:GetOwnerControl():GetControlObject("hsb")
		--local left, top, right, bottom = hsb:GetObjPos()
		pagesize = pagesize - 3
		
		local vsb = self:GetOwnerControl():GetControlObject("vsb")	
		vsb:SetPageSize(pagesize, true)
	else
		local vsb = self:GetOwnerControl():GetControlObject("vsb")
		--local left, top, right, bottom = vsb:GetObjPos()
		pagesize = pagesize - 3
		
		local hsb = self:GetOwnerControl():GetControlObject("hsb")	
		hsb:SetPageSize(pagesize, true)
	end
end

function OnSetSBRange(self, vertical, minrange, maxrange)
	if vertical then
		local var = self:GetOwnerControl():GetControlObject("vsb")	
		--XLMessageBox( "minrange = "..tostring( minrange).." maxrange = "..tostring( maxrange).." size = "..var:GetPageSize() )
		var:SetScrollRange(minrange, maxrange - var:GetPageSize(), true)
	else
		local var = self:GetOwnerControl():GetControlObject("hsb")	
		var:SetScrollRange(minrange, maxrange - var:GetPageSize()+8, true)
	end
end

function OnGetSBRange(self, vertical)
	if vertical then
		local var = self:GetOwnerControl():GetControlObject("vsb")
		return var:GetScrollRange()
	else
		local var = self:GetOwnerControl():GetControlObject("hsb")
		return var:GetScrollRange()
	end
end

function OnSetSBPos(self, vertical, pos)
	if vertical then
		local var = self:GetOwnerControl():GetControlObject("vsb")
		var:SetScrollPos(pos, true)
	else
		local var = self:GetOwnerControl():GetControlObject("hsb")
		var:SetScrollPos(pos, true)
	end
end

function OnGetSBPos(self, vertical)
	if vertical then
		local var = self:GetOwnerControl():GetControlObject("vsb")
		return var:GetScrollPos()
	else
		local var = self:GetOwnerControl():GetControlObject("hsb")
		return var:GetScrollPos()
	end
end

function Edit_OnRButtonUp( self, x, y, flag )
    local owner = self:GetOwnerControl()
	local attr = self:GetOwnerControl():GetAttribute()
	if attr.ShowMenu then
		local wnd_handle = self:GetOwner():GetBindHostWnd():GetWndHandle()
		local obj = XLGetGlobal("xunlei.MenuHelper")
		XLSetGlobal( "xunlei.cur.edit", self )
		obj:ShowMenu("single.menu", attr.MenuTreeID, attr.MenuID, wnd_handle)
	end
    owner:FireExtEvent("OnEditRClick")
end

function Undo_OnInit( self )
	local edit = XLGetGlobal( "xunlei.cur.edit" )
	if edit ~= nil then
		if not edit:CanUndo() or edit:GetReadOnly() then
			self:SetEnable( false )
		end
	end
end

function Undo_OnSelect( self, name, id )
	local edit = XLGetGlobal( "xunlei.cur.edit" )
	if edit ~= nil then
		edit:Undo()
	end
end

function Cut_OnInit( self )
	local edit = XLGetGlobal( "xunlei.cur.edit" )
	if edit ~= nil then
		local start, end_ = edit:GetSel()
		if start == end_ or edit:GetReadOnly() then
			self:SetEnable( false )
		end
	end
end

function Cut_OnSelect( self, name, id )
	local edit = XLGetGlobal( "xunlei.cur.edit" )
	if edit ~= nil then
		edit:Cut()
	end
end

function Copy_OnInit( self )
	local edit = XLGetGlobal( "xunlei.cur.edit" )
	if edit ~= nil then
		local start, end_ = edit:GetSel()
		if start == end_ then
			self:SetEnable( false )
		end
	end
end

function Copy_OnSelect( self, name, id )
	local edit = XLGetGlobal( "xunlei.cur.edit" )
	if edit ~= nil then
		edit:Copy()
	end
end

function Paste_OnInit( self )
	local edit = XLGetGlobal( "xunlei.cur.edit" )
	if edit ~= nil then
		if edit:GetReadOnly() then
			self:SetEnable( false )
		end
	end
	
--	local shell = XLGetObject( "Xunlei.UIEngine.OSShell" )
--	if not shell:IsClipboardTextFormatAvailable() then
--		self:SetEnable( false )
--	end
end

function Paste_OnSelect( self, name, id )
	local edit = XLGetGlobal( "xunlei.cur.edit" )
	if edit ~= nil then
		edit:Paste()
	end
end

function Delete_OnInit( self )
	local edit = XLGetGlobal( "xunlei.cur.edit" )
	if edit ~= nil then
		local start, end_ = edit:GetSel()
		if start == end_ or edit:GetReadOnly() then
			self:SetEnable( false )
		end
	end
end

function Delete_OnSelect( self )
	local edit = XLGetGlobal( "xunlei.cur.edit" )
	if edit ~= nil then
		edit:Clear()
	end
end


function SelAll_OnInit( self )
    local edit = XLGetGlobal( "xunlei.cur.edit" )
    if edit ~= nil then
        local text = edit:GetText()
        if text:len() == 0 then
            self:SetEnable(false)
        end
    end
end

function SelAll_OnSelect( self, name, id )
	local edit = XLGetGlobal( "xunlei.cur.edit" )
	if edit ~= nil then
		edit:SetSelAll()
	end
end

function AppendText( self, text, noscroll, canundo )
    local edit = self:GetControlObject("newedit.edit")
	if edit ~= nil then
		edit:AppendText( text, noscroll, canundo )
	end
end

function GetLineCount( self )
	local edit = self:GetControlObject("newedit.edit")
	local count = 0
	if edit ~= nil then
		count = edit:GetLineCount()
	end
	return count
end

function GetLine( self, idx )
	local edit = self:GetControlObject("newedit.edit")
	local text
	if edit ~= nil and idx >= 0 then
		text = edit:GetLine(idx)
	end
	return text
end

function OnScrollBarMouseWheel( self, name, x, y, distance )
	local ThumbPos = self:GetThumbPos()
    self:SetThumbPos(ThumbPos - distance/10)
end
function LineIndex( self, line )
	local edit = self:GetControlObject("newedit.edit")
	if edit ~= nil then
		return edit:LineIndex(line)
	end
	return -1
end

function PosFromChar( self, charindex )
	local edit = self:GetControlObject("newedit.edit")
	if edit ~= nil then
		return edit:PosFromChar(charindex)
	end
	return 0, 0
end

function ScrollCaret( self )
	local edit = self:GetControlObject("newedit.edit")
	if edit ~= nil then
		return edit:ScrollCaret(charindex)
	end
end


function OnEnableChange(self, enable)
	local attr = self:GetAttribute()
    local edit = self:GetControlObject("newedit.edit")
    edit:SetReadOnly(not enable or attr.ReadOnly)
    edit:SetNoCaret(not enable)
    local bkg = self:GetControlObject("newedit.bkg")
    if enable then 
        self:SetState(0)
    else
        self:SetState(2)
    end
end

function Undo(self)
	local edit = self:GetControlObject("newedit.edit")
	edit:Undo()
end

function LineLength(self, line)
	local edit = self:GetControlObject("newedit.edit")
	return edit:LineLength(line)
end

function ReplaceSel(self, text, bUndo)
	local edit = self:GetControlObject("newedit.edit")
	return edit:ReplaceSel(text, bUndo)
end

function SetControlTabOrder(self, tabOrder)
	local tabKeyEdit = self:GetControlObject("tabKey.Edit")
	tabKeyEdit:SetControlTabOrder(tabOrder)
end

function SetControlEnableTab(self, bEnable)
	local tabKeyEdit = self:GetControlObject("tabKey.Edit")
	tabKeyEdit:SetTabEnable(bEnable)
end

function SetBorder(self, status)
	local attr = self:GetAttribute()
	
	attr.Border = status
	self:GetControlObject("newedit.bkg"):SetVisible(status)
	--self:GetControlObject("newedit.bkg"):SetChildrenVisible(status)
end

function GetBorder(self)
	local attr = self:GetAttribute()
	return attr.Border
end