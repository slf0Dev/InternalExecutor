local Themes = {}

Themes.LightDefault = {
    Accent = Color3.fromRGB(100, 150, 255),  -- blue
    Secondary = Color3.fromRGB(255, 120, 200),  -- pink
    Success = Color3.fromRGB(120, 255, 150),  -- green
    Danger = Color3.fromRGB(255, 100, 100),  -- red
    Warning = Color3.fromRGB(255, 180, 100),  -- accent
    Dark = Color3.fromRGB(40, 40, 50),  -- dark color
    Light = Color3.fromRGB(240, 240, 250),  -- light color
    Background = Color3.fromRGB(230,230,230),  -- background
    SecondaryBackground = Color3.fromRGB(220, 220, 230),  -- secondary background
    Card = Color3.fromRGB(240, 240, 250),  -- card
    Text = Color3.fromRGB(30,30,30),  -- primary text
    SubText = Color3.fromRGB(180, 180, 190),  -- secondary text

    Fonts = {
        Bold = Font.fromName("Cairo",Enum.FontWeight.Bold, Enum.FontStyle.Normal),  -- bold font
        Regular = Font.fromName("Cairo",Enum.FontWeight.Regular, Enum.FontStyle.Normal),  -- regular font
    },  -- fonts
}

return Themes;