local function GetTipID(self)
    local id = self:GetID()
    id = id..".Tip"
    return id
end

local function RemoveTip(self)
    local attr = self:GetAttribute()
	if attr == nil then
		return
	end
    attr.ShowTipInFirst = false
    local id = GetTipID(self)
	local tempObj = self:GetControlObject(id)
	if tempObj then
		self:RemoveChild(tempObj)
	end
	return id
end

local function AddTip(self, nLeft, nTop, maxTextWidth)
    local attr = self:GetAttribute()
	if maxTextWidth == nil then
		maxTextWidth = 90
	end
	if nLeft == nil then nLeft = 0 end
	if nTop == nil then nTop = 0 end
	local id = GetTipID(self)
	local tempObj = self:GetControlObject(id)
	if tempObj then
		return
	end
	local xarManager = XLGetObject("Xunlei.UIEngine.XARManager")
	local xarFactory = xarManager:GetXARFactory()
	local tipObj = xarFactory:CreateUIObject(id,"WHome.CommonTips")
	
	local tipAttr = tipObj:GetAttribute()
	tipAttr.BkgTexture = "texture.scrollbar.tip.bkg"
	tipAttr.TextMarginH = 5
	tipAttr.TextMarginV = 8
	tipAttr.TextHAlign ="left"
	tipAttr.TextVAlign ="center"
	tipAttr.TrackMouse = true
	tipAttr.Multiline = true
	tipAttr.MultilineTextLimitWidth = maxTextWidth
	tipAttr.TextMarginLeft = 17
	tipObj:SetText(attr.TipText)
	tipObj:SetType(1)
	tipObj:SetZorder(50000000)
	self:AddChild(tipObj)
	local tipLeft,tipTop,tipRight,tipBottom = tipObj:GetTipRect(self)
	tipObj:SetObjPos(nLeft , nTop, nLeft + tipRight - tipLeft  +3,nTop + tipBottom - tipTop - 2)
	local timerManager = XLGetObject("Xunlei.UIEngine.TimerManager")
	timerManager:SetOnceTimer(function()RemoveTip(self)end, 5000)
end

function RouteToFather__OnChar(self, char)
    if char == 9 or char == 37 or char == 38 or char == 39 or char == 40 then
        self:RouteToFather()
    end
end

function OnBtnFocusChange(self, focus)
    local ctrl = self:GetOwnerControl()
    ctrl:FireExtEvent("OnScrollBarFocusChange", focus)
end

function ThumbBtn__OnMouse(self)

end

function SetState(self, state)
    local attr = self:GetAttribute()
    if attr.state == state then
        return
    end
    local bkg = self:GetControlObject("scrollbar.bkn")
    if state == 0 then
        bkg:SetTextureID(attr.NormalBkn)
    elseif state == 1 then
        bkg:SetTextureID(attr.HoverBkn)
    end
end

function UpdateThumbPos(self)
    local attr = self:GetAttribute()
    local type_ = attr.Type
	if attr.AutoVisibleChange then
		self:SetVisible(true)
	end
    local thumbBtn = self:GetControlObject("scrollbar.thumbbtn")
    local leftbtn = self:GetControlObject("scrollbar.leftbtn")
    local rightbtn = self:GetControlObject("scrollbar.rightbtn")
    
    --计算拖动按钮的长度
    local left,top,right,bottom = self:GetObjPos()
    local width = right - left
    local height = bottom - top
    
    --计算出去左右两个箭头的区域的长度
    local trackLen;
    if type_ == 0 then
        trackLen = width - attr.SideBtnLength * 2;
    else
        trackLen = height - attr.SideBtnLength * 2;
    end
    
    if attr.PageSize == 0 then
		if attr.AutoVisibleChange then
			self:SetVisible(false)
		end
        return
    end
    
    local range = attr.RangeEnd - attr.RangeBegin;
    if range <= 0 then
		if attr.AutoVisibleChange then
			self:SetVisible(false)
		end
        return
    end
            
    local thumbLen = trackLen * attr.PageSize / (range + attr.PageSize)
    if thumbLen < attr.ThumbBtnLength then
        thumbLen = attr.ThumbBtnLength
    end
    
    -- 没有区域显示thumb按钮了
    if trackLen <= thumbLen then
        thumbBtn:SetVisible(false, true)
        return
    end
    
    thumbBtn:SetVisible(true, true)
    leftbtn:SetEnable(true)
    rightbtn:SetEnable(true)
    local thumbPos = attr.SideBtnLength + (attr.ScrollPos - attr.RangeBegin)*(trackLen - thumbLen)/(range)
    
	if attr.SideBtnLength == 0 then
		if type_ == 0 then
			thumbBtn:SetObjPos(thumbPos, height - attr.ThumbBtnWidth, thumbPos + thumbLen, height)
		else
			thumbBtn:SetObjPos(width - attr.ThumbBtnWidth, thumbPos, width, thumbPos + thumbLen)
		end
	else
		if type_ == 0 then
			thumbBtn:SetObjPos(thumbPos, height - attr.ThumbRightMagrin - attr.ThumbBtnWidth, thumbPos + thumbLen, height - attr.ThumbRightMagrin)
		else
			thumbBtn:SetObjPos(width - attr.ThumbRightMagrin - attr.ThumbBtnWidth, thumbPos, width - attr.ThumbRightMagrin, thumbPos + thumbLen)
		end
	end
	
    if attr.ScrollPos == attr.RangeBegin then
        leftbtn:SetEnable(false)
    elseif attr.ScrollPos == attr.RangeEnd then
        rightbtn:SetEnable(false)
    end
