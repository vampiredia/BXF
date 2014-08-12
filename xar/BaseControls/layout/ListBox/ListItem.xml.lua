function OnInitControl(self)
	local attr = self:GetAttribute()
	if attr.ItemPaddingTop == nil then attr.ItemPaddingTop = 0 end
	if attr.ItemPaddingLeft == nil then attr.ItemPaddingLeft = 0 end
	if attr.ItemPaddingRight == nil then attr.ItemPaddingRight = 0 end
	if attr.ItemPaddingBottom == nil then attr.ItemPaddingBottom = 0 end
	if attr.NormalTextColor == nil then attr.NormalTextColor = "system.black" end
	if attr.ModifyTextColor == nil then attr.ModifyTextColor = "system.red" end
	
	-- create obj template child
	local itemObj = self:GetControlObject("item.bkg")
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	if attr.ItemType == 1 then 
		local objText = objFactory:CreateUIObject(attr.ItemTextID, "TextObject")
		itemObj:AddChild(objText)
		objText:SetVisible(false)
		objText:SetChildrenVisible(false)
		objText:SetHalign(attr.Halign)
	
		local objEdit = objFactory:CreateUIObject(attr.ItemEditID, "EditObject")
		itemObj:AddChild(objEdit)
		objEdit:AttachListener("OnChange", true, EDIT_OnChange)
		--objEdit:AttachListener("OnFocusChange", true, EDIT_OnFocusChange)
		objEdit:SetVisible(false)
		objEdit:SetChildrenVisible(false)
	end

	if attr.ItemType == 2 then
		local objBtnDel = objFactory:CreateUIObject(attr.ItemBtnDelID, "CoolJ.ImageButton")
		itemObj:AddChild(objBtnDel)
		objBtnDel:SetVisible(false)
		objBtnDel:SetChildrenVisible(false)
	end
	
	if attr.ItemType == 3 then 
		local objBtnAdd = objFactory:CreateUIObject(attr.ItemBtnAddID, "CoolJ.ImageButton")
		itemObj:AddChild(objBtnAdd)
		objBtnAdd:SetVisible(false)
		objBtnAdd:SetChildrenVisible(false)
	end
	
	UpdateUI(self)
end

function UpdateUI(self)
	local attr = self:GetAttribute()
	local itemObj = self:GetControlObject("item.bkg")
	local left, top, right, bottom = itemObj:GetObjPos()
	-- standard list item
	if attr.ItemType == 1 then
		if attr.ItemStatus == "readonly" then
			local objEdit = itemObj:GetChildByIndex(attr.ItemEditID)
			objEdit:SetVisible(false)
			objEdit:SetChildrenVisible(false)
			
			local objText = itemObj:GetChildByIndex(attr.ItemTextID)
			objText:SetVisible(true)
			objText:SetChildrenVisible(true)
			-- position
			objText:SetObjPos(left+attr.ItemPaddingLeft,
				top+attr.ItemPaddingTop,
				right-attr.ItemPaddingRight,
				bottom-attr.ItemPaddingBottom)			
		elseif attr.ItemStatus == "write" then
			local objText = itemObj:GetChildByIndex(attr.ItemTextID)
			objText:SetVisible(false)
			objText:SetChildrenVisible(false)
			
			local objEdit = itemObj:GetChildByIndex(attr.ItemEditID)
			objEdit:SetVisible(true)
			objEdit:SetChildrenVisible(true)
			-- position
			objEdit:SetObjPos(left+attr.ItemPaddingLeft,
				top+attr.ItemPaddingTop,
				right-attr.ItemPaddingRight,
				bottom-attr.ItemPaddingBottom)	
			objEdit:SetTextColor(attr.NormalTextColor)
		end
	-- del list item
	elseif attr.ItemType == 2 or attr.ItemType == 3 then
		local objBtn = self:GetChildByIndex(attr.ItemBtnDelID)
		if attr.ItemStatus == "write" then
			objBtn:SetVisible(true)
			objBtn:SetChildrenVisible(true)
			
			local parent_width = right - left
			local margin = 0
			if (parent_width - attr.BtnWidth) > 0 then
				margin = math.floor((parent_width - attr.BtnWidth) / 2)
			end
			if attr.BtnHalign == "left" then
				objBtn.SetObjPos(left+margin,
					top+margin,
					left+margin+attr.BtnWidth,
					top+margin+attr.BtnWidth)
			elseif attr.BtnHalign == "center" then
				left = math.floor((left + right - attr.BtnWidth ) / 2 )
				top = top + margin
				objBtn.SetObjPos(left, top, left+attr.BtnWidth, top+attr.BtnWidth)
			elseif attr.BtnHalign == "right" then
				objBtn.SetObjPos(right - margin - attr.BtnWidth,
					top+margin,
					right - margin,
					top+margin+attr.BtnWidth)
			end
		elseif attr.ItemStatus == "readonly" then
			objBtn:SetVisible(false)
			objBtn:SetChildrenVisible(false)
		end
	end
