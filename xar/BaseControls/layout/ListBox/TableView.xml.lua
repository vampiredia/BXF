-------------TableView控件使用说明-------------
----------------------------------------
--	一、总括：
--	实现一个列表控件有几部分：ListBox，逻辑处理中心；TableView，与逻辑无关的管理显示控件；
--	DataSource，与逻辑有关的数据管理操作中心；DataConverter，行显示管理中心；ListItem，单个行对象控件
--ListBox：管理所有TableView,DataSource,DataConverter，为逻辑处理中心，管理整个列表；
--TableView：作为ListBox的父类，主要用于管理、显示行对象控件，但不参与行对象内部显示细节；
--DataSource：存储、管理、操作数据，不但提供TableView固定的与逻辑无关接口，还提供ListBox,DataConverter与逻辑有关的接口；
--DataConverter：控制单个行对象内部的显示细节；
--ListItem：行对象控件；

----------------------------------------
--	二、标准接口
--不应轻易修改标准接口
--1、TableView
----标准接口详看TableView.xml的接口定义

--2、DataSource
----1)[int] ItemCount = GetItemCount([layoutobj] DataSource) 
----获得节点总数
----ItemCount:节点总数
----DataSource:DataSource

----2)[table] ItemData = GetItemDataByIndex([layoutobj] DataSource, [int] ItemIndex) 
----获得节点数据
----ItemData:节点数据，格式自定，TableView不需要知道格式
----DataSource:DataSource
----ItemIndex:节点索引，从1开始

----3)[int] SelectedItemCount = GetSelectedItemCount([layoutobj] DataSource)
----获取选中节点总数
----SelectedItemCount:选中节点总数
----DataSource:DataSource

----4)[table] SelectedItemIndexList = GetSelectedItemIndexList([layoutobj] DataSource)
----获取所有选中节点
----SelectedItemIndexList:选中节点ItemIndex列表{ItemIndex1,...}
----DataSource:DataSource

----5)[int] result = SelectAllItems([layoutobj] DataSource)
----选中所有节点
----result:0-成功；其他-失败
----DataSource:DataSource

----6)[int] result = UnSelectAllItems([layoutobj] DataSource)
----取消选中所有节点
----result:0-成功；其他-失败
----DataSource:DataSource

----7)[int] result = IsItemSelected([layoutobj] DataSource, [int]ItemIndex)
----判断一个节点是否被选中
----result:0-选中；其他-没选中
----DataSource:DataSource
----ItemIndex:节点索引，从1开始

----8)[int] result = SelectItem([layoutobj] DataSource, [table] ItemIndexList, [string] OperationType)
----选中某些节点
----result:0-成功；其他-失败
----DataSource:DataSource
----ItemIndexList:节点ItemIndex列表
----OperationType:CtrlDown-Ctrl按下；ShiftDown-Shift按下；nil-无其他键按下

----9)[int] result = UnSelectItem([layoutobj] DataSource, [table] ItemIndexList, [string] OperationType)
----取消选中某些节点
----result:0-成功；其他-失败
----DataSource:DataSource
----ItemIndexList:节点ItemIndex列表
----OperationType:CtrlDown-Ctrl按下；ShiftDown-Shift按下；nil-无其他键按下

----10)[int] result = ExclusiveSelectItem([layoutobj] DataSource, [table] ItemIndexList, [string] OperationType)
----排他性选中某些节点
----result:0-成功；其他-失败
----DataSource:DataSource
----ItemIndexList:节点ItemIndex列表
----OperationType:CtrlDown-Ctrl按下；ShiftDown-Shift按下；nil-无其他键按下

----11)[int] result = MoveItem([layoutobj] DataSource, [table] ItemIndexList, [int] TargetItemIndex, [function] CallbackFunc)
----移动节点，按ItemIndexList顺序把节点放在[TargetItemIndex, TargetItemIndex + #ItemIndexList)
----ItemIndexList:移动节点的ItemIndex列表
----TargetItemIndex:目标ItemIndex
----CallbackFunc:回调函数

--3、DataConverter
----1)[int] ItemHeight, [int] ItemWidth = GetItemSize([layoutobj] DataConverter, [int] ItemIndex)
----获取节点的高、宽
----ItemHeight:节点的高
----ItemWidth:节点的宽
----DataConverter:DataConverter
----ItemIndex:节点索引，从1开始

----2)[layoutobj] ItemObj = CreateUIObjectFromData([layoutobj] DataConverter, [string] ItemObjId, [int] ItemIndex, [table]ItemData, [int]OperationType)
----根据数据创建Item对象
----ItemObj:创建的Item对象
----DataConverter:DataConverter
----ItemObjId:对象的ID
----ItemIndex:节点索引，从1开始
----ItemData:节点数据，从DataSource中获取
----OperationType:外界调刷新时传入，如果需使用请配合使用

----3)UpdateUIObjectFromData([layoutobj] DataConverter, [int] ItemIndex, [layoutobj] ItemObj, [table]ItemData, [int]OperationType)
----更新Item对象的显示数据
----DataConverter:DataConverter
----ItemIndex:节点索引，从1开始
----ItemObj:显示节点数据的对象
----ItemData:节点数据，从DataSource中获取
----OperationType:外界调刷新时传入，如果需使用请配合使用

----4)SaveUIObjectState([layoutobj] DataConverter, [int] ItemIndex)
----保存节点的状态属性等信息
----DataConverter:DataConverter
----ItemIndex:节点索引，从1开始

----5)SetItemBkgType([layoutobj] DataConverter, [layoutobj] ItemObj, [int] BkgType)
----节点背景类型
----DataConverter:DataConverter
----ItemObj:显示节点数据的对象
----BkgType:0-无背景；1-选中背景；2-拖拽背景

----6)[int]left, [int] top, [int] right, [int] bottom = GetItemObjPos([layoutobj] DataConverter, [layoutobj] ItemObj)
----获得节点对象的大小位置，用于拖拽框的显示
----DataConverter:DataConverter
----ItemObj:显示节点数据的对象

--3、ListItem
--说明：由于历史原因，ListItem的鼠标事件需要通过自定义事件传给TableView，详见如下：

----1)OnItemMouseEvent
----TableView绑定此事件，ListItem用这个事件把鼠标事件传给TableView
----<OnItemMouseEvent> <!-- Item各种鼠标事件 -->
----	<param>
----		<string /> <!-- 事件类型 -->
----		<int /> <!-- x -->
----		<int /> <!-- y -->
----		<int /> <!-- flags -->
----	</param>
----</OnItemMouseEvent>

--2)OnItemEvent
----TableView绑定此事件但不会处理此事件，它会把这个事件原样传给外部调用者
----<OnItemEvent> <!-- Item各种事件 -->
----	<param>
----		<string /> <!-- 事件类型 -->
----		<table /> <!-- 自定义数据 -->
----	</param>
----</OnItemEvent>

--local --TVPrint = debug.bind(debug.print, "[HQ][TableView]")

---------------------------------------外部调用函数-----------------------------------
--设置DataSource和DataConverter，此为控件最先调用函数
function ViewCtrl_SetDataSourceAndDataConverter(ViewCtrlObj, DataSource, DataConverter)
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	ViewCtrlAttr.DataSource = DataSource
	ViewCtrlAttr.DataConverter = DataConverter
	
	--创建DragItem
	BuildDragItem(ViewCtrlObj)
end

--获得DataSource
--返回值：DataSource
function ViewCtrl_GetDataSource(ViewCtrlObj)
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	return ViewCtrlAttr.DataSource
end

--获得DataConverter
--返回值：DataConverter
function ViewCtrl_GetDataConverter(ViewCtrlObj)
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	return ViewCtrlAttr.DataConverter
end

--设置是否使用框选
function ViewCtrl_SetDirectBoxSelectAttr(ViewCtrlObj, useDirectBoxSelect)
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	ViewCtrlAttr.useDirectBoxSelect = useDirectBoxSelect
end 

--设置选择模式
--onlySingleSelect:true-只使用单选；false-使用单选、多选
function ViewCtrl_SetSelectMode(ViewCtrlObj, onlySingleSelect)
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	ViewCtrlAttr.onlySingleSelect = onlySingleSelect
end 

--获得Shift多选时第一个节点
function ViewCtrl_GetShiftStartItemIndex(ViewCtrlObj)
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	return ViewCtrlAttr.ShiftStartItemIndex
end 

--设置Shift多选时第一个节点
function ViewCtrl_SetShiftStartItemIndex(ViewCtrlObj, ItemIndex)
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	local OldShiftStartItemIndex = ViewCtrlAttr.ShiftStartItemIndex
	ViewCtrlAttr.ShiftStartItemIndex = ItemIndex
	
	--触发ShiftStartItemIndex改变事件
	ViewCtrlObj:FireExtEvent("OnShiftStartItemIndexChange", OldShiftStartItemIndex, ItemIndex)
end 

--重新载入数据：更新视图相关属性，刷新视图及更新滚动条
--OperationType:引起更新的动作（可自己定义，与DataConverter配合使用），TableView刷新滚动条时传下面这个：
--	ScrollChange:滚动条变化
--VisibleItemBeginIndex,VisibleItemEndIndex:可见节点范围
--返回值：0-重新载入数据成功；1-重新载入数据失败
function ViewCtrl_ReloadData(ViewCtrlObj, OperationType, VisibleItemBeginIndex, VisibleItemEndIndex)
	--TVPrint("ViewCtrl_ReloadData: OperationType = "..tostring(OperationType)..",VisibleItemBeginIndex = "..tostring(VisibleItemBeginIndex)..",VisibleItemEndIndex = "..tostring(VisibleItemEndIndex))
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	
	if ViewCtrlAttr.DataSource == nil or ViewCtrlAttr.DataSource.GetItemCount == nil then
		--TVPrint("ViewCtrl_ReloadData: DataSource is not init, return")
		return 1
	end 
	
	--得到总个数
	local ItemCount = ViewCtrlAttr.DataSource:GetItemCount()
	--计算节点总高度（包括第一个节点距顶部距离及节点间的距离）及节点最大宽度（包括节点距左边的距离）
	ViewCtrlAttr.iMaxItemWidth = 0
	ViewCtrlAttr.iItemTotalHeight = ViewCtrlAttr.iToTopDis
	ViewCtrlAttr.ItemHeightList = {} --节点高度列表
	for ItemIndex = 1, ItemCount do
		ViewCtrlAttr.ItemHeightList[ItemIndex], ViewCtrlAttr.ItemWidthList[ItemIndex] = ViewCtrlAttr.DataConverter:GetItemSize(ItemIndex)
		ViewCtrlAttr.iItemTotalHeight = ViewCtrlAttr.iItemTotalHeight + ViewCtrlAttr.ItemHeightList[ItemIndex] + ViewCtrlAttr.iItemSpacing
		if ViewCtrlAttr.iMaxItemWidth < ViewCtrlAttr.ItemWidthList[ItemIndex] then
			ViewCtrlAttr.iMaxItemWidth = ViewCtrlAttr.ItemWidthList[ItemIndex]
		end
	end 
	ViewCtrlAttr.iMaxItemWidth = ViewCtrlAttr.iMaxItemWidth + ViewCtrlAttr.iToLeftDis
	--TVPrint("ViewCtrl_ReloadData: ItemCount = "..tostring(ItemCount)..",iItemTotalHeight = "..tostring(ViewCtrlAttr.iItemTotalHeight)..",iMaxItemWidth = "..tostring(ViewCtrlAttr.iMaxItemWidth))
	
	--更新滚动条
	ViewCtrlObj:UpdateScrollInfo(VisibleItemBeginIndex, VisibleItemEndIndex)
	
	return 0
end 

--获得节点总数
function ViewCtrl_GetItemCount(ViewCtrlObj)
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	return ViewCtrlAttr.DataSource:GetItemCount()
end 

--清除所有节点对象的数据（暂时只是把所有可见对象设为不可见，不会删除对象）
function ViewCtrl_ClearAllItems(ViewCtrlObj)
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	for ItemIndex, ItemObjId in pairs(ViewCtrlAttr.VisibleObjMap) do
		local ItemObj = ViewCtrlObj:GetControlObject(ItemObjId)
		ViewCtrlAttr.DataConverter:SaveUIObjectState(ItemObj, ItemIndex)
		--ItemObj:SetObjPos(0, 0, 0, 0)
		ItemObj:SetVisible(false)
		ItemObj:SetChildrenVisible(false)
		ViewCtrlAttr.VisibleObjMap[ItemIndex] = nil
		table.insert(ViewCtrlAttr.UnVisibleObjList, ItemObjId)
	end 
	ViewCtrl_SetShiftStartItemIndex(ViewCtrlObj, 1)
