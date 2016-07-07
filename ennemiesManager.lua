module = "ennemiesManager"

local ennemiesManager = {}

--créer un ennemie
function ennemiesManager.newEnnemie(pX, pY, pPathToTexture, pEnnemieType)
  local ennemie = {}
  ennemie.x = pX
  ennemie.y = pY
  ennemie.type = pEnnemieType
  
  --on retient les lastPosition
  ennemie.lastX = pX
  ennemie.lastY = pY
  
   --le tileset de l'ennemie
  ennemie.tileset = {}
  ennemie.tileset.image = love.graphics.newImage(pPathToTexture)
  ennemie.tileset.quads = {
    love.graphics.newQuad(34,103,32,32,ennemie.tileset.image:getDimensions())
  }
  --fonction pour dessiner un ennemie 
  function ennemie.draw()
    love.graphics.draw(ennemie.tileset.image,ennemie.tileset.quads[ennemie.type],ennemie.x,ennemie.y)
  end
  
  --fonction qui update 
  function ennemie.update(pPlayer)
    --l'ennemie va vers le joueur 
    --si joueur trop loin 
    if pPlayer.y > ennemie.y then
      ennemie.y = ennemie.y + 2
    elseif pPlayer.y < ennemie.y then
      ennemie.y = ennemie.y - 2
    end
    
    if pPlayer.x > ennemie.x then
      ennemie.x = ennemie.x + 2
    elseif pPlayer.x < ennemie.x then
      ennemie.x = ennemie.x - 2
    end
    
  end
  
  --fonction pour reset les positions de l'ennemie 
  function ennemie.resetPosition()
    ennemie.x = ennemie.lastX
    ennemie.y = ennemie.lastY 
  end
  
  
  return ennemie
end

return ennemiesManager

