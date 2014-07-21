function SetRange(self, nMin, nMax)
	local slider = self:GetControlObject("SliderEdit.Slider")
	slider:SetRange(nMin, nMax)
	local edit = self:GetControlObject("SliderEdit.EditBox")
	edit:SetRange(nMin, nMax)
end

function SetText(self, str)
	local edit = self:GetControlObject("SliderEdit.EditBox")
	edit:SetText(str)
end

function GetText(self)
	local edit = self:GetControlObject("SliderEdit.EditBox")
	local str = edit:GetText()
	return str
end

function SetVisible(self, bVisible)
	self:SetChildrenVisible(bVisible)
end

function SetEnable(self, bEnable)
	local edit = self:GetControlObject("SliderEdit.EditBox")
	local btn = self:GetControlObject("SliderEdit.Btn")
	local attr = self:GetAttribute()
	edit:SetEnable(bEnable)
	btn:SetEnable(bEnable)
	
	local ctrl = self:GetControlObject("SliderEdit.bkg")
	local xarManager = XLGetObject("Xunlei.UIEngine.XARManager") 
	ctrl:SetResProvider(xarManager)
	if bEnable then
		ctrl:SetTextureID("texture.edit.bkg.normal")
		attr.Enable = true
	else
		attr.Enable = false
		ctrl:SetTextureID("texture.edit.bkg.disable")
	end
end

function GetEnable(self)
	local attr = self:GetAttribute()
	return attr.Enable
end

function SetFocus(self, focus)
	local edit = self:GetControlObject("SliderEdit.EditBox")
	edit:SetFocus(focus)
end

function Edit_OnInitControl(self)
	local attr = self:GetAttribute()
	local left, top, right, bottom = self:GetObjPos()
	local width, height = right-left, bottom-top

	attr.EditLeft = 0
	attr.EditTop = 4
	attr.EditWidth = width - 8
	attr.EditHeight = height - 4
end

function Btn_OnClick(self)
	local control = self:GetOwnerControl()
	local attr = control:GetAttribute()
	attr.BtnLButtonDown = false
	
	local slider = control:GetControlObject("SliderEdit.Slider")
	local layout =control:GetControlObject("SliderEdit.Slider.Layout")
	
	local bVisible = attr.SliderVisible
	if not bVisible then
		local edit = control:GetControlObject("SliderEdit.EditBox")
		local str = edit:GetText()
		if str == "" then
			slider:SetPos(attr.Min)
			edit:SetText(""..attr.Min)
		else
			local nVal = tonumber(str)
			if nVal < attr.Min then
				nVal = attr.Min
			elseif nVal > attr.Max then
				nVal = attr.Max
			end
			slider:SetPos(nVal)
		end
	end
	
	layout:SetChildrenVisible(not bVisible)
	attr.SliderVisible = not bVisible
	attr.SliderFocus = not bVisible
	
	if attr.SliderFocus then
		slider:SetFocus(true)
	end
	
	local left, top, right, bottom = layout:GetObjPos()
	control:FireExtEvent("OnSliderExpandChange", not bVisible, right - left, bottom - top+25)
	
	--local edit = control:GetControlObject("SliderEdit.EditBox")
	--edit:SetFocus(focus)
	--control:FireExtEvent("OnEditFocusChange", true)
end

function OnSilderChange(self, name, pos)
	local control = self:GetOwnerControl()
	local edit = control:GetControlObject("SliderEdit.EditBox")
	local oldvalue = edit:GetText()
	edit:SetText(""..pos)
	if oldvalue ~= ""..pos then
		control:FireExtEvent("OnValueChange")
	end
end

function Edit_OnEditChange(self)
	local control = self:GetOwnerControl()
	control:FireExtEvent("OnValueChange")
end

function Edit_OnFocusChange(self, name, focus)
	local owner = self:GetOwnerControl()
	owner:FireExtEvent("OnEditFocusChange", focus)
	local attr = owner:GetAttribute()
	attr.editFocus = focus
	
	--[[if not attr.editFocus and not attr.SliderFocus then
		HideSlider(owner)
	end]]