end 

--清除所有对象
function ViewCtrl_RemoveAllItems(ViewCtrlObj)
	--清除所有对象
	local ViewItemContainerObj = ViewCtrlObj:GetControlObject("view.itemcontainer")
	for i = 0, ViewItemContainerObj:GetChildCount() - 1 do
		local ItemObj = ViewItemContainerObj:GetChildByIndex(0)
		ViewItemContainerObj:RemoveChild(ItemObj)
	end 	
	--清除所有属性
	InitTableViewAttr(ViewCtrlObj)
	--设置滚动条不可见
	local VScrollObj = ViewCtrlObj:GetControlObject("view.vscroll")
	VScrollObj:SetVisible(false)
	VScrollObj:SetChildrenVisible(false)
	local HScrollObj = ViewCtrlObj:GetControlObject("view.hscroll")
	HScrollObj:SetVisible(false)
	HScrollObj:SetChildrenVisible(false)
end 

--选中某些节点
--ItemIndexList:节点ItemIndex列表
function ViewCtrl_SelectItem(ViewCtrlObj, ItemIndexList)
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	ViewCtrlAttr.DataSource:SelectItem(ItemIndexList)
end

--排他性选中某些节点
--ItemIndexList:节点ItemIndex列表
function ViewCtrl_ExclusiveSelectItem(ViewCtrlObj, ItemIndexList)
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	ViewCtrlAttr.DataSource:ExclusiveSelectItem(ItemIndexList)
end

--选中所有节点
function ViewCtrl_SelectAllItems(ViewCtrlObj)
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	ViewCtrlAttr.DataSource:SelectAllItems()
end

--取消所有选中
function ViewCtrl_UnSelectAllItems(ViewCtrlObj)
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	
	--调用DK接口取消所有选中
	ViewCtrlAttr.DataSource:UnSelectAllItems()
end

--通过索引获得可见节点对象
function ViewCtrl_GetItemObjByIndex(ViewCtrlObj, ItemIndex)
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	local ItemObjId = ViewCtrlAttr.VisibleObjMap[ItemIndex]
	if ItemObjId then
		local ItemObj = ViewCtrlObj:GetControlObject(ItemObjId)
		return ItemObj
	end
end 

--通过节点对象ID获得节点索引
function ViewCtrl_GetItemIndexByObjId(ViewCtrlObj, TheItemObjId)
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	for ItemIndex, ItemObjId in pairs(ViewCtrlAttr.VisibleObjMap) do
		if ItemObjId == TheItemObjId then
			return ItemIndex
		end 
	end
end 

--获得视图里所有对象列表
function ViewCtrl_GetAllItemObj(ViewCtrlObj)
	local ItemObjList = {} --存储所有对象
	local ViewItemContainerObj = ViewCtrlObj:GetControlObject("view.itemcontainer")
	for i = 0, ViewItemContainerObj:GetChildCount() - 1 do
		local ItemObj = ViewItemContainerObj:GetChildByIndex(i)
		table.insert(ItemObjList, ItemObj)
	end 
	return ItemObjList
end 

--获得视图里对象的位置
function ViewCtrl_GetItemObjPos(ViewCtrlObj, ItemIndex)
	local ItemObj = ViewCtrlObj:GetItemObjByIndex(ItemIndex)
	if ItemObj then
		return ItemObj:GetObjPos()
	end 
end

--获得所有节点的总高度
function ViewCtrl_GetTotalItemHeight(ViewCtrlObj)
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	return ViewCtrlAttr.iItemTotalHeight
end 

--设置索引节点的高度
function ViewCtrl_SetItemHeightByIndex(ViewCtrlObj, ItemIndex, height)
	if ItemIndex == nil or height == nil then
		return
	end 
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	
	if ViewCtrlAttr.ItemHeightList[ItemIndex] and ViewCtrlAttr.ItemHeightList[ItemIndex] ~= height then
		ViewCtrlAttr.iItemTotalHeight = ViewCtrlAttr.iItemTotalHeight - ViewCtrlAttr.ItemHeightList[ItemIndex] + height
		ViewCtrlAttr.ItemHeightList[ItemIndex] = height
	end
end

--设置索引节点的宽度
function ViewCtrl_SetItemWidthByIndex(ViewCtrlObj, ItemIndex, width)
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	if ViewCtrlAttr.ItemWidthList[ItemIndex] ~= width then
		ViewCtrlAttr.ItemWidthList[ItemIndex] = width
		if ViewCtrlAttr.iMaxItemWidth < width + ViewCtrlAttr.iToLeftDis then
			ViewCtrlAttr.iMaxItemWidth = width + ViewCtrlAttr.iToLeftDis
		end
	end
end 

--设置当前视图节点的宽度最大值
function ViewCtrl_SetItemMaxWidth(ViewCtrlObj, maxWidth)
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	ViewCtrlAttr.iMaxItemWidth = maxWidth + ViewCtrlAttr.iToLeftDis
end 

--滚动条：更新滚动条
--VisibleItemBeginIndex,VisibleItemEndIndex:可见节点范围
function ViewCtrl_UpdateScrollInfo(ViewCtrlObj, VisibleItemBeginIndex, VisibleItemEndIndex)
	--TVPrint("Enter TableView.xml.lua ViewCtrl_UpdateScrollInfo")
	
	--触发将要更新滚动条事件
	ViewCtrlObj:FireExtEvent("OnBeginUpdateScrollInfo")
	
	--计算滚动条是否可见
	UpdateScrollVisibility(ViewCtrlObj)
	
	--计算滚动条位置
	UpdateScrollPos(ViewCtrlObj, VisibleItemBeginIndex, VisibleItemEndIndex)

	--调整item窗口, 滚动条的位置
	UpdateObjectsPostion(ViewCtrlObj)

	--设置滚动条PageSize, Range
	SetScrollBarAttr(ViewCtrlObj)
end

--设置滚动条位置使节点对象完全可见
function ViewCtrl_SetItemVisibleCompletely(ViewCtrlObj, ItemIndex)
	--TVPrint("ViewCtrl_SetItemVisibleCompletely: ItemIndex = "..tostring(ItemIndex)..",RefreshView = "..tostring(RefreshView)..",Loop = "..tostring(Loop))
	ViewCtrlObj:ReloadData("Others", ItemIndex, ItemIndex)
end 

--获得当前视图中垂直滚动条的位置
function ViewCtrl_GetVScrollPos(ViewCtrlObj)
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	return ViewCtrlAttr.VScrollCurrentPos
end 

--设置视图中垂直滚动条的位置
--VScrollPos:滚动条的位置，home,0-最顶；end-最底；其他具体数值，超过按最大
--RefreshView:是否刷新视图
function ViewCtrl_SetVScrollPos(ViewCtrlObj, VScrollPos, RefreshView)
	--TVPrint("ViewCtrl_SetVScrollPos: VScrollPos = "..tostring(VScrollPos)..",RefreshView = "..tostring(RefreshView))
	if VScrollPos == nil then
		--TVPrint("ViewCtrl_SetVScrollPos: VScrollPos is nil")
		return
	end
	
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	
	if VScrollPos == "home" or VScrollPos == 0 then --最顶 
		VScrollPos = 0
	elseif VScrollPos == "end" or VScrollPos > ViewCtrlAttr.VScrollRange then --最底
		VScrollPos = ViewCtrlAttr.VScrollRange
	end
	--把滚动条弄到合适的位置
	ViewCtrlAttr.VScrollCurrentPos = VScrollPos
	if RefreshView == true then
		ViewCtrlObj:ReloadData("ScrollChange")
	end
end

--获得当前视图中水平滚动条的位置
function ViewCtrl_GetHScrollPos(ViewCtrlObj)
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	return ViewCtrlAttr.HScrollCurrentPos
end 

--获得当前视图显示节点的索引范围
--返回值：第一个显示节点索引，最后一个显示节点索引
function ViewCtrl_GetVisibleItemRange(ViewCtrlObj)
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	--TVPrint("ViewCtrl_GetVisibleItemRange: FirstShowItemIndex = "..tostring(ViewCtrlAttr.FirstShowItemIndex)..",LastShowItemIndex = "..tostring(ViewCtrlAttr.LastShowItemIndex))
	return ViewCtrlAttr.FirstShowItemIndex, ViewCtrlAttr.LastShowItemIndex
end 

--设置滚动条的可见性
--ScrollType:1-水平滚动条；2-垂直滚动条
function ViewCtrl_SetScrollVisible(ViewCtrlObj, ScrollType, Visible)
	--注意：这里并不改变TableView的属性
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	if ScrollType == 1 then --水平滚动条
		local HScrollObj = ViewCtrlObj:GetControlObject("view.hscroll")
		if Visible == true and ViewCtrlAttr.ShowHScroll == true then
			HScrollObj:SetVisible(true)
			HScrollObj:SetChildrenVisible(true)
		elseif Visible == false then
			HScrollObj:SetVisible(false)
			HScrollObj:SetChildrenVisible(false)
		end 
	elseif ScrollType == 2 then --垂直滚动条
		local VScrollObj = ViewCtrlObj:GetControlObject("view.hscroll")
		if Visible == true and ViewCtrlAttr.ShowVScroll == true then
			VScrollObj:SetVisible(true)
			VScrollObj:SetChildrenVisible(true)
		elseif Visible == false then
			VScrollObj:SetVisible(false)
			VScrollObj:SetChildrenVisible(false)
		end 
	end
end

--获得滚动条的可见性
--返回值：水平滚动条可见性，垂直滚动条可见性
function ViewCtrl_GetScrollVisible(ViewCtrlObj)
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	return ViewCtrlAttr.ShowHScroll, ViewCtrlAttr.ShowVScroll
end

--释放拖拽
function ViewCtrl_ReleaseDrag(ViewCtrlObj)
	--TVPrint("Enter TableView.xml.lua ViewCtrl_ReleaseDrag")
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	if ViewCtrlAttr.DragOutItem ~= nil then
		ViewCtrlAttr.DragOutItem:HideItem()
		ViewCtrlAttr.DragItemInView:HideItem()
	end
	if ViewCtrlAttr.CaptureType == 3 then
		if ViewCtrlAttr.DragInfo then
			if ViewCtrlAttr.DragInfo.HelpFunc ~= nil and ViewCtrlAttr.DragInfo.HelpFunc["StopAllDragMoveAni"] ~= nil then
				ViewCtrlAttr.DragInfo.HelpFunc["StopAllDragMoveAni"]()
			end
			ViewCtrlAttr.DragInfo = nil
		end
		
		--刷新整个列表
		ViewCtrlObj:FireExtEvent("OnDragFinish")
		ViewCtrl_ReloadData(ViewCtrlObj, nil)
		
		ViewCtrlAttr.CaptureType = 4
	end
	
	--TVPrint("Leave TableView.xml.lua ViewCtrl_ReleaseDrag")
end 


---------------------------------------各种控件事件-----------------------------------
--TableView控件初始化函数
function ViewCtrl_OnInitControl(ViewCtrlObj)	
	ViewCtrlObj:SetDefaultRedirect("control")
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	
	--属性定义
	ViewCtrlAttr.DataSource = nil --数据管理DataSource对象
	ViewCtrlAttr.DataConverter = nil --数据视图转换器对象
	
	--打印日志时增加调用类名
	local OwnerClass = ViewCtrlObj:GetOwnerControl():GetOwnerControl():GetClass()
	--TVPrint = debug.bind(debug.print, "[HQ]["..OwnerClass.."][TableView]")
	
	--初始化TableView的各种属性
	InitTableViewAttr(ViewCtrlObj)
end

--TableView控件绑定对象树控件
function ViewCtrl_OnBind(ViewCtrlObj)
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	
	--设置垂直滚动条 
	local VScrollObj = ViewCtrlObj:GetControlObject("view.vscroll")
	local VScrollAttr = VScrollObj:GetAttribute()
	VScrollAttr.width = ViewCtrlAttr.VScrollWidth
	VScrollAttr.ThumbBtnWidth = ViewCtrlAttr.VScrollThumbBtnWidth
	VScrollAttr.ThumbBtn_normal = ViewCtrlAttr.VScrollThumbBtnNor
	VScrollAttr.ThumbBtn_hover = ViewCtrlAttr.VScrollThumbBtnHover
	VScrollAttr.ThumbBtn_down = ViewCtrlAttr.VScrollThumbBtnDown
	VScrollAttr.ShowTipInFirst = ViewCtrlAttr.VShowTipInFirst
	--设置水平滚动条 
	local HScrollObj = ViewCtrlObj:GetControlObject("view.hscroll")
	local HScrollAttr = HScrollObj:GetAttribute()
	HScrollAttr.width = ViewCtrlAttr.VScrollHeight
	HScrollAttr.ThumbBtnWidth = ViewCtrlAttr.HScrollThumbBtnHeight
	HScrollAttr.ThumbBtn_normal = ViewCtrlAttr.HScrollThumbBtnNor
	HScrollAttr.ThumbBtn_hover = ViewCtrlAttr.HScrollThumbBtnHover
	HScrollAttr.ThumbBtn_down = ViewCtrlAttr.HScrollThumbBtnDown
	HScrollAttr.ShowTipInFirst = ViewCtrlAttr.HShowTipInFirst
