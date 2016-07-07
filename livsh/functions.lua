local function normalize(v)
	local Length = math.sqrt(v[1]^2 + v[2]^2)
	return {v[1] / Length, v[2] / Length}
end

local function dot(v1, v2)
	return v1[1] * v2[1] + v1[2] * v2[2]
end

local function lengthSqr(v)
	return v[1] ^ 2 + v[2] ^ 2
end

local function length(v)
	return math.sqrt(lengthSqr(v))
end

function love.light.calculateShadows(Light, Bodies)
	local Shadows = {}
	local ShadowsLength = 100000

	for i, Body in pairs(Bodies) do
		if Body.shadowType == "rectangle" or Body.shadowType == "polygon" then
			if not Body.castsNoShadow then
				local Vertices = Body:getVertices()
				local VerticesLength = #Vertices
				local VisibleEdge = {}
				for k = 1, VerticesLength, 2 do
					local indexOfNextVertex = (k + 2) % VerticesLength
					local normal = normalize {
						-Vertices[indexOfNextVertex+1] + Vertices[k + 1],
						Vertices[indexOfNextVertex] - Vertices[k]
					}
					local LightToPoint = normalize {
						Vertices[k] - Light.x,
						Vertices[k + 1] - Light.y
					}
					
					table.insert(VisibleEdge, dot(normal, LightToPoint) > 0)
				end

				local ShadowGeometry = {}
				local VisibleEdges = #VisibleEdge
				local FirstVertex
				
				for k = 1, VisibleEdges do
					local Vertex = {Vertices[k * 2 - 1], Vertices[k * 2]}
					local PrevIndex = k - 1
					if PrevIndex <= 0 then
						PrevIndex = VisibleEdges + PrevIndex
					end
					
					local NextIndex = (k + 1) % VisibleEdges
					if NextIndex == 0 then
						NextIndex = VisibleEdges
					end
					
					if not VisibleEdge[PrevIndex] and VisibleEdge[k] then
						FirstVertex = k
						
						local Length = ShadowsLength
						if Body.z and Light.z and Light.z > Body.z then
							Length = Body.z / math.atan2(Light.z, math.sqrt((Light.x - Vertex[1])^2 + (Light.y - Vertex[2])^2))
						end
						
						local LightVecBackFront = normalize {
							Vertex[1] - Light.x,
							Vertex[2] - Light.y
						}
						table.insert(ShadowGeometry, Vertex[1] + LightVecBackFront[1] * Length)
						table.insert(ShadowGeometry, Vertex[2] + LightVecBackFront[2] * Length)
						
						table.insert(ShadowGeometry, Vertex[1])
						table.insert(ShadowGeometry, Vertex[2])
						break
					end
				end
				
				if FirstVertex then
					for k = FirstVertex, 1, -1 do
						local Vertex = {Vertices[k * 2 - 1], Vertices[k * 2]}
						local PrevIndex = k - 1
						if PrevIndex <= 0 then
							PrevIndex = VisibleEdges + PrevIndex
						end
						
						local NextIndex = (k + 1) % VisibleEdges
						if NextIndex == 0 then
							NextIndex = VisibleEdges
						end
						
						if not VisibleEdge[k] and not VisibleEdge[PrevIndex] then
							table.insert(ShadowGeometry, Vertex[1])
							table.insert(ShadowGeometry, Vertex[2])
						end
					end
					
					for k = VisibleEdges, FirstVertex, -1 do
						local Vertex = {Vertices[k * 2 - 1], Vertices[k * 2]}
						local PrevIndex = k - 1
						if PrevIndex <= 0 then
							PrevIndex = VisibleEdges + PrevIndex
						end
						
						local NextIndex = (k + 1) % VisibleEdges
						if NextIndex == 0 then
							NextIndex = VisibleEdges
						end
						
						if not VisibleEdge[k] and not VisibleEdge[PrevIndex] then
							table.insert(ShadowGeometry, Vertex[1])
							table.insert(ShadowGeometry, Vertex[2])
						end
					end
				end
				
				local LastVertex
				for k = 1, VisibleEdges do
					local Vertex = {Vertices[k * 2 - 1], Vertices[k * 2]}
					local PrevIndex = k - 1
					if PrevIndex <= 0 then
						PrevIndex = VisibleEdges + PrevIndex
					end
					
					local NextIndex = (k + 1) % VisibleEdges
					if NextIndex == 0 then
						NextIndex = VisibleEdges
					end
					
					if not VisibleEdge[k] and VisibleEdge[PrevIndex] then
						LastVertex = k
						
						table.insert(ShadowGeometry, Vertex[1])
						table.insert(ShadowGeometry, Vertex[2])
						
						local Length = ShadowsLength
						if Body.z and Light.z and Light.z > Body.z then
							Length = Body.z / math.atan2(Light.z, math.sqrt((Light.x - Vertex[1])^2 + (Light.y - Vertex[2])^2))
						end
						
						local LightVecBackFront = normalize {
							Vertex[1] - Light.x,
							Vertex[2] - Light.y
						}
						table.insert(ShadowGeometry, Vertex[1] + LightVecBackFront[1] * Length)
						table.insert(ShadowGeometry, Vertex[2] + LightVecBackFront[2] * Length)
						break
					end
				end
				
				if LastVertex then
					for k = LastVertex, VisibleEdges do
						local Vertex = {Vertices[k * 2 - 1], Vertices[k * 2]}
						local PrevIndex = k - 1
						if PrevIndex <= 0 then
							PrevIndex = VisibleEdges + PrevIndex
						end
						
						local NextIndex = (k + 1) % VisibleEdges
						if NextIndex == 0 then
							NextIndex = VisibleEdges
						end
						
						if not VisibleEdge[k] and not VisibleEdge[PrevIndex] then
							local Length = ShadowsLength
							if Body.z and Light.z and Light.z > Body.z then
								Length = Body.z / math.atan2(Light.z, math.sqrt((Light.x - Vertex[1])^2 + (Light.y - Vertex[2])^2))
							end
							
							local LightVecBackFront = normalize {
								Vertex[1] - Light.x,
								Vertex[2] - Light.y
							}
							table.insert(ShadowGeometry, Vertex[1] + LightVecBackFront[1] * Length)
							table.insert(ShadowGeometry, Vertex[2] + LightVecBackFront[2] * Length)
						end
					end
					
					for k = 1, LastVertex do
						local Vertex = {Vertices[k * 2 - 1], Vertices[k * 2]}
						local PrevIndex = k - 1
						if PrevIndex <= 0 then
							PrevIndex = VisibleEdges + PrevIndex
						end
						
						local NextIndex = (k + 1) % VisibleEdges
						if NextIndex == 0 then
							NextIndex = VisibleEdges
						end
						
						if not VisibleEdge[k] and not VisibleEdge[PrevIndex] then
							local Length = ShadowsLength
							if Body.z and Light.z and Light.z > Body.z then
								Length = Body.z / math.atan2(Light.z, math.sqrt((Light.x - Vertex[1])^2 + (Light.y - Vertex[2])^2))
							end
							
							local LightVecBackFront = normalize {
								Vertex[1] - Light.x,
								Vertex[2] - Light.y
							}
							table.insert(ShadowGeometry, Vertex[1] + LightVecBackFront[1] * Length)
							table.insert(ShadowGeometry, Vertex[2] + LightVecBackFront[2] * Length)
						end
					end
				end
				
				if #ShadowGeometry > 0 then
					-- Triangulation is necessary, otherwise rays will be intersecting
					local Triangles = love.math.triangulate(ShadowGeometry)
					for _, Shadow in pairs(Triangles) do
						Shadow.alpha = Body.alpha
						Shadow.red = math.random(0, 255)
						Shadow.green = math.random(0, 255)
						Shadow.blue = math.random(0, 255)
						Shadow.type = "polygon"
						table.insert(Shadows, Shadow)
					end
				end
				
				--[[
				-- This is the old shadow calculation, it calculates the shadow over the polygon
				for k = 1, VisibleEdges do
					local PrevIndex = k - 1
					if PrevIndex <= 0 then
						PrevIndex = VisibleEdges + PrevIndex
					end
					
					local NextIndex = (k + 1) % VisibleEdges
					if NextIndex == 0 then
						NextIndex = VisibleEdges
					end
					
					local Vertex = {Vertices[k * 2 - 1], Vertices[k * 2]}

					if not VisibleEdge[PrevIndex] then
						local Length = ShadowsLength
						if Body.z and Light.z and Light.z > Body.z then
							Length = Body.z / math.atan2(Light.z, math.sqrt((Light.x - Vertex[1])^2 + (Light.y - Vertex[2])^2))
						end
						
						local LightVecBackFront = normalize {
							Vertex[1] - Light.x,
							Vertex[2] - Light.y
						}
						table.insert(ShadowGeometry, Vertex[1] + LightVecBackFront[1] * Length)
						table.insert(ShadowGeometry, Vertex[2] + LightVecBackFront[2] * Length)
					end

					if VisibleEdge[k] then
						table.insert(ShadowGeometry, Vertex[1])
						table.insert(ShadowGeometry, Vertex[2])
					end
					
					if not VisibleEdge[NextIndex] then
						local NextVertex = {Vertices[NextIndex * 2 - 1], Vertices[NextIndex * 2]}
						if VisibleEdge[k] then
							table.insert(ShadowGeometry, NextVertex[1])
							table.insert(ShadowGeometry, NextVertex[2])
						end
						
						local Length = ShadowsLength
						if Body.z and Light.z and Light.z > Body.z then
							Length = Body.z / math.atan2(Light.z, math.sqrt((Light.x - NextVertex[1])^2 + (Light.y - NextVertex[2])^2))
						end
						
						local LightVecBackFront = normalize {
							NextVertex[1]- Light.x,
							NextVertex[2] - Light.y
						}
						table.insert(ShadowGeometry, NextVertex[1] + LightVecBackFront[1] * Length)
						table.insert(ShadowGeometry, NextVertex[2] + LightVecBackFront[2] * Length)
					end
				end
				table.insert(Shadows, ShadowGeometry)
				]]
			end
		elseif Body.shadowType == "circle" then
			if not Body.castsNoShadow then
				local Horizon = math.sqrt(math.pow(Light.x - (Body.x - Body.ox), 2) + math.pow(Light.y - (Body.y - Body.oy), 2))
				
				if Horizon >= Body.radius and Horizon <= Light.range then
					local ShadowGeometry = {}
					local Angle = math.atan2(Light.x - (Body.x - Body.ox), (Body.y - Body.oy) - Light.y) + math.pi / 2
					local offset = math.acos(Body.radius/Horizon)
					
					local Length = ShadowsLength
					if Body.z and Light.z and Light.z > Body.z then
						Length = Body.z / math.atan2(Light.z, Horizon)
					end

					ShadowGeometry[1] = Light.x - Body.ox - math.sin(Angle - offset) * Horizon
					ShadowGeometry[2] = Light.y - Body.oy + math.cos(Angle - offset) * Horizon
					ShadowGeometry[3] = Light.x - Body.ox + math.sin(Angle + offset) * Horizon
					ShadowGeometry[4] = Light.y - Body.oy - math.cos(Angle + offset) * Horizon

					ShadowGeometry[7] = Light.x - Body.ox - math.sin(Angle - offset) * (Length + Horizon)
					ShadowGeometry[8] = Light.y - Body.oy + math.cos(Angle - offset) * (Length + Horizon)
					ShadowGeometry[5] = Light.x - Body.ox + math.sin(Angle + offset) * (Length + Horizon)
					ShadowGeometry[6] = Light.y - Body.oy - math.cos(Angle + offset) * (Length + Horizon)
					
					ShadowGeometry.type = "polygon"
					ShadowGeometry.alpha = Body.alpha
					ShadowGeometry.red = Body.red
					ShadowGeometry.green = Body.green
					ShadowGeometry.blue = Body.blue
					table.insert(Shadows, ShadowGeometry)

					local ArcShadowGeometry = {}
					ArcShadowGeometry.type = "arc"
					ArcShadowGeometry.alpha = Body.alpha
					ArcShadowGeometry.red = Body.red
					ArcShadowGeometry.green = Body.green
					ArcShadowGeometry.blue = Body.blue
					ArcShadowGeometry[1] = (ShadowGeometry[5] + ShadowGeometry[7])/2
					ArcShadowGeometry[2] = (ShadowGeometry[6] + ShadowGeometry[8])/2
					ArcShadowGeometry[3] = math.sqrt((ShadowGeometry[5] - ArcShadowGeometry[1])^2 + (ShadowGeometry[6] - ArcShadowGeometry[2])^2)
					ArcShadowGeometry[4] = Angle - math.pi/2
					ArcShadowGeometry[5] = Angle + math.pi/2
					table.insert(Shadows, ArcShadowGeometry)
				end
			end
		end
	end

	return Shadows