end

function EDIT_OnChange(self)
	local attr = self:GetAttribute()
	if attr.ModifyTextColor ~= nil then 
		self:SetTextColor(attr.ModifyTextColor)
	end
end

function OnItemStatusChanged(self, status)
	local attr = self:GetAttribute()
	if status == true then
		attr.ItemStatus = "write"
	else
		attr.ItemStatus = "readonly"
	end
	UpdateUI(self)
end

-- ////////////////////////////////////////////////////////////////////////
function Item_OnInitControl(self)
	local attr = self:GetAttribute()
	attr.Select = false
	attr.IsVisible = true
end

-- ////////////////////////////////////////////////////////////////////////
-- tColumnInfoList:
-- {
--		objItemGridID:,
--		
-- }
function Item_InitControl(self, nListItemIndex, tColumnInfoList)
	
end

function Item_OnLButtonDown(self, x, y, flags)
	x, y = ChildToParent(self, x, y)
	self:FireExtEvent("OnItemMouseEvent", "OnLButtonDown", x, y, flags)
end

function Item_OnLButtonUp(self, x, y, flags)
	x, y = ChildToParent(self, x, y)
	self:FireExtEvent("OnItemMouseEvent", "OnLButtonUp", x, y, flags)
end

function Item_OnLButtonDbClick(self, x, y, flags)
	x, y = ChildToParent(self, x, y)
	self:FireExtEvent("OnItemMouseEvent", "OnLButtonDbClick", x, y, flags)
end

function Item_OnRButtonDown(self, x, y, flags)
	x, y = ChildToParent(self, x, y)
	self:FireExtEvent("OnItemMouseEvent", "OnRButtonDown", x, y, flags)
end

function Item_OnRButtonUp(self, x, y, flags)
	self:FireExtEvent("OnItemMouseEvent", "OnRButtonUp", x, y, flags)
end


function Item_OnRButtonDbClick(self, x, y, flags)
	x, y = ChildToParent(self, x, y)
	self:FireExtEvent("OnItemMouseEvent", "OnRButtonDbClick", x, y, flags)
end


function Item_OnMouseMove(self, x, y, flags)
	x, y = ChildToParent(self, x, y)
	self:FireExtEvent("OnItemMouseEvent", "OnMouseMove", x, y, flags)
end

function Item_OnMouseLeave(self, x, y, flags)
	self:FireExtEvent("OnItemMouseEvent", "OnMouseLeave", x, y, flags)
end

function Item_OnMouseHover(self, x, y, flags)
	x, y = ChildToParent(self, x, y)
	self:FireExtEvent("OnItemMouseEvent", "OnMouseHover", x, y, flags)
end


function Item_OnMouseWheel(self, x, y, distance)
	x, y = ChildToParent(self, x, y)
	self:FireExtEvent("OnItemMouseEvent", "OnMouseWheel", x, y, distance)
end


function Item_OnKeyDown(self, uChar, uRepeatCount, uFlags)
	self:FireExtEvent("OnItemKeyEvent", "OnKeyDown", uChar, uRepeatCount, uFlags)
end


function Item_OnKeyUp(self, uChar, uRepeatCount, uFlags)
	self:FireExtEvent("OnItemKeyEvent", "OnKeyUp", uChar, uRepeatCount, uFlags)
end


function Item_OnChar(self, uChar, uRepeatCount, uFlags)
	self:FireExtEvent("OnItemKeyEvent", "OnChar", uChar, uRepeatCount, uFlags)
end