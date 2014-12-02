

function OnInitControl(self)

end

function OnLButtonDown(self, x, y, flags)
	local ctrl = self:GetOwnerControl()
	local attr = ctrl:GetAttribute()
	attr.OnClick = true
end

function OnLButtonUp(self, x, y, flags)
	local ctrl = self:GetOwnerControl()
	local attr = ctrl:GetAttribute()
	ctrl:LoadImage()
	
	attr.OnClick = false
end

function OnMouseEnter(self)

end

function OnMouseLeave(self)

end

-- 等比例拉伸图像用以显示
function StrectchImage(self, image)
	if image == nil then return end
	
	local str, width, height, length = image:GetInfo()
	local l,t,r,b = self:GetObjPos()
	local w = r-l
	local h = b-t
	
	local scale = math.max(width/w, height/h)
	return image:Stretch(width/scale, height/scale)
end

--
function LoadImage(self)
	local osshell = XLGetObject("CoolJ.OSShell")
	-- file open dialog
	local filename, filepath = osshell:FileOpenDialog("image")
	if not filepath then return end
	
	local imagecore = XLGetObject("CoolJ.ImageCore")
	local bitmap = imagecore:LoadImage(filepath)
	if not bitmap then return end
	
	local imageObj = self:GetControlObject("image")
	imageObj:SetBitmap(self:StrectchImage(bitmap))	
end