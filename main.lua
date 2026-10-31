-- Pong Game in Love2D
-- Task 1 & Task 2 Complete Implementation

local WINDOW_WIDTH = 800
local WINDOW_HEIGHT = 600

-- Ball initial speed constants
local INITIAL_BALL_SPEED_X = 320
local INITIAL_BALL_SPEED_Y = 160
local SPEED_MULTIPLIER_ON_HIT = 1.05 -- Own change: ball speeds up on paddle hit

-- Fonts
local scoreFont
local messageFont
local infoFont

function love.load()
    -- Set window title
    love.window.setTitle("Pong - Love2D")

    -- Set dark background color
    love.graphics.setBackgroundColor(0.08, 0.08, 0.11)

    -- Initialize fonts
    scoreFont = love.graphics.newFont(40)
    messageFont = love.graphics.newFont(20)
    infoFont = love.graphics.newFont(14)

    -- Player 1 (Left paddle)
    player1 = {
        x = 30,
        y = (WINDOW_HEIGHT - 100) / 2,
        width = 16,
        height = 100,
        speed = 420,
        score = 0,
        color = { 0.25, 0.75, 1.0 } -- Own change: Custom Cyan color
    }

    -- Player 2 (Right paddle)
    player2 = {
        x = WINDOW_WIDTH - 30 - 16,
        y = (WINDOW_HEIGHT - 100) / 2,
        width = 16,
        height = 100,
        speed = 420,
        score = 0,
        color = { 1.0, 0.42, 0.35 } -- Own change: Custom Coral color
    }

    -- Ball table
    ball = {
        x = (WINDOW_WIDTH - 14) / 2,
        y = (WINDOW_HEIGHT - 14) / 2,
        width = 14,
        height = 14,
        dx = INITIAL_BALL_SPEED_X,
        dy = INITIAL_BALL_SPEED_Y,
        color = { 1.0, 0.88, 0.2 } -- Own change: Custom Golden Yellow color
    }

    -- Game state: 'serve' or 'play' (Own change: Press Space to Serve)
    gameState = 'serve'
    servingPlayer = 1
end

-- AABB (Axis-Aligned Bounding Box) collision detection function
-- Checks whether two rectangular bounding boxes overlap
function checkCollision(a, b)
    return a.x < b.x + b.width and
           a.x + a.width > b.x and
           a.y < b.y + b.height and
           a.y + a.height > b.y
end

-- Reset ball to center and set state to 'serve'
function resetBall(servingTo)
    ball.x = (WINDOW_WIDTH - ball.width) / 2
    ball.y = (WINDOW_HEIGHT - ball.height) / 2

    -- Determine serve direction based on who scores
    local dirX = (servingTo == 1) and -1 or 1
    local randomY = love.math.random(-150, 150)
    if math.abs(randomY) < 50 then
        randomY = 60
    end

    ball.dx = INITIAL_BALL_SPEED_X * dirX
    ball.dy = randomY

    gameState = 'serve'
    servingPlayer = servingTo
end

function love.keypressed(key)
    -- Space to serve the ball
    if key == 'space' then
        if gameState == 'serve' then
            gameState = 'play'
        end
    end

    -- Escape to quit
    if key == 'escape' then
        love.event.quit()
    end
end

