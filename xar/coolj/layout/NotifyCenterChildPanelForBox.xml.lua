local table_data = {}
table.insert(table_data, {type="紧急呼叫", title="", datetime=""})

function OnInitControl(self)
	local attr = self:GetAttribute()
end

function NLH_SetText(self, text)
	local obj = self:GetControlObject("text")
	obj:SetText(text)
end

function NLH_GetText(self)
	local obj = self:GetControlObject("text")
	return obj:GetText()
end

function LIST_OnInitControl(self)
	for i=1, 30 do
		local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
		local obj = objFactory:CreateUIObject("listitem."..i, "CoolJ.NotifyBox.Left.Head")
		obj:SetText(i.."")
		local attr = obj:GetAttribute()
		obj:SetObjPos(0,0,attr.Width,attr.Height)
		self:InsertItem(obj)
	end
	
end