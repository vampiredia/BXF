--/////////////////////////////////////////////////////////////////////////////////////--
--ListBox说明：
--ListBox实现列表的基本框架，包括显示相关、表头等，包含ListBox,TableView
--ListBox没有实现ListItem,DataSource,DataConverter，使用者需自己实现，如果要用到表头，则还需考虑与表头的互动
--DataSource,DataConverter的标准接口的标准参考TableView.xml.lua
--/////////////////////////////////////////////////////////////////////////////////////--

--local LBPrint = debug.bind(debug.print, "[HQ][ListBox]")

--子对象的坐标转换为父对象的坐标
function CoordinateChildToParent(ChildObj, x, y)
	if x == nil or y == nil then
		return
	end
	local left, top = ChildObj:GetObjPos()
	return x + left, y + top
end

-----------------------------------HeaderItem相关函数------------------------------------

--使用此TaskListHeaderItem时需要AddChild前设置以下属性：
--HeaderItemAttr.NormalBkgID：Normal背景ID
--HeaderItemAttr.HoverBkgID：Hover背景ID
--HeaderItemAttr.DownBkgID：Down背景ID
--HeaderItemAttr.ChangeBkgID：改变时背景ID
--HeaderItemAttr.AscendIconID：升序图标ID
--HeaderItemAttr.DescendIconID：降序图标ID
--HeaderItemAttr.ItemWidth：宽度
--HeaderItemAttr.ItemHeight：高度
--HeaderItemAttr.Text：名字
--HeaderItemAttr.TextLeftOffSet: 名字左偏移
--HeaderItemAttr.TextHalign：名字对齐方式，left,center,right
--HeaderItemAttr.SubItem：true-则不能改变宽度；false-则可以改变宽度
--HeaderItemAttr.IncludeNext:true-包括下一个HeaderItem，下一个HeaderItem的宽度将并入此HeaderItem

-----------------------控件外部函数----------------------
--设置HeaderItem的排序
--sortState:-1-降序；0-图标不可见；1-升序
--IsFireEvent:是否触发OnHeaderItemClick事件
function HeaderItem_SetItemSortState(HeaderItemObj, sortState, IsFireEvent)
	HeaderItemObj:SetSortState(sortState)
	if IsFireEvent == true then
		HeaderItemObj:FireExtEvent("OnHeaderItemClick")
	end
end

--获得对象的宽度和高度
function HeaderItem_GetItemSize(HeaderItemObj)
	local HeaderItemAttr = HeaderItemObj:GetAttribute()
	return HeaderItemAttr.ItemWidth, HeaderItemAttr.ItemHeight
end

--设置状态
--newState:状态：0-普通；1-按下；2-不可用；3-悬浮；4-拖动
function HeaderItem_SetItemState(HeaderItemObj, newState)
    local HeaderItemAttr = HeaderItemObj:GetAttribute()	
    local HeaderItemBkgObj = HeaderItemObj:GetControlObject("headeritem.bkg")
	--获得前一个Item及后一个Item
	local HeaderObj = HeaderItemObj:GetOwnerControl()
	local HeaderAttr = HeaderObj:GetAttribute()
	local PreHeaderItemObj = nil
	local NextHeaderItemObj = nil
	if HeaderItemAttr.ItemCount ~= nil then
		PreHeaderItemObj = ownercontrolattr.HeaderItemList[HeaderItemAttr.ItemIndex - 1]
		NextHeaderItemObj = ownercontrolattr.HeaderItemList[HeaderItemAttr.ItemIndex + 1]
	end
	
	--更改背景纹理
	if HeaderItemBkgObj then
		HeaderItemAttr.ControlState = newState
		--普通状态
	    if newState == 0 then
		    if HeaderItemAttr.NormalBkgID then
			    HeaderItemBkgObj:SetTextureID(HeaderItemAttr.NormalBkgID)
			end
			--HeaderItemAttr.ControlState = newState
			if PreHeaderItemObj ~= nil then
				local PreHeaderItemAttr = PreHeaderItemObj:GetAttribute()
				if PreHeaderItemAttr then
					if PreHeaderItemAttr.SubItem then
						PreHeaderItemObj:SetState(0)
					end
				end
			end
			if NextHeaderItemObj ~= nil then
				local NextHeaderItemAttr = NextHeaderItemObj:GetAttribute()
				if NextHeaderItemAttr then
					if HeaderItemAttr.SubItem then
						if NextHeaderItemAttr.ControlState ~= 0 then
							NextHeaderItemObj:SetState(0)
						end
					end
				end
			end
		--按下状态
		elseif newState == 1 then
		    if HeaderItemAttr.DownBkgID then
			    HeaderItemBkgObj:SetTextureID(HeaderItemAttr.DownBkgID)
			end
			--HeaderItemAttr.ControlState = newState
		--不可用状态
		elseif newState == 2 then
		    if HeaderItemAttr.DisableBkgID then
			    HeaderItemBkgObj:SetTextureID(HeaderItemAttr.DisableBkgID)
			end
			--HeaderItemAttr.ControlState = newState
		--悬浮状态
		elseif newState == 3 then
		    if HeaderItemAttr.HoverBkgID then
			    HeaderItemBkgObj:SetTextureID(HeaderItemAttr.HoverBkgID)
			end	
			--HeaderItemAttr.ControlState = newState
			if PreHeaderItemObj ~= nil then
				local PreHeaderItemAttr = PreHeaderItemObj:GetAttribute()
				if PreHeaderItemAttr then
					if PreHeaderItemAttr.SubItem then
						PreHeaderItemObj:SetState(3)
					end
				end
			end
			if NextHeaderItemObj ~= nil then
				local NextHeaderItemAttr = NextHeaderItemObj:GetAttribute()
				if NextHeaderItemAttr then
					if HeaderItemAttr.SubItem then
						if NextHeaderItemAttr.ControlState ~= 3 then
							NextHeaderItemObj:SetState(3)
						end
					end
				end
			end
		--拖动状态
		elseif newState == 4 then -- 拖动
			if HeaderItemAttr.ChangeBkgID then
			    HeaderItemBkgObj:SetTextureID(HeaderItemAttr.ChangeBkgID)
			end
			--HeaderItemAttr.ControlState = newState
			if PreHeaderItemObj ~= nil then
				local PreHeaderItemAttr = PreHeaderItemObj:GetAttribute()
				if PreHeaderItemAttr then
					if PreHeaderItemAttr.SubItem then
						PreHeaderItemObj:SetState(4)
					end
				end
			end
		end
	end	
end

--设置排序图标
--sortState:-1-降序；0-图标不可见；1-升序
function HeaderItem_SetSortState(HeaderItemObj, sortState)
	local HeaderItemAttr = HeaderItemObj:GetAttribute()
	
	--判断是否显示排序图标
	if HeaderItemAttr.ShowSortIcon ~= true then
		return
	end
	
	local HeaderItemSortIconObj = HeaderItemObj:GetControlObject("headeritem.sorticon")
	
	if HeaderItemSortIconObj then
		if sortState == -1 then --降序 
			if HeaderItemAttr.DescendIconID then
				HeaderItemSortIconObj:SetResID(HeaderItemAttr.DescendIconID)
				HeaderItemSortIconObj:SetVisible(true)
				HeaderItemSortIconObj:SetChildrenVisible(true)
			end 
		elseif sortState == 0 then --不可见
			HeaderItemSortIconObj:SetVisible(false)
			HeaderItemSortIconObj:SetChildrenVisible(false)
		elseif sortState == 1 then --升序
			if HeaderItemAttr.AscendIconID then
				HeaderItemSortIconObj:SetResID(HeaderItemAttr.AscendIconID)
				HeaderItemSortIconObj:SetVisible(true)
				HeaderItemSortIconObj:SetChildrenVisible(true)
			end 
		end
	end 
	HeaderItemAttr.SortState = sortState
end

--获得排序状态
--返回值：-1-降序；0-图标不可见；1-升序
function HeaderItem_GetSortState(HeaderItemObj)
	local HeaderItemAttr = HeaderItemObj:GetAttribute()
	return HeaderItemAttr.SortState
