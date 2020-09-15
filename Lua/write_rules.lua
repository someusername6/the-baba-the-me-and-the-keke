--[[

Script to overwrite the pause menu rules -- ensuring the column count only
takes into account the visible rules.

]]--


function writerules(parent,name,x_,y_)
	local visible_rules_ = 0
	for i,rules in ipairs(visualfeatures) do
		local ids = rules[3]
		local fullinvis = true
		for a,b in ipairs(ids) do
			for c,d in ipairs(b) do
				local dunit = mmf.newObject(d)
				
				if dunit.visible then
					fullinvis = false
				end
			end
		end
		if (fullinvis == false) then
			visible_rules_ = visible_rules_ + 1
		end
	end
	
	local basex = x_
	local basey = y_
	local linelimit = 12
	
	local x,y = basex,basey
	
	if (visible_rules_ > 0) then
		writetext(langtext("rules") .. ":",0,x,y,name,true,2,true)
	end
	
	local columns = math.floor((visible_rules_ - 1) / linelimit) + 1
	local columnwidth = math.min(screenw - f_tilesize * 2, columns * f_tilesize * 10) / columns
	local i_ = 1
	
	for i,rules in ipairs(visualfeatures) do
		local currcolumn = math.floor((i_ - 1) / linelimit) - (columns * 0.5)
		
		x = basex + columnwidth * currcolumn + columnwidth * 0.5
		y = basey + (((i_ - 1) % linelimit) + 1) * f_tilesize * 0.8
		
		local text = ""
		local rule = rules[1]
		
		text = text .. rule[1] .. " "
		
		local conds = rules[2]
		local ids = rules[3]
		local tags = rules[4]
		
		local fullinvis = true
		for a,b in ipairs(ids) do
			for c,d in ipairs(b) do
				local dunit = mmf.newObject(d)
				
				if dunit.visible then
					fullinvis = false
				end
			end
		end
		
		if (fullinvis == false) then
			if (#conds > 0) then
				for a,cond in ipairs(conds) do
					local middlecond = true
					
					if (cond[2] == nil) or ((cond[2] ~= nil) and (#cond[2] == 0)) then
						middlecond = false
					end
					
					if middlecond then
						text = text .. cond[1] .. " "
						
						if (cond[2] ~= nil) then
							if (#cond[2] > 0) then
								for c,d in ipairs(cond[2]) do
									text = text .. d .. " "
									
									if (#cond[2] > 1) and (c ~= #cond[2]) then
										text = text .. "& "
									end
								end
							end
						end
						
						if (a < #conds) then
							text = text .. "& "
						end
					else
						text = cond[1] .. " " .. text
					end
				end
			end
			
			local target = rule[3]
			local isnot = string.sub(target, 1, 4)
			local target_ = target
			
			if (isnot == "not ") then
				target_ = string.sub(target, 5)
			else
				isnot = ""
			end
			
			if (word_names[target_] ~= nil) then
				target = isnot .. word_names[target_]
			end
			
			text = text .. rule[2] .. " " .. target
			
			for a,b in ipairs(tags) do
				if (b == "mimic") then
					text = text .. " (mimic)"
				end
			end
			
			writetext(text,0,x,y,name,true,2,true)
			i_ = i_ + 1
		end
	end
end