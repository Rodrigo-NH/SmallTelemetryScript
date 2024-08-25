local function getOptTable()
    local mapoptionstable = {
        { "Center on", 2,
            {
                { "Vehicle - once",   1 },
                { "Vehicle - sticky", 1 },
                { "Home",             1 },
                { "Center map",       1 },
                { "WayPoint", 2,
                    {
                        -- to be filled with actual waypoints
                    }
                },
            }
        },
        { "Snap on segment", 2,
            {
                { "Actual goto segment", 9 },
                { "Waypoint reference", 2,
                    {
                        -- to be filled with actual waypoints
                    }
                },
            }
        },
        { "Reset scale", 1 },
        { "Go to", 2,
            {
                -- to be filled with actual waypoints
            }
        },
        { "Abort Go to", 7 },
        { "Load mission from SD card", 2,
            {
                -- to be filled with mission files from /missions/ directory
            }
        },
        { "Info ON/OFF", 8 },
    }
    return mapoptionstable
end

return {
    getOptTable = getOptTable,
}
