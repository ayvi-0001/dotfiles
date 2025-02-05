--- @sync entry
local F = {}

function F:entry(job) 
   local h = cx.active.current.hovered
   local original_url = h.link_to
   if h and original_url then
      if original_url.is_regular  then
         ya.manager_emit("cd", { original_url .. "/.." } )
      else
         ya.manager_emit("cd", { original_url } )
      end
   end
end

return F