end

--添加用户自定义对象
--UserObj:自定义对象
--left, top, right, bottom:相对于表头Item的坐标
function HeaderItem_AddUserObj(HeaderItemObj, UserObj, left, top, right, bottom)
	local HeaderItemBkgObj = HeaderItemObj:GetControlObject("headeritem.bkg")
	HeaderItemBkgObj:AddChild(UserObj)
	UserObj:SetObjPos(left, top, right, bottom)
end

--删除用户自定义对象
--UserObj:自定义对象
function HeaderItem_RemoveUserObj(HeaderItemObj, UserObj)
	if UserObj then
		local HeaderItemBkgObj = HeaderItemObj:GetControlObject("headeritem.bkg")
		
		local bIsControlRet = UserObj:IsControl()
		if true == bIsControlRet then
			local bIsChildRet = HeaderItemBkgObj:IsChild(UserObj)
			if true == bIsChildRet then
				HeaderItemBkgObj:RemoveChild(UserObj)
			end 
		end 
	end
end



-----------------------控件事件函数-----------------------
--控件绑定事件
function HeaderItem_OnBind(HeaderItemObj)
	local HeaderItemAttr = HeaderItemObj:GetAttribute()
	--设置名字
	HeaderItem_SetItemText(HeaderItemObj, HeaderItemAttr.Text)
	--是否显示分割线
	if HeaderItemAttr.ShowSplitter == true then
		HeaderItem_SetSplitterVisible(HeaderItemObj, true)
	else
		HeaderItem_SetSplitterVisible(HeaderItemObj, false)
	end
end

--控件初始化事件
function HeaderItem_OnInitControl(HeaderItemObj)
	HeaderItemObj:SetDefaultRedirect("control")
	local HeaderItemAttr = HeaderItemObj:GetAttribute()
	
	--属性
	HeaderItemAttr.IsLButtonDown = false --鼠标左键是否按下并且处理可拖动状态
	HeaderItemAttr.SortState = 0 --排序状态：-1-降序；0-图标不可见；1-升序
	
	--设置背景
	local HeaderItemBkgObj = HeaderItemObj:GetControlObject("headeritem.bkg")
	HeaderItemBkgObj:SetTextureID(HeaderItemAttr.NormalBkgID)	
	--设置分割线
	local HeaderItemSplitterObj = HeaderItemObj:GetControlObject("headeritem.splitter")
	HeaderItemSplitterObj:SetResID(HeaderItemAttr.SplitterResId)
	--设置字体及颜色
	local HeaderItemTextObj = HeaderItemObj:GetControlObject("headeritem.text")
	HeaderItemTextObj:SetTextFontResID(HeaderItemAttr.TextFont)
	HeaderItemTextObj:SetTextColorResID(HeaderItemAttr.TextColor)
	
	--调整各子对象的位置
	HeaderItem_AdjustChildPos(HeaderItemObj)
end

--控件位置改变事件
function HeaderItem_OnPosChange(HeaderItemObj)
	
end

--控件鼠标左键按下事件
function HeaderItem_OnLButtonDown(HeaderItemObj)
	local HeaderItemAttr = HeaderItemObj:GetAttribute()
	
	local CursorId = HeaderItemObj:GetCursorID()
	if CursorId == "IDC_SIZEWE" then --改变大小
		HeaderItemAttr.IsLButtonDown = true
		HeaderItemObj:SetCaptureMouse(true)
	else
		if HeaderItemAttr.Enable then
			local sortState = HeaderItemAttr.SortState
			if sortState == -1 then
				HeaderItemObj:SetItemState(1)
				HeaderItem_SetSortState(HeaderItemObj, 1)
			elseif sortState == 0 then
				HeaderItemObj:SetItemState(1)
				HeaderItem_SetSortState(HeaderItemObj, -1)
			elseif sortState == 1 then
				HeaderItemObj:SetItemState(1)
				HeaderItem_SetSortState(HeaderItemObj, -1)
			else
				HeaderItemObj:SetItemState(1)
				HeaderItem_SetSortState(HeaderItemObj, 0)
			end
			HeaderItemObj:SetCaptureMouse(true)
		end   
	end
end

--控件鼠标左键弹起事件
function HeaderItem_OnLButtonUp(HeaderItemObj)
	local HeaderItemAttr = HeaderItemObj:GetAttribute()
	
	if HeaderItemAttr.Enable then
		if HeaderItemAttr.ControlState == 1 then
			HeaderItemObj:FireExtEvent("OnHeaderItemClick")
			HeaderItemObj:SetItemState(0)
		end 
	end 
	
	HeaderItemAttr.IsLButtonDown = false
	HeaderItemObj:SetCaptureMouse(false)
	
	local HeaderObj = HeaderItemObj:GetOwnerControl()
	local HeaderAttr = HeaderObj:GetAttribute()
	
	HeaderAttr.IsMove = false
	
	local TheHeaderItemObj = HeaderAttr.HeaderItemList[HeaderAttr.ExtendItemIndex]
	if TheHeaderItemObj then
		TheHeaderItemObj:SetItemState(0)
	end 
end

--控件鼠标右键弹起事件
function HeaderItem_OnRButtonUp(HeaderItemObj)
	HeaderItemObj:RouteToFather()
end

--控件鼠标移动事件
function HeaderItem_OnMouseMove(HeaderItemObj, x, y)
	local HeaderItemAttr = HeaderItemObj:GetAttribute()
	--Header对象
	local HeaderObj = HeaderItemObj:GetOwnerControl()
	local HeaderAttr = HeaderObj:GetAttribute()
	
	local IsSelf = false --标志是否为当前Item宽度改变
	--如果为鼠标在此Item后10像素到下个Item前10像素之间
	if x > HeaderItemAttr.ItemWidth - 10 then
		if not HeaderItemAttr.SubItem then --此Item的宽度可以改变
			HeaderItemObj:SetCursorID("IDC_SIZEWE")
			if HeaderItemAttr.Enable then
				if HeaderItemAttr.ControlState == 0 then
					HeaderItemObj:SetItemState(3)
				end 
			end
			IsSelf = true
		else --此Item的宽度不可以改变
			HeaderItemObj:SetCursorID("IDC_ARROW")
			if HeaderItemAttr.Enable then
				if HeaderItemAttr.ControlState == 0 then
					HeaderItemObj:SetItemState(3)
				end 
			end
		end
	elseif 10 > x then --如果为鼠标在此Item前10个像素内
		local PreHeaderItemObj = HeaderAttr.HeaderItemList[HeaderItemAttr.ItemIndex - 1]
		if PreHeaderItemObj then
			local PreHeaderItemAttr = PreHeaderItemObj:GetAttribute()
			if not PreHeaderItemAttr.SubItem then --前一Item可以改变大小
				HeaderItemObj:SetCursorID("IDC_SIZEWE")
				if PreHeaderItemAttr.Enable then
					if PreHeaderItemAttr.ControlState == 0 then
						PreHeaderItemObj:SetItemState(3)
					end 
				end 
				if HeaderItemAttr.Enable then
					if HeaderItemAttr.ControlState == 3 then
						HeaderItemObj:SetItemState(0)
					end 
				end 
			else --前一Item不可以改变大小
				HeaderItemObj:SetCursorID("IDC_ARROW")
				if HeaderItemAttr.Enable then
					if HeaderItemAttr.ControlState == 0 then
						HeaderItemObj:SetItemState(3)
					end 
				end 
			end
		end 
		-- if HeaderItemAttr.Enable and PreHeaderItemAttr ~= nil and not PreHeaderItemAttr.SubItem then
			-- if HeaderItemAttr.ControlState == 3 then
				-- HeaderItemObj:SetState(0)
			-- end
		-- end
	elseif HeaderAttr.IsMove == false then --其他情况
		HeaderItemObj:SetCursorID("IDC_ARROW")
		if HeaderItemAttr.Enable then
			if HeaderItemAttr.ControlState == 0 then
				HeaderItemObj:SetItemState(3)
			end 
		end 
		local PreHeaderItemObj = HeaderAttr.HeaderItemList[HeaderItemAttr.ItemIndex - 1]
		if PreHeaderItemObj then
			local PreHeaderItemAttr = PreHeaderItemObj:GetAttribute()
			if not PreHeaderItemAttr.SubItem then
				if PreHeaderItemAttr.Enable then
					if PreHeaderItemAttr.ControlState == 3 then
						PreHeaderItemObj:SetItemState(0)
					end 
				end 
			end 
		end
	end
	
	--获得鼠标距Header左边界的距离
	local ActualX = 0
	for TheItemIndex, TheHeaderItemObj in pairs(HeaderAttr.HeaderItemList) do
		local TheHeaderItemAttr = TheHeaderItemObj:GetAttribute()
		if TheItemIndex == HeaderItemAttr.ItemIndex then
			break
		end
		ActualX = ActualX + TheHeaderItemAttr.ItemWidth
	end 
	--判断并处理拖动的情况	
	if HeaderItemAttr.IsLButtonDown then
		if HeaderAttr.IsMove == false then
			HeaderAttr.ExtendItemIndex = HeaderItemAttr.ItemIndex --存储当前ItemIndex
			if IsSelf then --当前对象宽度改变
				HeaderItemObj:SetItemState(4)
			else --前一个对象宽度改变
				HeaderAttr.ExtendItemIndex = HeaderItemAttr.ItemIndex - 1
				local PreHeaderItemObj = HeaderAttr.HeaderItemList[HeaderItemAttr.ItemIndex - 1]
				if PreHeaderItemObj then
					local PreHeaderItemAttr = PreHeaderItemObj:GetAttribute()
					PreHeaderItemObj:SetItemState(4)
				end 
			end
		end
		HeaderAttr.IsMove = true
		--HeaderObj:MoveHeader(ActualX + x)
		HeaderItemObj:FireExtEvent("OnHeaderItemWidthChanged", ActualX + x)
	end
