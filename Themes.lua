local Themes = {}

Themes.CurrentTheme = {}

Themes.LightDefault = {
    Accent = Color3.fromRGB(60, 119, 247),  -- blue
    Secondary = Color3.fromRGB(255, 120, 200),  -- pink
    Success = Color3.fromRGB(120, 255, 150),  -- green
    Danger = Color3.fromRGB(255, 100, 100),  -- red
    Warning = Color3.fromRGB(255, 180, 100),  -- accent
    Dark = Color3.fromRGB(40, 40, 50),  -- dark color
    Light = Color3.fromRGB(240, 240, 250),  -- light color
    Background = Color3.fromRGB(230,230,230),  -- background
    SecondaryBackground = Color3.fromRGB(220, 220, 220),  -- secondary background
    Card = Color3.fromRGB(240, 240, 250),  -- card
    Text = Color3.fromRGB(30,30,30),  -- primary text
    SubText = Color3.fromRGB(180, 180, 190),  -- secondary text

    Fonts = {
        Bold = Font.fromName("Cairo",Enum.FontWeight.Bold, Enum.FontStyle.Normal),  -- bold font
        Regular = Font.fromName("Cairo",Enum.FontWeight.Regular, Enum.FontStyle.Normal),  -- regular font
    },
    TokenColors = {
        ["background"] = Color3.fromRGB(220, 220, 220),
        ["iden"] = Color3.fromRGB(50, 50, 70),
        ["keyword"] = Color3.fromRGB(133, 35, 125),
        ["builtin"] = Color3.fromRGB(0, 112, 201),
        ["string"] = Color3.fromRGB(46, 147, 68),
        ["number"] = Color3.fromRGB(255, 89, 46),
        ["comment"] = Color3.fromRGB(127, 144, 148),
        ["operator"] = Color3.fromRGB(230, 162, 60),
        ["custom"] = Color3.fromRGB(87, 130, 202),
    } -- Editor Colors
}

Themes.DarkDefault = {
    Accent = Color3.fromRGB(60, 119, 247),
    Secondary = Color3.fromRGB(255, 120, 200),
    Success = Color3.fromRGB(120, 255, 150),
    Danger = Color3.fromRGB(255, 100, 100),
    Warning = Color3.fromRGB(255, 180, 100),
    Dark = Color3.fromRGB(20, 20, 30),
    Light = Color3.fromRGB(60, 60, 80),
    Background = Color3.fromRGB(15, 15, 25),
    SecondaryBackground = Color3.fromRGB(30, 30, 45),
    Card = Color3.fromRGB(40, 40, 60),
    Text = Color3.fromRGB(210, 210, 230),
    SubText = Color3.fromRGB(140, 140, 160),

    Fonts = {
        Bold = Font.fromName("Cairo", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        Regular = Font.fromName("Cairo", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
    },

    TokenColors = {
        ["background"] = Color3.fromRGB(30, 30, 40),
        ["iden"] = Color3.fromRGB(210, 210, 230),
        ["keyword"] = Color3.fromRGB(180, 120, 255),
        ["builtin"] = Color3.fromRGB(100, 160, 255),
        ["string"] = Color3.fromRGB(140, 220, 140),
        ["number"] = Color3.fromRGB(255, 120, 110),
        ["comment"] = Color3.fromRGB(100, 120, 140),
        ["operator"] = Color3.fromRGB(250, 210, 140),
        ["custom"] = Color3.fromRGB(120, 150, 220),
    }
}


return Themes;