end

function Btn_OnLButtonDown(self)
	local owner = self:GetOwnerControl()
	local attr = owner:GetAttribute()
	attr.BtnLButtonDown = true
end

function Slider__OnSliderLostFocus(self, focus)
	local ctrl = self:GetOwnerControl()
	local attr = ctrl:GetAttribute()
	attr.SliderFocus = false
	HideSlider(self)
end

function Slider__OnLButtonDown(self)
	local ctrl = self:GetOwnerControl()
	local attr = ctrl:GetAttribute()
	attr.SliderFocus = true
end

function OnInitControl(self)
	--全键盘支持控件
	local tabKeySupportObj = self:GetControlObject("TabKeySupport.edit")
	local edit = self:GetControlObject("SliderEdit.EditBox")
	tabKeySupportObj:RegisterTabObj(edit, nil, nil, nil, true, nil)

---[[
	local attr = self:GetAttribute()
	local layout =self:GetControlObject("SliderEdit.Slider.Layout")
	layout:SetChildrenVisible(false)
	local leftlayout, toplayout, rightlayout, bottomlayout = layout:GetObjPos()
	
	local sliderbkg = self:GetControlObject("SliderEdit.Slider.bkg")
	local leftbkg, topbkg, rightbkg, bottombkg = sliderbkg:GetObjPos()
	sliderbkg:SetObjPos(rightlayout-attr.SliderWidth, topbkg, rightlayout, bottombkg)
		
	if not attr.EnableEdit then
		edit:SetReadOnly(true)
	end
	attr.BtnLButtonDown = false
	attr.SliderVisible = false
	attr.SliderFocus = false
	attr.editFocus = false
	attr.SliderBkgFocus = false
	self:SetEnable(attr.Enable)
	
	local slider = self:GetControlObject("SliderEdit.Slider")
	local left, top, right, bottom = slider:GetObjPos()
	self:SetRange(attr.Min, attr.Max)
	slider:SetObjPos(left+4, top, attr.SliderWidth-13, bottom)
	slider:SetZorder(5000)
	
	local count = slider:GetChildCount()
	local childbkg = slider:GetChildByIndex(0)
	local idbkg =childbkg:GetID()
	local childCtrl = childbkg:GetOwnerControl()
	local childbtn = childCtrl:GetControlObject("sliderbar.btn")
	local idbtn =childbtn:GetID()
	
	local function OnLButtonDown(self)
		attr.SliderBkgFocus = true
	end
	
	sliderbkg:AttachListener("OnLButtonDown", true, OnLButtonDown)
	
	local function OnFocusChange(self, focus)
		if not focus then
			attr.SliderBkgFocus = false
			HideSlider(self)
		end
	end
	sliderbkg:AttachListener("OnFocusChange", true, OnFocusChange)
	--]]
end
function HideSlider(self)
	local ctrl = self:GetOwnerControl()
	local attr = ctrl:GetAttribute()
	if not attr.BtnLButtonDown and attr.SliderVisible and not attr.SliderBkgFocus and not attr.SliderFocus then
		local layout =ctrl:GetControlObject("SliderEdit.Slider.Layout")
		local left, top, right, bottom = layout:GetObjPos()
		layout:SetChildrenVisible(false)
		attr.SliderVisible = false
		ctrl:FireExtEvent("OnSliderExpandChange", false, right - left, bottom - top+25)
	end
end

function AddTip(self, text, sessionName, type_)
	local edit = self:GetControlObject("SliderEdit.EditBox")
	edit:AddTip(text, sessionName, type_)
end

function RemoveTip(self)
	local edit = self:GetControlObject("SliderEdit.EditBox")
	edit:RemoveTip()
end

function SetTabOrder(self, tabOrder)
	local tabKeySupportObj = self:GetControlObject("TabKeySupport.edit")
	tabKeySupportObj:SetControlTabOrder(tabOrder)
end

function SetTabOrderEnable(self, bEnable)
	local tabKeySupportObj = self:GetControlObject("TabKeySupport.edit")
	tabKeySupportObj:SetTabEnable(bEnable)
end