end

function HeaderItem_OnMouseWheel(HeaderItemObj)

end

--控件鼠标离开事件
function HeaderItem_OnMouseLeave(HeaderItemObj)
	local HeaderItemAttr = HeaderItemObj:GetAttribute()
	if HeaderItemAttr.ControlState == 3 then
		HeaderItemObj:SetItemState(0)
	else
		local HeaderObj = HeaderItemObj:GetOwnerControl()
		local HeaderAttr = HeaderObj:GetAttribute()
		local PreHeaderItemObj = HeaderAttr.HeaderItemList[HeaderItemAttr.ItemIndex - 1]
		if PreHeaderItemObj then
			local PreHeaderItemAttr = PreHeaderItemObj:GetAttribute()
			if PreHeaderItemAttr then
				if not PreHeaderItemAttr.SubItem then
					if PreHeaderItemAttr.Enable then
						if PreHeaderItemAttr.ControlState == 3 then
							PreHeaderItemObj:SetItemState(0)
						end 
					end 
				end 
			end 
		end 
	end 
end 



-------------------------控件内部函数------------------------
--设置名字
function HeaderItem_SetItemText(HeaderItemObj, strText)
	if strText ~= nil then
		local HeaderItemTextObj = HeaderItemObj:GetControlObject("headeritem.text")
		HeaderItemTextObj:SetText(strText)
	end 
end 

--设置分割线的可见性
function HeaderItem_SetSplitterVisible(HeaderItemObj, visible)
	local HeaderItemSplitterObj = HeaderItemObj:GetControlObject("headeritem.splitter")
	HeaderItemSplitterObj:SetVisible(visible)
	HeaderItemSplitterObj:SetChildrenVisible(visible)
end 

--更新HeaderItem子对象的位置大小
function HeaderItem_AdjustChildPos(HeaderItemObj)
	local HeaderItemAttr = HeaderItemObj:GetAttribute()
	local HeaderItemTextObj = HeaderItemObj:GetControlObject("headeritem.text")
	local HeaderItemSortIconObj = HeaderItemObj:GetControlObject("headeritem.sorticon")
	--名字文本宽度
	local TextWidth = HeaderItemTextObj:GetTextExtent()
	--名字左偏移
	local TextLeftOffSet = HeaderItemAttr.TextLeftOffSet
	if TextLeftOffSet == nil then
		TextLeftOffSet = 8
	end 
	
	if HeaderItemAttr.TextHalign == "left" then
		HeaderItemTextObj:SetObjPos(TextLeftOffSet, 0, TextLeftOffSet + TextWidth, "father.height")
		HeaderItemSortIconObj:SetObjPos(TextLeftOffSet + TextWidth, 0, TextLeftOffSet + TextWidth + 10, "father.height")
	elseif HeaderItemAttr.TextHalign == "center" then
		--暂不支持
	elseif HeaderItemAttr.TextHalign == "right" then
		--暂不支持
	end
end






--------------------------------------Header相关函数--------------------------------------

------------------------控件外部函数------------------------
--在列表头末尾添加子对象
--HeaderItemObj:子对象
function Header_AppendItem(HeaderObj, HeaderItemObj)
	--插入子对象
	local HeaderBkgObj = HeaderObj:GetControlObject("header.bkg")
	HeaderBkgObj:AddChild(HeaderItemObj)	
	HeaderItemObj:AttachListener("OnHeaderItemClick", true, HeaderItem_OnClick)
	HeaderItemObj:AttachListener("OnHeaderItemWidthChanged", true, HeaderItem_OnWidthChanged)
	--存储子对象
	local HeaderAttr = HeaderObj:GetAttribute()
	table.insert(HeaderAttr.HeaderItemList, HeaderItemObj)
	--设置子对象属性
	local HeaderItemCount = Header_GetHeaderItemCount(HeaderObj)
	local HeaderItemAttr = HeaderItemObj:GetAttribute()
	HeaderItemAttr.ItemIndex = HeaderItemCount
	--调整位置
	Header_AdjustItemPos(HeaderObj, false)
end

--移动列表头Item
function Header_MoveHeader(HeaderObj, pos)
	local HeaderAttr = HeaderObj:GetAttribute()
	local HeaderItemList = HeaderAttr.HeaderItemList
	local leftHeader, topHeader, rightHeader, bottomHeader = HeaderObj:GetObjPos()
	
	local left = 0
	for ItemIndex, HeaderItemObj in pairs(HeaderItemList) do
		local HeaderItemAttr = HeaderItemObj:GetAttribute()
		local width, height = HeaderItemObj:GetItemSize()
		if ItemIndex == HeaderAttr.ExtendItemIndex then --如果为触发此操作的Item则进行下面的操作
			HeaderItemAttr.ItemWidth = pos - left
			--最小宽度限制
			if HeaderItemAttr.ItemWidth < HeaderItemAttr.MinWidth then
				HeaderItemAttr.ItemWidth = HeaderItemAttr.MinWidth
			end
			--最大宽度限制
			if HeaderItemAttr.MaxWidth and HeaderItemAttr.ItemWidth > HeaderItemAttr.MaxWidth then
				HeaderItemAttr.ItemWidth = HeaderItemAttr.MaxWidth
			end 
			break
		end
		left = left + width
	end
	Header_AdjustItemPos(HeaderObj, true)
end

--设置列表头Item的宽度
function Header_SetHeaderItemWidth(HeaderObj, HeaderItemId, ItemWidth, isDrag)
	if HeaderItemId then
		local HeaderItemObj = HeaderObj:GetControlObject(HeaderItemId)
		if HeaderItemObj then
			local HeaderItemAttr = HeaderItemObj:GetAttribute()
			HeaderItemAttr.ItemWidth = ItemWidth
			--最小宽度限制
			if HeaderItemAttr.ItemWidth < HeaderItemAttr.MinWidth then
				HeaderItemAttr.ItemWidth = HeaderItemAttr.MinWidth
			end
			--最大宽度限制
			if HeaderItemAttr.MaxWidth and HeaderItemAttr.ItemWidth > HeaderItemAttr.MaxWidth then
				HeaderItemAttr.ItemWidth = HeaderItemAttr.MaxWidth
			end 
			Header_AdjustItemPos(HeaderObj, isDrag)
		end 
	end
