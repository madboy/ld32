local height = love.graphics.getHeight()
local width = love.graphics.getWidth()

local pw = 25
local ph = 25

local ground = {[1]={name='yellow', r=255, g=255, b=0},
                [2]={name='yellow-orange', r=255, g=204, b=0},
                [3]={name='orange', r=255, g=165, b=0},
                [4]={name='orange-red', r=255, g=69, b=0},
                [5]={name='red', r=255, g=0, b=0},
                [6]={name='red-violet', r=244, g=62, b=113},
                [7]={name='violet', r=102, g=51, b=153},
                [8]={name='violet-blue', r=76, g=80, b=169},
                [9]={name='blue', r=0, g=0, b=255},
                [10]={name='blue-green', r=33, g=182, b=168},
                [11]={name='green', r=0, g=255, b=0},
                [12]={name='green-yellow', r=160, g=255, b=32},
                [13]={name='black', r=0, g=0, b=0},
                [14]={name='white', r=255, g=255, b=255},
                [0]={name="exit", r=0, g=128, b=0}}

local tileSize = 60
local grid = 5
local grids = {[1]=0, [2]=tileSize, [3]=2*tileSize, [4]=3*tileSize, [0]=4*tileSize, [5]=4*tileSize}

local tiles = {2,2,2,2,2,
               2,2,0,2,2,
               2,2,2,2,2,
               2,2,2,2,2,
               2,2,2,2,2}

local start = {x=grids[3]+tileSize*0.5-pw*0.5, y=height-ph}
local exit = {x = grids[3], y = grids[1], w = tileSize, h = tileSize*0.5, r=ground[0].r, g=ground[0].g, b=ground[0].b}

local player = {x=start.x, y=start.y, w=pw, h=ph, r=255, g=255, b=255, tile=2}

local messages = {"Level clear!", "Color attunement error!"}

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

local speed = 128
local colorSpeed = 20 -- this one is very dependant on the colors we use for the ground
function love.update(dt)
    if love.keyboard.isDown("up") then
        if (player.y - (speed * dt)) > 0 then
            player.y = player.y - (speed * dt)
        end
    end
    if love.keyboard.isDown("down") then
        if (player.y + player.h + (speed * dt)) < height then
            player.y = player.y + (speed * dt)
        end
    end
    if love.keyboard.isDown("right") then
        if (player.x + player.w + (speed * dt)) < width then
            player.x = player.x + (speed * dt)
        end
    end
    if love.keyboard.isDown("left") then
        if (player.x - (speed * dt)) > 0 then
            player.x = player.x - (speed * dt)
        end
    end
    if updateColor then
        player.r = mix(player.r, ground[player.tile].r, dt)
        player.g = mix(player.g, ground[player.tile].g, dt)
        player.b = mix(player.b, ground[player.tile].b, dt)
    end
end

function love.load()
end

function mix(c1, c2, rate)
    if c1 < c2 then
        return c1 + (rate * colorSpeed)
    else
        return c1 - (rate * colorSpeed)
    end
end

function inArea(a)
    return (player.x >= a.x) and (player.y >= a.y) and
            ((player.x + player.w) < (a.x + a.w)) and
            ((player.y + player.h) < (a.y + a.h))
end

function inTile(x, y)
    return (player.x >= x) and (player.y >= y) and
            ((player.x + player.w) < (x + tileSize)) and
            ((player.y + player.h) < (y + tileSize))
end

function withinLimit(c1, c2)
    if math.abs(c2 - c1) < 25 then
        return true
    end
    return false
end

function colorMatch()
    if withinLimit(player.r, exit.r) and
        withinLimit(player.g, exit.g) and
        withinLimit(player.b, exit.b) then
        return true
    end
    return false
end

function canExit()
    if inArea(exit) then
        if colorMatch() then
            return true, 1
        else
            return true, 2
        end
    end
    return false
end

function getTilePosition(i)
    xpos = i % grid
    ypos = math.ceil(i/grid)
    return grids[xpos], grids[ypos]
end

function love.draw()
    local area = 1

    for i, t in ipairs(tiles) do
        love.graphics.setColor(ground[t].r, ground[t].g, ground[t].b)
        local x, y = getTilePosition(i)
        love.graphics.rectangle("fill", x, y, 60, 60)

        if inTile(x, y) then
            player.tile = t
        end
    end

    love.graphics.setColor(exit.r, exit.g, exit.b)
    love.graphics.rectangle("fill", exit.x, exit.y, exit.w, exit.h)

    love.graphics.setColor(0, 0, 0)
    love.graphics.print("EXIT", exit.x, exit.y)

    love.graphics.setColor(player.r, player.g, player.b)
    love.graphics.rectangle("fill", player.x, player.y, player.w, player.h)
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("line", player.x, player.y, player.w, player.h)

    local can_exit, msg = canExit()
    if can_exit then
        updateColor = false
        love.graphics.setColor(0, 0, 0)
        love.graphics.print(string.format("%s", messages[msg]), width*0.13, height*0.2)
    else
        updateColor = true
    end
end
