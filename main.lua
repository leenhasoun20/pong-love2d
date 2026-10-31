-- Pong Game in Love2D - Part 1
-- Task 1: Window and Paddles

local WINDOW_WIDTH = 800
local WINDOW_HEIGHT = 600

function love.load()
    -- Set window title and background color
    love.window.setTitle("Pong - Love2D")
    love.graphics.setBackgroundColor(0.1, 0.1, 0.12) -- Dark background

    -- Player 1 (Left paddle) Lua table
    player1 = {
        x = 30,
        y = (WINDOW_HEIGHT - 100) / 2,
        width = 15,
        height = 100,
        speed = 400
    }

    -- Player 2 (Right paddle) Lua table
    player2 = {
        x = WINDOW_WIDTH - 30 - 15,
        y = (WINDOW_HEIGHT - 100) / 2,
        width = 15,
        height = 100,
        speed = 400
    }
end

function love.update(dt)
    -- Player 1 controls: 'w' (up) and 's' (down)
    -- Movement multiplied by dt for frame-rate independence
    if love.keyboard.isDown('w') then
        player1.y = player1.y - player1.speed * dt
    end
    if love.keyboard.isDown('s') then
        player1.y = player1.y + player1.speed * dt
    end

    -- Player 2 controls: 'up' arrow and 'down' arrow
    if love.keyboard.isDown('up') then
        player2.y = player2.y - player2.speed * dt
    end
    if love.keyboard.isDown('down') then
        player2.y = player2.y + player2.speed * dt
    end

    -- Clamp paddles within screen bounds (prevent leaving top or bottom)
    player1.y = math.max(0, math.min(WINDOW_HEIGHT - player1.height, player1.y))
    player2.y = math.max(0, math.min(WINDOW_HEIGHT - player2.height, player2.y))
end

function love.draw()
    -- Draw left paddle
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle('fill', player1.x, player1.y, player1.width, player1.height)

    -- Draw right paddle
    love.graphics.rectangle('fill', player2.x, player2.y, player2.width, player2.height)
end
