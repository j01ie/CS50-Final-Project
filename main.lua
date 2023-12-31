-- Basics
local WINDOW_WIDTH = 800
local WINDOW_HEIGHT = 600
local FPS = 60

-- Ball settings
local ball = {
    x = WINDOW_WIDTH / 2,
    y = WINDOW_HEIGHT,
    radius = 30,
    color = {255, 0, 0}, -- Red ball
    speed = 200
}

-- Jacks settings
local jacks = {}
local maxJacks = 10
local jackSize = 50
local jackImage = nil

-- Score settings
local score = 0

-- Track game state
local gameState = "start"

-- Game title
local gameTitle = "Jack's Game"
local gameTitleFont = love.graphics.newFont(40)

-- Congratulations text
local congratulationsText = "Congratulations!"
local congratulationsFont = love.graphics.newFont(20)

-- Reset button
local resetButton = {
    x = WINDOW_WIDTH / 2 - 70, -- Adjusted x position
    y = WINDOW_HEIGHT / 2 + 25,
    width = 100,
    height = 50,
    font = love.graphics.newFont(20),
    textColor = {0, 0, 0}
}

-- Start button
local startButton = {
    x = WINDOW_WIDTH / 2 - 50,
    y = WINDOW_HEIGHT / 2 - 25,
    width = 100,
    height = 50,
    font = love.graphics.newFont(20),
    textColor = {0, 0, 0}
}

-- Load function
function love.load()
    love.window.setTitle("Jack's Game")
    jackImage = love.graphics.newImage("jack_image.PNG")
    math.randomseed(os.time())
    resetGame()
end

-- Reset game function
function resetGame()
    gameState = "start"
    score = 0
    resetBall()
    spawnJacks()
end

-- Reset ball function
function resetBall()
    ball.x = math.random(ball.radius, WINDOW_WIDTH - ball.radius)
    ball.y = WINDOW_HEIGHT
end

-- Spawn jack basic function 
function spawnJack()
    local jack = {
        x = math.random(jackSize, WINDOW_WIDTH - jackSize),
        y = math.random(jackSize, WINDOW_HEIGHT - jackSize),
        size = jackSize
    }
    table.insert(jacks, jack)
end

-- Spawn multiple jacks for the duration of the game 
function spawnJacks()
    while #jacks < maxJacks do
        spawnJack()
    end
end

-- Update function the controls ball movement and removes jacks that are clicked while keeping score
function love.update(dt)
    if gameState == "playing" then
        -- Move ball upwards until it hits top of window
        ball.y = ball.y - ball.speed * dt

        -- Check if ball has reached the top and then bring it back down
        if ball.y < 0 then
            ball.y = 0
            ball.speed = -ball.speed
        end

        -- Check if ball has reached bottom of window, and once it has reset it for another game
        if ball.y > WINDOW_HEIGHT then
            resetBall()
            ball.speed = math.abs(ball.speed)
            gameState = "end" 
        end
    end

    -- Remove jacks that are clicked
    for i = #jacks, 1, -1 do
        local jack = jacks[i]
        if love.mouse.isDown(1) and
            love.mouse.getX() > jack.x and love.mouse.getX() < jack.x + jack.size and
            love.mouse.getY() > jack.y and love.mouse.getY() < jack.y + jack.size then
            table.remove(jacks, i)
            score = score + 1
            spawnJack() -- call orrigional spawn jack funtion to replace a jack if it is clicked
        end
    end
end

-- Draw function to design everything 
function love.draw()
    -- Set background color to white
    love.graphics.setBackgroundColor(255, 255, 255)

    if gameState == "playing" then
        -- Draw red ball
        love.graphics.setColor(ball.color)
        love.graphics.circle("fill", ball.x, ball.y, ball.radius)

        -- Draw jacks using .png image
        love.graphics.setColor(255, 255, 255)
        for _, jack in ipairs(jacks) do
            love.graphics.draw(jackImage, jack.x, jack.y, 0, jack.size / jackImage:getWidth(), jack.size / jackImage:getHeight())
        end

        -- Score counter
        love.graphics.setColor(0, 0, 0)
        local smallFont = love.graphics.newFont(14)  -- Adjust font size as needed
        love.graphics.setFont(smallFont)
        love.graphics.print("Score: " .. score, 10, 10)
        love.graphics.setFont(gameTitleFont)
   
    elseif gameState == "start" then
        -- Draw start screen
        centerButton(startButton, WINDOW_HEIGHT / 2)
        love.graphics.setColor(0, 255, 0)
        love.graphics.rectangle("fill", startButton.x, startButton.y, startButton.width, startButton.height)
        love.graphics.setColor(startButton.textColor)
        love.graphics.setFont(startButton.font)
        love.graphics.print("Start", startButton.x + 20, startButton.y + 20)

        -- Draw game title
        love.graphics.setFont(gameTitleFont)
        love.graphics.setColor(0, 0, 0)
        local titleWidth = gameTitleFont:getWidth(gameTitle)
        love.graphics.print(gameTitle, (WINDOW_WIDTH - titleWidth) / 2, WINDOW_HEIGHT / 4)

    elseif gameState == "end" then
        -- Draw end screen
        centerButton(resetButton, WINDOW_HEIGHT / 2)
        love.graphics.setColor(0, 15, 240)
        love.graphics.rectangle("fill", resetButton.x, resetButton.y, resetButton.width, resetButton.height)
        love.graphics.setColor(resetButton.textColor)
        love.graphics.setFont(resetButton.font)
        love.graphics.print("Reset", resetButton.x + 20, resetButton.y + 20) -- Adjusted x position

        -- Draw game title
        love.graphics.setFont(gameTitleFont)
        love.graphics.setColor(0, 0, 0)
        local titleWidth = gameTitleFont:getWidth(gameTitle)
        love.graphics.print(gameTitle, (WINDOW_WIDTH - titleWidth) / 2, WINDOW_HEIGHT / 4)

        -- Draw congratulations text under title
        love.graphics.setFont(congratulationsFont)
        local congratsWidth = congratulationsFont:getWidth(congratulationsText)
        love.graphics.print(congratulationsText, (WINDOW_WIDTH - congratsWidth) / 2, WINDOW_HEIGHT / 2 - 50)

        -- Include user's final score under the reset button
        local scoreText = "Your Score: " .. score
        local scoreTextWidth = resetButton.font:getWidth(scoreText)
        love.graphics.print(scoreText, resetButton.x + resetButton.width / 2 - scoreTextWidth / 2, resetButton.y + resetButton.height + 10) -- Centered x position
    end
end

-- Mouse presses function
function love.mousepressed(x, y, button, istouch, presses)
    if gameState == "start" then
        -- Start button
        if x > startButton.x and x < startButton.x + startButton.width and
           y > startButton.y and y < startButton.y + startButton.height then
            gameState = "playing"
        end
    elseif gameState == "end" then
        -- Reset button
        if x > resetButton.x and x < resetButton.x + resetButton.width and
           y > resetButton.y and y < resetButton.y + resetButton.height then
            resetGame()
        end
    end
end

-- Center the two buttons
function centerButton(button, centerY)
    button.x = WINDOW_WIDTH / 2 - button.width / 2
    button.y = centerY - button.height / 2
end

