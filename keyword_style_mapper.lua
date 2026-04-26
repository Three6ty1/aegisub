script_name = "Keyword → Style Mapper"
script_description = "Apply styles based on keywords (Removes style after)"
script_author = "ChatGPT (Three6ty1)"
script_version = "1.1"

include("karaskel.lua")

local function escape_pattern(text)
    return text:gsub("([^%w])", "%%%1")
end

function keyword_style_mapper(subtitles, sel)

    local meta, styles = karaskel.collect_head(subtitles, false)

    local style_names = {}
    for i = 1, styles.n do
        table.insert(style_names, styles[i].name)
    end

    if #style_names == 0 then
        aegisub.debug.out("No styles found in script.\n")
        return
    end

    local pressed, res_count = aegisub.dialog.display({
        {class="label", label="How many keyword mappings?", x=0,y=0},
        {class="intedit", name="count", value=1, min=1, max=20, x=0, y=1}
    }, {"OK", "Cancel"})

    if pressed ~= "OK" then aegisub.cancel() end

    local count = res_count.count
    local config = {}

    for i = 0, math.min(count, styles.n) -1  do
        local row = i * 3

        table.insert(config, {
            x=0, y=row,
            class="label",
            label="Keyword " .. (i+1)
        })

        table.insert(config, {
            x=1, y=row,
            class="edit",
            name="k"..i,
            value="",
            width=30
        })

        table.insert(config, {
            x=0, y=row+1,
            class="label",
            label="Style"
        })

        table.insert(config, {
            x=1, y=row+1,
            class="dropdown",
            name="s"..i,
            items=style_names,
            value=style_names[i + 1],
            width=30
        })
    end

    local pressed2, res = aegisub.dialog.display(config, {"OK", "Cancel"})
    if pressed2 ~= "OK" then aegisub.cancel() end

    local mappings = {}

    for i = 0, count - 1 do
        local key = res["k"..i]
        local style = res["s"..i]

        if key and key ~= "" then
            table.insert(mappings, {
                key = escape_pattern(key),
                style = style
            })
        end
    end

    for _, i in ipairs(sel) do
        local line = subtitles[i]

        if line.class == "dialogue" then
            local text = line.text

            for _, m in ipairs(mappings) do
                if text:find("^" .. m.key) then
                    text = text:gsub("^" .. m.key, "")
                    line.style = m.style
                    break
                end
            end

            line.text = text
            subtitles[i] = line
        end
    end
end

aegisub.register_macro(script_name, script_description, keyword_style_mapper)