end 

--获得列表关Item的宽度
function Header_GetHeaderItemWidth(HeaderObj, HeaderItemId)
	if HeaderItemId then
		local HeaderItemObj = HeaderObj:GetControlObject(HeaderItemId)
		if HeaderItemObj then
			local HeaderItemAttr = HeaderItemObj:GetAttribute()
			return HeaderItemAttr.ItemWidth
		end 
	end 
end 

--删除某个子对象
function Header_RemoveItem(HeaderObj, TheItemIndex)
	local HeaderAttr = HeaderObj:GetAttribute()
	local HeaderItemList = HeaderAttr.HeaderItemList
	
	for ItemIndex, HeaderItemObj in ipairs(HeaderItemList) do
		if TheItemIndex == ItemIndex then
			HeaderObj:RemoveChild(HeaderItemObj)
			table.remove(HeaderItemList, HeaderItemObj)
			break
		end 
	end
end 

--删除所有子对象
function Header_RemoveAllItems(HeaderObj)
	local HeaderAttr = HeaderObj:GetAttribute()
	local HeaderBkgObj = HeaderObj:GetControlObject("header.bkg")
	
	for ItemIndex, HeaderItemObj in pairs(HeaderAttr.HeaderItemList) do
		HeaderBkgObj:RemoveChild(HeaderItemObj)
	end 
	HeaderAttr.HeaderItemList = {}
end 

--获得子对象的宽度及名字距子对象左边界的距离
function Header_GetItemWidth(HeaderObj, TheItemIndex)
	local HeaderAttr = HeaderObj:GetAttribute()
	local HeaderItemList = HeaderAttr.HeaderItemList
	
	for ItemIndex, HeaderItemObj in ipairs(HeaderItemList) do
		if ItemIndex == TheItemIndex then
			local HeaderItemAttr = HeaderItemObj:GetAttribute()
			if HeaderItemAttr.TextHalign == "left" then
				return HeaderItemAttr.ItemWidth, 0
			elseif HeaderItemAttr.TextHalign == "center" then
				
			elseif HeaderItemAttr.TextHalign == "right" then
				
			end 
		end
	end 
end

--获得Header的宽度
function Header_GetHeaderWidth(HeaderObj)
	local HeaderAttr = HeaderObj:GetAttribute()
	local HeaderItemList = HeaderAttr.HeaderItemList
	
	local HeaderWidth = 0 --Header宽度
	for ItemIndex, HeaderItemObj in ipairs(HeaderItemList) do
		local HeaderItemAttr = HeaderItemObj:GetAttribute()
		if HeaderItemAttr.TextHalign == "left" then
			HeaderWidth = HeaderWidth + HeaderItemAttr.ItemWidth
		elseif HeaderItemAttr.TextHalign == "center" then
			
		elseif HeaderItemAttr.TextHalign == "right" then
			
		end 
	end 
	return HeaderWidth
end 

--设置HeaderItem的排序
function Header_SetHeaderItemSortState(HeaderObj, HeaderItemId, sortState, IsFireEvent)
	if HeaderItemId then
		local HeaderItemObj = HeaderObj:GetControlObject(HeaderItemId)
		if HeaderItemObj then
			HeaderItemObj:SetItemSortState(sortState, IsFireEvent)
		end 
	end
end

--添加用户自定义对象到表头Item
--UserObj:自定义对象
--left, top, right, bottom:相对于表头Item的坐标
function Header_AddUserObjToHeaderItem(HeaderObj, HeaderItemId, UserObj, left, top, right, bottom)
	if HeaderItemId then
		local HeaderItemObj = HeaderObj:GetControlObject(HeaderItemId)
		if HeaderItemObj then
			HeaderItemObj:AddUserObj(UserObj, left, top, right, bottom)
		end 
	end
end

--从表头Item中删除用户自定义对象
--UserObj:自定义对象
function Header_RemoveUserObjFromHeaderItem(HeaderObj, HeaderItemId, UserObj)
	if HeaderItemId then
		local HeaderItemObj = HeaderObj:GetControlObject(HeaderItemId)
		if HeaderItemObj then
			HeaderItemObj:RemoveUserObj(UserObj)
		end 
	end
end



-------------------------控件事件函数------------------------
function Header_OnInitControl(HeaderObj)
	local HeaderAttr = HeaderObj:GetAttribute()
	
	--属性定义
	HeaderAttr.HeaderItemList = {} --存储子对象的列表{HeaderItemObj1,HeaderItemObj1,...}
end

function Header_OnPosChange(HeaderObj)
	--Header_AdjustItemPos(HeaderObj, false)
end

--表头右键弹起事件
function Header_OnRButtonUp(HeaderObj, x, y, flags)
	HeaderObj:FireExtEvent("OnHeaderMouseEvent", x, y, flags)
end

-- 
function Header_OnMouse(HeaderObj)

end

-------------------------控件内部函数-------------------------
--列表头子对象单击事件
function HeaderItem_OnClick(HeaderItemObj)
	local HeaderObj = HeaderItemObj:GetOwnerControl()
	local ItemIndex = Header_GetItemIndexByObj(HeaderObj, HeaderItemObj)
	if ItemIndex ~= nil then
		Header_SelectItem(HeaderObj, ItemIndex)
	end 
end

--列表头子对象宽度改变事件
function HeaderItem_OnWidthChanged(HeaderItemObj, eventName, pos)
	local HeaderObj = HeaderItemObj:GetOwnerControl()
	HeaderObj:MoveHeader(pos)
end 

--获得子对象总数
function Header_GetHeaderItemCount(HeaderObj)
	local HeaderAttr = HeaderObj:GetAttribute()
	return #HeaderAttr.HeaderItemList
end

--通过HeaderItemObj获得ItemIndex
function Header_GetItemIndexByObj(HeaderObj, HeaderItemObj)
	local HeaderAttr = HeaderObj:GetAttribute()
	local HeaderItemObjId = HeaderItemObj:GetID()
	local ItemIndex = nil
	for i = 1, #HeaderAttr.HeaderItemList do
		if HeaderItemObjId == HeaderAttr.HeaderItemList[i]:GetID() then
			ItemIndex = i
			return ItemIndex
		end
	end 
end 

--设置选中
function Header_SelectItem(HeaderObj, ItemIndex)
	local HeaderAttr = HeaderObj:GetAttribute()
	local HeaderItemList = HeaderAttr.HeaderItemList
	for i = 1, #HeaderItemList do
		if i ~= ItemIndex then
			HeaderItemList[i]:SetSortState(0)
		end
	end 
	
	local HeaderItemObj = HeaderItemList[ItemIndex]
	local HeaderItemAttr = HeaderItemObj:GetAttribute()
	local HeaderItemId = HeaderItemObj:GetID()
	HeaderObj:FireExtEvent("OnSelChanged", HeaderItemId, HeaderItemAttr.SortState)
end

