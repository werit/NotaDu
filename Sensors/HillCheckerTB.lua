local sensorInfo = {
	name = "HillCheckerTB",
	desc = "Returns position of 4 highiest places",
	author = "Werit",
	date = "2018-07-22",
	license = "NA",
}

-- get madatory module operators
VFS.Include("modules.lua") -- modules table
VFS.Include(modules.attach.data.path .. modules.attach.data.head) -- attach lib module

-- get other madatory dependencies
attach.Module(modules, "message") -- communication backend load

local EVAL_PERIOD_DEFAULT = 10 -- caching 10 sec
function getInfo()
    return {
-- it is expected that we would not need completely up-to-date information
-- this is copy from example
    period = EVAL_PERIOD_DEFAULT,
    }
end

--primitivna verzia hladania kopcov
function findHills(hills)
	hill_points = {}

	for i=1,4 do
		hill_points[i] = {}
		-- precistim si exclude point
		exlude_point = nil
		for j=1,#hills do
			-- kontrola, ci som uz vybral dalsi vrch
			if exlude_point == nil then
				if hills[j][3] == 'y' then
					-- tuto mi to crashovalo, ked som to priamo priradzoval
					exlude_point = {}
					exlude_point[1] = hills[j][1]
					exlude_point[2] = hills[j][2]
					-- naplnim i-ty vrch
					hill_points[i][1] = hills[j][1]
					hill_points[i][2] = hills[j][2]
					-- tu uz tiez reprezentujem kopec
					hills[j][3] = 'n'
				end
			else
				-- mam vybraty vrchol a negujem vsetky, ktore su blizko neho
				if (hills[j][3] =='y' and
				math.abs(hills[j][1]-exlude_point[1]) <200 and
				math.abs(hills[j][2]-exlude_point[2]) <200 )then
					-- mark point as part of some already represented hill
					hills[j][3] ='n'
				end
			end -- if nil


		end -- for j
	end -- for i

	return hill_points
end

-- generujem grid z mapy
-- rozsekam si mapu na mensie
function makeGridFromMap(hillHeightRequiered)
  -- grid mapy
  -- ide o dvojrozmerne pole, ktore bude obsahovat :
  -- informaciu o vyske daneho bodu
  local grid  ={}
  local mapWidth = Game.mapSizeX
  -- cakal by som mapSizeY, ale ....
  -- hlavne potom budem pouzivat y-ovu os ako by som sa pozeral zhora
  local mapHeight = Game.mapSizeZ
  -- hard coded, objavene skusanim, ziadna vyssia logika
  local gridSize = 50
  local xGridCount = math.floor(mapWidth / gridSize)
  local yGridCount = math.floor(mapHeight / gridSize)

	--mnozina bodov kopcov
	hill_set = {}
	hill_set_cnt = 1
  -- cyklus priradzujuci kazdemu bodu gridu jeho vysku
  for i=0,xGridCount do
    -- treba inicializovat
    -- toto mi zabralo nekonecne casu zistit
    grid[i] = {}
    for j=0,yGridCount do
			local hill_hg = Spring.GetGroundHeight(i*gridSize,j*gridSize)
			if hill_hg >= hillHeightRequiered  then
				hill_set[hill_set_cnt] = {i*gridSize,j*gridSize,'y'}
				hill_set_cnt =hill_set_cnt+1
			end
      grid[i][j] = hill_hg
    end
  end
  return
		--grid,
		hill_set

end

-- toto je funkcia, ktora sa fakt vracia, ale netusim, kto a ako ju cita
return function(hillHeightRequiered)
  -- prepare grid
  hills = makeGridFromMap(hillHeightRequiered)
  -- search grid for hills and return result
  return findHills(hills)
end
