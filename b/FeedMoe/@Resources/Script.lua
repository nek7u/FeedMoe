-- 20191122.0001
function Initialize()
	-- nessesary 'UpdateDivider=-1' in Measure=Script section, or 'function Update()' is called every seconds.([Update=1000]*UpdateDivider)
	SKIN:Bang('!SetOption', SELF:GetName(), 'UpdateDivider', -1)
	-- global, feedreader executed status
	fres = 0
	-- BACKGROUND_STYLE
	if(nil==SKIN:GetVariable('BACKGROUND_STYLE')) then
		SKIN:Bang('!WriteKeyValue', 'Variables', 'BACKGROUND_STYLE', '0')
	end
	-- GetVariable returns string value. and GetVariable('variable', default) not work?
	local mi = SKIN:GetVariable('MAX_ITEMS')
	if(nil==tonumber(mi)) then mi = 8 -- 8: default value
	else mi = math.floor(tonumber(mi)) end
	mi = math.min(math.max(mi, 1), 20) -- 20: MeterItem count.
	-- Update interval minuts(1-)
	local fuim = SKIN:GetVariable('FEED_UPDATE_INTERVAL_MINUTES')
	if(nil==tonumber(fuim)) then fuim = 10 -- 10: default value
	else fuim = math.floor(tonumber(fuim)) end
	fuim = math.max(fuim, 1)
	SKIN:Bang('!SetVariable', 'FEED_UPDATE_INTERVAL_MINUTES', fuim)
end

function f_feedreader_execute_before()
	-- global, feedreader executed status
	fres = 1
end

function f_feedreader_execute_after()
	-- retrieve feed title from xml.
	local ft = SKIN:GetVariable('FEED_TITLE', '')
	if(''==ft) then
		SKIN:Bang('!SetOption', 'MeterFeedTitle', 'MeasureName', 'MeasureFeedTitle')
		SKIN:Bang('!SetOption', 'MeterFeedTitle', 'Text', '%1')
	end
	-- bind measure to meter.
	local mi
	local i,j = 1,1
	local mx = tonumber(SKIN:GetVariable('MAX_ITEMS'))
	local ic = tonumber(SKIN:GetMeasure('MeasureItemCount'):GetStringValue())
	-- lua does and not support regex and '(abc|def)'.
	local ilus = '^'..SKIN:GetVariable('ITEM_LINK_URI_SCHEME', 'https?')..'://.+'
	while(j<=40) -- 40: MeasureItem(Title|Link) count.
	do
		if(''~=SKIN:GetMeasure('MeasureItemTitle'..j):GetStringValue() and string.find(SKIN:GetMeasure('MeasureItemLink'..j):GetStringValue(), ilus)) then
			mi = 'MeterItem'..i
			SKIN:Bang('!SetOption', mi, 'MeasureName', ('MeasureItemTitle'..j))
			SKIN:Bang('!SetOption', mi, 'MeterStyle', 'MeterItem')
			SKIN:Bang('!SetOption', mi, 'LeftMouseUpAction', ('[MeasureItemLink'..j..']'))
			SKIN:Bang('!UpdateMeter', mi)
			i = i + 1
		end
		if(i>mx) then break end
		j = j + 1
		if(j>ic) then break end
	end
	-- reset unused MeterItem(s)
	local k = i
	while(k<=20) -- 20: MeterItem count.
	do
		mi = 'MeterItem'..k
		SKIN:Bang('!SetOption', mi, 'MeasureName', '')
		SKIN:Bang('!SetOption', mi, 'MeterStyle', '')
		SKIN:Bang('!SetOption', mi, 'LeftMouseUpAction', '')
		SKIN:Bang('!UpdateMeter', mi)
		k = k + 1
	end
	-- define MeterBackgroundBody height.
	if(0<SKIN:GetMeter('MeterItem1'):GetH()) then
		SKIN:Bang('!SetOption', 'MeterBackgroundBody', 'H', (SKIN:GetMeter('MeterItem1'):GetH()*(i-1)+SKIN:GetVariable('SKIN_BACKGROUND_BODY_PADDING')*2))
	end
	SKIN:Bang('!UpdateMeter', 'MeterBackgroundBody')

	SKIN:Bang('!UpdateMeterGroup', 'GrpBody')
	-- !Redraw: redraw immediately. !RedrawGroup: redraw after Update=xxxx ms.
	SKIN:Bang('!Redraw')
	-- if 0 item by feed, keyword or url filtering, set BACKGROUND_STYLE=0
	if(1==i) then
		--f_skin_refresh(0)
		SKIN:Bang('!SetVariable', 'BACKGROUND_STYLE', 0)
	end
	-- global, feedreader executed status
	fres = 0
end

function f_feedreader_update()
	if(1==fres) then
		SKIN:Bang('!DisableMeasure', 'MeasureFeedReader')
		SKIN:Bang('!SetOption', 'MeterFeedTitle', 'Text', 'error.')
		f_skin_refresh(0)
	end
end

function f_skin_refresh(a)
	-- skin background visible or invisible
	local bi = SKIN:GetVariable('BACKGROUND_INVISIBLE')
	if(nil==tonumber(bi)) then bi = 0 else bi = tonumber(bi) end
	if(1==bi) then
		SKIN:Bang('!SetOption', 'MeterBackgroundHeader', 'MeterStyle', 'MeterBackground|MeterBackgroundInvisible')
		SKIN:Bang('!SetOption', 'MeterBackgroundBody', 'MeterStyle', 'MeterBackground|MeterBackgroundInvisible')
		SKIN:Bang('!SetOption', 'MeterLine', 'MeterStyle', 'MeterLineVisible')
	else
		SKIN:Bang('!SetOption', 'MeterBackgroundHeader', 'MeterStyle', 'MeterBackground|MeterBackgroundHeaderVisible')
		SKIN:Bang('!SetOption', 'MeterBackgroundBody', 'MeterStyle', 'MeterBackground|MeterBackgroundBodyVisible')
		SKIN:Bang('!SetOption', 'MeterLine', 'MeterStyle', 'MeterLineInvisible')
	end
	-- a: BACKGROUND_STYLE=(0|1|2)
	if(2==a) then
		SKIN:Bang('!ShowMeterGroup', 'GrpBody')
		SKIN:Bang('!HideMeterGroup', 'GrpHeader')
	elseif(1==a) then
		SKIN:Bang('!ShowMeterGroup', 'GrpHeader')
		SKIN:Bang('!HideMeterGroup', 'GrpBody')
	else
		SKIN:Bang('!ShowMeterGroup', 'GrpHeader')
		SKIN:Bang('!ShowMeterGroup', 'GrpBody')
	end
	SKIN:Bang('!UpdateMeterGroup', 'GrpHeader')
	SKIN:Bang('!UpdateMeterGroup', 'GrpBody')
	SKIN:Bang('!Redraw')
end
