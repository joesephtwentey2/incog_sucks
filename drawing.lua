-- You will experience severe FPS drops if you fill the shapes since i decided to draw each pixel on its own.
local gui = Instance.new("ScreenGui")
gui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(1, 0, 1, 0)
frame.BackgroundTransparency = 1
frame.Parent = gui

function drawPixel(x, y, color)
    local pixel = Instance.new("Frame")
    pixel.Size = UDim2.new(0, 1, 0, 1)
    pixel.Position = UDim2.new(0, x, 0, y)
    pixel.BackgroundColor3 = color
    pixel.BorderSizePixel = 0
    pixel.Parent = frame
end

local function drawCircle(properties)
    local center = properties.Position
    local radius = properties.Radius
    local color = properties.Color
    local filled = properties.Filled

    local function plot(xc, yc, x, y)
        drawPixel(xc + x, yc + y, color)
        drawPixel(xc - x, yc + y, color)
        drawPixel(xc + x, yc - y, color)
        drawPixel(xc - x, yc - y, color)
        drawPixel(xc + y, yc + x, color)
        drawPixel(xc - y, yc + x, color)
        drawPixel(xc + y, yc - x, color)
        drawPixel(xc - y, yc - x, color)
    end

    local x = 0
    local y = radius
    local p = 1 - radius

    while x < y do
        if filled then
            for i = x, y do
                plot(center.X, center.Y, x, i)
                plot(center.X, center.Y, i, x)
            end
        else
            plot(center.X, center.Y, x, y)
            plot(center.X, center.Y, y, x)
        end

        x = x + 1
        if p < 0 then
            p = p + 2 * x + 1
        else
            y = y - 1
            p = p + 2 * (x - y) + 1
        end
    end
end

local function drawSquare(properties)
    local center = properties.Position
    local size = properties.Size
    local color = properties.Color
    local filled = properties.Filled

    local halfSize = size / 2
    local topLeft = Vector2.new(center.X - halfSize, center.Y - halfSize)
    local bottomRight = Vector2.new(center.X + halfSize, center.Y + halfSize)

    if filled then
        for x = topLeft.X, bottomRight.X do
            for y = topLeft.Y, bottomRight.Y do
                drawPixel(x, y, color)
            end
        end
    else
        for x = topLeft.X, bottomRight.X do
            drawPixel(x, topLeft.Y, color)
            drawPixel(x, bottomRight.Y, color)
        end
        for y = topLeft.Y, bottomRight.Y do
            drawPixel(topLeft.X, y, color)
            drawPixel(bottomRight.X, y, color)
        end
    end
end

local function drawLine(properties)
    local startPoint = properties.StartPoint
    local endPoint = properties.EndPoint
    local color = properties.Color

    local delta = endPoint - startPoint
    local steps = math.max(math.abs(delta.X), math.abs(delta.Y))

    for i = 0, steps do
        local t = i / steps
        local x = math.floor(startPoint.X + t * delta.X + 0.5)
        local y = math.floor(startPoint.Y + t * delta.Y + 0.5)
        drawPixel(x, y, color)
    end
end

local function drawTriangle(properties)
    local point1 = properties.Point1
    local point2 = properties.Point2
    local point3 = properties.Point3
    local color = properties.Color
    local filled = properties.Filled

    local function fillPoints(p1, p2)
        local delta = p2 - p1
        local steps = math.max(math.abs(delta.X), math.abs(delta.Y))

        for i = 0, steps do
            local t = i / steps
            local x = math.floor(p1.X + t * delta.X + 0.5)
            local y = math.floor(p1.Y + t * delta.Y + 0.5)
            drawPixel(x, y, color)
        end
    end

    fillPoints(point1, point2)
    fillPoints(point2, point3)
    fillPoints(point3, point1)

    if filled then
        local minX = math.min(point1.X, point2.X, point3.X)
        local minY = math.min(point1.Y, point2.Y, point3.Y)
        local maxX = math.max(point1.X, point2.X, point3.X)
        local maxY = math.max(point1.Y, point2.Y, point3.Y)

        for x = minX, maxX do
            for y = minY, maxY do
                local p = Vector2.new(x, y)
                local b1 = ((point2.X - point1.X) * (p.Y - point1.Y) - (point2.Y - point1.Y) * (p.X - point1.X)) < 0
                local b2 = ((point3.X - point2.X) * (p.Y - point2.Y) - (point3.Y - point2.Y) * (p.X - point2.X)) < 0
                local b3 = ((point1.X - point3.X) * (p.Y - point3.Y) - (point1.Y - point3.Y) * (p.X - point3.X)) < 0

                if b1 == b2 and b2 == b3 then
                    drawPixel(x, y, color)
                end
            end
        end
    end
