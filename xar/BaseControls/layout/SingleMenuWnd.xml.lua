function OnEndMenu(self)
	local tree = self:GetBindUIObjectTree()
	if tree then
		_G["gShowMenu"] = false
		local menu = tree:GetRootObject()
		menu:AnimateHide()
	end
end

function OnPopupMenu(self)
	local menuTree = self:GetBindUIObjectTree()
	local context = menuTree:GetRootObject()
	context:AnimateShow()
end

