-- filters/issue_toc_bullets.lua
-- Collect all level-2 headings (##) and inject as a plain bullet list
-- into a Div with class "issue-toc".

local headings = {}

local function collect_headings(blocks)
  for _, b in ipairs(blocks) do
    if b.t == "Header" and b.level == 2 then
      -- store the inline content (formatted text) of the header
      table.insert(headings, b.content)
    elseif b.t == "Div" then
      collect_headings(b.content)
    end
  end
end

local function replace_placeholders(blocks)
  local out = {}
  for _, b in ipairs(blocks) do
    if b.t == "Div" and b.classes:includes("issue-toc") then
      -- Build bullet list items as Plain blocks
      local items = {}
      for _, h in ipairs(headings) do
        table.insert(items, { pandoc.Plain(h) })
      end

      -- If there are no headings, drop the placeholder silently
      if #items > 0 then
        table.insert(out, pandoc.BulletList(items))
      end
    else
      if b.t == "Div" then
        b.content = replace_placeholders(b.content)
      end
      table.insert(out, b)
    end
  end
  return out
end

function Pandoc(doc)
  headings = {}
  collect_headings(doc.blocks)

  -- Optional: if you want to EXCLUDE the first level-2 heading (your main issue title),
  -- uncomment the next 3 lines:
   if #headings > 0 then
     table.remove(headings, 1)
   end

  doc.blocks = replace_placeholders(doc.blocks)
  return doc
end