end

function UpdatePos(self)              
    local attr = self:GetAttribute()
    local type_ = attr.Type
                
    local left,top,right,bottom = self:GetObjPos()
    local width = right - left
    local height = bottom - top
    
    local bkn = self:GetControlObject("scrollbar.bkn")
    bkn:SetObjPos(0,0,width, height)
    bkn:SetVisible(true)
    local leftBtn = self:GetControlObject("scrollbar.leftbtn")
    local rightBtn = self:GetControlObject("scrollbar.rightbtn")

    if type_ == 0 then
        leftBtn:SetObjPos(0, 0, attr.SideBtnLength, height)
    else 
        leftBtn:SetObjPos(0, 0, width, attr.SideBtnLength)
    end
                
    if type_ == 0 then
        rightBtn:SetObjPos(width - attr.SideBtnLength, 0, width, height)
    else 
        rightBtn:SetObjPos(0, height - attr.SideBtnLength, width, height)
    end
    
    self:UpdateThumbPos()			
end

function GetThumbPos(self)
    local attr = self:GetAttribute()
    local thumbBtn = self:GetControlObject("scrollbar.thumbbtn")
    local thumbLeft, thumbTop, thumbRight, thumbBottom = thumbBtn:GetObjPos()
    if attr.Type == 0 then
        return thumbLeft
    else
        return thumbTop
    end
end

function GetThumbHeight(self)
	local attr = self:GetAttribute()
    local thumbBtn = self:GetControlObject("scrollbar.thumbbtn")
    local thumbLeft, thumbTop, thumbRight, thumbBottom = thumbBtn:GetObjPos()
    if attr.Type == 0 then
        return thumbRight - thumbLeft
    else
        return thumbBottom - thumbTop
    end
end

function SetThumbPos(self, newPos)
    local attr = self:GetAttribute()
    local thumbBtn = self:GetControlObject("scrollbar.thumbbtn")
    local thumbLeft, thumbTop, thumbRight, thumbBottom = thumbBtn:GetObjPos()
    local thumbWidth = thumbRight - thumbLeft
    local thumbHeight = thumbBottom - thumbTop
    local left,top,right,bottom = self:GetObjPos()
    local thumbLength
    
    if attr.Type == 0 then
        if newPos < attr.SideBtnLength then
            newPos = attr.SideBtnLength
        elseif newPos > right -left - attr.SideBtnLength - thumbWidth then
            newPos = right - left - attr.SideBtnLength - thumbWidth
        end
        
        thumbLeft = newPos
        thumbRight = thumbLeft + thumbWidth
        trackLength = right - left - attr.SideBtnLength * 2
        thumbLength = thumbWidth
    else
        if newPos < attr.SideBtnLength then
            newPos = attr.SideBtnLength
        elseif newPos > bottom -top - attr.SideBtnLength - thumbHeight then
            newPos = bottom - top - attr.SideBtnLength - thumbHeight
        end
        
        thumbTop = newPos
        thumbBottom = thumbTop + thumbHeight
        trackLength = bottom - top - attr.SideBtnLength * 2
        thumbLength = thumbHeight
    end
    
    local newScrollPos = (newPos - attr.SideBtnLength) * (attr.RangeEnd - attr.RangeBegin) / (trackLength - thumbLength) + attr.RangeBegin
    thumbBtn:SetObjPos(thumbLeft, thumbTop, thumbRight, thumbBottom)
    attr.ScrollPos = newScrollPos
    if attr.Type == 0 then
        self:FireExtEvent("OnHScroll", 4, newScrollPos)
    else
        self:FireExtEvent("OnVScroll", 4, newScrollPos)
    end
end