end

function love.light.HeightMapToNormalMap(heightMap, strength)
	local imgData = heightMap:getData()
	local imgData2 = love.image.newImageData(heightMap:getWidth(), heightMap:getHeight())
	local red, green, blue, alpha
	local x, y
	local matrix = {}
	matrix[1] = {}
	matrix[2] = {}
	matrix[3] = {}
	strength = strength or 1.0

	for i = 0, heightMap:getHeight() - 1 do
		for k = 0, heightMap:getWidth() - 1 do
			for l = 1, 3 do
				for m = 1, 3 do
					if k + (l - 1) < 1 then
						x = heightMap:getWidth() - 1
					elseif k + (l - 1) > heightMap:getWidth() - 1 then
						x = 1
					else
						x = k + l - 1
					end

					if i + (m - 1) < 1 then
						y = heightMap:getHeight() - 1
					elseif i + (m - 1) > heightMap:getHeight() - 1 then
						y = 1
					else
						y = i + m - 1
					end

					local red, green, blue, alpha = imgData:getPixel(x, y)
					matrix[l][m] = red
				end
			end

			red = (255 + ((matrix[1][2] - matrix[2][2]) + (matrix[2][2] - matrix[3][2])) * strength) / 2.0
			green = (255 + ((matrix[2][2] - matrix[1][1]) + (matrix[2][3] - matrix[2][2])) * strength) / 2.0
			blue = 192

			imgData2:setPixel(k, i, red, green, blue)
		end
	end

	return love.graphics.newImage(imgData2)
end