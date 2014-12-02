function TAI_OnInitControl(self)
	local attr = self:GetAttribute()
end

function TAI_OnClick(self)
	local shell = XLGetObject( "CoolJ.OSShell" )
	--XLMessageBox(shell:UUID())

	local ctrl = self:GetOwnerControl():GetOwnerControl()
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	
	local obj = objFactory:CreateUIObject(shell:UUID(), "CoolJ.TableFAQItem")
	obj:SetCaptionText(math.random(0, 9999))
	obj:SetAnswerText(math.random(0, 9999))
	local oattr = obj:GetAttribute()
	oattr.MoveEnable = true
	ctrl:AddItem(obj)
	
end