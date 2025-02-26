function getFont(name, size)
    outputConsole("Loading font " .. name .. ".ttf")
    local font = dxCreateFont(name .. ".ttf", size)

    for i = 1, 10 do
        if not font then
            outputConsole("Failed to load font " .. name .. ".ttf, retrying...")
            font = dxCreateFont(name .. ".ttf", size)
        else
            break
        end
    end

    if not font then
        outputConsole("Failed to load font " .. name .. ".ttf")
    end

    return font
end