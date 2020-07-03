--20200703
--UTF-16LE BOM / UCS-2 LE BOM

function Initialize()
	-- global, FeedReader executed status, it is for detecting network errors.
	fres = 0
end

function FeedReader_ExecuteBefore()
	fres = 1
end

function FeedReader_ExecuteAfter()
	-- get Title from xml feed.
	local ft = SKIN:GetVariable('FEED_TITLE', '')
	if(''==ft) then
		SKIN:Bang('!SetOption', 'mtFeedTitle', 'MeasureName', 'msFeedTitle')
		SKIN:Bang('!SetOption', 'mtFeedTitle', 'Text', '%1')
	end
	-- bind measure to meter.
	local mi
	local i,j = 1,1
	local mx = tonumber(SKIN:GetVariable('MAX_ITEMS'))
	local ic = tonumber(SKIN:GetMeasure('msItemCount'):GetStringValue())
	-- lua does not support regex and '(abc|def)'.
	local ilus = '^'..SKIN:GetVariable('ITEM_LINK_URI_SCHEME', 'https?')..'://.+'
	while(j<=40) -- 40: msItem(Title|Link) count.
	do
		if(''~=SKIN:GetMeasure('msItemTitle'..j):GetStringValue() and string.find(SKIN:GetMeasure('msItemLink'..j):GetStringValue(), ilus)) then
			mi = 'mtItem'..i
			SKIN:Bang('!SetOption', mi, 'MeasureName', ('msItemTitle'..j))
			SKIN:Bang('!SetOption', mi, 'MeterStyle', 'stItem')
			SKIN:Bang('!SetOption', mi, 'ToolTipText', ('[msItemLink'..j..']'))
			SKIN:Bang('!SetOption', mi, 'LeftMouseUpAction', ('[msItemLink'..j..']'))
			SKIN:Bang('!SetOption', mi, 'DynamicVariables', 1)
			SKIN:Bang('!UpdateMeter', mi)
			i = i + 1
		end
		if(i>mx) then break end
		j = j + 1
		if(j>ic) then break end
	end
	-- reset unused mtItem(s).
	local k = i
	while(k<=20) -- 20: mtItem count.
	do
		mi = 'mtItem'..k
		SKIN:Bang('!SetOption', mi, 'MeasureName', '')
		SKIN:Bang('!SetOption', mi, 'MeterStyle', '')
		SKIN:Bang('!SetOption', mi, 'ToolTipText', '')
		SKIN:Bang('!SetOption', mi, 'LeftMouseUpAction', '')
		SKIN:Bang('!SetOption', mi, 'DynamicVariables', 0)
		SKIN:Bang('!UpdateMeter', mi)
		k = k + 1
	end
	-- current item count = i-1
	SKIN:Bang('!SetVariable', 'ITEMS_COUNT', i-1)
	-- if 0 item by feed, keyword or url filtering, hide mtBackground_Body
	if(1==i) then SKIN:Bang('!SetVariable', 'SHOW_BODY', 0) end
	SKIN:Bang('!UpdateMeasure', 'msAction_TOGGLE_BODY')
	fres = 0
end

function FeedReader_Update()
	-- 1: msFeedReader process has not been completed normally.
	if(1==fres) then
		SKIN:Bang('!DisableMeasure', 'msFeedReader')
		SKIN:Bang('!SetOption', 'mtFeedTitle', 'Text', 'error.')
		SKIN:Bang('!UpdateMeter', 'mtFeedTitle')
		SKIN:Bang('!SetVariable', 'SHOW_HEADER', 1)
		SKIN:Bang('!UpdateMeasure', 'msAction_TOGGLE_HEADER')
	end
end

--[=====[
--]=====]