--调整子对象位置
--isDrag:是否为拖拽改变大小
function Header_AdjustItemPos(HeaderObj, isDrag)
	local HeaderAttr = HeaderObj:GetAttribute()
    if #HeaderAttr.HeaderItemList < 1 then
		return 
	end

	local leftHeader, topHeader, rightHeader, bottomHeader = HeaderObj:GetObjPos()
	-- LBPrint("Header_AdjustItemPos: leftHeader = "..leftHeader..",topHeader = "..topHeader..",rightHeader = "..rightHeader..",bottomHeader = "..bottomHeader)
	-- if isDrag == nil then
		-- isDrag = true
	-- end
	
	local left = HeaderAttr.LeftBegin
	local HeaderItemList = HeaderAttr.HeaderItemList
	local HeaderItemIndex = Header_GetHeaderItemCount(HeaderObj)
	-- LBPrint("Header_AdjustItemPos: HeaderItemIndex = "..tostring(HeaderItemIndex))
	
	for i = 1, #HeaderAttr.HeaderItemList do
		local HeaderItemObj = HeaderItemList[i]
		local HeaderItemAttr = HeaderItemObj:GetAttribute()
		local width, height = HeaderItemObj:GetItemSize()
		if height == nil then
			height = bottomHeader - topHeader
		end 
		-- LBPrint("Header_AdjustItemPos: i = "..i..",left = "..left..",width = "..width..",height = "..height)
		
		--HeaderItemAttr.bTail = false
		HeaderItemObj:SetObjPos(left, bottomHeader - topHeader - height, left + width, bottomHeader - topHeader)
		if i == HeaderItemIndex then --最后一个有特殊待遇
			if (left + width) < (rightHeader - leftHeader) then
			    HeaderItemObj:SetObjPos(left, bottomHeader - topHeader - height, rightHeader - leftHeader, bottomHeader - topHeader)
            end					
		end
			    
		left = left + width
	end
	HeaderObj:FireExtEvent("OnItemPosChanged", isDrag)
end




--------------------------------------ListBox相关函数--------------------------------------
-------------------------控件外部函数------------------------
--获得TableView控件
function ListBox_GetTableViewObj(ListBoxObj)
	return ListBoxObj:GetControlObject("listbox.tableview")
end 

--设置DataSource与DataConverter，此函数应该最早调用
function ListBox_SetDataSourceAndDataConverter(ListBoxObj, DataSource, DataConverter)
	--设置TableView的DataSource和DataConverter
	local TableViewObj = ListBox_GetTableViewObj(ListBoxObj)
	TableViewObj:SetDataSourceAndDataConverter(DataSource, DataConverter)
end

--获得DataSource
--返回值：DataSource
function ListBox_GetDataSource(ListBoxObj)
	local TableViewObj = ListBox_GetTableViewObj(ListBoxObj)
	return TableViewObj:GetDataSource()
end

--获得DataConverter
--返回值：DataConverter
function ListBox_GetDataConverter(ListBoxObj)
	local TableViewObj = ListBox_GetTableViewObj(ListBoxObj)
	return TableViewObj:GetDataConverter()
end

--重新载入数据：更新视图相关属性，刷新视图及更新滚动条
--OperationType:引起更新的动作（可自己定义，与DataConverter配合使用），TableView刷新滚动条时传下面这个：
--	ScrollChange:滚动条变化
--VisibleItemBeginIndex,VisibleItemEndIndex:可见节点范围
--InhibitRefreshTableView:是否禁止刷新列表
--返回值：0-重新载入数据成功；1-重新载入数据失败
function ListBox_ReloadData(ListBoxObj, OperationType, VisibleItemBeginIndex, VisibleItemEndIndex)
	local TableViewObj = ListBox_GetTableViewObj(ListBoxObj)
	TableViewObj:ReloadData(OperationType, VisibleItemBeginIndex, VisibleItemEndIndex)
end 

--获得节点总数
function ListBox_GetItemCount(ListBoxObj)
	local TableViewObj = ListBox_GetTableViewObj(ListBoxObj)
	return TableViewObj:GetItemCount()
end

--清除所有节点对象的数据（暂时只是把所有可见对象设为不可见，不会删除对象）
function ListBox_ClearAllItems(ListBoxObj)
	local TableViewObj = ListBox_GetTableViewObj(ListBoxObj)
	TableViewObj:ClearAllItems()
end

--清除所有对象
function ListBox_RemoveAllItems(ListBoxObj)
	local TableViewObj = ListBox_GetTableViewObj(ListBoxObj)
	TableViewObj:RemoveAllItems()
end

--选中所有节点
function ListBox_SelectAllItems(ListBoxObj)
	local TableViewObj = ListBox_GetTableViewObj(ListBoxObj)
	TableViewObj:SelectAllItems()
end

--取消所有选中
function ListBox_UnSelectAllItems(ListBoxObj)
	local TableViewObj = ListBox_GetTableViewObj(ListBoxObj)
	TableViewObj:UnSelectAllItems()
end

--排他性选中某些节点
--ItemIndexList:节点ItemIndex列表
function ListBox_ExclusiveSelectItem(ListBoxObj, ItemIndexList)
	local TableViewObj = ListBox_GetTableViewObj(ListBoxObj)
	TableViewObj:ExclusiveSelectItem(ItemIndexList)
end 

--通过索引获得可见节点对象
function ListBox_GetItemObjByIndex(ListBoxObj, ItemIndex)
	local TableViewObj = ListBox_GetTableViewObj(ListBoxObj)
	return TableViewObj:GetItemObjByIndex(ItemIndex)
end

--通过节点对象ID获得节点索引
function ListBox_GetItemIndexByObjId(ListBoxObj, ItemObjId)
	local TableViewObj = ListBox_GetTableViewObj(ListBoxObj)
	return TableViewObj:GetItemIndexByObjId(ItemObjId)
end 

--获得视图里所有对象列表
function ListBox_GetAllItemObj(ListBoxObj)
	local TableViewObj = ListBox_GetTableViewObj(ListBoxObj)
	return TableViewObj:GetAllItemObj()
end

--获得视图里对象的位置
function ListBox_GetItemObjPos(ListBoxObj, ItemIndex)
	local TableViewObj = ListBox_GetTableViewObj(ListBoxObj)
	local itemLeft, itemTop, itemRight, itemBottom = TableViewObj:GetItemObjPos(ItemIndex)
	if itemLeft ~= nil then
		local viewLeft, viewTop, viewRight, viewBottom = TableViewObj:GetObjPos()
		return itemLeft + viewLeft, itemTop + viewTop, itemRight + viewLeft, itemBottom + viewTop
	end 
end 

--获得所有节点的总高度
function ListBox_GetTotalItemHeight(ListBoxObj)
	local TableViewObj = ListBox_GetTableViewObj(ListBoxObj)
	return TableViewObj:GetTotalItemHeight()
end 

--设置索引节点的高度
function ListBox_SetItemHeightByIndex(ListBoxObj, ItemIndex, height)
	local TableViewObj = ListBox_GetTableViewObj(ListBoxObj)
	TableViewObj:SetItemHeightByIndex(ItemIndex, height)
end

--设置索引节点的宽度
function ListBox_SetItemWidthByIndex(ListBoxObj, ItemIndex, width)
	local TableViewObj = ListBox_GetTableViewObj(ListBoxObj)
	TableViewObj:SetItemWidthByIndex(ItemIndex, width)
end

--设置当前视图节点的宽度最大值
function ListBox_SetItemMaxWidth(ListBoxObj, maxWidth)
	local TableViewObj = ListBox_GetTableViewObj(ListBoxObj)
	TableViewObj:SetItemMaxWidth(maxWidth)
end

--滚动条：更新滚动条
--VisibleItemBeginIndex,VisibleItemEndIndex:可见节点范围
function ListBox_UpdateScrollInfo(ListBoxObj, VisibleItemBeginIndex, VisibleItemEndIndex)
	local TableViewObj = ListBox_GetTableViewObj(ListBoxObj)
	TableViewObj:UpdateScrollInfo(VisibleItemBeginIndex, VisibleItemEndIndex)
end

--设置滚动条位置使节点对象完全可见
function ListBox_SetItemVisibleCompletely(ListBoxObj, ItemIndex)
	local TableViewObj = ListBox_GetTableViewObj(ListBoxObj)
	TableViewObj:SetItemVisibleCompletely(ItemIndex)
end

--获得当前视图中垂直滚动条的位置
function ListBox_GetVScrollPos(ListBoxObj)
	local TableViewObj = ListBox_GetTableViewObj(ListBoxObj)
	return TableViewObj:GetVScrollPos()
end 

--设置视图中垂直滚动条的位置
--VScrollPos:滚动条的位置，home，0-最顶；end-最底；其他具体数值，超过按最大
--RefreshView:是否刷新视图
function ListBox_SetVScrollPos(ListBoxObj, VScrollPos, RefreshView)
	local TableViewObj = ListBox_GetTableViewObj(ListBoxObj)
	TableViewObj:SetVScrollPos(VScrollPos, RefreshView)
