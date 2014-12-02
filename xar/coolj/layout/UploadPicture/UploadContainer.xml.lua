

function OnInitControl(self)
	local attr = self:GetAttribute()
	
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	local itemObj = self:GetControlObject("item")
	local itemWidth = attr.ItemWidth + attr.Margin*2
	local itemHeight = attr.ItemHeight + attr.Margin*2
	for i=1, attr.MaxNum do
		local name = "item."..i
		local obj = objFactory:CreateUIObject(name, "CoolJ.Upload.ItemForImage")
		
		local left = attr.Margin + ((i-1) % attr.ColumnNum) * itemWidth
		local right = left + attr.ItemWidth
		local top = attr.Margin + math.floor((i-1) / attr.ColumnNum) * itemHeight
		local bottom = top + attr.ItemHeight
		obj:SetObjPos(left, top, right, bottom)
		
		itemObj:AddChild(obj)
	end
end