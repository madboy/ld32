local height = love.graphics.getHeight()
local width = love.graphics.getWidth()

local pw = 25
local ph = 25

local start = {x=width*0.5, y=height-ph}

local player = {x=start.x, y=start.y, w=pw, h=ph, r=255, g=255, b=255, area=1}

local exit = {x=width*0.5, y=0, w=player.w*2, h=player.h*1.3, r=115, g=155, b=115}
local messages = {"Level clear!", "Color attunement error!"}

local areas = {{x=0, y=0, w=width, h=height*0.5, r=115, g=115, b=155},
               {x=0, y=height*0.5, w=width, h=height*0.5, r=155, g=115, b=115},
               {x=exit.x-player.w, y=height*0.2, w=player.w*3, h=player.h*2, r=115, g=155, b=115}}

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

local speed = 128
local colorSpeed = 20
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
        player.r = mix(player.r, areas[player.area].r, dt)
        player.g = mix(player.g, areas[player.area].g, dt)
        player.b = mix(player.b, areas[player.area].b, dt)
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

function love.draw()
    local area = 1

    for i, a in ipairs(areas) do
        love.graphics.setColor(a.r, a.g, a.b)
        love.graphics.rectangle("fill", a.x, a.y, a.w, a.h)

        if inArea(a) then
            player.area = i
        end
    end

    love.graphics.setColor(exit.r, exit.g, exit.b)
    love.graphics.rectangle("fill", exit.x, exit.y, exit.w, exit.h)


    love.graphics.setColor(player.r, player.g, player.b)
    love.graphics.rectangle("fill", player.x, player.y, player.w, player.h)
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("line", player.x, player.y, player.w, player.h)

    love. graphics.push()
    love.graphics.scale(2, 2)
    local can_exit, msg = canExit()
    if can_exit then
        updateColor = false
        love.graphics.print(string.format("%s", messages[msg]), width*0.13, height*0.2)
    else
        updateColor = true
    end
    love.graphics.pop()
end
