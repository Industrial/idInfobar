local _G = _G

local TL, TC, TR = 'TOPLEFT', 'TOP', 'TOPRIGHT'
local ML, MC, MR = 'LEFT', 'CENTER', 'RIGHT'
local BL, BC, BR = 'BOTTOMLEFT', 'BOTTOM', 'BOTTOMRIGHT'

local addon = CreateFrame('Frame')
addon.onupdate_refresh = 1
addon.onupdate_time = addon.onupdate_refresh
addon.inset = 5
addon.padding = 5

function addon.pop_in(frame)
	frame:ClearAllPoints()
	frame:SetPoint(TL, UIParent, TL)
	frame:SetPoint(TR, UIParent, TR)
end

function addon.pop_out(frame)
	frame:ClearAllPoints()
	frame:SetPoint(BL, UIParent, TL, 0, -1)
	frame:SetPoint(BR, UIParent, TR, 0, -1)
end

function addon:get_fps ()
	return ('%.1ffps'):format(GetFramerate())
end

function addon:get_ram ()
	return ('%.2fMiB'):format(gcinfo()/1024)
end

function addon:get_lag ()
	return ('%sms'):format(select(3, GetNetStats()))
end

function addon:get_money ()
	local copper = GetMoney() - GetCursorMoney() - GetPlayerTradeMoney() - GetSendMailMoney()
	gold = math.floor(copper/10000)
	copper = copper - gold*10000
	silver = math.floor(copper/100)
	copper = copper - silver*100

	return ('%sg%ss%sc'):format(gold, silver, copper)
end

function addon:get_exp ()
	local xp   = UnitXP('player')
	local max  = UnitXPMax('player')
	local left = max - xp
	local rest = GetXPExhaustion()
	local out  = (max - xp)..'xp'

	if rest then
		rest = math.floor(rest/max*100)
		if rest < 1 then
			out = out .. ' (1%)'
		else
			out = out .. ' ('..rest..'%)'
		end
	end

	return out
end

function addon:get_loc ()
	local x,y = GetPlayerMapPosition('player')
	return ('%.1f,%.1f'):format(x*100, y*100)
end

function addon:get_time ()
	return date('%X')
end

function addon:update ()
	self.texts.left.fps:SetText(self:get_fps())
	self.texts.left.ram:SetText(self:get_ram())
	self.texts.left.lag:SetText(self:get_lag())
	self.texts.center.money:SetText(self:get_money())
	self.texts.center.exp:SetText(self:get_exp())
	self.texts.right.loc:SetText(self:get_loc())
	self.texts.right.time:SetText(self:get_time())
end

function addon:PLAYER_LOGIN ()
	local frame = CreateFrame('Button', 'idInfobarFrame', UIParent)
	local texts = {
		['left'] = {},
		['center'] = {},
		['right'] = {},
	}
	local fps = frame:CreateFontString()
	local ram = frame:CreateFontString()
	local lag = frame:CreateFontString()
	local money = frame:CreateFontString()
	local exp = frame:CreateFontString()
	local loc = frame:CreateFontString()
	local time = frame:CreateFontString()

	fps:SetJustifyH('LEFT')
	ram:SetJustifyH('LEFT')
	lag:SetJustifyH('LEFT')
	money:SetJustifyH('RIGHT')
	exp:SetJustifyH('LEFT')
	loc:SetJustifyH('RIGHT')
	time:SetJustifyH('RIGHT')

	texts.left.fps = fps
	texts.left.ram = ram
	texts.left.lag = lag
	texts.center.money = money
	texts.center.exp = exp
	texts.right.loc = loc
	texts.right.time = time

	for k, v in pairs(texts) do
		for l, w in pairs(v) do
			w:SetFont(STANDARD_TEXT_FONT, 12)
			w:SetTextColor(1, 1, 1)
			w:SetJustifyV('CENTER')
		end
	end

	fps:SetPoint(ML, frame, ML, self.inset, 0)
	ram:SetPoint(ML, fps, MR, self.padding, 0)
	lag:SetPoint(ML, ram, MR, self.padding, 0)

	money:SetPoint(MR, frame, MC, -self.inset / 2, 0)
	exp:SetPoint(ML, money, MR, self.inset, 0)

	exp:SetPoint(MR, loc, ML, -self.padding, 0)
	loc:SetPoint(MR, time, ML, -self.padding, 0)
	time:SetPoint(MR, frame, MR, -self.inset, 0)

	frame:SetBackdrop({
		bgFile = 'Interface/Tooltips/UI-Tooltip-Background',
		edgeFile = '',
		tile = true,
		tileSize = 16,
		edgeSize = 0,
		insets = {
			left = 0,
			right = 0,
			top = 0,
			bottom = 0
		}
	})
	frame:SetBackdropColor(0, 0, 0, 1)

	frame:SetHeight(20)

	self.frame = frame
	self.texts = texts

	frame:SetScript('OnEnter', self.pop_in)
	frame:SetScript('OnLeave', self.pop_out)

	self:SetScript('OnUpdate', self.onupdate)

	self.pop_out(frame)
end

function addon:onevent (event, ...)
	handler = addon[event]
	if handler then
		handler(addon, ...)
	end
end

function addon:onupdate (elapsed)
	self.onupdate_time = self.onupdate_time - elapsed
	if self.onupdate_time <= 0 then
		self:update()
		self.onupdate_time = self.onupdate_refresh
	end
end

addon:SetScript('OnEvent', addon.onevent)
addon:RegisterEvent('PLAYER_LOGIN')

