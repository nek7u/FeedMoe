--20200721
--UTF-16LE BOM / UCS-2 LE BOM

function Initialize()
	-- global, FeedReader executed status, it is for detecting network errors.
	fres = 0
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
	-- ITEM_IMAGE_NODE_PATH | blank '' is not allowed as Path= | FeedReader.dll Type=ItemCustom
	if(''==SKIN:GetVariable('ITEM_IMAGE_NODE_PATH','')) then sw('ITEM_IMAGE_NODE_PATH', '_') end
	-- FETCH_IMAGES
	if('1'==SKIN:GetVariable('FETCH_IMAGES') and '_'==SKIN:GetVariable('ITEM_IMAGE_NODE_PATH')) then
		sw('FETCH_IMAGES', 0)
	end
end

function FeedReader_ExecuteBefore()
	fres = 1
	-- Fetch images feature enabled or not
	local fie = ('1'==SKIN:GetVariable('FETCH_IMAGES') and '_'~=SKIN:GetVariable('ITEM_IMAGE_NODE_PATH'))
	if(fie) then
		SKIN:Bang('!SetOptionGroup', 'grItemImageURL', 'Attribute', SKIN:GetVariable('ITEM_IMAGE_NODE_ATTRIBUTE'))
		SKIN:Bang('!SetOptionGroup', 'grItemImageURL', 'NameSpace', SKIN:GetVariable('ITEM_IMAGE_NODE_NAMESPACE'))
		SKIN:Bang('!SetOptionGroup', 'grItemImageURL', 'Path', SKIN:GetVariable('ITEM_IMAGE_NODE_PATH'))
		SKIN:Bang('!SetOptionGroup', 'grItemImageURL', 'RegExpSubstitute', 1)
		SKIN:Bang('!SetOptionGroup', 'grItemImageURL', 'Substitute', SKIN:GetVariable('ITEM_IMAGE_URL_SUBSTITUTE'))
		SKIN:Bang('!SetOptionGroup', 'grItemImageURL', 'ItenNum', '')
	else
		SKIN:Bang('!SetOptionGroup', 'grItemImageURL', 'Attribute', '')
		SKIN:Bang('!SetOptionGroup', 'grItemImageURL', 'NameSpace', '')
		-- blank '' is not allowed as Path= | FeedReader.dll Type=ItemCustom
		SKIN:Bang('!SetOptionGroup', 'grItemImageURL', 'Path', '_')
		SKIN:Bang('!SetOptionGroup', 'grItemImageURL', 'RegExpSubstitute', '')
		SKIN:Bang('!SetOptionGroup', 'grItemImageURL', 'Substitute', '')
		SKIN:Bang('!SetOptionGroup', 'grItemImageURL', 'ItenNum', '')
	end
end

function FeedReader_ExecuteAfter()
	-- get Title from xml feed.
	if(''==SKIN:GetVariable('FEED_TITLE', '')) then
		SKIN:Bang('!SetOption', 'mtFeedTitle', 'MeasureName', 'msFeedTitle')
		SKIN:Bang('!SetOption', 'mtFeedTitle', 'Text', '%1')
	end
	-- FeedReader Type=ItemCount
	local ic = tonumber(SKIN:GetMeasure('msItemCount'):GetStringValue())
	-- Fetch images feature enabled or not
	local fie = ('1'==SKIN:GetVariable('FETCH_IMAGES') and '_'~=SKIN:GetVariable('ITEM_IMAGE_NODE_PATH'))
	-- Setup ItemNum of msItemImageURL
	-- This is to avoid errors.  Type=ItemCustom & ItemNum=1-40
	-- "FeedReader.dll: GetNode() - Item number out of range."
	local n = 1
	if(fie) then
		while(n<=40) -- 40: msItemImageURL count.
		do
			SKIN:Bang('!SetOption', 'msItemImageURL'..n, 'ItemNum', (n<=ic and n or ''))
			n = n + 1
		end
	end
	SKIN:Bang('!UpdateMeasureGroup', 'grItemImageURL')

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
			-- mtIcon_Image
			mi = 'mtIcon_Image'..i
			if(fie) then
				si = SKIN:GetMeasure('msItemImageURL'..j):GetStringValue()
				if(''~=si) then
					SKIN:Bang('!SetOption', mi, 'MeterStyle', 'stIcon_Image')
					SKIN:Bang('!SetOption', mi, 'Y', '([mtItem'..i..':Y]+2)')
					SKIN:Bang('!SetOption', mi, 'DynamicVariables', 1)
					SKIN:Bang('!SetOption', mi, 'LeftMouseUpAction', '[msItemImageURL'..j..']')
				else
					SKIN:Bang('!SetOption', mi, 'MeterStyle', '')
					SKIN:Bang('!SetOption', mi, 'Y', '')
					SKIN:Bang('!SetOption', mi, 'DynamicVariables', 0)
					SKIN:Bang('!SetOption', mi, 'LeftMouseUpAction', '')
				end
			end
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
		--mtIcon_Image
		mi = 'mtIcon_Image'..k
		SKIN:Bang('!SetOption', mi, 'MeterStyle', '')
		SKIN:Bang('!SetOption', mi, 'Y', '')
		SKIN:Bang('!SetOption', mi, 'DynamicVariables', 0)
		SKIN:Bang('!SetOption', mi, 'LeftMouseUpAction', '')
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
		SKIN:Bang('!HideMeterGroup', 'grBody')
		SKIN:Bang('!UpdateMeterGroup', 'grBackground')
	end
end

function sw(k, v)
		SKIN:Bang('!SetVariable', k, v)
		SKIN:Bang('!WriteKeyValue', 'Variables', k, v)
end

-- https://docs.rainmeter.net/snippets/clamp/
function clamp_num(num, lower, upper)
	return math.max(lower, math.min(upper, num))
end
