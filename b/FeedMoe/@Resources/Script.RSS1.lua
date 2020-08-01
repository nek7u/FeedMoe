--20200728
--UTF-16LE BOM / UCS-2 LE BOM

function Initialize()
	-- LOCALE_NAME
	if(''==SKIN:GetVariable('LOCALE_NAME', '')) then
		SKIN:Bang('!EnableMeasure', 'msRegistry_LocaleName')
		SKIN:Bang('!UpdateMeasure', 'msRegistry_LocaleName')
	end
	local m, n
	-- MAX_ITEMS | 1:min, 8:default, 20:max - mtItem count
	m = tonumber(SKIN:GetVariable('MAX_ITEMS'))
	n = clamp_num((nil~=m and m or 8), 1, 20)
	if(m~=n) then sw('MAX_ITEMS', n) end
	-- SHOW_HEADER, SHOW_BODY
	if('1'~=SKIN:GetVariable('SHOW_HEADER') and '1'~=SKIN:GetVariable('SHOW_BODY')) then
		sw('SHOW_HEADER', 1)
		sw('SHOW_BODY', 1)
	end
	-- [RSS1.0/RDF] FETCH_IMAGES, force disable fetch image feature.
	if('0'~=SKIN:GetVariable('FETCH_IMAGES')) then sw('FETCH_IMAGES', 0) end
	-- [RSS1.0/RDF] Setup feed measures
	SKIN:Bang('!SetOptionGroup', 'grFeed', 'Plugin', 'XmlParser')
	SKIN:Bang('!SetOptionGroup', 'grFeed', 'Source', '[msWebParser]')
	SKIN:Bang('!SetOptionGroup', 'grFeed', 'RegExpSubstitute', 1)
	local i = 1
	while(i<=40) -- 40: msItemTitle/msItemLink count.
	do
		SKIN:Bang('!SetOption', 'msItemTitle'..i, 'Query', 'string(/RDF/item['..i..']/title/text())')
		SKIN:Bang('!SetOption', 'msItemTitle'..i, 'Substitute', '#ITEM_TITLE_SUBSTITUTE#')
		SKIN:Bang('!SetOption', 'msItemLink'..i, 'Query', 'string(/RDF/item['..i..']/link/text())')
		SKIN:Bang('!SetOption', 'msItemLink'..i, 'Substitute', '#ITEM_LINK_SUBSTITUTE#')
		i = i + 1
	end
	SKIN:Bang('!UpdateMeasureGroup', 'grFeed')
end

function WebParser_Finish()
	-- [RSS1.0/RDF]
	SKIN:Bang('!EnableMeasureGroup', 'grFeed')
	SKIN:Bang('!UpdateMeasureGroup', 'grFeed')
	-- get Title from xml feed.
	if(''==SKIN:GetVariable('FEED_TITLE', '')) then
		SKIN:Bang('!SetOption', 'mtFeedTitle', 'MeasureName', 'msFeedTitle')
		SKIN:Bang('!SetOption', 'mtFeedTitle', 'Text', '%1')
		-- [RSS1.0/RDF]
		SKIN:Bang('!UpdateMeter', 'mtFeedTitle')
	end
	bind_measures()
	SKIN:Bang('!CommandMeasure', 'msWebParser', 'Reset')
end

function bind_measures()
	-- ItemCount
	local ic = tonumber(SKIN:GetMeasure('msItemCount'):GetStringValue())
	-- bind measure to meter.
	local mi, si
	local i,j = 1,1
	local mx = tonumber(SKIN:GetVariable('MAX_ITEMS'))
	-- lua does not support regex and '(abc|def)'.
	local ilus = '^'..SKIN:GetVariable('ITEM_LINK_URI_SCHEME', 'https?')..'://.+'
	while(j<=40) -- 40: msItem(Title|Link) count.
	do
		if(''~=SKIN:GetMeasure('msItemTitle'..j):GetStringValue() and string.find(SKIN:GetMeasure('msItemLink'..j):GetStringValue(), ilus)) then
			-- mtItem
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
		-- mtItem
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
end

-- [RSS1.0/RDF]
function WebParser_Error()
	SKIN:Bang('!CommandMeasure', 'msWebParser', 'Reset')
	SKIN:Bang('!DisableMeasure', 'msWebParser')
	SKIN:Bang('!SetOption', 'mtFeedTitle', 'Text', 'error.')
	SKIN:Bang('!UpdateMeter', 'mtFeedTitle')
	SKIN:Bang('!SetVariable', 'SHOW_HEADER', 1)
	SKIN:Bang('!UpdateMeasure', 'msAction_TOGGLE_HEADER')
	SKIN:Bang('!HideMeterGroup', 'grBody')
	SKIN:Bang('!UpdateMeterGroup', 'grBackground')
end

function sw(k, v)
	SKIN:Bang('!SetVariable', k, v)
	SKIN:Bang('!WriteKeyValue', 'Variables', k, v)
end

-- https://docs.rainmeter.net/snippets/clamp/
function clamp_num(num, lower, upper)
	return math.max(lower, math.min(upper, num))
end
