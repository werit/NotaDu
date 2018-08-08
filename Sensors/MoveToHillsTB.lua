local sensorInfo = {
	name = "MoveToHillsTB",
	desc = "Moves to 4 places specified as hills parameter",
	author = "Werit",
	date = "2018-08-07",
	license = "NA",
}

-- get madatory module operators
VFS.Include("modules.lua") -- modules table
VFS.Include(modules.attach.data.path .. modules.attach.data.head) -- attach lib module

-- get other madatory dependencies
attach.Module(modules, "message") -- communication backend load

local EVAL_PERIOD_DEFAULT = 0 -- no caching
function getInfo()
    return {
-- it is expected that we would not need completely up-to-date information
-- this is copy from example
    period = EVAL_PERIOD_DEFAULT,
    }
end


return function(hills)
  if #units > 0 then
    iter = math.min(#units,#hills)
    for i=1,iter do
      -- pohyb na miesto
      Spring.GiveOrderToUnit(units[i], CMD.MOVE,
      { hills[i][1], Spring.GetGroundHeight(hills[i][1],hills[i][2]), hills[i][2] },
       {})
    end
  end
end -- function(hills)