function love.update(dt)
    -- ==========================================
    -- 1. Paddle Movement (multiplied by dt)
    -- ==========================================
    -- Player 1 movement (W and S keys)
    if love.keyboard.isDown('w') then
        player1.y = player1.y - player1.speed * dt
    end
    if love.keyboard.isDown('s') then
        player1.y = player1.y + player1.speed * dt
    end

    -- Player 2 movement (Up and Down arrows)
    if love.keyboard.isDown('up') then
        player2.y = player2.y - player2.speed * dt
    end
    if love.keyboard.isDown('down') then
        player2.y = player2.y + player2.speed * dt
    end

    -- Clamp paddles inside screen bounds
    player1.y = math.max(0, math.min(WINDOW_HEIGHT - player1.height, player1.y))
    player2.y = math.max(0, math.min(WINDOW_HEIGHT - player2.height, player2.y))

    -- ==========================================
    -- 2. Ball Movement & Physics
    -- ==========================================
    if gameState == 'play' then
        -- Move ball by velocities multiplied by dt
        ball.x = ball.x + ball.dx * dt
        ball.y = ball.y + ball.dy * dt

        -- Top wall collision
        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
        end

        -- Bottom wall collision
        if ball.y + ball.height >= WINDOW_HEIGHT then
            ball.y = WINDOW_HEIGHT - ball.height
            ball.dy = -ball.dy
        end

        -- Paddle 1 collision (Left paddle)
        if checkCollision(ball, player1) then
            -- Reverse horizontal velocity and slightly increase speed
            ball.dx = math.abs(ball.dx) * SPEED_MULTIPLIER_ON_HIT
            -- Move ball just outside the paddle to prevent getting stuck
            ball.x = player1.x + player1.width

            -- Adjust vertical angle based on where it hit the paddle
            local paddleCenter = player1.y + (player1.height / 2)
            local ballCenter = ball.y + (ball.height / 2)
            local hitOffset = (ballCenter - paddleCenter) / (player1.height / 2)
            ball.dy = ball.dy + hitOffset * 60
        end

        -- Paddle 2 collision (Right paddle)
        if checkCollision(ball, player2) then
            -- Reverse horizontal velocity and slightly increase speed
            ball.dx = -math.abs(ball.dx) * SPEED_MULTIPLIER_ON_HIT
            -- Move ball just outside the paddle to prevent getting stuck
            ball.x = player2.x - ball.width

            -- Adjust vertical angle based on where it hit the paddle
            local paddleCenter = player2.y + (player2.height / 2)
            local ballCenter = ball.y + (ball.height / 2)
            local hitOffset = (ballCenter - paddleCenter) / (player2.height / 2)
            ball.dy = ball.dy + hitOffset * 60
        end

        -- Scoring checks
        -- Ball passed left wall -> Player 2 scores
        if ball.x + ball.width < 0 then
            player2.score = player2.score + 1
            resetBall(1)
        end

        -- Ball passed right wall -> Player 1 scores
        if ball.x > WINDOW_WIDTH then
            player1.score = player1.score + 1
            resetBall(2)
        end
    end
end

function love.draw()
    -- Draw center dashed dividing line
    love.graphics.setColor(1, 1, 1, 0.15)
    for y = 10, WINDOW_HEIGHT, 24 do
        love.graphics.rectangle('fill', (WINDOW_WIDTH / 2) - 1, y, 2, 14)
    end

    -- Draw scores
    love.graphics.setFont(scoreFont)
    love.graphics.setColor(player1.color)
    love.graphics.printf(tostring(player1.score), (WINDOW_WIDTH / 2) - 100, 30, 80, 'right')

    love.graphics.setColor(player2.color)
    love.graphics.printf(tostring(player2.score), (WINDOW_WIDTH / 2) + 20, 30, 80, 'left')

    -- Draw left paddle (Player 1) with custom Cyan color
    love.graphics.setColor(player1.color)
    love.graphics.rectangle('fill', player1.x, player1.y, player1.width, player1.height)

    -- Draw right paddle (Player 2) with custom Coral color
    love.graphics.setColor(player2.color)
    love.graphics.rectangle('fill', player2.x, player2.y, player2.width, player2.height)

    -- Draw ball with custom Golden Yellow color
    love.graphics.setColor(ball.color)
    love.graphics.rectangle('fill', ball.x, ball.y, ball.width, ball.height)

    -- Draw status message when in 'serve' state
    if gameState == 'serve' then
        love.graphics.setFont(messageFont)
        love.graphics.setColor(1, 1, 1, 0.9)
        love.graphics.printf("Press SPACE to Serve!", 0, WINDOW_HEIGHT - 90, WINDOW_WIDTH, 'center')

        love.graphics.setFont(infoFont)
        love.graphics.setColor(0.7, 0.7, 0.7, 0.8)
        love.graphics.printf("Controls: Player 1 [W/S] | Player 2 [Up/Down]", 0, WINDOW_HEIGHT - 55, WINDOW_WIDTH, 'center')
    end
end