end

local function drawQuad(properties)
    local pointA = properties.PointA
    local pointB = properties.PointB
    local pointC = properties.PointC
    local pointD = properties.PointD
    local color = properties.Color
    local filled = properties.Filled
    local thickness = properties.Thickness

    if filled then
        local minX = math.min(pointA.X, pointB.X, pointC.X, pointD.X)
        local minY = math.min(pointA.Y, pointB.Y, pointC.Y, pointD.Y)
        local maxX = math.max(pointA.X, pointB.X, pointC.X, pointD.X)
        local maxY = math.max(pointA.Y, pointB.Y, pointC.Y, pointD.Y)

        for x = minX, maxX do
            for y = minY, maxY do
                local p = Vector2.new(x, y)
                local b1 = ((pointB.X - pointA.X) * (p.Y - pointA.Y) - (pointB.Y - pointA.Y) * (p.X - pointA.X)) < 0
                local b2 = ((pointC.X - pointB.X) * (p.Y - pointB.Y) - (pointC.Y - pointB.Y) * (p.X - pointB.X)) < 0
                local b3 = ((pointD.X - pointC.X) * (p.Y - pointC.Y) - (pointD.Y - pointC.Y) * (p.X - pointC.X)) < 0
                local b4 = ((pointA.X - pointD.X) * (p.Y - pointD.Y) - (pointA.Y - pointD.Y) * (p.X - pointD.X)) < 0

                if b1 == b2 and b2 == b3 and b3 == b4 then
                    drawPixel(x, y, color)
                end
            end
        end
    else
        drawLine({ StartPoint = pointA, EndPoint = pointB, Color = color })
        drawLine({ StartPoint = pointB, EndPoint = pointC, Color = color })
        drawLine({ StartPoint = pointC, EndPoint = pointD, Color = color })
        drawLine({ StartPoint = pointD, EndPoint = pointA, Color = color })

        if thickness and thickness > 1 then
            local halfThickness = math.floor(thickness / 2)
            for i = 1, halfThickness do
                drawLine({ StartPoint = pointA + Vector2.new(i, i), EndPoint = pointB + Vector2.new(i, i), Color = color })
                drawLine({ StartPoint = pointB + Vector2.new(i, i), EndPoint = pointC + Vector2.new(i, i), Color = color })
                drawLine({ StartPoint = pointC + Vector2.new(i, i), EndPoint = pointD + Vector2.new(i, i), Color = color })
                drawLine({ StartPoint = pointD + Vector2.new(i, i), EndPoint = pointA + Vector2.new(i, i), Color = color })
            end
        end
    end
end

local function drawText(text, position, color, fontSize)
    local textLabel = Instance.new("TextLabel")
    textLabel.Text = text
    textLabel.TextColor3 = color
    textLabel.Position = UDim2.new(0, position.X, 0, position.Y)
    textLabel.TextSize = fontSize
    textLabel.Parent = frame
end

local Drawing = {}
Drawing.__index = Drawing

function Drawing.new(shape, properties)
    local self = setmetatable({}, Drawing)
    if shape == "circle" then
        drawCircle(properties)
    elseif shape == "square" then
        drawSquare(properties)
    elseif shape == "line" then
        drawLine(properties)
    elseif shape == "triangle" then
        drawTriangle(properties)
    elseif shape == "quad" then
        drawQuad(properties)
    elseif shape == "text" then
        drawText(properties.Text, properties.Position, properties.Color, properties.FontSize)
    end
    return self
end



-- USAGE
Drawing.new("circle", {
    Radius = 50,
    Color = Color3.fromRGB(255, 255, 255),
    Filled = false,
    Position = Vector2.new(50, 50),
    Visible = true
})

Drawing.new("square", {
    Size = 100,
    Color = Color3.fromRGB(255, 255, 255),
    Filled = false,
    Position = Vector2.new(100, 50),
    Visible = true
})

Drawing.new("triangle", {
    Point1 = Vector2.new(225, 25),
    Point2 = Vector2.new(275, 25),
    Point3 = Vector2.new(250, 75),
    Color = Color3.fromRGB(255, 255, 255),
    Filled = false,
    Visible = true
})


Drawing.new("text", {
    Text = "incognito",
    Position = Vector2.new(200, 400),
    Color = Color3.fromRGB(255, 255, 255), 
    FontSize = 24,
    Visible = true
})

Drawing.new("quad", {
    PointA = Vector2.new(200, 460),
    PointB = Vector2.new(300, 400),
    PointC = Vector2.new(370, 500),
    PointD = Vector2.new(200, 590),
    Color = Color3.fromRGB(255, 255, 255),
    Filled = false,
    Thickness = 1,
    Visible = true
})
