--[[
Copyright (c) 2013 Kevin Bergin

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
]]

local controller = {}
controller.__index = controller

local MAX_STICK_MAG = math.sqrt(2)

local ps3ButtonMap = {
    'SELECT', 'L3', 'R3', 'START', 'UP', 'RIGHT', 'DOWN', 'LEFT',
    'L2', 'R2', 'L1', 'R1', 'TRIANGLE', 'CIRCLE', 'X', 'SQUARE', 'PS'
}

--- Get a reference to a controller
-- @param number The id of the controller (1, 2, 3, 4 etc..)
-- @param buttonListener A callback that is notified of button presses
-- @param stickListener A callback that is notified of analog stick changes
function getController(number, buttonListener, stickListener)
    if love.joystick.getNumJoysticks() < number then
        return nil
    end
    local c = {}
    c.number = number
    c.numButtons = love.joystick.getNumButtons(number)
    c.buttonListener = buttonListener
    c.stickListener = stickListener
    return setmetatable(c, controller)
end

--- Check for any button presses or stick movements
function controller:update(restrict)
    if self.buttonListener ~= nil then 
        for i=1,self.numButtons do 
            if love.joystick.isDown(self.number, i) then
                self.buttonListener(ps3ButtonMap[i])
            end
        end
    end
    if self.stickListener ~= nil then
        leftStickVector = getStickVector(self)
        rightStickVector = getStickVector(self, 2)
        if restrict == false or magnitude(leftStickVector) > 0.2 then
            stickListener('LEFT', leftStickVector)
        end
        if restrict == false or magnitude(rightStickVector) > 0.2 then
            stickListener('RIGHT', rightStickVector)
        end
    end
end

-- Some helpers

local leftVector = {x = -1, y = 0}
local rightVector = {x = 1, y = 0}
local upVector = {x = 0, y = -1}
local downVector = {x = 0, y = 1}

function  pointingLeft(vector)
    return vector.x < 0 and pointing(vector, leftVector)
end

function  pointingRight(vector)
   return vector.x > 0 and pointing(vector, rightVector) 
end

function  pointingUp(vector)
   return vector.y < 0 and pointing(vector, upVector) 
end

function  pointingDown(vector)
   return vector.y > 0 and pointing(vector, downVector) 
end

function  pointing(vector, baseVector)
    if magnitude(vector) >= 1 then
        if angleBetween(baseVector, vector) <= 1 then
            return true
        end
    end
    return false
end

-- Return the magnitude of the specified vector
function magnitude(vector)
    return math.sqrt(math.pow(vector.x, 2) + math.pow(vector.y, 2))
end

--- Normalise the given vector (great vector with magnitude of 1)
function normalise(vector)
    mag = magnitude(vector)
    return {x = vector.x/mag, y = vector.y/mag}
end

-- Compute the dot product of two vectors
function dot(vector1, vector2)
    return vector1.x * vector2.x + vector1.y * vector2.y
end

-- Get the angle between two vectors, this will return 0 -> 180 degress (in radians)
function angleBetween(vector1, vector2)
    return math.acos(dot(vector1, vector2))
end

-- Get the angle between two vectors, this will return 0 -> +-180 degress (in radians),
function angleBetweenSigned(vector1, vector2)
    return math.atan2(vector2.y,vector2.x) - math.atan2(vector1.y,vector1.x)
end

-- The compute the directional vector of the specified stick (1 = left, 2 = right)
function getStickVector(controller, stick)
    -- default to left stick
    leftRightAxis = 1
    upDownAxis = 2
    if stick == 2 then
        leftRightAxis = 3
        upDownAxis = 4
    end
    leftRight = love.joystick.getAxis(controller.number, leftRightAxis)
    upDown = love.joystick.getAxis(controller.number, upDownAxis)
    return {x = leftRight, y = upDown}
end
