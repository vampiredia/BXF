--[[
-- 指定日期是否可用，可用则返回日期相关的table，否则返回nil
	hour		8
	month_days	28
	min			0
	wday		5		-- 当天星期，星期天为1
	day			28		-- 当天日期
	month		2		-- 当天月份
	year		2013	-- 当天年份
	sec			0		-- 当前时间秒数，默认0
	yday		59		-- 当天是今年的第几天
	isdst		false	
]]
function IsDateValid(date_string)
	local date_table = {}

	while(true) do
		local pos = string.find(date_string, "-")
		if not pos then
			if string.len(date_string) > 0 then
				date_table[#date_table+1] = date_string
			end
			break
		end

		local sub_str = string.sub(date_string, 1, pos - 1)
		if string.len(sub_str) > 0 then
			date_table[#date_table+1] = sub_str
		end
		date_string = string.sub(date_string, pos+1, #date_string)
	end

	if table.getn(date_table) ~= 3 then
		return nil
	end

	local year = tonumber(date_table[1])
	local month = tonumber(date_table[2])
	local day = tonumber(date_table[3])

	if year == nil or month == nil or day == nil then
		return nil
	end

	if year < 1970 or year >= 2200 then
		return nil
	end

	if month < 1 or month > 12 then
		return nil
	end


	local small_month = {4, 6, 9, 11}
	local month_days = 31

	for i=0, table.getn(small_month) do
		if month == small_month[i] then
			month_days = 30
			break
		end
	end

	if month == 2 then
		if year % 4 == 0 then
			month_days = 29
		else
			month_days = 28
		end
	end

	if day < 1 or day > month_days then
		return nil
	end


	local cur_time = {
		year=year,
		month=month,
		day=1,
		hour=8,
		sec=0
	}
	local table_time = os.date("*t", os.time(cur_time))
	if table_time ~= nil then
		table_time["mday"] = month_days
		table_time["cday"] = day
	end

	return table_time
end


function GetCurDate(year, month, day)
	if year == nil then
		year = os.date("%Y")
	end
	if month == nil then
		month = os.date("%m")
	end
	if day == nil then
		day = os.date("%d")
	end
	local cur_time = {
		year=year,
		month=month,
		day=1,
		hour=8,
		sec=0
	}
	local table_time = os.date("*t", os.time(cur_time))
	table_time["cday"] = day

	local small_month = {4, 6, 9, 11}
	local month_days = 31

	for i=0, table.getn(small_month) do
		if month == small_month[i] then
			month_days = 30
			break
		end
	end

	if month == 2 then
		if year % 4 == 0 then
			month_days = 29
		else
			month_days = 28
		end
	end
	table_time["mday"] = month_days

	return table_time
end


function GetDisplayTitle(table_time)
	local month_chs = {
		"一月",
		"二月",
		"三月",
		"四月",
		"五月",
		"六月",
		"七月",
		"八月",
		"九月",
		"十月",
		"十一月",
		"十二月",
	}
	return table_time["year"] .. "  " .. month_chs[table_time["month"]]
end

function OnInitControlCalendarCtrl(self)
	self:SetDefaultRedirect("control")
	local headerObj = self:GetControlObject("calendar.header")
	if headerObj == nil then
		return
	end
	
	local table_time = GetCurDate()
	local text = table_time["year"] .. "-" .. string.format("%02d", table_time["month"]) .. "-" .. string.format("%02d", table_time["cday"])
	headerObj:SetDate(text)
	
	OnInitControlHeader(self)
end


function OnInitControlHeader(self)	
	local gridObj = self:GetControlObject("calendar.header")
	if gridObj == nil then
		return
	end

	-- title
	local text = gridObj:GetDate()
	local table_time = IsDateValid(text)
	if table_time ~= nil then 
		local gridTitleObj = self:GetControlObject("text.calendar.grid.title")
		if gridTitleObj ~= nil then
			gridTitleObj:SetText(GetDisplayTitle(table_time))
		end
	end
	
	InitCalendarDate(self)
	UpdateCalendarDate(self, table_time)
end

function InitCalendarDate(self)
	local objDayGrid = self:GetControlObject("layout.calendar.grid.day")
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	for i=1, 31 do
		local objBtnItem = objFactory:CreateUIObject(i, "WHome.CalendarItem")
		local objBtn = objBtnItem:GetControlObject("btn.calendar.item")
		objBtn:SetText(i .. "")
		objDayGrid:AddChild(objBtnItem)
		objBtnItem:SetVisible(false)
		objBtnItem:SetChildrenVisible(false)
	end
end

function UpdateCalendarDate(self, table_time)
	local attr = self:GetAttribute()
	
	local n = 8 - table_time["wday"]
	local l = math.floor((table_time["mday"] - n) / 7) + 1
	local r = 7
	local height = attr.TopCalendarItem * 2 + l * attr.WidthCalendarItem + (l-1)*attr.MarginCalendarItem
	local width = attr.LeftCalendarItem + 7 * attr.WidthCalendarItem + 7 * attr.MarginCalendarItem
	
	local table_position = {}
	local left = attr.LeftCalendarItem
	local top = attr.TopCalendarItem
	for i = 1, l do
		for j = 1, 7 do
			table.insert(table_position, {
				left=left,
				top=top,
				right=left+attr.WidthCalendarItem,
				bottom=top+attr.WidthCalendarItem
			})
			left = (left + attr.WidthCalendarItem + attr.MarginCalendarItem) % width
		end
		left = attr.LeftCalendarItem
		top = top + attr.WidthCalendarItem + attr.MarginCalendarItem
	end
	local table_property = {}
	local pos = table_time["wday"] - 1
	local objDayGrid = self:GetControlObject("layout.calendar.grid.day")
	for i = 1, table_time["mday"] do
		local objBtnItem = objDayGrid:GetChildByIndex(i-1)
		local objBtn = objBtnItem:GetControlObject("btn.calendar.item")
		objBtnItem:SetObjPos(table_position[pos]["left"], table_position[pos]["top"], table_position[pos]["right"], table_position[pos]["bottom"])
		objBtnItem:SetVisible(true)
		objBtnItem:SetChildrenVisible(true)
		pos = pos + 1
	end
	for i = table_time["mday"]+1, 31 do
		local objBtnItem = objFactory:GetChildByIndex(i-1)
		objBtnItem:SetVisible(false)
		objBtnItem:SetChildrenVisible(false)		
	end
	
	--
	local objWeekGrid = self:GetControlObject("layout.calendar.grid.week")
	for i = 0, objWeekGrid:GetChildCount()-1 do
		local obj = objWeekGrid:GetChildByIndex(i)
		obj:SetVisible(true)
		obj:SetChildrenVisible(true)
	end
end


function EDIT_OnFocusChange(self, focus)
	if focus == true then
		
	else
	
	end
end


function GetDate(self)
	--[[
	-- 日期控件
	-- 如果edittext控件为nil或者非标准日期，返回当前系统获取到的日期
	-- 标准日期：2014-05-26，日期是否非法
	-- 否则根据给定日期弹出日期选择控件
	-- 
	]]
	local edit = self:GetControlObject("calendar.input.edit")
	if edit ~= nil then
		return edit:GetText()
	end
end

function SetDate(self, text)
	local edit = self:GetControlObject("calendar.input.edit")
	if edit ~= nil then
		edit:SetText(text)
	end
end


function BTN_OnClickPrePage(self)
	
end