end 

--TableView控件位置改变函数
function ViewCtrl_OnPosChange(ViewCtrlObj, oldLeft, oldTop, oldRight, oldBottom, newLeft, newTop, newRight, newBottom)
	--TVPrint("ViewCtrl_OnPosChange: newLeft = "..tostring(newLeft)..",newTop = "..tostring(newTop)..",newRight = "..tostring(newRight)..",newBottom = "..tostring(newBottom))
	if newLeft < 0 or newTop < 0 or newRight < 0 or newBottom < 0 then
		return
	end 
	--刷新视图
	--ViewCtrlObj:ReloadData("Others")
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	if ViewCtrlAttr.DataSource ~= nil and ViewCtrlAttr.DataConverter ~= nil then
		ViewCtrlObj:UpdateScrollInfo()
	end 
end

--TableCtrl控件可见性改变函数
function ViewCtrl_OnVisibleChange(ViewCtrlObj, IsVisible)
	if IsVisible == true then
		--ViewCtrlObj:ReloadData(nil)
		ViewCtrl_UpdateScrollInfo(ViewCtrlObj)
	end
end 

--鼠标左键按下事件（以ItemObj是否存在来判断是否为节点的鼠标事件）
function ViewCtrl_OnLButtonDown(ViewCtrlObj, x, y, flags, ItemObj)
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()	
	
	ViewCtrlAttr.SelectCursorX = x 
	ViewCtrlAttr.SelectCursorY = y
	
	--点击空白背景处
	if ItemObj == nil then 
		if ViewCtrlAttr.useDirectBoxSelect == true then
			--框选开始 
			ViewCtrlAttr.CaptureType = 1  --鼠标操作标示为框选
			ViewCtrlAttr.directBoxSelectX = x 
			ViewCtrlAttr.directBoxSelectY = y
			SetTableViewCaptureMouse(ViewCtrlObj, true)
		end
	--点击节点对象
	else 
		SetTableViewCaptureMouse(ViewCtrlObj, true)
		--判断此节点是否已经选中
		local ItemIndex = ViewCtrlObj:GetItemIndexByObjId(ItemObj:GetID())
		if ViewCtrlAttr.DataSource:IsItemSelected(ItemIndex) == 0 then
			--已经选中则记录
			ViewCtrlAttr.HaveSelectedBeforLBDown = ItemIndex
		else
			--没有选中则执行选中操作
			local isCtrlDown = BitAnd(flags, 8) ~= 0	
			local isShiftDown = BitAnd(flags, 4) ~= 0	
			
			--判断是否只设置为单选
			if ViewCtrlAttr.onlySingleSelect == true then	
				isCtrlDown = false
				isShiftDown = false
			end 
			
			if isCtrlDown == true then --CTRL选择
				ViewCtrlObj:SetShiftStartItemIndex(ItemIndex)
				--如果当前对象为非选中则在左键按下时处理，如当前对象为选中则在左键弹起时处理
				ViewCtrlAttr.DataSource:SelectItem({ItemIndex}, "CtrlDown")
			elseif isShiftDown == true then --SHIFT选择
				SelectItemRange(ViewCtrlObj, ViewCtrlAttr.ShiftStartItemIndex, ItemIndex, "ShiftDown")
			else --单选
				ViewCtrlObj:SetShiftStartItemIndex(ItemIndex)
				ViewCtrlAttr.DataSource:ExclusiveSelectItem({ItemIndex}, "MouseDown")
			end	
		end
		ViewCtrlAttr.CaptureType = 2  --鼠标操作标示为选中
	end 
end

--鼠标左键弹起事件（以ItemObj是否存在来判断是否为节点的鼠标事件）
function ViewCtrl_OnLButtonUp(ViewCtrlObj, x, y, flags, ItemObj)
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	
	--用于确认当前是否在节点之上
	if ItemObj == nil and ViewCtrlAttr.IsTableViewCaptureMouse == true then
		ItemObj = GetItemObjByMouseCoord(ViewCtrlObj, x, y)
	end 
	
	local isCtrlDown = BitAnd(flags, 8) ~= 0	
	local isShiftDown = BitAnd(flags, 4) ~= 0
	
	--先清理移动任务列表的timer
	if ViewCtrlAttr.DragInfo and ViewCtrlAttr.DragInfo.DragMoveViewCtrlTimerID then
		local tm = XLGetObject("Xunlei.UIEngine.TimerManager")
		tm:KillTimer(ViewCtrlAttr.DragInfo.DragMoveViewCtrlTimerID)
		ViewCtrlAttr.DragInfo.DragMoveViewCtrlTimerID = nil 
	end
	
	if ViewCtrlAttr.CaptureType == 1 then --可以框选
		local OperationType = "MouseDown"
		if isCtrlDown == false and isShiftDown == false then
			--取消所有选中
			ViewCtrlObj:UnSelectAllItems()
		else
			if isCtrlDown == true then
				OperationType = "CtrlDown"
			elseif isShiftDown == true then
				OperationType = "ShiftDown"
			end 
		end
		
		local DirectboxSelectObj = ViewCtrlObj:GetControlObject("view.directboxselect")
		DirectboxSelectObj:SetObjPos(0, 0, 0, 0)
		SetTableViewCaptureMouse(ViewCtrlObj, false)
		
		--计算与框选框有相交的对象
		if x < 0 then
			x = 0
		end
		if y < 0 then
			y = 0
		end
		SetSelectItemByRect(ViewCtrlObj, ViewCtrlAttr.directBoxSelectX, ViewCtrlAttr.directBoxSelectY, x, y, OperationType)
	elseif ViewCtrlAttr.CaptureType == 3 or ViewCtrlAttr.CaptureType == 4 and ViewCtrlAttr.DragInfo then
		ViewCtrlAttr.DragOutItem:HideItem()
		ViewCtrlAttr.DragItemInView:HideItem()
		
		if ViewCtrlAttr.DragInfo and ViewCtrlAttr.DragInfo.CanDrag and ViewCtrlAttr.DragInfo.HelpFunc then
			ViewCtrlAttr.DragInfo.HelpFunc["StopAllDragMoveAni"]()
		end
		
		--刷新整个列表
		ViewCtrlObj:FireExtEvent("OnDragFinish")
		ViewCtrl_ReloadData(ViewCtrlObj, nil)
		
		if IsPointInViewCtrl(ViewCtrlObj, x, y) then
			if ViewCtrlAttr.DragInfo.CanDrag then
				ViewCtrlAttr.DragInfo = nil
			end
		else
			ViewCtrlAttr.DragInfo = nil
			local absx, absy = ViewCtrlObj:GetAbsPos()
			absx = absx + x
			absy = absy + y
			ViewCtrlObj:FireExtEvent("OnDropOut", absx, absy, ViewCtrlAttr.DragOutItem)
		end
	elseif ViewCtrlAttr.CaptureType == 2 then  --选中节点
		if ViewCtrlAttr.HaveSelectedBeforLBDown and ItemObj then
			--取得选中节点的ItemIndex
			local ItemIndex = ViewCtrlObj:GetItemIndexByObjId(ItemObj:GetID())
			
			--判断是否只设置为单选
			if ViewCtrlAttr.onlySingleSelect == true then	
				isCtrlDown = false
				isShiftDown = false
			end 
			
			if isCtrlDown == true then --CTRL选择
				ViewCtrlObj:SetShiftStartItemIndex(ItemIndex)
				--如果当前对象为非选中则在左键按下时处理，如当前对象为选中则在左键弹起时处理
				if ViewCtrlAttr.DataSource:IsItemSelected(ItemIndex) == 0 then
					ViewCtrlAttr.DataSource:UnSelectItem({ItemIndex}, "CtrlDown")
				else 
					ViewCtrlAttr.DataSource:SelectItem({ItemIndex}, "CtrlDown")
				end 
			elseif isShiftDown == true then --SHIFT选择
				SelectItemRange(ViewCtrlObj, ViewCtrlAttr.ShiftStartItemIndex, ItemIndex, "ShiftDown")
			else --单选
				ViewCtrlObj:SetShiftStartItemIndex(ItemIndex)
				ViewCtrlAttr.DataSource:ExclusiveSelectItem({ItemIndex}, "MouseDown")
			end	
		end
	end	
	
	SetTableViewCaptureMouse(ViewCtrlObj, false)
	ViewCtrlAttr.HaveSelectedBeforLBDown = nil
	ViewCtrlAttr.CaptureType = 0  --重置鼠标操作标示
end

--鼠标左键双击事件（以ItemObj是否存在来判断是否为节点的鼠标事件）
function ViewCtrl_OnLButtonDbClick(ViewCtrlObj, x, y, flags, ItemObj)
	x, y = CoordinateChildToParent(ViewCtrlObj, x, y)
	ViewCtrlObj:FireExtEvent("OnMouseEvent", "OnLButtonDbClick", x, y, flags, ItemObj)
end

--鼠标右键按下事件（以ItemObj是否存在来判断是否为节点的鼠标事件）
--设置选中与取消选中
function ViewCtrl_OnRButtonDown(ViewCtrlObj, x, y, flags, ItemObj)
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	if ItemObj then --右键单击了任务对象
		local TheItemObjId = ItemObj:GetID()
		local TheItemIndex = nil	
		
		--取得选中节点的ItemIndex
		for ItemIndex, ItemObjId in pairs(ViewCtrlAttr.VisibleObjMap) do
			if ItemObjId == TheItemObjId then
				TheItemIndex = ItemIndex
				break
			end
		end
		
		--判断此任务对象是否已经选中，如是则不做操作，如不是则排他性选中此任务对象
		local Select = ViewCtrlAttr.DataSource:IsItemSelected(TheItemIndex)
		if Select ~= 0 then	--没有选中
			ViewCtrlAttr.DataSource:ExclusiveSelectItem({TheItemIndex}, "MouseDown")
		end
	else --右键单击了空白处（迅雷7不会取消选中）
		--取消所有选中
	end
end

--鼠标右键弹起事件（以ItemObj是否存在来判断是否为节点的鼠标事件）
function ViewCtrl_OnRButtonUp(ViewCtrlObj, x, y, flags, ItemObj)
	x, y = CoordinateChildToParent(ViewCtrlObj, x, y)
	ViewCtrlObj:FireExtEvent("OnMouseEvent", "OnRButtonUp", x, y, flags, ItemObj)
end

--鼠标滚轮事件
function ViewCtrl_OnMouseWheel(ViewCtrlObj, x, y, distance)
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	if ViewCtrlAttr.ShowVScroll == true or ViewCtrlAttr.VScrollEnable == true then
		local VScrollObj = ViewCtrlObj:GetControlObject("view.vscroll")
		local ThumbPos = VScrollObj:GetThumbPos()
		VScrollObj:SetThumbPos(ThumbPos - distance/10)
	end
end

--鼠标移动事件
function ViewCtrl_OnMouseMove(ViewCtrlObj, x, y, flags, ItemObj)
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	
	--用于确认当前是否在节点之上
	if ItemObj == nil and ViewCtrlAttr.IsTableViewCaptureMouse == true then
		ItemObj = GetItemObjByMouseCoord(ViewCtrlObj, x, y)
	end 

	--1是框选，2是选中，3是拖拽，4是拖拽被其他原因打断，非主动释放
	if ViewCtrlAttr.CaptureType == 1 then
		local DirectboxSelectObj = ViewCtrlObj:GetControlObject("view.directboxselect")
		DirectboxSelectObj:SetObjPos(math.min(x, ViewCtrlAttr.directBoxSelectX), math.min(y, ViewCtrlAttr.directBoxSelectY), math.max(x, ViewCtrlAttr.directBoxSelectX), math.max(y, ViewCtrlAttr.directBoxSelectY))
	elseif ViewCtrlAttr.CaptureType == 2 then
		if ViewCtrlAttr.SelectCursorX == -1 and ViewCtrlAttr.SelectCursorY == -1 then
			ViewCtrlAttr.SelectCursorX = x
			ViewCtrlAttr.SelectCursorY = y
		end
		
		if math.abs(ViewCtrlAttr.SelectCursorX - x) > 4 or math.abs(ViewCtrlAttr.SelectCursorY - y) > 4 then
			ViewCtrlAttr.DragInfo = nil
			InitDragHelpInfo(ViewCtrlObj, y)		
			--触发拖拽，转换capture类型
			ViewCtrlAttr.CaptureType = 3
		end
	elseif ViewCtrlAttr.CaptureType == 3 then
		DoDragOperation(ViewCtrlObj, x, y, flags)
	elseif ViewCtrlAttr.CaptureType == 4 then
		ViewCtrlAttr.CaptureType = 0
	end
	
	x, y = CoordinateChildToParent(ViewCtrlObj, x, y)
	ViewCtrlObj:FireExtEvent("OnMouseEvent", "OnMouseMove", x, y, flags, ItemObj)
