local Path = (...):gsub("%p", "/").."/"

LOVE_LIGHT_BLURV = love.graphics.newShader(Path.."shader/blurv.glsl")
LOVE_LIGHT_BLURH = love.graphics.newShader(Path.."shader/blurh.glsl")
LOVE_LIGHT_BLURV:send("screen", {love.graphics.getWidth(), love.graphics.getHeight()})
LOVE_LIGHT_BLURH:send("screen", {love.graphics.getWidth(), love.graphics.getHeight()})

love.light = {}
love.light.ShadowTypes = {}

local RequirePath = ...

love.light.ShadowTypes.circle = require(RequirePath..".shadowtype.circle")
love.light.ShadowTypes.polygon = require(RequirePath..".shadowtype.polygon")
love.light.ShadowTypes.rectangle = require(RequirePath..".shadowtype.rectangle")

require(RequirePath..".functions")
require(RequirePath..".light")
require(RequirePath..".postshader")

require(RequirePath..".world")
require(RequirePath..".body")
require(RequirePath..".room")

local HeightMapToNormalMap = love.light.HeightMapToNormalMap

function love.light.newRectangle(p, x, y, width, height)
	return p:newBody("rectangle", x, y, width, height)
end

function love.light.newCircle(p, x, y, radius)
	return p:newBody("circle", x, y, radius)
end

function love.light.newPolygon(p, ...)
	return p:newBody("polygon", ...)
end

function love.light.newImage(p, img, x, y, width, height, ox, oy)
	return p:newBody("image", img, x, y, width, height, ox, oy)
end

function love.light.newRefraction(p, normal, x, y, width, height)
	return p:newBody("refraction", normal, x, y, width, height)
end

function love.light.newRefractionHeightMap(p, heightMap, x, y, strength)
	local normal = HeightMapToNormalMap(heightMap, strength)
	return love.light.newRefraction(p, normal, x, y)
end

function love.light.newReflection(p, normal, x, y, width, height)
	return p:newBody("reflection", normal, x, y, width, height)
end

function love.light.newReflectionHeightMap(p, heightMap, x, y, strength)
	local normal = HeightMapToNormalMap(heightMap, strength)
	return love.light.newReflection(p, normal, x, y)
end