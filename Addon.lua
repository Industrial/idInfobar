--[[----------------------------------------------------------------------------
  Copyright (c) 2008, Tom Wieland
  All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.
  * Neither the name of idInfobar nor the names of its contributors may be used
    to endorse or promote products derived from this software without specific
    prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
  POSSIBILITY OF SUCH DAMAGE.
------------------------------------------------------------------------------]]

local _G = _G

local TL, TC, TR = 'TOPLEFT', 'TOP', 'TOPRIGHT'
local ML, MC, MR = 'LEFT', 'CENTER', 'RIGHT'
local BL, BC, BR = 'BOTTOMLEFT', 'BOTTOM', 'BOTTOMRIGHT'

local frame = CreateFrame('Button', 'idInfobarFrame', UIParent)
local textleft = frame:CreateFontString()
local textcenter = frame:CreateFontString()
local textright = frame:CreateFontString()

local fps = ''
local mem = ''
local lag = ''
local exp = ''
local loc = ''
local money = ''
local time = ''
local onupdate_time = 1

local update
local update_xp
local update_money
local move_in
local move_out
local enable
local onevent
local onupdate

function update ()
	local x,y = GetPlayerMapPosition('player')
	fps   = ('%.1ffps'):format(GetFramerate())
	mem   = ('%.2fMiB'):format(gcinfo()/1024)
	lag   = ('%sms'):format(select(3, GetNetStats()))
	time  = date('%X')
	loc   = ('%.1f,%.1f'):format(x*100, y*100)

	textleft:SetText(('%s %s %s'):format(fps, mem, lag))
	textcenter:SetText(('%s %s'):format(exp, money))
	textright:SetText(('%s %s'):format(loc, time))
end

function update_xp ()
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

	exp = out
end

function update_money ()
	local copper = GetMoney() - GetCursorMoney() - GetPlayerTradeMoney() - GetSendMailMoney()
	gold = math.floor(copper/10000)
	copper = copper - gold*10000
	silver = math.floor(copper/100)
	copper = copper - silver*100

	money = ('%sg%ss%sc'):format(gold, silver, copper)
end

function move_in ()
	frame:ClearAllPoints()
	frame:SetPoint(TL, UIParent, TL, 0, 0)
	frame:SetPoint(TR, UIParent, TR, 0, 0)
end

function move_out ()
	frame:ClearAllPoints()
	frame:SetPoint(BL, UIParent, TL, 0, -1)
	frame:SetPoint(BR, UIParent, TR, 0, -1)
end

function onupdate (frame, elapsed)
	onupdate_time = onupdate_time - elapsed
	if onupdate_time <= 0 then
		update()
		onupdate_time = 1
	end
end

function onevent (frame, event, ...)
	if event == 'PLAYER_XP_UPDATE' then
		update_xp()
	elseif event == 'PLAYER_LEVEL_UP' then
		update_xp()
	elseif event == 'PLAYER_MONEY' then
		update_money()
	end
end

textleft:SetFont(STANDARD_TEXT_FONT, 12)
textleft:SetTextColor(1, 1, 1)
textcenter:SetFont(STANDARD_TEXT_FONT, 12)
textcenter:SetTextColor(1, 1, 1)
textright:SetFont(STANDARD_TEXT_FONT, 12)
textright:SetTextColor(1, 1, 1)

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
frame:SetScript('OnLeave', move_out)
frame:SetScript('OnEnter', move_in)

textleft:SetJustifyH('LEFT')
textleft:SetJustifyV('CENTER')
textleft:SetPoint(ML, frame, ML, 5, 0)
textleft:SetPoint(MR, textcenter, ML)

textcenter:SetJustifyH('CENTER')
textcenter:SetJustifyV('CENTER')
textcenter:SetPoint(MC, frame, MC)

textright:SetJustifyH('RIGHT')
textright:SetJustifyV('CENTER')
textright:SetPoint(ML, textcenter, MR)
textright:SetPoint(MR, frame, MR, -5, 0)

move_out()
update_xp()
update_money()
update()

frame:SetScript('OnEvent', onevent)
frame:SetScript('OnUpdate', onupdate)
frame:RegisterEvent('PLAYER_XP_UPDATE')
frame:RegisterEvent('PLAYER_LEVEL_UP')
frame:RegisterEvent('PLAYER_MONEY')
