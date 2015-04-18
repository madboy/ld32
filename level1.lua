level1 = {}

function level1.init()
    tileSize = 60
    grid = 5
    origo = {x=100, y=100}
    height = origo.y + grid*tileSize
    width = origo.x + grid*tileSize

    gridsx = {[1]=origo.x,
              [2]=origo.x + tileSize,
              [3]=origo.x + 2*tileSize,
              [4]=origo.x + 3*tileSize,
              [0]=origo.x + 4*tileSize}

    gridsy = {[1]=origo.y,
              [2]=origo.y + tileSize,
              [3]=origo.y + 2*tileSize,
              [4]=origo.y + 3*tileSize,
              [5]=origo.y + 4*tileSize}

    tiles = {2,2,2,2,2,
             2,2,0,2,2,
             2,2,2,2,2,
             2,2,2,2,2,
             2,2,2,2,2}

    start = {x=gridsx[3]+tileSize*0.5-pw*0.5, y=height-ph}
    exit = {x = gridsx[3], y = gridsy[1], w = tileSize, h = tileSize*0.5, r=ground[0].r, g=ground[0].g, b=ground[0].b}
    player = {x=start.x, y=start.y, w=pw, h=ph, r=255, g=255, b=255, tile=2}
    speed = 128
    colorSpeed = 25
end

return level1