end

--鼠标悬浮事件
function ViewCtrl_OnMouseHover(ViewCtrlObj, x, y, flags, ItemObj)
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	
	--用于确认当前是否在节点之上
	if ItemObj == nil and ViewCtrlAttr.IsTableViewCaptureMouse == true then
		ItemObj = GetItemObjByMouseCoord(ViewCtrlObj, x, y)
	end 
	x, y = CoordinateChildToParent(ViewCtrlObj, x, y)
	ViewCtrlObj:FireExtEvent("OnMouseEvent", "OnMouseHover", x, y, flags, ItemObj)
end 

--鼠标离开事件
function ViewCtrl_OnMouseLeave(ViewCtrlObj, x, y, flags, ItemObj)
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	
	--用于确认当前是否在节点之上
	if ItemObj == nil and ViewCtrlAttr.IsTableViewCaptureMouse == true then
		ItemObj = GetItemObjByMouseCoord(ViewCtrlObj, x, y)
	end 
	x, y = CoordinateChildToParent(ViewCtrlObj, x, y)
	ViewCtrlObj:FireExtEvent("OnMouseEvent", "OnMouseLeave", x, y, flags, ItemObj)
end 

function ViewCtrl_OnCaptureChange(ViewCtrlObj, bCapture)
	--TVPrint("bear ViewCtrl_OnCaptureChange")
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	if not bCapture then
		if ViewCtrlAttr.DragOutItem ~= nil then
			ViewCtrlAttr.DragOutItem:HideItem()
			ViewCtrlAttr.DragItemInView:HideItem()
		end
		
		--1是框选， 2是选中，3是拖拽
		if ViewCtrlAttr.CaptureType == 3 then
			--刷新整个列表
			ViewCtrlObj:FireExtEvent("OnDragFinish")
			ViewCtrl_ReloadData(ViewCtrlObj, nil)
			
			--TVPrint("bear ViewCtrl_OnCaptureChange ViewCtrlAttr.CaptureType = 3")
			ViewCtrlAttr.CaptureType = 4
		end
	end
end

--垂直滚动条：拖动按钮改变事件
function OnVScroll(VScrollObj, eventName, ntype, param)
	--TVPrint("OnVScroll: ntype = "..tostring(ntype)..",param = "..tostring(param))
	local ViewCtrlObj = VScrollObj:GetOwnerControl()
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	
	if ntype == 4 then
		ViewCtrlAttr.VScrollCurrentPos = param
	else	
		local scrollPos = ViewCtrlAttr.VScrollCurrentPos
		if ntype == 1 then			--上滚一行
			scrollPos = scrollPos - 60
		elseif ntype == 2 then	--下滚一行
			scrollPos = scrollPos + 60
		elseif ntype == 3 then	--滚一页
			if param == -1 then	--在滑块上面点击  上滚一页
				scrollPos = scrollPos - 120
			else							--在滑块下面点击	  下滚一页
				scrollPos = scrollPos + 120
			end
		end

		if scrollPos < 0 then
			scrollPos = 0
		elseif scrollPos > ViewCtrlAttr.VScrollRange then
			scrollPos = ViewCtrlAttr.VScrollRange
		end

		if scrollPos == ViewCtrlAttr.VScrollCurrentPos then
			return
		end
		ViewCtrlAttr.VScrollCurrentPos = scrollPos
	end
	VScrollObj:SetScrollPos(ViewCtrlAttr.VScrollCurrentPos, true)
	
	--刷新视图
	RefreshViewByVScroll(ViewCtrlObj, "ScrollChange")
	
	ViewCtrlObj:FireExtEvent("OnVScrollChange", ViewCtrlAttr.VScrollCurrentPos)
end

--垂直滚动条：鼠标滚动事件
function OnVScollBarMouseWheel(VScrollObj, name, x, y, distance)
	local ThumbPos = VScrollObj:GetThumbPos()
	VScrollObj:SetThumbPos(ThumbPos - distance/10)
end

--垂直滚动条：焦点变化事件
function OnVScollBarFocusChange(VScrollObj, event, focus)
	
end

--水平滚动条：拖动按钮改变事件
function OnHScroll(HScrollObj, eventName, ntype, param)
	--TVPrint("OnHScroll: ntype = "..tostring(ntype)..",param = "..tostring(param))
	local ViewCtrlObj = HScrollObj:GetOwnerControl()
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	
	if ntype == 4 then
		ViewCtrlAttr.HScrollCurrentPos = param
	else	
		local scrollPos = ViewCtrlAttr.HScrollCurrentPos
		if ntype == 1 then			--左滚一行
			scrollPos = scrollPos - 60
		elseif ntype == 2 then	--右滚一行
			scrollPos = scrollPos + 60
		elseif ntype == 3 then	--滚一页
			if param == -1 then	--在滑块左边点击  左滚一页
				scrollPos = scrollPos - 120
			else							--在滑块有变点击	  右滚一页
				scrollPos = scrollPos + 120
			end
		end
		
		if scrollPos < 0 then
			scrollPos = 0
		elseif scrollPos > ViewCtrlAttr.HScrollRange then
			scrollPos = ViewCtrlAttr.HScrollRange
		end

		if scrollPos == ViewCtrlAttr.HScrollCurrentPos then
			return
		end
		ViewCtrlAttr.HScrollCurrentPos = scrollPos
		HScrollObj:SetScrollPos(ViewCtrlAttr.HScrollCurrentPos, true)
	end
	
	--刷新视图
	RefreshViewByHScroll(ViewCtrlObj)
	
	ViewCtrlObj:FireExtEvent("OnHScrollChange", ViewCtrlAttr.HScrollCurrentPos)
end

--水平滚动条：鼠标滚动事件
function OnHScrollBarMouseWheel(HScrollObj, name, x, y, distance)
	local ThumbPos = HScrollObj:GetThumbPos()
	HScrollObj:SetThumbPos(ThumbPos - distance/10)
end

--水平滚动条：焦点变化事件
function OnHScrollBarFocusChange(HScrollObj, event, focus)

end



---------------------------------------内部处理函数-----------------------------------
--初始化TableView的各种属性
function InitTableViewAttr(ViewCtrlObj)
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	
	--属性定义
	ViewCtrlAttr.iItemTotalHeight = 0 --总高度
	ViewCtrlAttr.iMaxItemWidth = 0 --为Item最大宽度+iToLeftDis
	ViewCtrlAttr.ItemHeightList = {} --每个节点对象的高度列表
	ViewCtrlAttr.ItemWidthList = {} --每个节点对象的宽度列表
	ViewCtrlAttr.FirstShowItemIndex = nil --保存第一个可见节点的ItemIndex
	ViewCtrlAttr.LastShowItemIndex = nil --保存最后一个可见节点的ItemIndex
	ViewCtrlAttr.FirstShowItemTopPos = nil --保存第一个可见节点的顶部位置
	
	ViewCtrlAttr.ClientWidth = 0 --客户区宽度，为视图宽度减去垂直滚动条后的宽度
	ViewCtrlAttr.ClientHeight = 0 --客户区高度，为视图高度减去水平滚动条后的高度
	
	ViewCtrlAttr.VScrollCurrentPos = 0 --垂直滚动条当前位置
	ViewCtrlAttr.HScrollCurrentPos = 0 --水平滚动条当前位置
	ViewCtrlAttr.VScrollRange = 0 --垂直滚动条的滚动范围
	ViewCtrlAttr.HScrollRange = 0 --水平滚动条的滚动范围
	ViewCtrlAttr.ShowVScroll = false --是否显示垂直滚动条
	ViewCtrlAttr.ShowHScroll = false --是否显示水平滚动条
	
	ViewCtrlAttr.ShiftStartItemIndex = 1 --Shift多选时第一个节点	
	ViewCtrl_SetShiftStartItemIndex(ViewCtrlObj, 1) --设置
	ViewCtrlAttr.directBoxSelectX = nil --框选开始的横坐标	
	ViewCtrlAttr.directBoxSelectY = nil --框选开始的纵坐标
	ViewCtrlAttr.SelectCursorX = nil --选中的横坐标	
	ViewCtrlAttr.SelectCursorY = nil --选中的纵坐标
	ViewCtrlAttr.CaptureType = 0 --鼠标动作的类型，1是框选，2是选中，3是拖拽，4是拖拽被其他原因打断，非主动释放
	ViewCtrlAttr.HaveSelectedBeforLBDown = nil --鼠标左键按下前当前节点是否选中，选中则为此节点索引，不选中则为nil
	
	--存储已创建但不可见的对象
	--值：对象的ID
	ViewCtrlAttr.UnVisibleObjList = {}	
	--存储已创建但可见的对象
	--关键字：对应数据的ItemIndex
	--值：对象的ID
	ViewCtrlAttr.VisibleObjMap = {} 
end

--子对象的坐标转换为父对象的坐标
function CoordinateChildToParent(ChildObj, x, y)
	local left, top = ChildObj:GetObjPos()
	return x + left, y + top
end

--设置TableView捕获鼠标
function SetTableViewCaptureMouse(ViewCtrlObj, IsCapture)
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	ViewCtrlObj:SetCaptureMouse(IsCapture)
	ViewCtrlAttr.IsTableViewCaptureMouse = IsCapture
end 

