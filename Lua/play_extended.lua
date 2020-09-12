--[[

Script to add new notes to the PLAY verb.

- The play object needs to be edited on the .ld file for your level to have a list of the supported notes, for example

   object001_customobjects=a,c♯,e,,

(this allows the rule parser to identify the new rule as valid)

- New objects need to be created corresponding to the new notes, with type 5 (style like 'BA')

All 88 notes of a keyboard are included, and they may be represented as:

- numbers 1 through 88, or
- scientific notation (a0 through c8), or
- a♭, a, a♯, ..., g♯, mapping to a♭4 through g♯5

]]--

-- Function to build the base of all supported frequencies
function buildfreqs()
	-- https://en.wikipedia.org/wiki/Piano_key_frequencies
	local freqs = {
		[49] = 44000.00,
		[50] = 46616.38,
		[51] = 49388.33,
		[52] = 52325.11,
		[53] = 55436.53,
		[54] = 58732.95,
		[55] = 62225.40,
		[56] = 65925.51,
		[57] = 69845.65,
		[58] = 73998.88,
		[59] = 78399.09,
		[60] = 83060.94,
	}
	
	-- Extend to the 88 piano keys
	for i=48,1,-1 do
		freqs[i] = freqs[i + 12] / 2
	end
	for i=61,88 do
		freqs[i] = freqs[i - 12] * 2
	end
	
	-- Add scientific names
	freqs["a0"] = freqs[1]
	freqs["a♯0"] = freqs[2]
	freqs["b♭0"] = freqs[2]
	freqs["b0"] = freqs[3]
	for i=1,7 do
		freqs["c" .. i] = freqs[12*i - 8]
		freqs["c♯" .. i] = freqs[12*i - 7]
		freqs["d♭" .. i] = freqs[12*i - 7]
		freqs["d" .. i] = freqs[12*i - 6]
		freqs["d♯" .. i] = freqs[12*i - 5]
		freqs["e♭" .. i] = freqs[12*i - 5]
		freqs["e" .. i] = freqs[12*i - 4]
		freqs["f" .. i] = freqs[12*i - 3]
		freqs["f♯" .. i] = freqs[12*i - 2]
		freqs["g♭" .. i] = freqs[12*i - 2]
		freqs["g" .. i] = freqs[12*i - 1]
		freqs["g♯" .. i] = freqs[12*i]
		freqs["a♭" .. i] = freqs[12*i]
		freqs["a" .. i] = freqs[12*i + 1]
		freqs["a♯" .. i] = freqs[12*i + 2]
		freqs["b♭" .. i] = freqs[12*i + 2]		
		freqs["b" .. i] = freqs[12*i + 3]
	end
	freqs["c8"] = freqs[88]
	
	-- Add default baba names (no octave number, start on A)
	freqs["a♭"] = freqs["a♭4"]
	freqs["a"] = freqs["a4"]
	freqs["a♯"] = freqs["a♯4"]
	freqs["b♭"] = freqs["b♭4"]
	freqs["b"] = freqs["b4"]
	freqs["c"] = freqs["c5"]
	freqs["c♯"] = freqs["c♯5"]
	freqs["d♭"] = freqs["d♭5"]
	freqs["d"] = freqs["d5"]
	freqs["d♯"] = freqs["d♯5"]
	freqs["e♭"] = freqs["e4"]
	freqs["e"] = freqs["e4"]
	freqs["f"] = freqs["f5"]
	freqs["f♯"] = freqs["f♯5"]
	freqs["g♭"] = freqs["g♭5"]
	freqs["g"] = freqs["g5"]
	freqs["g♯"] = freqs["g♯5"]
	
	return freqs
end

updated_freqs = false

if not updated_freqs then
	updated_freqs = true
	play_data['tunes']['bullet'] = 'drum_kick'
	play_data['freqs'] = buildfreqs()
end
