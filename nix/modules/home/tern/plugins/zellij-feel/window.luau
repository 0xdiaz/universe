-- zjstatus-style status segments (user@host, clock) and the calisia layout,
-- ported from the Ghostty + Zellij setup, plus a new Claude Code tab shortcut.

local CLOCK_FORMAT = "%A, %d %b %Y %H:%M"

local user = tern.getenv("USER") or "?"
local host = ""
local clock = ""
-- Built outside the formatter: a status hook over its 4 ms budget is disabled
-- until the next reload.
local segs = {}

local function trim(s: string): string
	return (string.gsub(s, "%s+$", ""))
end

local function rebuild()
	local next = {}
	if host ~= "" then
		table.insert(next, { text = user .. "@" .. host, icon = "user", tone = "muted" })
	end
	if clock ~= "" then
		table.insert(next, { text = clock, icon = "clock", tone = "muted" })
	end
	segs = next
	tern.chrome.refresh()
end

tern.process.run({ "uname", "-n" }, function(r)
	if r.status == 0 then
		host = trim(r.stdout)
		rebuild()
	end
end)

local function tick()
	local ok, now = pcall(function()
		return os.date(CLOCK_FORMAT)
	end)
	if ok and type(now) == "string" then
		clock = now
		rebuild()
	else
		tern.process.run({ "date", "+" .. CLOCK_FORMAT }, function(r)
			if r.status == 0 then
				clock = trim(r.stdout)
				rebuild()
			end
		end)
	end
	tern.timer(30000, tick)
end
tern.timer(10, tick)

tern.chrome.status(function(_pane)
	return segs
end)

-- One pane on the left, two stacked on the right.
tern.command({
	id = "calisia",
	title = "Layout: calisia",
	run = function(cx)
		cx.layout:tab({
			name = "calisia",
			split = "right",
			{},
			{ split = "down", {}, {} },
		})
	end,
})

-- Typed into a fresh shell rather than launched as the tab's command, so fish's
-- interactive init (GITHUB_PERSONAL_ACCESS_TOKEN for the github MCP) runs and
-- the tab stays open when claude exits. It goes through `tern run`: in shells
-- missing Tern's shell integration, cx:run's text sat unsent until something
-- else wrote to the pane. Waits for the first prompt (up to 5 s, then types
-- anyway).
local TERN = "/Applications/Tern.app/Contents/MacOS/tern"

local function run_at_prompt(pane: number, command: string, tries: number)
	tern.timer(100, function(cx)
		if not cx then
			return
		end
		local p = cx.session:pane(pane)
		if not p then
			return
		end
		if p.at_prompt or tries <= 0 then
			tern.process.run({ TERN, "run", tostring(pane), command }, function(r)
				if r.status ~= 0 then
					tern.log.warn("claude_tab: tern run failed", r.status, r.stderr)
				end
			end)
		else
			run_at_prompt(pane, command, tries - 1)
		end
	end)
end

tern.command({
	id = "claude_tab",
	title = "New Claude Code tab",
	keys = { "ctrl+a>a", "ctrl+cmd+c" },
	run = function(cx)
		local pane = cx.layout:new_tab()
		if pane then
			run_at_prompt(pane, "claude", 50)
		end
	end,
})