function SetScrollPos(self, newPos, update)
    local attr = self:GetAttribute()
    
    if newPos < attr.RangeBegin then
        newPos = attr.RangeBegin
    elseif newPos > attr.RangeEnd then
        newPos = attr.RangeEnd
    end
    
    attr.ScrollPos = newPos
    if update then
        self:UpdateThumbPos()
    end
end

function SetScrollRange(self, rangeBegin, rangeEnd, update)
    local attr = self:GetAttribute()
    
    if rangeBegin > rangeEnd then
        return
    end
    
    attr.RangeBegin = rangeBegin
    attr.RangeEnd = rangeEnd
    
    if attr.ScrollPos > attr.RangeEnd then
        attr.ScrollPos = attr.RangeEnd
    end
    
    if update then
        self:UpdateThumbPos()
    end
end

function GetScrollPos(self)
    local attr = self:GetAttribute()
    return attr.ScrollPos
end

function GetScrollRange(self)
    local attr = self:GetAttribute()
    return attr.RangeBegin, attr.RangeEnd
end

function GetPageSize(self)
    local attr = self:GetAttribute()
    return attr.PageSize
end

function SetPageSize(self ,pagesize, update)
    local attr = self:GetAttribute()
    attr.PageSize = pagesize
    if update then
        self:UpdateThumbPos()
    end
end

function LBtn_OnLeftBtnDown(self)
    local sb = self:GetOwnerControl()
    local attr = sb:GetAttribute()

    if attr.Type == 0 then
        sb:FireExtEvent("OnHScroll", 1,0)
    else
        sb:FireExtEvent("OnVScroll", 1,0)
    end
    return 0, true
end

function RBtn_OnLeftBtnDown(self)   
    local sb = self:GetOwnerControl()
    local attr = sb:GetAttribute()

    if attr.Type == 0 then
        sb:FireExtEvent("OnHScroll", 2,0)
    else
        sb:FireExtEvent("OnVScroll", 2,0)
    end
    return 0, true
end

function ThumbBtn_OnMouseMove(self, x, y, flag)   
    local sb = self:GetOwnerControl()
    local sleft,stop,sright,sbottom = sb:GetObjPos()
    local attr = sb:GetAttribute()
    
    if not attr.TrackMouse then
        return 0, false
    end
    
    if BitAnd(flag, 1) == 0 then
        return 0, false
    end
    
    --[[if flag == 0 then
        return 0, true
    end]]
    
    local left,top,right,bottom = self:GetObjPos()

    local offset
    if attr.Type == 0 then
        x = left + x
        offset = x - attr.TrackMousePos
        attr.TrackMousePos = x
    else
        y = top + y
        offset = y - attr.TrackMousePos
        attr.TrackMousePos = y
    end
    
    local id = GetTipID(sb)
	local tempObj = sb:GetControlObject(id)
	if tempObj then
	    local l,t,r,b = tempObj:GetObjPos()
	    if attr.Type == 1 then
		    tempObj:SetObjPos(l,t+offset,r,b+offset)
		else
		    --tempObj:SetObjPos(l+offset,t,r+offset,b)
		end
    else
        if attr.ShowTipInFirst then
            if attr.Type == 1 then
                AddTip(sb, 20, y)
                self:FireExtEvent("OnShowTip")
            else
                --AddTip(sb, x-50, sbottom-stop-10)
            end
        end
	end
    
    if offset == 0 then
        return 0, false
    elseif offset < 0 then
        if attr.ScrollPos <= attr.RangeBegin then
            return 0, false
        end
    elseif attr.ScrollPos >= attr.RangeEnd then
        return 0, false
    end
    
    
	
    
    if attr.Type == 0 then
        sb:SetThumbPos(left + offset)
    else
        sb:SetThumbPos(top + offset)
    end

    return 0, false
end

function ThumbBtn_OnLeftBtnDown(self, x, y)   
    local sb = self:GetOwnerControl()
    local attr = sb:GetAttribute()
    local left, top, right, bottom = self:GetObjPos()
    attr.TrackMouse = true
    self:SetCaptureMouse(true)
    if attr.Type == 0 then
        attr.TrackMousePos = x + left
    else
        attr.TrackMousePos = y + top
    end
    return 0, true
end

function ThumbBtn_OnLeftBtnUp(self)    
    local sb = self:GetOwnerControl()
    local attr =sb:GetAttribute()
    self:SetCaptureMouse(false)
    attr.TrackMouse = false
    attr.TrackMousePos = 0
    RemoveTip(sb)
    return 0, true
end

