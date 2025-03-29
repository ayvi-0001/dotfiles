--- @sync entry
-- https://yazi-rs.github.io/docs/tips#navigation-wraparound
return {
	entry = function(_, job)
		local current = cx.active.current
		local new = (current.cursor + job.args[1]) % #current.files
		ya.manager_emit("arrow", { new - current.cursor })
	end,
}
