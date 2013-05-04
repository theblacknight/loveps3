require("loveps3")

local currentPress = 'None'
local x = 0
local y = 0
local emissionRate = 20
local gravity = 1

local minSpeed = 100
local maxSpeed = 300
local spread = 1

local r = 255
local g = 255
local b = 255

function love.load()
    particle = love.graphics.newImage('assets/particle.png')
    ps = love.graphics.newParticleSystem(particle, 256)
    ps:setParticleLife(1.5)
    ps:setSpread(spread)
    ps:setSpeed(minSpeed, maxSpeed)
    ps:setSpin(1, 3, 1)
    ps:setSizeVariation(1)
    ps:setDirection(1.5)
    refreshParticleSystem()
    ps:stop()

    controller1 = getController(1, buttonListener, stickListener)
    controller2 = getController(2, buttonListener, stickListener)
end

function love.update(dt)
    ps:start()
    ps:update(dt)
    controller1:update()
    if controller2 ~= nil then
        controller2:update()
    end
end

function love.draw()
    love.graphics.draw(ps, love.graphics.getWidth()/2, love.graphics.getHeight()/2)
    love.graphics.print(string.format('Emission rate: %d', emissionRate), 10, 10)
    love.graphics.print(string.format('Gravity rate: %d', gravity), 10, 30)
    love.graphics.print(string.format('X: %f', x), 10, 50)
    love.graphics.print(string.format('Y: %f', y), 10, 70)
end


------

function refreshParticleSystem()
    ps:setEmissionRate(emissionRate)
    ps:setGravity(gravity)
    ps:setColors(r, g, b, 255, r, g, b, 255)
    ps:setPosition(x, y)
    ps:setSpread(spread)
    ps:setSpeed(minSpeed, maxSpeed)
end

------

local baseVector = {x = 1, y = 0}

function stickListener(stick, vector)
    if stick == 'RIGHT' then
        ps:setDirection(angleBetweenSigned(baseVector, vector))
    else
        x = x + vector.x * 2
        y = y + vector.y * 2
        ps:setPosition(x, y)
    end
end

function buttonListener(button)
    if button == 'R2' then
        emissionRate = emissionRate + 1
    elseif button == 'L2' then
        if emissionRate > 1 then
            emissionRate = emissionRate - 1
        end
    elseif button == 'R1' then
        gravity = gravity + 1
    elseif button == 'L1' then
        gravity = gravity - 1
    elseif button == 'LEFT' then
        if spread > 0 then
            spread = spread - 0.01
        end
    elseif button == 'RIGHT' then    
        spread = spread + 0.01
    elseif button == 'UP' then
        maxSpeed = maxSpeed + 1
        minSpeed = minSpeed + 1
    elseif button == 'DOWN' then
        if minSpeed > 0 then
            maxSpeed = maxSpeed - 1
            minSpeed = minSpeed - 1
        end
    elseif button == 'CIRCLE' then
        r = 255
        g = 0
        b = 0
    elseif button == 'X' then
        r = 255
        g = 255
        b = 255
    elseif button == 'SQUARE' then
        r = 0
        g = 0
        b = 255
    elseif button == 'TRIANGLE' then
        r = 0
        g = 255
        b = 0
    elseif button == 'START' then
        love.event.push("quit")
    end
    refreshParticleSystem()
end