--移动节点，按ItemIndexList顺序把节点放在[TargetItemIndex, TargetItemIndex + #ItemIndexList)
--ItemIndexList:移动节点的ItemIndex列表，确保ItemIndex由小到大的顺序
--TargetItemIndex:目标ItemIndex
--注意：仅限拖拽使用，因只能确保把连续的节点移动到相邻的位置上
function MoveItem(ViewCtrlObj, ItemIndexList, TargetItemIndex)
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	local ItemHeightList = ViewCtrlAttr.ItemHeightList
	local ItemWidthList = ViewCtrlAttr.ItemWidthList
	local VisibleObjMap = ViewCtrlAttr.VisibleObjMap
	
	--修改TableView的节点高度及宽度数据
	local ItemHeight, ItemWidth
	local ItemObjId
	local TargetItemIndexTmp1 = TargetItemIndex
	if TargetItemIndex > ItemIndexList[1] then
		for Index = 1, #ItemIndexList do
			local ItemIndex = ItemIndexList[1]
			--更新Shift数据
			if ItemIndex == ViewCtrlAttr.ShiftStartItemIndex then
				ViewCtrlAttr.ShiftStartItemIndex = TargetItemIndex
			end 
			--更新节点高度及宽度数据
			ItemHeight = ItemHeightList[ItemIndex]
			ItemWidth = ItemWidthList[ItemIndex]
			table.remove(ItemHeightList, ItemIndex)
			table.insert(ItemHeightList, TargetItemIndex, ItemHeight)
			table.remove(ItemWidthList, ItemIndex)
			table.insert(ItemWidthList, TargetItemIndex, ItemWidth)
		end
	else
		for Index, ItemIndex in ipairs(ItemIndexList) do
			--更新Shift数据
			if ItemIndex == ViewCtrlAttr.ShiftStartItemIndex then
				ViewCtrlAttr.ShiftStartItemIndex = TargetItemIndexTmp1
			end 
			--更新节点高度及宽度数据
			ItemHeight = ItemHeightList[ItemIndex]
			ItemWidth = ItemWidthList[ItemIndex]
			table.remove(ItemHeightList, ItemIndex)
			table.insert(ItemHeightList, TargetItemIndexTmp1, ItemHeight)
			table.remove(ItemWidthList, ItemIndex)
			table.insert(ItemWidthList, TargetItemIndexTmp1, ItemWidth)
			
			TargetItemIndexTmp1 = TargetItemIndexTmp1 + 1
		end
	end
	
	--修改TableView的可见对象列表
	local TargetItemIndexTmp2 = TargetItemIndex
	if TargetItemIndex > ItemIndexList[1] then
		for Index = #ItemIndexList, 1, -1 do
			local ItemIndex = ItemIndexList[Index]
			--更新可见对象列表
			ItemObjId = VisibleObjMap[ItemIndex]
			for Index = ItemIndex, TargetItemIndexTmp2 - 1 do
				VisibleObjMap[Index] = VisibleObjMap[Index + 1]
			end 
			VisibleObjMap[TargetItemIndexTmp2] = ItemObjId
			
			TargetItemIndexTmp2 = TargetItemIndexTmp2 - 1
		end
	else
		for Index, ItemIndex in ipairs(ItemIndexList) do
			--更新可见对象列表
			ItemObjId = VisibleObjMap[ItemIndex]
			for Index = ItemIndex, TargetItemIndexTmp2 + 1, -1 do
				VisibleObjMap[Index] = VisibleObjMap[Index - 1]
			end 
			VisibleObjMap[TargetItemIndexTmp2] = ItemObjId
			
			TargetItemIndexTmp2 = TargetItemIndexTmp2 + 1
		end
	end
	
	--改变DataSource的节点顺序
	ViewCtrlAttr.DataSource:MoveItem(ItemIndexList, TargetItemIndex, function() end)
end

--获得可显示节点的ItemIndex范围及第一个显示节点的位置，起点都为1
--此位置是相对于可见顶部
function GetVisibleItemRange(ViewCtrlObj)
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	
	local FirstShowItemIndex = nil
	local LastShowItemIndex = nil
	local FirstShowItemPos = ViewCtrlAttr.iToTopDis
	local iTop = ViewCtrlAttr.iToTopDis
	
	local ItemHeightListCount = #ViewCtrlAttr.ItemHeightList
	local ItemCount = ItemHeightListCount
	if ViewCtrlAttr.DataSource.GetItemCount then
		ItemCount = ViewCtrlAttr.DataSource:GetItemCount()
	end
	if ItemCount > ItemHeightListCount then
		return
	end 
	
	--TVPrint("GetVisibleItemRange: ItemCount = "..tostring(ItemCount))
	for ItemIndex = 1, ItemCount do
		if FirstShowItemIndex == nil and iTop + ViewCtrlAttr.ItemHeightList[ItemIndex] > ViewCtrlAttr.VScrollCurrentPos then
			FirstShowItemIndex = ItemIndex
			FirstShowItemPos = iTop
		end
		if iTop + ViewCtrlAttr.ItemHeightList[ItemIndex] >= ViewCtrlAttr.VScrollCurrentPos + ViewCtrlAttr.ClientHeight then
			LastShowItemIndex = ItemIndex
			break
		end
		iTop = iTop + ViewCtrlAttr.ItemHeightList[ItemIndex] + ViewCtrlAttr.iItemSpacing
		if ItemIndex == ItemCount then
			LastShowItemIndex = ItemIndex
		end
	end 
	
	return FirstShowItemIndex, LastShowItemIndex, FirstShowItemPos - ViewCtrlAttr.VScrollCurrentPos
end 

--计算节点到可见顶部的距离
function CalculateItemTopPos(ViewCtrlObj, referItemIndex, referTopPos, targetItemIndex)
	if referItemIndex == targetItemIndex then
		return referTopPos
	end

	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	
	local targetItemTopPos = referTopPos
	for ItemIndex = referItemIndex, targetItemIndex - 1 do
		targetItemTopPos = targetItemTopPos + ViewCtrlAttr.ItemHeightList[ItemIndex] + ViewCtrlAttr.iItemSpacing
	end 
	
	return targetItemTopPos
end 

--创建Item对象
--ItemIndex:节点索引
--ItemData:节点数据
--返回值：ItemObj
function CreateNewItem(ViewCtrlObj, ItemIndex, ItemData, OperationType)
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	local ViewItemContainerObj = ViewCtrlObj:GetControlObject("view.itemcontainer")
	local iChildCount = ViewItemContainerObj:GetChildCount() + 1
	local ItemObjId = "item"..iChildCount
	local ItemObj = ViewCtrlAttr.DataConverter:CreateUIObjectFromData(ItemObjId, ItemIndex, ItemData, OperationType)
	if ItemObj == nil then
		--TVPrint("CreateNewItem: ItemObj is nil")
		return
	end
	
	ItemObj:SetVisible(false)
	ItemObj:SetChildrenVisible(false)
	--ItemObj:SetObjPos(0, 0, 0, 0)
	ViewItemContainerObj:AddChild(ItemObj)
	
	--绑定Item的各种鼠标事件
	local function BindItemMouseEvent(ItemCtrlObj, eventName, mouseEventType, x, y, flags)
		x, y = CoordinateChildToParent(ItemCtrlObj, x, y)
		
		if mouseEventType == "OnLButtonDown" then
			ViewCtrl_OnLButtonDown(ViewCtrlObj, x, y, flags, ItemCtrlObj)
		elseif mouseEventType == "OnLButtonUp" then
			ViewCtrl_OnLButtonUp(ViewCtrlObj, x, y, flags, ItemCtrlObj)
		elseif mouseEventType == "OnLButtonDbClick" then
			ViewCtrl_OnLButtonDbClick(ViewCtrlObj, x, y, flags, ItemCtrlObj)
		elseif mouseEventType == "OnRButtonDown" then
			ViewCtrl_OnRButtonDown(ViewCtrlObj, x, y, flags, ItemCtrlObj)
		elseif mouseEventType == "OnRButtonUp" then
			ViewCtrl_OnRButtonUp(ViewCtrlObj, x, y, flags, ItemCtrlObj)
		elseif mouseEventType == "OnMouseWheel" then
			ViewCtrl_OnMouseWheel(ViewCtrlObj, x, y, flags)
		elseif mouseEventType == "OnMouseMove" then
			ViewCtrl_OnMouseMove(ViewCtrlObj, x, y, flags, ItemCtrlObj)
		elseif mouseEventType == "OnMouseHover" then
			ViewCtrl_OnMouseHover(ViewCtrlObj, x, y, flags, ItemCtrlObj)
		elseif mouseEventType == "OnMouseLeave" then
			ViewCtrl_OnMouseLeave(ViewCtrlObj, x, y, flags, ItemCtrlObj)
		end
	end
	ItemObj:AttachListener("OnItemMouseEvent", true, BindItemMouseEvent)
	
	--绑定Item的各种事件
	local function BindItemEvent(ItemCtrlObj, eventName, eventType, UserData)
		ViewCtrlObj:FireExtEvent("OnItemEvent", eventType, UserData, ItemCtrlObj)
	end
	ItemObj:AttachListener("OnItemEvent", true, BindItemEvent)
	
	return ItemObj
end 

--选中一定连续范围内的节点
--选中从FirstItemIndex到LastItemIndex（包括两者）范围内的所有节点，其他节点都不选中
--OperationType:CtrlDown-Ctrl按下；ShiftDown-Shift按下；MouseDown-单鼠标选中；nil-无其他键按下
function SelectItemRange(ViewCtrlObj, ItemIndex1, ItemIndex2, OperationType)
	local FirstItemIndex = math.min(ItemIndex1, ItemIndex2)
	local LastItemIndex = math.max(ItemIndex1, ItemIndex2)
	
	local ItemIndexList = {}
	for ItemIndex = FirstItemIndex, LastItemIndex do
		table.insert(ItemIndexList, ItemIndex)
	end 
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	--ViewCtrlAttr.DataSource:SelectTask(1, ItemIndexList)
	ViewCtrlAttr.DataSource:ExclusiveSelectItem(ItemIndexList, OperationType)
end

--计算与框选框相交的对象的函数
--DownX, DownY：鼠标按下时的坐标
--UpX, UpY：鼠标弹起时的坐标
function SetSelectItemByRect(ViewCtrlObj, DownX, DownY, UpX, UpY, OperationType)
	
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	
	
	--框选框的边界
	local iLeftBorder = math.min(DownX, UpX)
	local iRightBorder = math.max(DownX, UpX)
	local iTopBorder = math.min(DownY, UpY)
	local iBottomBorder = math.max(DownY, UpY)
	
	--获得与矩形区域相交的节点的ItemIndex列表
	local ItemIndexList = GetItemIndexListInRect(ViewCtrlObj, DownX, DownY, UpX, UpY)
	
	--判断“框选”有没有选中，如有，把最近选中Index传给SHIFT使用
	local ItemIndexCount = #ItemIndexList
	if ItemIndexCount > 0 then
		if iTopBorder == DownY then
			ViewCtrl_SetShiftStartItemIndex(ViewCtrlObj, ItemIndexList[ItemIndexCount])
		else
			ViewCtrl_SetShiftStartItemIndex(ViewCtrlObj, ItemIndexList[1])
		end 
	
		--选中这些节点对象
		--ViewCtrlAttr.DataSource:ExclusiveSelectItem(ItemIndexList, "MouseDown")
		ViewCtrlAttr.DataSource:SelectItem(ItemIndexList, OperationType)
	end
end

--获得与鼠标相交的节点对象
--返回值：ItemObj or nil
function GetItemObjByMouseCoord(ViewCtrlObj, MouseX, MouseY)
	--获得节点索引
	local ItemIndexList = GetItemIndexListInRect(ViewCtrlObj, MouseX, MouseY, MouseX, MouseY)
	
	if ItemIndexList and #ItemIndexList > 0 then
		return ViewCtrl_GetItemObjByIndex(ViewCtrlObj, ItemIndexList[1])
	end 
end

--获得与矩形区域相交的节点的ItemIndex列表
function GetItemIndexListInRect(ViewCtrlObj, DownX, DownY, UpX, UpY)
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	
	--框选框的边界
	local LeftBorder = math.min(DownX, UpX)
	local RightBorder = math.max(DownX, UpX)
	local TopBorder = math.min(DownY, UpY)
	local BottomBorder = math.max(DownY, UpY)

	--遍历所有可见对象，找出与框选框相交子对象的ItemIndex
	local ItemIndexList = {}
	for ItemIndex, ItemObjId in pairs(ViewCtrlAttr.VisibleObjMap) do
		local ItemObj = ViewCtrlObj:GetControlObject(ItemObjId)
		local itemLeft, itemTop, itemRight, itemBottom = ItemObj:GetObjPos()
		
		if itemRight < LeftBorder or itemLeft > RightBorder or itemBottom < TopBorder or itemTop > BottomBorder then
			
		else --与框选框有相交，选中
			table.insert(ItemIndexList, ItemIndex)
		end
	end 
	return ItemIndexList
end

--设置Item对象的水平位置
function SetObjectLeftPos(ViewCtrlObj, ItemObj, ItemIndex, iLeftPos)
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	local left, top, right, bottom = ItemObj:GetObjPos()
	left = iLeftPos
	right = left + ViewCtrlAttr.ItemWidthList[ItemIndex]
	ItemObj:SetObjPos(left, top, right, bottom)
end

--滚动条：由垂直滚动条变化而刷新视图函数
--OperationType:引起更新的动作（可自己定义，与DataConverter配合使用），TableView刷新滚动条时传下面这个：
--	ScrollChange:滚动条变化
function RefreshViewByVScroll(ViewCtrlObj, OperationType)
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	
	if ViewCtrlAttr.DataSource == nil or ViewCtrlAttr.DataConverter == nil then
		return
	end 
	
	--获得第一个显示对象及最后一个显示对象的ItemIndex
	local FirstShowItemIndex, LastShowItemIndex, FirstShowItemPos = GetVisibleItemRange(ViewCtrlObj)
	--TVPrint("RefreshViewByVScroll: FirstShowItemIndex = "..tostring(FirstShowItemIndex)..",LastShowItemIndex = "..tostring(LastShowItemIndex))
	if FirstShowItemIndex == nil or LastShowItemIndex == nil then
		ViewCtrl_ClearAllItems(ViewCtrlObj)
		return
	end 
	--存储第一个可见节点的相关信息
	ViewCtrlAttr.FirstShowItemIndex = FirstShowItemIndex
	ViewCtrlAttr.LastShowItemIndex = LastShowItemIndex
	ViewCtrlAttr.FirstShowItemTopPos = FirstShowItemPos
	
	--暂时存储可见节点ItemIndex table
	--关键字：ItemIndex
	--值：0暂时无用
	local VisibleItemIndexMap = {}
	for ItemIndexTemp = FirstShowItemIndex, LastShowItemIndex do
		VisibleItemIndexMap[ItemIndexTemp] = 0
	end 	
	
	--遍历所有可见对象VisibleObjMap，不可见的从此MAP删除并将其加入UnVisibleObjList
	--在删除对象的情况下这里的可见对象有可能大于总行数
	for ItemIndex, ItemObjId in pairs(ViewCtrlAttr.VisibleObjMap) do
		local ItemObjId = ViewCtrlAttr.VisibleObjMap[ItemIndex]		
		local ItemObj = ViewCtrlObj:GetControlObject(ItemObjId)
		
		--判断此对象节点是否仍然可见
		if ItemIndex >= FirstShowItemIndex and ItemIndex <= LastShowItemIndex then --仍然可见
			local ItemData = ViewCtrlAttr.DataSource:GetItemDataByIndex(ItemIndex)
			--ViewCtrlAttr.DataConverter:UpdateUIObjectFromData(ItemIndex, ItemObj, ItemData, OperationType)
			--更新对象的位置操作统一放在更新对象的数据操作的后面
			local left, top, right, bottom = ItemObj:GetObjPos()
			top = CalculateItemTopPos(ViewCtrlObj, FirstShowItemIndex, FirstShowItemPos, ItemIndex)
			bottom = top + ViewCtrlAttr.ItemHeightList[ItemIndex]
			ItemObj:SetObjPos(left, top, right, bottom)
			ItemObj:SetVisible(true)
			ItemObj:SetChildrenVisible(true)
			--试验下数据操作放到更新对象位置后面
			ViewCtrlAttr.DataConverter:UpdateUIObjectFromData(ItemIndex, ItemObj, ItemData, OperationType)
			
			VisibleItemIndexMap[ItemIndex] = nil
		else --变为不可见
			--保存节点的属性信息
			ViewCtrlAttr.DataConverter:SaveUIObjectState(ItemObj, ItemIndex)
			ViewCtrlAttr.VisibleObjMap[ItemIndex] = nil
			--ItemObj:SetObjPos(0, 0, 0, 0)
			ItemObj:SetVisible(false)
			ItemObj:SetChildrenVisible(false)
			table.insert(ViewCtrlAttr.UnVisibleObjList, ItemObjId)
		end
	end 
	
	--遍历所有未显示的可见节点VisibleItemIndexMap，使其可见
	for ItemIndex, v in pairs(VisibleItemIndexMap) do
		local ItemData = ViewCtrlAttr.DataSource:GetItemDataByIndex(ItemIndex)
		
		--判断是否有现成的对象
		local iUnVisibleObjCount = #ViewCtrlAttr.UnVisibleObjList
		local ItemObj = nil
		local ItemObjId = nil
		if iUnVisibleObjCount < 1 then --没有现成的
			ItemObj = CreateNewItem(ViewCtrlObj, ItemIndex, ItemData, OperationType)
			ItemObjId = ItemObj:GetID()
			ViewCtrlAttr.VisibleObjMap[ItemIndex] = ItemObjId
			--ViewCtrlAttr.DataConverter:UpdateUIObjectFromData(ItemIndex, ItemObj, ItemData, OperationType)
		else --有现成的
			ItemObjId = ViewCtrlAttr.UnVisibleObjList[iUnVisibleObjCount]
			ItemObj = ViewCtrlObj:GetControlObject(ItemObjId)
			if ItemObj == nil then
				return
			end 
			ViewCtrlAttr.VisibleObjMap[ItemIndex] = ItemObjId
			--ViewCtrlAttr.DataConverter:UpdateUIObjectFromData(ItemIndex, ItemObj, ItemData, OperationType)
			table.remove(ViewCtrlAttr.UnVisibleObjList, iUnVisibleObjCount)
		end
		--计算节点的位置
		local left = ViewCtrlAttr.iToLeftDis - ViewCtrlAttr.HScrollCurrentPos
		local top = CalculateItemTopPos(ViewCtrlObj, FirstShowItemIndex, FirstShowItemPos, ItemIndex)
		local right = left + ViewCtrlAttr.ItemWidthList[ItemIndex]
		local bottom = top + ViewCtrlAttr.ItemHeightList[ItemIndex]
		--更新对象的位置操作统一放在更新对象的数据操作的后面
		ItemObj:SetObjPos(left, top, right, bottom)
		ItemObj:SetVisible(true)
		ItemObj:SetChildrenVisible(true)
		--试验下数据操作放到更新对象位置后面
		ViewCtrlAttr.DataConverter:UpdateUIObjectFromData(ItemIndex, ItemObj, ItemData, OperationType)
	end
end 

--滚动条：由水平滚动条变化而刷新视图函数
function RefreshViewByHScroll(ViewCtrlObj)
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()

	local HScrollCurrentPos = ViewCtrlAttr.HScrollCurrentPos
	
	for ItemIndex, ItemObjId in pairs(ViewCtrlAttr.VisibleObjMap) do
		local ItemObj = ViewCtrlObj:GetControlObject(ItemObjId)
		SetObjectLeftPos(ViewCtrlObj, ItemObj, ItemIndex, -HScrollCurrentPos + ViewCtrlAttr.iToLeftDis)
	end
end

--滚动条：计算滚动条是否可见，经过这个函数，可见区域大小会减去滚动条的宽度
function UpdateScrollVisibility(ViewCtrlObj)
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	
	local viewLeft, viewTop, viewRight, viewBottom = ViewCtrlObj:GetObjPos()
	local iItemTotalHeight = ViewCtrlAttr.iItemTotalHeight
	local iMaxItemWidth = ViewCtrlAttr.iMaxItemWidth
	--TVPrint("UpdateScrollVisibility: iItemTotalHeight = "..tostring(iItemTotalHeight)..",iMaxItemWidth = "..tostring(iMaxItemWidth))
	
	--客户区宽度及高度
	ViewCtrlAttr.ClientWidth = viewRight - viewLeft
	ViewCtrlAttr.ClientHeight = viewBottom - viewTop
	
	--垂直滚动条
	local ShowVScroll = false
	if iItemTotalHeight > ViewCtrlAttr.ClientHeight and true == ViewCtrlAttr.VScrollVisible then
		ShowVScroll = true
		--减去垂直滚动条的宽度
		ViewCtrlAttr.ClientWidth = ViewCtrlAttr.ClientWidth - ViewCtrlAttr.VScrollWidth
	end
	
	--水平滚动条 
	local ShowHScroll = false
	if iMaxItemWidth > ViewCtrlAttr.ClientWidth and true == ViewCtrlAttr.HScrollVisible then
		ShowHScroll = true
		--减去水平滚动条的高度
		ViewCtrlAttr.ClientHeight = ViewCtrlAttr.ClientHeight - ViewCtrlAttr.HScrollHeight
		
		--出现的水平滚动条可能会导致出现垂直滚动条
		if (not ShowVScroll or ViewCtrlAttr.VScrollEnable) and iItemTotalHeight > ViewCtrlAttr.ClientHeight and true == ViewCtrlAttr.VScrollVisible then
			ShowVScroll = true
			--减去垂直滚动条的宽度
			ViewCtrlAttr.ClientWidth = ViewCtrlAttr.ClientWidth - ViewCtrlAttr.VScrollWidth
		end 
	end 
	
	ViewCtrlAttr.ShowVScroll = ShowVScroll
	ViewCtrlAttr.ShowHScroll = ShowHScroll
	--TVPrint("UpdateScrollVisibility: ShowVScroll = "..tostring(ShowVScroll)..",ShowHScroll = "..tostring(ShowHScroll))
end

--滚动条：计算滚动条位置
--VisibleItemBeginIndex,VisibleItemEndIndex:可见节点范围
function UpdateScrollPos(ViewCtrlObj, VisibleItemBeginIndex, VisibleItemEndIndex)
	--原则：Item上边在视图上方不可见时Item靠顶显示
	--      Item下边在视图下方不可见时Item靠底显示	
	--TVPrint("UpdateScrollPos: VisibleItemBeginIndex = "..tostring(VisibleItemBeginIndex)..",VisibleItemEndIndex = "..tostring(VisibleItemEndIndex))
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	
	local ShowVScroll = ViewCtrlAttr.ShowVScroll	
	
	local VScrollCurrentPos = ViewCtrlAttr.VScrollCurrentPos
	--更新垂直滚动条的位置
	if (ShowVScroll or ViewCtrlAttr.VScrollEnable) and VisibleItemBeginIndex and VisibleItemEndIndex then
		local VisibleItemBIndex = math.min(VisibleItemBeginIndex, VisibleItemEndIndex)
		local VisibleItemEIndex = math.max(VisibleItemBeginIndex, VisibleItemEndIndex)
		
		--限制
		local ItemHeightListCount = #ViewCtrlAttr.ItemHeightList
		if VisibleItemBIndex > ItemHeightListCount then
			VisibleItemBIndex = ItemHeightListCount
		end
		if VisibleItemEIndex > ItemHeightListCount then
			VisibleItemEIndex = ItemHeightListCount
		end 
		
		--获得节点对象的top位置及bottom位置
		local ItemBTop = CalculateItemTopPos(ViewCtrlObj, 1, ViewCtrlAttr.iToTopDis, VisibleItemBIndex)
		local ItemETop = CalculateItemTopPos(ViewCtrlObj, VisibleItemBIndex, ItemBTop, VisibleItemEIndex)
		local ItemEBottom = ItemETop + ViewCtrlAttr.ItemHeightList[VisibleItemEIndex]
		--TVPrint("UpdateScrollPos: VScrollCurrentPos = "..tostring(VScrollCurrentPos)..",ClientHeight = "..ViewCtrlAttr.ClientHeight..",ItemBTop = "..tostring(ItemBTop)..",ItemEBottom = "..tostring(ItemEBottom))
		
		--判断节点对象大概位置
		if ItemEBottom - ItemBTop >= ViewCtrlAttr.ClientHeight then --如果选中节点总高度大于客户区高度，则第一个选中节点为顶
			VScrollCurrentPos = ItemBTop
		else
			if ItemBTop >= VScrollCurrentPos then
				if ItemEBottom <= VScrollCurrentPos + ViewCtrlAttr.ClientHeight then --完全可见
					--TVPrint("UpdateScrollPos: The items is visible completelly")
				else --节点对象可能靠底部显示一部分或完全不可见
					VScrollCurrentPos = ItemEBottom - ViewCtrlAttr.ClientHeight
				end 
			else --节点对象可能靠顶部显示一部分或完全不可见
				VScrollCurrentPos = ItemBTop
			end	
		end
	end 
	--更正垂直滚动条
	if ViewCtrlAttr.iItemTotalHeight > ViewCtrlAttr.ClientHeight and 
		VScrollCurrentPos > ViewCtrlAttr.iItemTotalHeight - ViewCtrlAttr.ClientHeight then
			VScrollCurrentPos = ViewCtrlAttr.iItemTotalHeight - ViewCtrlAttr.ClientHeight
	end
	ViewCtrlAttr.VScrollCurrentPos = VScrollCurrentPos
	--更正水平滚动条
	if ViewCtrlAttr.iMaxItemWidth > ViewCtrlAttr.ClientWidth and 
		ViewCtrlAttr.HScrollCurrentPos > ViewCtrlAttr.iMaxItemWidth - ViewCtrlAttr.ClientWidth then
			ViewCtrlAttr.HScrollCurrentPos = ViewCtrlAttr.iMaxItemWidth - ViewCtrlAttr.ClientWidth
	end 
	--水平滚动条不用处理	
	--TVPrint("UpdateScrollPos: VScrollCurrentPos = "..tostring(ViewCtrlAttr.VScrollCurrentPos)..",HScrollCurrentPos = "..tostring(ViewCtrlAttr.HScrollCurrentPos))
end 

--滚动条：调整item窗口, 滚动条的位置
function UpdateObjectsPostion(ViewCtrlObj)
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()

	local ShowVScroll, ShowHScroll = ViewCtrlAttr.ShowVScroll, ViewCtrlAttr.ShowHScroll
	local VScrollWidth, HScrollHeight = ViewCtrlAttr.VScrollWidth, ViewCtrlAttr.HScrollHeight

	--调整水平滚动条的位置
	if ShowHScroll then
		local HScrollObj = ViewCtrlObj:GetControlObject("view.hscroll")
		local hTop = ViewCtrlAttr.ClientHeight - ViewCtrlAttr.ScrollToMarginDis --这里为何不用减去HScrollHeight，因UpdateScrollVisibility中ClientHeight已经减去了
		if ShowVScroll or ViewCtrlAttr.VScrollEnable then
			HScrollObj:SetObjPos(0, hTop, ViewCtrlAttr.ClientWidth, hTop + HScrollHeight)
		else
			HScrollObj:SetObjPos(0, hTop, ViewCtrlAttr.ClientWidth, hTop + HScrollHeight)
		end
	end

	--调整垂直滚动条的位置
	if ShowVScroll or ViewCtrlAttr.VScrollEnable then
		local VScrollObj = ViewCtrlObj:GetControlObject("view.vscroll")
		local left = ViewCtrlAttr.ClientWidth - ViewCtrlAttr.ScrollToMarginDis --这里为何不用减去VScrollWidth，因UpdateScrollVisibility中ClientWidth已经减去了
		local right = left + VScrollWidth
		local top = 0 -- 为了让滚动条顶到list的头部 attr.ItemTopPos
		local bottom = ViewCtrlAttr.ClientHeight
		if ShowHScroll then
			bottom = ViewCtrlAttr.ClientHeight + HScrollHeight
		end
		VScrollObj:SetObjPos(left, top, right, bottom)
	end
end

--滚动条：设置滚动条PageSize, Range
function SetScrollBarAttr(ViewCtrlObj)
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	
	local ShowVScroll, ShowHScroll = ViewCtrlAttr.ShowVScroll, ViewCtrlAttr.ShowHScroll
	--获得所有节点显示所需的总高度及总宽度
	local iItemTotalHeight, iMaxItemWidth = ViewCtrlAttr.iItemTotalHeight, ViewCtrlAttr.iMaxItemWidth
	
	--设置垂直滚动条的可见性及相关属性
	local VScrollObj = ViewCtrlObj:GetControlObject("view.vscroll")
	VScrollObj:SetVisible(ShowVScroll)
	VScrollObj:SetChildrenVisible(ShowVScroll)
	if ShowVScroll or ViewCtrlAttr.VScrollEnable then
		VScrollObj:SetPageSize(ViewCtrlAttr.ClientHeight)
		ViewCtrlAttr.VScrollRange = iItemTotalHeight - ViewCtrlAttr.ClientHeight
		VScrollObj:SetScrollRange(0, ViewCtrlAttr.VScrollRange, true)
		--设置捕获焦点
		--VScrollObj:SetFocus(true)
	else
		--如果垂直滚动条不可见，则将滚动条滚动到最顶位置
		ViewCtrlAttr.VScrollCurrentPos = 0
	end 
	VScrollObj:FireExtEvent("OnVScroll", 4, ViewCtrlAttr.VScrollCurrentPos)
	
	--设置水平滚动条的可见性及相关属性
	local HScrollObj = ViewCtrlObj:GetControlObject("view.hscroll")
	HScrollObj:SetVisible(ShowHScroll)
	HScrollObj:SetChildrenVisible(ShowHScroll)
	if ShowHScroll then
		HScrollObj:SetPageSize(ViewCtrlAttr.ClientWidth)
		ViewCtrlAttr.HScrollRange = iMaxItemWidth - ViewCtrlAttr.ClientWidth
		HScrollObj:SetScrollRange(0, ViewCtrlAttr.HScrollRange, true)
	else
		--如果水平滚动条不可见，则将滚动条滚动到最左位置
		ViewCtrlAttr.HScrollCurrentPos = 0
	end
	HScrollObj:FireExtEvent("OnHScroll", 4, ViewCtrlAttr.HScrollCurrentPos)
end 

function GetSelectedItemIndexSortedList(ViewCtrlObj)
	local SelectedArray = {}
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	local hr, selcetList = ViewCtrlAttr.DataSource:GetSelectedItemIndexList()
	if selcetList ~= nil and #selcetList ~= 0 then
		for key, value in pairs(selcetList) do
			local insertIndex = #SelectedArray + 1
			for subKey, subValue in pairs(SelectedArray) do
				if value < subValue then
					insertIndex = subKey
					break
				end
			end
			
			table.insert(SelectedArray, insertIndex, value)
		end
	end
	
	return SelectedArray
end

-- 得到pos所在任务的索引及被覆盖的高度
function GetItemIndexByPos(ViewCtrlObj, pos)
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	local ItemCount = ViewCtrlAttr.DataSource:GetItemCount()
	local height = 0
	for index, value in ipairs(ViewCtrlAttr.ItemHeightList) do
		height = height + value + ViewCtrlAttr.iItemSpacing
		if height > pos then
			return index
		elseif height == pos then
			index = index+1
			if index > ItemCount then
				index = ItemCount
			end
			return index
		end
	end
end

function BuildDragItem(ViewCtrlObj)
	local ownerTree = ViewCtrlObj:GetOwner()
	local rootObject = ownerTree:GetRootObject()
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	
	if ViewCtrlAttr.DragOutItem ~= nil then
		rootObject:RemoveChild(ViewCtrlAttr.DragOutItem)
		ViewCtrlAttr.DragOutItem = nil
	end
	
	local index = 1
	local DragOutItemID = "DragOutItem."..index
	if rootObject:IsControl() then
		local DragOutItem = rootObject:GetControlObject(DragOutItemID)
		while DragOutItem ~= nil do
			index = index + 1
			DragOutItemID = "DragOutItem."..index
			DragOutItem = rootObject:GetControlObject(DragOutItemID)
		end
	else
		local DragOutItem = ownerTree:GetUIObject(DragOutItemID)
		while DragOutItem ~= nil do
			index = index + 1
			DragOutItemID = "DragOutItem."..index
			DragOutItem = ownerTree:GetUIObject(DragOutItemID)
		end
	end

	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	ViewCtrlAttr.DragOutItem = objFactory:CreateUIObject(DragOutItemID, "WHome.DragItem")
	rootObject:AddChild(ViewCtrlAttr.DragOutItem)
	ViewCtrlAttr.DragOutItem:SetZorder(50000000)
	ViewCtrlAttr.DragOutItem:HideItem()
	
	--------------------------------
	if ViewCtrlAttr.DragItemInView ~= nil then
		ViewCtrlObj:RemoveChild(ViewCtrlAttr.DragItemInView)
	end
	local DragItemInViewID = "DragItemInView"
	ViewCtrlAttr.DragItemInView = objFactory:CreateUIObject(DragItemInViewID, "WHome.DragItem")
	ViewCtrlObj:AddChild(ViewCtrlAttr.DragItemInView)
	ViewCtrlAttr.DragItemInView:HideItem()
end

function InitDragHelpInfo(ViewCtrlObj, CursorY)
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	---[===[  为drag初始化一些信息
	ViewCtrlAttr.DragInfo = {}
	
	--记录选中的任务列表
	--对选中的index进行排序，从小到大排序
	local SelectedArray = GetSelectedItemIndexSortedList(ViewCtrlObj)
	
	--是否能拖动,如果选中任务为空、或者选中任务的不在同一个分组中，将不能拖动
	ViewCtrlAttr.DragInfo.CanDrag = true
	if SelectedArray == nil or #SelectedArray == 0 then
		ViewCtrlAttr.DragInfo.CanDrag = false
		return
	end
	
	--记录选中的任务的总高度
	ViewCtrlAttr.DragInfo.SelectedTotalH = 0
	
	--记录拖动的任务将要移动到的位置
	ViewCtrlAttr.DragInfo.MoveToIndex = -1
	
	--记录drag时的帮助函数
	ViewCtrlAttr.DragInfo.HelpFunc = {}
	
	--记录当前界面上显示的任务的位置信息和原始位置信息的对应关系
	ViewCtrlAttr.DragInfo.ItemInfo = {}
	
	local nMoveCount = 0
	local cursorSelectedIndex = GetItemIndexByPos(ViewCtrlObj, CursorY + ViewCtrlAttr.VScrollCurrentPos)
	--鼠标选中的任务在ViewCtrl里面的index
	if cursorSelectedIndex == nil or ViewCtrlAttr.DataSource:IsItemSelected(cursorSelectedIndex) ~= 0 then
		ViewCtrlAttr.DragInfo.CanDrag = false
		return
	end
	
	local ItemCount = ViewCtrlAttr.DataSource:GetItemCount()
	for ItemIndex = 1, ItemCount do
		if ViewCtrlAttr.DataSource:IsItemSelected(ItemIndex) == 0 then  -- 0为选中
			--统计需要移动到一起的item数
			if ItemIndex <= cursorSelectedIndex then
				nMoveCount = nMoveCount + 1
			end
			
			ViewCtrlAttr.DragInfo.SelectedTotalH = ViewCtrlAttr.DragInfo.SelectedTotalH + ViewCtrlAttr.ItemHeightList[ItemIndex]
		end
		
		local data = {}
		table.insert(ViewCtrlAttr.DragInfo.ItemInfo,data)
	end
		
	ViewCtrlAttr.DragInfo.HelpFunc["StopAllDragMoveAni"] = function(bForceStop)
		for i=1, #ViewCtrlAttr.DragInfo.ItemInfo do
			if ViewCtrlAttr.DragInfo.ItemInfo[i]["ItemInPosChangeAni"] then
				if bForceStop then
					ViewCtrlAttr.DragInfo.ItemInfo[i]["ItemInPosChangeAni"]:ForceStop()
				else
					ViewCtrlAttr.DragInfo.ItemInfo[i]["ItemInPosChangeAni"]:Stop()
				end
			end
		end
	end
	
	ViewCtrlAttr.DragInfo.HelpFunc["MoveItemInfo"] = function(needMoveIndexArray,toIndex)
			if needMoveIndexArray == nil then
				return
			end
			local topIndex,bottomIndex = needMoveIndexArray[1], needMoveIndexArray[#needMoveIndexArray]
			--TVPrint("bear InitDragHelpInfo MoveItemInfo toIndex = "..tostring(toIndex)..", topIndex = "..tostring(topIndex))
			
			MoveItem(ViewCtrlObj, needMoveIndexArray, toIndex)
		end
		
	--如果选择的任务不是连续的，先将任务移动到一起，以鼠标所在的任务为中心，两边向中间靠拢
	local bResetPos = false
	if nMoveCount > 0 then
		for i=nMoveCount-1, 1, -1 do
			bResetPos = true
			cursorSelectedIndex = cursorSelectedIndex - 1
			local tempArray = {}
			tempArray[1] = SelectedArray[i]
			--TVPrint("bear InitDragHelpInfo MoveItemInfo pre i = "..tostring(i)..", cursorSelectedIndex = "..tostring(cursorSelectedIndex)..", preIndex = "..tostring(tempArray[1]))
			ViewCtrlAttr.DragInfo.HelpFunc["MoveItemInfo"](tempArray, cursorSelectedIndex)
		end
		
		cursorSelectedIndex = SelectedArray[nMoveCount]
		for i=nMoveCount+1, #SelectedArray do
			bResetPos = true
			cursorSelectedIndex = cursorSelectedIndex + 1
			local tempArray = {}
			tempArray[1] = SelectedArray[i]
			----TVPrint("bear InitDragHelpInfo MoveItemInfo next i = "..tostring(i)..", cursorSelectedIndex = "..tostring(cursorSelectedIndex)..", preIndex = "..tostring(tempArray[1]))
			ViewCtrlAttr.DragInfo.HelpFunc["MoveItemInfo"](tempArray, cursorSelectedIndex)
		end
	end
	
	if bResetPos then
		--只需要重新设置选中任务中的最上边的一个任务和最下边任务之间的
		local nEnd = SelectedArray[#SelectedArray]
		local nBegin = SelectedArray[1]
		
		for ItemIndex=nBegin, nEnd do
			-- 获取节点应该显示的位置，将节点移动到该位置
			local ItemObj = ViewCtrl_GetItemObjByIndex(ViewCtrlObj, ItemIndex)
			if ItemObj == nil then
				break
			end
			
			local left, top, right, bottom = ItemObj:GetObjPos()
			top = CalculateItemTopPos(ViewCtrlObj, ViewCtrlAttr.FirstShowItemIndex, ViewCtrlAttr.FirstShowItemTopPos, ItemIndex)
			bottom = top + ViewCtrlAttr.ItemHeightList[ItemIndex]
			ItemObj:SetObjPos(left, top, right, bottom)
		end
		ViewCtrlAttr.DragInfo.MoveToIndex = SelectedArray[1]
	end
end

function IsPointInViewCtrlMovedArea(ViewCtrlObj, x, y)
	local l,t,r,b = ViewCtrlObj:GetAbsPos()
	if x > l and x < r and y > t and y < t+25 then
		return true,"MoveUp"
	end
	
	if x > l and x < r and y > b-25 and y < b then
		return true,"MoveDown"
	end
	return false
end

function IsPointInViewCtrl(ViewCtrlObj, x, y)
	local left,top,right,bottom = ViewCtrlObj:GetObjPos()
	local width = right - left - 60  --减去60，TableView的箭头的大小
	local height = bottom - top
	if x < 0 or y < 0 or x > width or y > height then
		return false
	else
		return true
	end
end

function DoDragOperation(ViewCtrlObj, x, y, flags)
	--显示拖拽框
	local absx, absy = ViewCtrlObj:GetAbsPos()
	absx = absx + x
	absy = absy + y
	
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	if absx < 0 or absy < 0 then
		ViewCtrlAttr.DragOutItem:SetChildrenVisible(false)
		ViewCtrlAttr.DragItemInView:SetChildrenVisible(false)
	else
		local bContinue = true
		local bCanMoveViewCtrl, direction = IsPointInViewCtrlMovedArea(ViewCtrlObj,absx,absy)
		if  bCanMoveViewCtrl and ViewCtrlAttr.DragInfo.CanDrag then
			local function DragMoveViewCtrlTimer()
				if ViewCtrlAttr.DragInfo == nil then
					return
				end
				
				--移动到任务列表的最顶部或者最底部
				local VScrollObj = ViewCtrlObj:GetControlObject("view.vscroll")
				local scrollBegin, scorllEnd = VScrollObj:GetScrollRange()
				local left,top,right,bottom = ViewCtrlObj:GetObjPos()
				local width = right - left
				local height = bottom - top
				
				local ItemIndex = GetItemIndexByPos(ViewCtrlObj, y + ViewCtrlAttr.VScrollCurrentPos)
				if ItemIndex == nil then
					return
				end
				if ItemIndex ~= nil and ViewCtrlAttr.DataSource:IsItemSelected(ItemIndex) ~= 0 then  --未选中
					if ItemIndex ~= -1  and ViewCtrlAttr.DragInfo.MoveToIndex ~= ItemIndex then
						DragMoveAniAndSwapData(ViewCtrlObj, ItemIndex)
					end
				end
				
				local itemHeight, itemWidth = ViewCtrlAttr.DataConverter:GetItemSize(ItemIndex)
				local offset = itemHeight
				local vscrollPos = ViewCtrlAttr.VScrollCurrentPos
				local bUpdate = false
				if direction == "MoveUp" then --鼠标向上移动
					if ViewCtrlAttr.VScrollCurrentPos >= scrollBegin then
						vscrollPos = vscrollPos - offset
						if vscrollPos < scrollBegin then
							vscrollPos = scrollBegin 
						end
						
						bUpdate = true
					end
				elseif direction == "MoveDown" then --鼠标向下移动
					if ViewCtrlAttr.VScrollCurrentPos <= scorllEnd then
						vscrollPos = vscrollPos + offset
						if vscrollPos > scorllEnd then
							vscrollPos = scorllEnd
						end
						
						bUpdate = true
					end
				end
				
				if bUpdate then
					ViewCtrl_SetVScrollPos(ViewCtrlObj, vscrollPos, true)
					ViewCtrl_OnMouseMove(ViewCtrlObj, x, y, flags)
				end
			end
			
			if ViewCtrlAttr.DragInfo.DragMoveViewCtrlTimerID == nil then
				local tm = XLGetObject("Xunlei.UIEngine.TimerManager")
				ViewCtrlAttr.DragInfo.DragMoveViewCtrlTimerID = tm:SetTimer(DragMoveViewCtrlTimer, 300)
			end
		else
			if ViewCtrlAttr.DragInfo.DragMoveViewCtrlTimerID then
				local tm = XLGetObject("Xunlei.UIEngine.TimerManager")
				tm:KillTimer(ViewCtrlAttr.DragInfo.DragMoveViewCtrlTimerID)
				ViewCtrlAttr.DragInfo.DragMoveViewCtrlTimerID = nil
			end
		end
		
		if IsPointInViewCtrl(ViewCtrlObj, x, y) and ViewCtrlAttr.DragInfo.CanDrag then
			local ItemIndex = GetItemIndexByPos(ViewCtrlObj, y + ViewCtrlAttr.VScrollCurrentPos)
			
			if ItemIndex ~= nil and ViewCtrlAttr.DataSource:IsItemSelected(ItemIndex) ~= 0 then  --未选中
				local nowIndex = ItemIndex
				----TVPrint("bear ItemIndex = "..tostring(ItemIndex)..", nowIndex = "..tostring(nowIndex)..", MoveToIndex = "..tostring(ViewCtrlAttr.DragInfo.MoveToIndex))
				if nowIndex ~= -1 and ViewCtrlAttr.DragInfo.MoveToIndex ~= nowIndex then
					DragMoveAniAndSwapData(ViewCtrlObj, nowIndex)
					--选中的任务不在当前界面上，交换后，需要刷新界面将其显示出来
					--if not ViewCtrlAttr.DragInfo.HelpFunc["IsSelectedTaskInItemList"]() then
						--UpdateUIForDragMoveList(self)
					--end
				end
			end
			
			local helpFunc = ViewCtrlAttr.DragInfo.HelpFunc
			local SelectedArray = GetSelectedItemIndexSortedList(ViewCtrlObj)
			local sTopSelectedNowIndex = SelectedArray[1]
			local sBottomSelectedNowIndex = SelectedArray[#SelectedArray]
			local DragItemLeft = 0
			local DragItemRight = 0
			
			if sTopSelectedNowIndex ~= nil and sBottomSelectedNowIndex ~= nil then
				local tempTop = y - ViewCtrlAttr.DragInfo.SelectedTotalH / 2
				for i=sTopSelectedNowIndex, sBottomSelectedNowIndex do
					local ItemObj = ViewCtrl_GetItemObjByIndex(ViewCtrlObj, i)
					if ItemObj then
						ViewCtrlAttr.DataConverter:SetItemBkgType(ItemObj, 2)
						local left, top, right, bottom = ItemObj:GetObjPos()
						local tempH = bottom - top
						local itemAttr = ItemObj:GetAttribute()
						if itemAttr.PreZorder == nil then
							itemAttr.PreZorder = ItemObj:GetZorder()
						end
						ItemObj:SetZorder(itemAttr.PreZorder + 100)
						ItemObj:SetObjPos(left, tempTop, right, tempTop+tempH)
						tempTop = tempTop+tempH
						
						local bkgLeft, bkgTop, bkgRight, bkgBottom = ViewCtrlAttr.DataConverter:GetItemObjPos(ItemObj)
						DragItemLeft = bkgLeft
						DragItemRight = bkgRight
					end
				end
			end
			
			ViewCtrlAttr.DragItemInView:SetChildrenVisible(true)
			ViewCtrlAttr.DragOutItem:SetChildrenVisible(false)
			--减去阴影部分长度和高度
			ViewCtrlAttr.DragItemInView:SetObjPos(DragItemLeft - 5, y-ViewCtrlAttr.DragInfo.SelectedTotalH / 2- 8, DragItemRight + 5, y+ ViewCtrlAttr.DragInfo.SelectedTotalH/2+ 5)
			
			ViewCtrlObj:FireExtEvent("OnDrag", absx, absy, ViewCtrlAttr.DragItemInView, ItemIndex)
			bContinue = false --标记跳过后面的操作
		end
		
		if bContinue then
			if ViewCtrlAttr.DragInfo.CanDrag then
				ViewCtrlAttr.DragInfo.HelpFunc["StopAllDragMoveAni"](true)
				
				--显示选中的任务
				local helpFunc = ViewCtrlAttr.DragInfo.HelpFunc
				local SelectedArray = GetSelectedItemIndexSortedList(ViewCtrlObj)
				local sTopSelectedNowIndex = SelectedArray[1]
				local sBottomSelectedNowIndex = SelectedArray[#SelectedArray]
				
				if sTopSelectedNowIndex ~= nil and sBottomSelectedNowIndex ~= nil then
					for ItemIndex=sTopSelectedNowIndex,sBottomSelectedNowIndex do
						local ItemObj = ViewCtrl_GetItemObjByIndex(ViewCtrlObj, ItemIndex)
						if ItemObj then
							-- 获取节点应该显示的位置，将节点移动到该位置，并选中节点
							local left, top, right, bottom = ItemObj:GetObjPos()
							top = CalculateItemTopPos(ViewCtrlObj, ViewCtrlAttr.FirstShowItemIndex, ViewCtrlAttr.FirstShowItemTopPos, ItemIndex)
							bottom = top + ViewCtrlAttr.ItemHeightList[ItemIndex]
							ItemObj:SetObjPos(left, top, right, bottom)
							
							local itemAttr = ItemObj:GetAttribute()
							if itemAttr.PreZorder ~= nil then
								ItemObj:SetZorder(itemAttr.PreZorder)
							end
							itemAttr.PreZorder = nil
							----TVPrint("bear GetSelectedItemIndexSortedList SetItemBkgType 1 ItemIndex = "..tostring(ItemIndex))
							ViewCtrlAttr.DataConverter:SetItemBkgType(ItemObj, 1)
						end
					end
				end
					
				----TVPrint("bear OnDragOutTableView")
				ViewCtrlObj:FireExtEvent("OnDragOutTableView", absx, absy, ViewCtrlAttr.DragOutItem)
				ViewCtrlAttr.DragOutItem:SetObjPos(absx-33, absy-50, absx-33+60, absy-50+60)
				--ViewCtrlAttr.DragOutItem:SetChildrenVisible(true)
				ViewCtrlAttr.DragItemInView:SetChildrenVisible(false)
			end
		end
	end
	
	local shell = XLGetObject( "CoolJ.OSShell" )
	local tl,tt,tr,tb = ViewCtrlObj:GetOwner():GetBindHostWnd():GetWindowRect()
	local mx, my = shell:GetCursorPos()
	if not (tl<=mx and mx<=tr and tt<=my and my<=tb) then
		ViewCtrlObj:FireExtEvent("OnDragOutHostWnd", ViewCtrlAttr.DragOutItem)
	end
end

function DragMoveAniAndSwapData(ViewCtrlObj, moveToIndex)
	local ViewCtrlAttr = ViewCtrlObj:GetAttribute()
	
	local moveItemNowIndex = moveToIndex
	local selectedItemH = ViewCtrlAttr.DragInfo.SelectedTotalH

	local SelectedArray = GetSelectedItemIndexSortedList(ViewCtrlObj)
	local sTopItemNowIndex = SelectedArray[1]
	local sBottomItemNowIndex = SelectedArray[#SelectedArray]
	
	if sTopItemNowIndex == nil or sBottomItemNowIndex == nil then
		return 
	end
	
	local iAniIndex,nMaxAniIndex = -1,-1
	if moveItemNowIndex < sTopItemNowIndex then
		iAniIndex = moveItemNowIndex
		nMaxAniIndex = sTopItemNowIndex-1
	elseif moveItemNowIndex > sBottomItemNowIndex then
		selectedItemH = 0 - selectedItemH
		iAniIndex = sBottomItemNowIndex+1
		nMaxAniIndex = moveItemNowIndex
	else
		return
	end
	
	local aniFactory = XLGetObject("Xunlei.UIEngine.AnimationFactory")
	for ItemIndex = iAniIndex, nMaxAniIndex do
		local iItemInfo = ViewCtrlAttr.DragInfo.ItemInfo[ItemIndex]
		if iItemInfo == nil then
			break
		end
		
		local moveObj = ViewCtrl_GetItemObjByIndex(ViewCtrlObj, ItemIndex)
		if iItemInfo.ItemInPosChangeAni then
			iItemInfo.ItemInPosChangeAni:ForceStop()
		end
		
		if moveObj then
			--因为动画，top,bottom不能以界面的位置为准
			local initLeft, initTop, initRight, initBottom = moveObj:GetObjPos()
			initTop = CalculateItemTopPos(ViewCtrlObj, ViewCtrlAttr.FirstShowItemIndex, ViewCtrlAttr.FirstShowItemTopPos, ItemIndex)
			initBottom = initTop + ViewCtrlAttr.ItemHeightList[ItemIndex]
			
			local posAni = aniFactory:CreateAnimation("PosChangeAnimation")
			posAni:SetTotalTime(500)
			posAni:BindLayoutObj(moveObj)
			posAni:SetKeyFrameRect(initLeft,initTop,initRight,initBottom, initLeft,initTop+selectedItemH,initRight,initBottom+selectedItemH)
			local tree = moveObj:GetOwner()
			tree:AddAnimation(posAni)
			iItemInfo.ItemInPosChangeAni = posAni
			local function onAniFinish(ani,oldState,newState)
				if newState == 4 then
					iItemInfo.ItemInPosChangeAni = nil
					moveObj:SetObjPos(initLeft,initTop+selectedItemH,initRight,initBottom+selectedItemH)
				end
			end
			posAni:AttachListener(true, onAniFinish)
			posAni:Resume()
		end
	end
	
	--移动iteminfo位置
	ViewCtrlAttr.DragInfo.HelpFunc["MoveItemInfo"](SelectedArray, moveItemNowIndex)			
	ViewCtrlAttr.DragInfo.MoveToIndex = moveItemNowIndex
end