end

--获得当前视图中水平滚动条的位置
function ListBox_GetHScrollPos(ListBoxObj)
	local TableViewObj = ListBox_GetTableViewObj(ListBoxObj)
	return TableViewObj:GetHScrollPos()
end 

--获得当前视图显示节点的索引范围
--返回值：第一个显示节点索引，最后一个显示节点索引
function ListBox_GetVisibleItemRange(ListBoxObj)
	local TableViewObj = ListBox_GetTableViewObj(ListBoxObj)
	return TableViewObj:GetVisibleItemRange()
end 

--设置滚动条的可见性
--ScrollType:1-水平滚动条；2-垂直滚动条
function ListBox_SetScrollVisible(ListBoxObj, ScrollType, Visible)
	local TableViewObj = ListBox_GetTableViewObj(ListBoxObj)
	return TableViewObj:SetScrollVisible(ScrollType, Visible)
end

--获得滚动条的可见性
--返回值：水平滚动条可见性，垂直滚动条可见性
function ListBox_GetScrollVisible(ListBoxObj)
	local TableViewObj = ListBox_GetTableViewObj(ListBoxObj)
	return TableViewObj:GetScrollVisible()
end

--获得Shift多选时第一个节点
function ListBox_GetShiftStartItemIndex(ListBoxObj)
	local TableViewObj = ListBox_GetTableViewObj(ListBoxObj)
	return TableViewObj:GetShiftStartItemIndex()
end 

--设置Shift多选时第一个节点
function ListBox_SetShiftStartItemIndex(ListBoxObj, ItemIndex)
	local TableViewObj = ListBox_GetTableViewObj(ListBoxObj)
	TableViewObj:SetShiftStartItemIndex(ItemIndex)
end 

--释放拖拽
function ListBox_ReleaseDrag(ListBoxObj)
	local TableViewObj = ListBox_GetTableViewObj(ListBoxObj)
	TableViewObj:ReleaseDrag()
end

--在表头尾插入列
--HeaderItemInfo:{"HeaderItemId":""(唯一ID), "ItemWidth":int(宽度), "Text":""(列名), "TextLeftOffSet":int(名字左偏移), "TextHalign":"left,center,right"(列名对齐方式), "SubItem":bool(是否不可拖动), "MaxSize":int(最大宽度), "MiniSize":int(最小宽度), "ShowSplitter":bool(是否显示分割线), "ShowSortIcon":bool(是否显示排序图标),"IncludeNext":bool(是否包含下一个HeaderItem),"SortProperty":int(排序属性，与DK一致)}
function ListBox_InsertColumn(ListBoxObj, HeaderItemInfo)
	local ListBoxAttr = ListBoxObj:GetAttribute()
	table.insert(ListBoxAttr.HeaderInfoList, HeaderItemInfo)
end

--删除列
function ListBox_RemoveColumn(ListBoxObj, HeaderItemId)
	local ListBoxAttr = ListBoxObj:GetAttribute()
	local ListBoxHeaderObj = ListBoxObj:GetControlObject("listbox.header")
	
	for ItemIndex, HeaderItemInfo in ipairs(ListBoxAttr.HeaderInfoList) do
		if HeaderItemId == HeaderItemInfo.HeaderItemId then
			ListBoxHeaderObj:RemoveItem(ItemIndex)
			table.remove(ListBoxAttr.HeaderInfoList, ItemIndex)
			break
		end
	end 
end

--删除所有列
function ListBox_RemoveAllColumn(ListBoxObj)
	local ListBoxAttr = ListBoxObj:GetAttribute()
	local ListBoxHeaderObj = ListBoxObj:GetControlObject("listbox.header")
	
	ListBoxHeaderObj:RemoveAllItems()
	ListBoxAttr.HeaderInfoList = {}
end 

--重新设置列表头
function ListBox_ReloadHeader(ListBoxObj)
	local ListBoxAttr = ListBoxObj:GetAttribute()
	ListBoxAttr.HeaderInited = false
	
	--清除列表的所有子对象
	local ListBoxHeaderObj = ListBoxObj:GetControlObject("listbox.header")
	ListBoxHeaderObj:RemoveAllItems()
	
	--初始化Header
	for i, HeaderItemInfo in pairs(ListBoxAttr.HeaderInfoList) do
		--暂时设置最后一列的大小不可以手动改变
		if i == #ListBoxAttr.HeaderInfoList then
			HeaderItemInfo.SubItem = true
		end
		ListBox_AddItemToHeader(ListBoxObj, ListBoxHeaderObj, HeaderItemInfo)
	end 
	--更新ListBox中存储的表头信息
	ListBox_UpdateHeaderInfo(ListBoxObj)
	
	ListBoxAttr.HeaderInited = true
end

--设置表头的可见性
function ListBox_SetHeaderVisible(ListBoxObj, Visible)
	local ListBoxAttr = ListBoxObj:GetAttribute()
	-- if Visible == ListBoxAttr.ShowHeader then
		-- return
	-- end
	
	local TableViewObj = ListBox_GetTableViewObj(ListBoxObj)
	local ListBoxHeaderObj = ListBoxObj:GetControlObject("listbox.header")
	if Visible == true then
		ListBoxHeaderObj:SetObjPos(ListBoxAttr.HeaderToLeftDis, "0", "father.width", "25")
		ListBoxHeaderObj:SetVisible(true)
		ListBoxHeaderObj:SetChildrenVisible(true)
		TableViewObj:SetObjPos("0", "25", "father.width", "father.height")
	else
		--ListBoxHeaderObj:SetObjPos("0", "0", "father.width", "25")
		ListBoxHeaderObj:SetVisible(false)
		ListBoxHeaderObj:SetChildrenVisible(false)
		TableViewObj:SetObjPos("0", "0", "father.width", "father.height")
	end
	ListBoxAttr.ShowHeader = Visible
	
	--日志
	local headerLeft, headerTop, headerRight, headerBottom = ListBoxHeaderObj:GetObjPos()
	-- LBPrint("ListBox_SetHeaderVisible: headerLeft = "..headerLeft..",headerTop = "..headerTop..",headerRight = "..headerRight..",headerBottom = "..headerBottom)
end

--获得Header的可见性
function ListBox_GetHeaderVisible(ListBoxObj)
	local ListBoxHeaderObj = ListBoxObj:GetControlObject("listbox.header")
	return ListBoxHeaderObj:GetVisible()
end

--获得Header在ListBox中的位置
function ListBox_GetHeaderObjPos(ListBoxObj)
	local ListBoxHeaderObj = ListBoxObj:GetControlObject("listbox.header")
	return ListBoxHeaderObj:GetObjPos()
end 

--获得Header的宽度
function ListBox_GetHeaderWidth(ListBoxObj)
	local ListBoxHeaderObj = ListBoxObj:GetControlObject("listbox.header")
	return ListBoxHeaderObj:GetHeaderWidth()
end 

--设置表头Item的宽度
function ListBox_SetHeaderItemWidth(ListBoxObj, HeaderItemId, ItemWidth, isDrag)
	local ListBoxHeaderObj = ListBoxObj:GetControlObject("listbox.header")
	ListBoxHeaderObj:SetHeaderItemWidth(HeaderItemId, ItemWidth, isDrag)
end 

--获得表头Item的宽度
function ListBox_GetHeaderItemWidth(ListBoxObj, HeaderItemId)
	local ListBoxHeaderObj = ListBoxObj:GetControlObject("listbox.header")
	return ListBoxHeaderObj:GetHeaderItemWidth(HeaderItemId)
end 

--获得排序属性
function ListBox_GetSortProperty(ListBoxObj, HeaderItemId)
	local ListBoxAttr = ListBoxObj:GetAttribute()
	local HeaderInfoList = ListBoxAttr.HeaderInfoList
	
	for Index, HeaderItemInfo in ipairs(HeaderInfoList) do
		if HeaderItemInfo.HeaderItemId == HeaderItemId then
			return HeaderItemInfo.SortProperty
		end 
	end