function OnBind(self)
    local attr = self:GetAttribute()
    attr.TrackMousePos = 0
    attr.OldTop = 0
    --设置背景
    local bkn = self:GetControlObject("scrollbar.bkn")
    bkn:SetTextureID(attr.NormalBkn)
    local leftBtn = self:GetControlObject("scrollbar.leftbtn")
    local rightBtn = self:GetControlObject("scrollbar.rightbtn")
    --设置左侧箭头
    local leftBtnAttr = leftBtn:GetAttribute()
    leftBtnAttr.NormalBkgID = attr.LeftBtn_normal;
    leftBtnAttr.DownBkgID = attr.LeftBtn_down;
    leftBtnAttr.HoverBkgID = attr.LeftBtn_hover;
    leftBtnAttr.DisableBkgID = attr.LeftBtn_normal;

    --设置右侧箭头
    local rightBtnAttr = rightBtn:GetAttribute()
    rightBtnAttr.NormalBkgID = attr.RightBtn_normal;
    rightBtnAttr.DownBkgID = attr.RightBtn_down;
    rightBtnAttr.HoverBkgID = attr.RightBtn_hover;
    rightBtnAttr.DisableBkgID = attr.RightBtn_normal;
    if attr.SideBtnLength ~= 0 then
        leftBtn:AttachListener("OnLButtonDown", false, self.LBtn_OnLeftBtnDown)
        rightBtn:AttachListener("OnLButtonDown",false, self.RBtn_OnLeftBtnDown)
    end
    
    --设置拖动按钮
    local thumbBtn = self:GetControlObject("scrollbar.thumbbtn")
    local thumbBtnAttr = thumbBtn:GetAttribute()
    thumbBtnAttr.NormalBkgID = attr.ThumbBtn_normal;
    thumbBtnAttr.DownBkgID = attr.ThumbBtn_down;
    thumbBtnAttr.HoverBkgID = attr.ThumbBtn_hover;
    thumbBtnAttr.DisableBkgID = attr.ThumbBtn_normal;
    
    self:UpdatePos()
    
    local left,top,right,bottom = self:GetObjPos()
    self:PushDirtyRect(left, top, right, bottom)
    
    thumbBtn:AttachListener("OnMouseMove",false, self.ThumbBtn_OnMouseMove)
    thumbBtn:AttachListener("OnLButtonDown",false, self.ThumbBtn_OnLeftBtnDown)
    thumbBtn:AttachListener("OnLButtonUp",false, self.ThumbBtn_OnLeftBtnUp)
end

function OnPosChange(self)   
	local attr = self:GetAttribute()
	if not attr.ShowOnPosChange then
		return
	end
    if not self:GetOwner() then
        return
    end
    self:UpdatePos()
end

function OnLButtonDown(self, x, y)
    local attr = self:GetAttribute()

    local thumbBtn = self:GetControlObject("scrollbar.thumbbtn")
    local left, top, right, bottom = thumbBtn:GetObjPos();
    local upordown
    local attr = self:GetAttribute()
    if attr.Type == 0 then
        if x < left then
            self:FireExtEvent("OnHScroll", 3, -1)
        elseif x > right then
            self:FireExtEvent("OnHScroll", 3, 1)
        end
    else
        if y < top then
            self:FireExtEvent("OnVScroll", 3, -1)
        elseif y > bottom then
            self:FireExtEvent("OnVScroll", 3, 1)
        end
    end
end

function OnMouseMove(self)
    self:SetState(1)
end

function OnMouseLeave(self, x, y)
    local left, top, right, bottom = self:GetObjPos()
    local width, height = right - left, bottom - top
    if x < 0 or x > width or y <= 0 or y >= height then
        self:SetState(0)
    end
end

function OnButtonMouseMove(self, name, x, y)
    local scrollbar = self:GetOwnerControl()
    scrollbar:SetState(1)
	
    local attr = scrollbar:GetAttribute()
	if attr.HoverDecorateID then
		local decorate = self:GetControlObject("scrollbar.decorate")
		--decorate:SetResID(attr.HoverDecorateID)
	end
	local absLeft, absTop, absRight, absBottom = self:GetAbsPos()
	local owner = self:GetOwnerControl()
	owner:FireExtEvent("OnMousePosEvent", absLeft + x, absTop + y)
end

function OnButtonMouseDown(self)
    local scrollbar = self:GetOwnerControl()	
    local attr = scrollbar:GetAttribute()
	if attr.DownDecorateID then
		local decorate = self:GetControlObject("scrollbar.decorate")
		decorate:SetResID(attr.DownDecorateID)
	end
end

