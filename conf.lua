function love.conf(t)
    t.window = t.window or t.screen

    t.title = "ld32"
    tileSize = 60
    grid = 5
    t.window.height = tileSize * grid
    t.window.width = tileSize * grid

    t.console = true

    t.screen = t.screen or t.window
end
