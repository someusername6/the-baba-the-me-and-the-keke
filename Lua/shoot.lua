--[[

Script to support the SHOOT property -- fall in current direction.

]]--

function fallblock()
	local checks = {}
	
	local isfall = findallfeature(nil,"is","fall",true)
	local isfall_r = findallfeature(nil,"is","fallright",true)
	local isfall_u = findallfeature(nil,"is","fallup",true)
	local isfall_l = findallfeature(nil,"is","fallleft",true)
	local isshoot = findallfeature(nil,"is","shoot",true)
	
	local flist = {}
	flist.down = {}
	flist.right = {}
	flist.up = {}
	flist.left = {}
	
	local fd,fr,fu,fl = flist.down,flist.right,flist.up,flist.left

	for a,unitid in ipairs(isfall) do
		table.insert(checks, {unitid, 3})
		
		if (fd[unitid] == nil) then
			fd[unitid] = 1
		else
			fd[unitid] = fd[unitid] + 1
		end
	end
	
	for a,unitid in ipairs(isfall_r) do
		table.insert(checks, {unitid, 0})
		
		if (fr[unitid] == nil) then
			fr[unitid] = 1
		else
			fr[unitid] = fr[unitid] + 1
		end
	end
	
	for a,unitid in ipairs(isfall_u) do
		table.insert(checks, {unitid, 1})
		
		if (fu[unitid] == nil) then
			fu[unitid] = 1
		else
			fu[unitid] = fu[unitid] + 1
		end
		
		if (fd[unitid] ~= nil) and (fd[unitid] > 0)and (fu[unitid] > 0) then
			fd[unitid] = fd[unitid] - 1
			fu[unitid] = fu[unitid] - 1
		end
	end
	
	for a,unitid in ipairs(isfall_l) do
		table.insert(checks, {unitid, 2})
		
		if (fl[unitid] == nil) then
			fl[unitid] = 1
		else
			fl[unitid] = fl[unitid] + 1
		end
		
		if (fr[unitid] ~= nil) and (fr[unitid] > 0)and (fl[unitid] > 0) then
			fr[unitid] = fr[unitid] - 1
			fl[unitid] = fl[unitid] - 1
		end
	end
	
	for a,unitid in ipairs(isshoot) do
		local unit = mmf.newObject(unitid)
		local unitdir = unit.values[DIR]
		
		table.insert(checks, {unitid, unitdir})
		
		if (unitdir == 0) then
			if (fr[unitid] == nil) then
				fr[unitid] = 1
			else
				fr[unitid] = fr[unitid] + 1
			end
			if (fl[unitid] ~= nil) and (fl[unitid] > 0)and (fr[unitid] > 0) then
				fl[unitid] = fl[unitid] - 1
				fr[unitid] = fr[unitid] - 1
			end
		elseif (unitdir == 1) then
			if (fu[unitid] == nil) then
				fu[unitid] = 1
			else
				fu[unitid] = fu[unitid] + 1
			end			
			if (fd[unitid] ~= nil) and (fd[unitid] > 0)and (fu[unitid] > 0) then
				fd[unitid] = fd[unitid] - 1
				fu[unitid] = fu[unitid] - 1
			end
		elseif (unitdir == 2) then
			if (fl[unitid] == nil) then
				fl[unitid] = 1
			else
				fl[unitid] = fl[unitid] + 1
			end
			if (fr[unitid] ~= nil) and (fr[unitid] > 0)and (fl[unitid] > 0) then
				fr[unitid] = fr[unitid] - 1
				fl[unitid] = fl[unitid] - 1
			end
		elseif (unitdir == 3) then
			if (fd[unitid] == nil) then
				fd[unitid] = 1
			else
				fd[unitid] = fd[unitid] + 1
			end
			if (fu[unitid] ~= nil) and (fu[unitid] > 0)and (fd[unitid] > 0) then
				fu[unitid] = fu[unitid] - 1
				fd[unitid] = fd[unitid] - 1
			end
		end
	end
	
	local done = false
	local objdatalist = {}
	
	local limiter = 0
	local limit = 1000
	
	while (done == false) and (limiter < limit) do
		local settled = true
		
		if (#checks > 0) then
			for a,data in pairs(checks) do
				local unitid = data[1]
				local falldir = data[2]
				
				if (objectdata[unitid] == nil) then
					objectdata[unitid] = {}
				end
				
				local drs = ndirs[falldir + 1]
				local ox,oy = drs[1],drs[2]
				
				local unit = mmf.newObject(unitid)
				local x,y,dir = unit.values[XPOS],unit.values[YPOS],unit.values[DIR]
				local name = getname(unit)
				local onground = false
				
				local valid = false
				
				local flistnames = {"right", "up", "left", "down"}
				local flist_ = flist[flistnames[falldir + 1]]
				
				if (flist_[unitid] ~= nil) and (flist_[unitid] > 0) then
					valid = true
				end
				
				local odata = objectdata[unitid]
				if (odata.fallen ~= nil) and (odata.fallen ~= falldir) then
					valid = false
					onground = true
				end
				
				if (odata.fallen == nil) then
					table.insert(objdatalist, {unitid, falldir})
				end
				
				if unit.flags[DEAD] or isstill(unitid,x,y) then
					valid = false
				end
				
				if valid then
					while (onground == false) and (limiter < limit) do
						local below,below_,specials = check(unitid,x,y,falldir,false,"fall")
						local deletethese = {}
						
						local result = 0
						for c,d in pairs(below) do
							if (d ~= 0) then
								result = 1
							else
								if (below_[c] ~= 0) and (result ~= 1) then
									if (result ~= 0) then
										result = 2
									else
										for e,f in ipairs(specials) do
											if (f[1] == below_[c]) then
												result = 2
											end
											
											if (f[2] == "weak") then
												table.insert(deletethese, f[1])
											end
										end
									end
								end
							end
							--MF_alert(tostring(y) .. " -- " .. tostring(d) .. " (" .. tostring(below_[c]) .. ")")
						end
						
						--MF_alert(tostring(y) .. " -- result: " .. tostring(result))
						
						if (result ~= 1) then
							local gone = false
							
							if (result == 0) then
								update(unitid,x + ox,y + oy)
							elseif (result == 2) then
								gone = move(unitid,ox,oy,dir,specials,true,true,x,y)
							end
							
							-- Poista tästä kommenttimerkit jos haluat, että fall tsekkaa juttuja per pudottu tile
							if (gone == false) then
								x = x + ox
								y = y + oy
								settled = false
								
								for a,b in ipairs(deletethese) do
									delete(b,x,y)
						
									local pmult,sound = checkeffecthistory("weak")
									setsoundname("removal",1,sound)
									generaldata.values[SHAKE] = 3
									MF_particles("destroy",x,y,5 * pmult,0,3,1,1)
								end
								
								if unit.flags[DEAD] then
									onground = true
									settled = true
									table.remove(checks, a)
								else
									update(unitid,x,y)
									--[[
									local stillgoing = hasfeature(name,"is","fall",unitid,x,y)
									if (stillgoing == nil) then
										onground = true
										table.remove(checks, a)
									end
									]]--
								end
							else
								onground = true
							end
						else
							onground = true
						end
						
						limiter = limiter + 1
					end
				else
					onground = true
				end
			end
			
			if settled then
				done = true
			end
		else
			done = true
		end
	end
	
	if (limiter >= limit) then
		HACK_INFINITY = 200
		destroylevel("infinity")
		return
	end
	
	for i,v in ipairs(objdatalist) do
		local unitid = v[1]
		local falldir = v[2]
		
		if (objectdata[unitid] == nil) then
			objectdata[unitid] = {}
		end
		
		local odata = objectdata[unitid]
		
		if (odata.fallen == nil) then
			odata.fallen = falldir
		end
	end
end