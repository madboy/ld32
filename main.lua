local height = love.graphics.getHeight()
local width = love.graphics.getWidth()

local player = {x=0, y=0, w=25, h=25, r=255, g=255, b=255}
local areas = {{x=0, y=0, w=width, h=height*0.5, r=115, g=115, b=155}, 
               {x=0, y=height*0.5, w=width, h=height*0.5, r=155, g=115, b=115}}

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

function love.update(dt)
    if love.keyboard.isDown("up") then
        if (player.y - 1) > 0 then
            player.y = player.y - 1
        end
    end
    if love.keyboard.isDown("down") then
        if (player.y + player.h + 1) < height then
            player.y = player.y + 1
        end
    end
    if love.keyboard.isDown("right") then
        if (player.x + player.w + 1) < width then
            player.x = player.x + 1
        end
    end
    if love.keyboard.isDown("left") then
        if (player.x - 1) > 0 then
            player.x = player.x - 1
        end
    end
end

function love.load()
end

function mix(c1, c2)
    if c1 < c2 then
        return c1 + 0.06
    else
        return c1 - 0.06
    end
end

function inArea(a)
    return (player.x >= a.x) and (player.y >= a.y) and
            ((player.x + player.w) < (a.x + a.w)) and
            ((player.y + player.h) < (a.y + a.h))
end

function love.draw()
    for i, a in ipairs(areas) do
        love.graphics.setColor(a.r, a.g, a.b)
        love.graphics.rectangle("fill", a.x, a.y, a.w, a.h) 

        if inArea(a) then
            player.r = mix(player.r, a.r)
            player.g = mix(player.g, a.g)
            player.b = mix(player.b, a.b)
        end
    end
    love.graphics.setColor(player.r, player.g, player.b)
    love.graphics.rectangle("fill", player.x, player.y, player.w, player.h)
end