function OnBtnLButtonDown(self, x, y)
	local absl, abst, absr, absb = self:GetAbsPos()
	local ownerObj = self:GetOwnerControl()
	ownerObj:FireExtEvent("OnButtonClickEvent", 1, absl + x, abst + y)
end

function OnBtnLButtonUp(self, x, y)
	local absl, abst, absr, absb = self:GetAbsPos()
	local ownerObj = self:GetOwnerControl()
	ownerObj:FireExtEvent("OnButtonClickEvent", 2, absl + x, abst + y)
end

function OnButtonMouseLeave(self, name, x, y)
    local scrollbar = self:GetOwnerControl()
    local attr = scrollbar:GetAttribute()
    local btnleft, btntop, btnright, btnbottom = self:GetObjPos()
    local sbleft, sbtop, sbright, sbbottom = scrollbar:GetObjPos()
    if attr.Type == 1 then
        if x + btnleft <= sbleft or x + btnleft >= sbright then
            scrollbar:SetState(0)
        end
    else
        if y + btntop <= sbtop or y + btntop >= sbbottom then
            scrollbar:SetState(0)
        end
    end
	
	if attr.NormalDecorateID then
		local decorate = self:GetControlObject("scrollbar.decorate")
		decorate:SetResID(attr.NormalDecorateID)
	end
	local absLeft, absTop, absRight, absBottom = self:GetAbsPos()
	local owner = self:GetOwnerControl()
	owner:FireExtEvent("OnMousePosEvent", absLeft + x, absTop + y)
end

function OnInitControl(self)
    local attr = self:GetAttribute()
    local leftBtn = self:GetControlObject("scrollbar.leftbtn")
    local rightBtn = self:GetControlObject("scrollbar.rightbtn")
	
	OnVisibleChange(self, self:GetVisible())
	
	local thumbbtn = self:GetControlObject("scrollbar.thumbbtn")
	local decorate = thumbbtn:GetControlObject("scrollbar.decorate")
	if attr.NormalDecorateID then
		decorate:SetResID(attr.NormalDecorateID)
	end
	if attr.Type == 0 then	--横滚动条
		decorate:SetObjPos("(father.width-5)/2", 0, "(father.width-5)/2+5", "father.height")
	else
		decorate:SetObjPos(0, "(father.height-5)/2", "father.width", "(father.height-5)/2+5")
	end
end

function OnMouseWheel(self, x, y, distance)
    self:FireExtEvent("OnScrollBarMouseWheel", x, y, distance)
end

function ThumbBtn__OnMouseWheel(self, x, y, distance)
    local sb = self:GetOwnerControl()
    sb:OnMouseWheel(x, y, distance)
end

function OnKeyDown(self, uChar, uRepeatCount)
	local attr = self:GetAttribute()
	if not attr.UseKeyEvent then
		return
	end
	if uRepeatCount ~= 1 then
		return
	end
	local direction = 0
	local attr = self:GetAttribute()
	local shell = XLGetObject( "CoolJ.OSShell" )
	if attr.Type == 1 and 40 == uChar and shell:GetKeyState( 17 ) >= 0 then		-- VK_DOWN 40
		direction = 2
	elseif attr.Type == 1 and 38 == uChar and shell:GetKeyState( 17 ) >= 0 then		-- VK_UP 38
		direction = 1
	elseif attr.Type == 0 and 37 == uChar and shell:GetKeyState( 17 ) >= 0 then		-- VK_LEFT 37
		direction = 1
	elseif attr.Type == 0 and 39 == uChar and shell:GetKeyState( 17 ) >= 0 then		-- VK_RIGHT 39
		direction = 2	
	end
	if direction == 0 then
		return
	end
	if attr.Type == 0 then
		self:FireExtEvent("OnHScroll", direction,0)
	else
		self:FireExtEvent("OnVScroll", direction,0)
	end
end

function SetFirstTip(self, isShowTip)
    local attr = self:GetAttribute()
    if isShowTip ~= attr.ShowTipInFirst then
        attr.ShowTipInFirst = isShowTip
    end
end

function OnEnableChange(self, enable)
    local thumbtn = self:GetControlObject("scrollbar.thumbbtn")
    local leftbtn = self:GetControlObject("scrollbar.leftbtn")
    local rightbtn = self:GetControlObject("scrollbar.rightbtn")
    if enable then
        self:UpdateThumbPos()
    else
        thumbtn:SetVisible(enable)
        leftbtn:SetEnable(enable)
        rightbtn:SetEnable(enable)
    end
end

function OnVisibleChange(self, visible)
    local bkg = self:GetControlObject("scrollbar.bkn")
    bkg:SetChildrenVisible(visible)
    bkg:SetVisible(visible)
    --self:SetVisible(visible)
end