end 

--通过排序属性获得HeaderItemId,如有多个相同的排序属性，取第一个
function ListBox_GetHeaderItemIdBySortProperty(ListBoxObj, SortProperty)
	local ListBoxAttr = ListBoxObj:GetAttribute()
	local HeaderInfoList = ListBoxAttr.HeaderInfoList
	
	for Index, HeaderItemInfo in ipairs(HeaderInfoList) do
		if HeaderItemInfo.SortProperty == SortProperty then
			return HeaderItemInfo.HeaderItemId
		end 
	end
end 

--设置HeaderItem的排序
function ListBox_SetHeaderItemSortState(ListBoxObj, HeaderItemId, sortState, IsFireEvent)
	local ListBoxHeaderObj = ListBoxObj:GetControlObject("listbox.header")
	ListBoxHeaderObj:SetHeaderItemSortState(HeaderItemId, sortState, IsFireEvent)
end 

--获得列表头所有列的宽度等信息
--返回值：{{"ItemWidth":0},...}
function ListBox_GetHeaderItemInfoList(ListBoxObj)
	local ListBoxAttr = ListBoxObj:GetAttribute()
	local HeaderInfoList = ListBoxAttr.HeaderInfoList
	if HeaderInfoList == nil then
		return
	end
	
	local HeaderItemInfoList = {} --存储信息
	local IncludeNext = false --存储前一个HeaderItem是否包含当前HeaderItem
	for Index, HeaderItemInfo in ipairs(HeaderInfoList) do
		if IncludeNext == true then
			HeaderItemInfoList[Index - 1]["ItemWidth"] = HeaderItemInfoList[Index - 1]["ItemWidth"] + HeaderItemInfo.ItemWidth
		else
			table.insert(HeaderItemInfoList, {ItemWidth = HeaderItemInfo.ItemWidth})
		end
		IncludeNext = HeaderItemInfo.IncludeNext
	end 
	
	return HeaderItemInfoList
end

--添加用户自定义对象到表头Item
--UserObj:自定义对象
--left, top, right, bottom:相对于表头Item的坐标
function ListBox_AddUserObjToHeaderItem(ListBoxObj, HeaderItemId, UserObj, left, top, right, bottom)
	local ListBoxHeaderObj = ListBoxObj:GetControlObject("listbox.header")
	ListBoxHeaderObj:AddUserObjToHeaderItem(HeaderItemId, UserObj, left, top, right, bottom)
end

--从表头Item中删除用户自定义对象
function ListBox_RemoveUserObjFromHeaderItem(ListBoxObj, HeaderItemId, UserObj)
	local ListBoxHeaderObj = ListBoxObj:GetControlObject("listbox.header")
	ListBoxHeaderObj:RemoveUserObjFromHeaderItem(HeaderItemId, UserObj)
end

--获得TableView在ListBox中的位置
function ListBox_GetTableViewObjPos(ListBoxObj)
	local TableViewObj = ListBox_GetTableViewObj(ListBoxObj)
	return TableViewObj:GetObjPos()
end 



-------------------------控件事件函数------------------------
--控件初始化事件
function ListBox_OnInitControl(ListBoxObj)
	local ListBoxAttr = ListBoxObj:GetAttribute()
	
	--属性定义
	ListBoxAttr.HeaderInited = false --true-已经初始化表头
	ListBoxAttr.HeaderInfoList = {} --列表头每个Item信息的列表
	
	--设置TableView的相关属性
	local TableViewObj = ListBox_GetTableViewObj(ListBoxObj)
	local TableViewAttr = TableViewObj:GetAttribute()
	TableViewAttr.iToTopDis = ListBoxAttr.iToTopDis
	TableViewAttr.iToLeftDis = ListBoxAttr.iToLeftDis
	TableViewAttr.iItemSpacing = ListBoxAttr.iItemSpacing
	TableViewAttr.HScrollVisible = ListBoxAttr.HScrollVisible
	TableViewAttr.VScrollVisible = ListBoxAttr.VScrollVisible
	TableViewAttr.VScrollEnable = ListBoxAttr.VScrollEnable
	TableViewAttr.ScrollToMarginDis = ListBoxAttr.ScrollToMarginDis
	
	--判断是否要出现列表头
	if ListBoxAttr.ShowHeader == true then
		ListBox_SetHeaderVisible(ListBoxObj, true)
	end 
	
	--判断是否使用框选
	if ListBoxAttr.useDirectBoxSelect ~= true then
		TableViewObj:SetDirectBoxSelectAttr(false)
	end 
	
	--判断是否只使用单选，不使用Ctrl选及Shift选
	if ListBoxAttr.onlySingleSelect == true then
		TableViewObj:SetSelectMode(true)
	end
	
	if ListBoxAttr.IsCanDrag == true then
		TableViewObj:SetDragMode(true)
	end
end

--控件绑定到对象树事件
function ListBox_OnBind(ListBoxObj)
	local ListBoxAttr = ListBoxObj:GetAttribute()
	local TableViewObj = ListBox_GetTableViewObj(ListBoxObj)
	local TableViewAttr = TableViewObj:GetAttribute()
	
	--设置垂直滚动条 
	TableViewAttr.VScrollWidth = ListBoxAttr.VScrollWidth
	TableViewAttr.VScrollThumbBtnWidth = ListBoxAttr.VScrollThumbBtnWidth
	TableViewAttr.VScrollThumbBtnNor = ListBoxAttr.VScrollThumbBtnNor
	TableViewAttr.VScrollThumbBtnHover = ListBoxAttr.VScrollThumbBtnHover
	TableViewAttr.VScrollThumbBtnDown = ListBoxAttr.VScrollThumbBtnDown
	TableViewAttr.VShowTipInFirst = ListBoxAttr.VShowTipInFirst
	--设置水平滚动条 
	TableViewAttr.VScrollHeight = ListBoxAttr.VScrollHeight
	TableViewAttr.HScrollThumbBtnHeight = ListBoxAttr.HScrollThumbBtnHeight
	TableViewAttr.HScrollThumbBtnNor = ListBoxAttr.HScrollThumbBtnNor
	TableViewAttr.HScrollThumbBtnHover = ListBoxAttr.HScrollThumbBtnHover
	TableViewAttr.HScrollThumbBtnDown = ListBoxAttr.HScrollThumbBtnDown
	TableViewAttr.HShowTipInFirst = ListBoxAttr.HShowTipInFirst
end 

function ListBox_OnPosChange(ListBoxObj, oldLeft, oldTop, oldRight, oldBottom, newLeft, newTop, newRight, newBottom)
	--最小化及复原或大小不变时不作下面的操作
	-- if (oldRight < 0 and oldBottom < 0) or (newRight < 0 and newBottom < 0) then
		-- return
	-- end
	local ListBoxAttr = ListBoxObj:GetAttribute()
	ListBox_SetHeaderVisible(ListBoxObj, ListBoxAttr.ShowHeader)
end

--列表头：列表头项选中改变事件
--HeaderItemId:列ID
--sortState:-1-降序；0-图标不可见；1-升序
function ListBoxHeader_OnSelChanged(ListBoxHeaderObj, eventName, HeaderItemId, sortState)
	local ListBoxObj = ListBoxHeaderObj:GetOwnerControl()
	ListBoxObj:FireExtEvent("OnHeaderItemSelChanged", HeaderItemId, sortState)
end

--列表头：表头Header位置改变事件
--isDrag:是否为拖动引起的改变
function ListBoxHeader_OnItemPosChanged(ListBoxHeaderObj, eventName, isDrag)
	local ListBoxObj = ListBoxHeaderObj:GetOwnerControl()
	local ListBoxAttr = ListBoxObj:GetAttribute()
	
	--如果列表头还未初始化则返回
	if ListBoxAttr.HeaderInited ~= true then
		return
	end
	
	--更新列表头信息
	ListBox_UpdateHeaderInfo(ListBoxObj)
	
	--获得列表头每个子对象的宽度信息
	local GridInfoList = ListBox_GetHeaderItemInfoList(ListBoxObj)
	
	ListBoxObj:FireExtEvent("OnHeaderItemPosChanged", isDrag, GridInfoList)
