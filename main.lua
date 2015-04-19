require("levels")
pw = 25
ph = 25

ground = {[1]={name='yellow', type='normal', r=255, g=255, b=0},
          [2]={name='yellow-orange', type='normal', r=255, g=204, b=0},
          [3]={name='orange', type='normal', r=255, g=165, b=0},
          [4]={name='orange-red', type='normal', r=255, g=69, b=0},
          [5]={name='red', type='normal', r=255, g=0, b=0},
          [6]={name='red-violet', type='buff', r=244, g=62, b=113},
          [7]={name='violet', type='normal', r=102, g=51, b=153},
          [8]={name='violet-blue', type='normal', r=76, g=80, b=169},
          [9]={name='blue', type='normal', r=0, g=0, b=255},
          [10]={name='blue-green', type='normal', r=33, g=182, b=168},
          [11]={name='green', type='normal', r=0, g=255, b=0},
          [12]={name='green-yellow', type='normal', r=160, g=255, b=32},
          [13]={name='black', type='degen', r=0, g=0, b=0},
          [14]={name='white', type='buff', r=255, g=255, b=255},
          [15]={name='player', type='normal', r=255, g=255, b=255},
          [0]={name="exit", type='normal', r=0, g=128, b=0}}
tileSize = 0
grid = 0
origo = {}
height = 0
width = 0
gridsx = {}
gridsy = {}
tiles = {}
start = {}
exit = {}
player = {}
speed = 0
colorSpeed = 0 -- this one is very dependant on the colors we use for the ground
decay = 0
paused = false

l = 1

local originalSpeed = {speed=0, colorSpeed=0}
local messages = {"level clear!", "color attunement error!"}

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
    if key == "r" then
        level.init(pw, ph)
    end
    if key == "l" and paused then
        level = levels[l]
        level.init(pw, ph)
        originalSpeed.speed = speed
        originalSpeed.colorSpeed = colorSpeed
    end
end

function clamp(val, lower, upper)
    return math.max(lower, math.min(val, upper))
end

function love.update(dt)
    if paused then return end

    if love.keyboard.isDown("up") then
        if (player.y - (speed * dt)) > origo.y then
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
        if (player.x - (speed * dt)) > origo.x then
            player.x = player.x - (speed * dt)
        end
    end
    if updateColor then
        if ground[player.tile].name == 'white' and
            decay > 0 then
            colorSpeed = clamp(colorSpeed * 0.5, 0, 100)
            decay = decay - (dt * decaySpeed)
        end
        if ground[player.tile].name == 'red-violet' and
            decay > 0 then
            speed = clamp(speed * 2, 0, 250)
            decay = decay - (dt * decaySpeed)
        end
        if decay <= 0 then
            decay = decay - (dt * decaySpeed)
        end
        if decay < -400 then
            decay = 5
        elseif decay < -250 then
            speed = originalSpeed.speed
            colorSpeed = originalSpeed.colorSpeed
        end
        player.r = mix(player.r, ground[player.tile].r, dt)
        player.g = mix(player.g, ground[player.tile].g, dt)
        player.b = mix(player.b, ground[player.tile].b, dt)
    end
end

function love.load()
    game_font = love.graphics.newImage("assets/font.png")
    game_font:setFilter("nearest", "nearest")
    font = love.graphics.newImageFont(game_font, "abcdefghijklmnopqrstuvwxyz,.!:;?1234567890 \"")
    love.graphics.setFont(font)

    level = levels[3]
    level.init(pw, ph)
    originalSpeed.speed = speed
    originalSpeed.colorSpeed = colorSpeed
    love.graphics.setBackgroundColor(115,115,115)
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
    if math.abs(c2 - c1) < 30 then
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

function nextLevel(msg)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(string.format("%s", messages[msg]), width*0.13, height*0.2)
    if paused then return end
    l = l + 1
    paused = true
end

function getTilePosition(i)
    xpos = i % grid
    ypos = math.ceil(i/grid)
    return gridsx[xpos], gridsy[ypos]
end

function indicateBuff(t)
    local r, g, b = ground[t].r, ground[t].g, ground[t].b
    local fluctuation = 25
    r = math.random(clamp(r-fluctuation, 0, 255), clamp(r+fluctuation, 0, 255))
    g = math.random(clamp(g-fluctuation, 0, 255), clamp(g+fluctuation, 0, 255))
    b = math.random(clamp(b-fluctuation, 0, 255), clamp(b+fluctuation, 0, 255))
    return r, g, b
end

function love.draw()
    local area = 1

    for i, t in ipairs(tiles) do
        if ground[t].type == 'buff' and decay > 0 then
            local r, g, b = indicateBuff(t)
            love.graphics.print(string.format("%d, %d, %d", r, g, b), 25, 10)
            love.graphics.setColor(r, g, b)
        else
            love.graphics.setColor(ground[t].r, ground[t].g, ground[t].b)
        end
        local x, y = getTilePosition(i)
        love.graphics.rectangle("fill", x, y, tileSize, tileSize)

        if inTile(x, y) then
            player.tile = t
        end
    end

    love.graphics.setColor(exit.r, exit.g, exit.b)
    love.graphics.rectangle("fill", exit.x, exit.y, exit.w, exit.h)

    love.graphics.setColor(0, 0, 0)
    love.graphics.print("exit", exit.x, exit.y)

    love.graphics.setColor(player.r, player.g, player.b)
    love.graphics.rectangle("fill", player.x, player.y, player.w, player.h)
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("line", player.x, player.y, player.w, player.h)

    local can_exit, msg = canExit()
    if can_exit then
        updateColor = false
        if msg == 1 then
            nextLevel(msg)
        else
            love.graphics.setColor(0, 0, 0)
            love.graphics.print(string.format("%s", messages[msg]), width*0.20, height*0.2)
        end
    else
        updateColor = true
    end
    love.graphics.print(decay, 10, 10)
end