end

--列表头：表头鼠标事件
function ListBoxHeader_OnHeaderMouseEvent(ListBoxHeaderObj, eventName, x, y, flags)
	local ListBoxObj = ListBoxHeaderObj:GetOwnerControl()
	x, y = CoordinateChildToParent(ListBoxObj, x, y)
	ListBoxObj:FireExtEvent("OnMouseEvent", "OnHeaderMouseEvent", x, y, flags)
end

--TableView：TableView鼠标事件
function TableView_OnMouseEvent(TableViewObj, eventName, mouseEventType, x, y, flags, ItemObj)	
	local ListBoxObj = TableViewObj:GetOwnerControl()
	x, y = CoordinateChildToParent(ListBoxObj, x, y)
	ListBoxObj:FireExtEvent("OnMouseEvent", mouseEventType, x, y, flags, ItemObj)
end 

--TableView：节点对象的各种事件
function TableView_OnItemEvent(TableViewObj, eventName, eventType, UserData, ItemObj)
	local ListBoxObj = TableViewObj:GetOwnerControl()
	ListBoxObj:FireExtEvent("OnItemEvent", eventType, UserData, ItemObj)
end 

--TableView：Shift多选时第一个节点变化事件
function TableView_OnShiftStartItemIndexChange(TableViewObj, OldShiftStartItemIndex, NewShiftStartItemIndex)
	local ListBoxObj = TableViewObj:GetOwnerControl()
	ListBoxObj:FireExtEvent("OnShiftStartItemIndexChange", OldShiftStartItemIndex, NewShiftStartItemIndex)
end 

--TableView：将要更新滚动条事件
function TableView_OnBeginUpdateScrollInfo(TableViewObj, eventName)
	local ListBoxObj = TableViewObj:GetOwnerControl()
	ListBoxObj:FireExtEvent("OnBeginUpdateScrollInfo")
end

--TableView：TableView水平滚动条改变事件
function TableView_OnHScrollChange(TableViewObj, eventName, HScrollCurrentPos)
	-- LBPrint("TableView_OnHScrollChange: HScrollCurrentPos = "..tostring(HScrollCurrentPos))
	local ListBoxObj = TableViewObj:GetOwnerControl()
	local ListBoxHeaderObj = ListBoxObj:GetControlObject("listbox.header")
	ListBoxHeaderAttr = ListBoxHeaderObj:GetAttribute()
	
	ListBoxHeaderAttr.LeftBegin = -HScrollCurrentPos
	ListBoxHeaderObj:AdjustItemPos(false)
	
	ListBoxObj:FireExtEvent("OnHScrollChange", HScrollCurrentPos)
end

--TableView：TableView垂直滚动条改变事件
function TableView_OnVScrollChange(TableViewObj, eventName, VScrollCurrentPos)
	local ListBoxObj = TableViewObj:GetOwnerControl()
	
	ListBoxObj:FireExtEvent("OnVScrollChange", VScrollCurrentPos)
end

--TableView：TableView拖拽事件
function TableView_OnDrag(TableViewObj, eventName, x, y, DragItemObj, ItemIndex)	
	local ListBoxObj = TableViewObj:GetOwnerControl()
	x, y = CoordinateChildToParent(ListBoxObj, x, y)
	ListBoxObj:FireExtEvent("OnDrag", x, y, DragItemObj, ItemIndex)
end 

--TableView：TableView拖拽出TableView事件
function TableView_OnDragOutTableView(TableViewObj, eventName, x, y, DragItemObj)
	local ListBoxObj = TableViewObj:GetOwnerControl()
	x, y = CoordinateChildToParent(ListBoxObj, x, y)
	ListBoxObj:FireExtEvent("OnDragOutTableView", x, y, DragItemObj)
end 

--TableView：TableView拖拽出TableView所在窗口事件
function TableView_OnDragOutHostWnd(TableViewObj, eventName, DragItemObj)
	local ListBoxObj = TableViewObj:GetOwnerControl()
	ListBoxObj:FireExtEvent("OnDragOutHostWnd", DragItemObj)
end 

--TableView：TableView拖拽出TableView并放开鼠标投下的事件
function TableView_OnDropOut(TableViewObj, eventName, x, y, DragItemObj)	
	local ListBoxObj = TableViewObj:GetOwnerControl()
	x, y = CoordinateChildToParent(ListBoxObj, x, y)
	ListBoxObj:FireExtEvent("OnDropOut", x, y, DragItemObj)
end 

--TableView：拖拽完成的事件
function TableView_OnDragFinish(TableViewObj, eventName)	
	local ListBoxObj = TableViewObj:GetOwnerControl()
	ListBoxObj:FireExtEvent("OnDragFinish")
end 



-------------------------控件内部函数------------------------
--更新列表头子对象的信息
function ListBox_UpdateHeaderInfo(ListBoxObj)
	local ListBoxAttr = ListBoxObj:GetAttribute()
	local ListBoxHeaderObj = ListBoxObj:GetControlObject("listbox.header")
	local HeaderInfoList = ListBoxAttr.HeaderInfoList
	
	for ItemIndex, HeaderItemInfo in ipairs(HeaderInfoList) do
		local ItemWidth, textLeftPos = ListBoxHeaderObj:GetItemWidth(ItemIndex)
		HeaderItemInfo.ItemWidth = ItemWidth
		HeaderItemInfo.TextLeftPos = textLeftPos
	end
end

--添加单个对象到列表头Header
function ListBox_AddItemToHeader(ListBoxObj, ListBoxHeaderObj, HeaderItemInfo)
	if HeaderItemInfo.HeaderItemId == nil then
		return
	end
	
	--生成Item
	local headerLeft, headerTop, headerRight, headerBottom = ListBoxHeaderObj:GetObjPos()
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	local HeaderItemObj = objFactory:CreateUIObject(HeaderItemInfo.HeaderItemId, "WHome.ListBox.HeaderItem")
	local HeaderItemAttr = HeaderItemObj:GetAttribute()
	
	local ListBoxAttr = ListBoxObj:GetAttribute()
	--填充各种属性
	HeaderItemAttr.NormalBkgID = ListBoxAttr.HeaderItemNormalBkg
	HeaderItemAttr.HoverBkgID = ListBoxAttr.HeaderItemHoverBkg
	HeaderItemAttr.DownBkgID = ListBoxAttr.HeaderItemDownBkg
	HeaderItemAttr.ChangeBkgID = ListBoxAttr.HeaderItemChangeBkg
	HeaderItemAttr.ItemWidth = HeaderItemInfo.ItemWidth
	HeaderItemAttr.ItemHeight = nil
	HeaderItemAttr.AscendIconID = ListBoxAttr.HeaderItemAscendIcon
	HeaderItemAttr.DescendIconID = ListBoxAttr.HeaderItemDescendIcon
	HeaderItemAttr.SplitterResId = ListBoxAttr.SplitterResId
	HeaderItemAttr.TextFont = ListBoxAttr.TextFont
	HeaderItemAttr.TextColor = ListBoxAttr.TextColor
	HeaderItemAttr.Text = HeaderItemInfo.Text
	HeaderItemAttr.TextLeftOffSet = HeaderItemInfo.TextLeftOffSet
	HeaderItemAttr.TextHalign = HeaderItemInfo.TextHalign
	HeaderItemAttr.MinWidth = HeaderItemInfo.MiniSize
	HeaderItemAttr.MaxWidth = HeaderItemInfo.MaxSize
	HeaderItemAttr.SubItem = HeaderItemInfo.SubItem
	HeaderItemAttr.ShowSplitter = HeaderItemInfo.ShowSplitter
	HeaderItemAttr.ShowSortIcon = HeaderItemInfo.ShowSortIcon
	HeaderItemAttr.IncludeNext = HeaderItemInfo.IncludeNext
	--添加Item到列表头
	ListBoxHeaderObj:AppendItem(HeaderItemObj)
end