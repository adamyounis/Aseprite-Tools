--[[
Description: 
A script to save all different layers in different .png files.
Made by Gaspi.
   - Itch.io: https://gaspi.itch.io/
   - Twitter: @_Gaspi

Groups mod by Adam Younis.
   - itch.io https://uppon-hill.itch.io/
   - Twitter: @AdamCYounis
--]]

-- Auxiliar functions.
function getPath(str,sep)
   -- Source: https://stackoverflow.com/questions/9102126/lua-return-directory-path-from-path
    sep=sep or'/'
    return str:match("(.*"..sep..")")
end

function getFileName(str,sep)
   --[[ Sources:
      - https://codereview.stackexchange.com/questions/90177/get-file-name-with-extension-and-get-only-extension
      - https://stackoverflow.com/questions/18884396/extracting-filename-only-with-pattern-matching
   --]]
   str = str:match("^.+"..sep.."(.+)$")
   return str:match("(.+)%..+")
end

-- Hides all layers and sublayers inside a group, returning a list with all initial states of each layer's visibility.
function hideLayers(sprite)
   local layerVisibility = {}
   for i,layer in ipairs(sprite.layers) do
      layerVisibility[i] = layer.isVisible
      layer.isVisible = false
      if (layer.isGroup) then
            layerVisibility[i] = hideLayers(layer)
      end
   end
   return layerVisibility
end

-- Restore layers visibility.
function restoreLayersVisibility(layerVisibility, sprite)
   for i,layer in ipairs(sprite.layers) do
      -- Avoid group layers.
        layer.isVisible = layerVisibility[i]
        if (layer.isGroup) then
            restoreLayersVisibility(layerVisibility[i], layer)
      end
   end
end
   
-- Save the root layers as individual sprites.
function exportLayers(sprite, rootLayer, pathPrefix, pathSufix)
   for i,layer in ipairs(rootLayer.layers) do
      if (layer.isEditable) then
         if (not layer.isGroup) then
            -- Individual layer. Save it.
            layer.isVisible = true
            local layerName = "_" .. string.lower(layer.name)
            sprite:saveCopyAs(pathPrefix .. layerName .. pathSufix .. ".png")
            layer.isVisible = false
         else
            -- Root Groups. Save them too.
            layer.isVisible = true
            
            for i, layer2 in ipairs(layer.layers) do
               if(layer2.isEditable) then
                layer2.isVisible = true;
               end
            end           
            local layerName = "_" .. string.lower(layer.name)
            sprite:saveCopyAs(pathPrefix .. layerName .. pathSufix .. ".png")
            layer.isVisible = false

            for i, layer2 in ipairs(layer.layers) do
                layer2.isVisible = false;
            end       
         end
      end
   end
end

-- Identify current sprite.
local sprite = app.activeSprite
if (sprite == nil) then
   -- Show error, no sprite active.
   local dlg = Dialog("Error")
   dlg:label{  id = 0,
               text = "No sprite is currently active. Please, open a sprite first and run the script with it active."
            }
   dlg:newrow()
   dlg:button{ id = 1,
               text = "Close",
               onclick = function()
                         dlg:close()
                         end
            }
   dlg:show()
   return
end

-- Path where sprites are saved.
local spritePath = sprite.filename
-- Identify operative system.
local separator
if (string.sub(spritePath, 1, 1) == "/") then
   separator = "/"
else
   separator = "\\"
end
local spriteName = getFileName(spritePath, separator)
local path = getPath(spritePath, separator) .. spriteName .. separator

-- Add a '_' to the filename if it has multiple frames
local multipleFrames = ""
if (#sprite.frames > 1) then
   multipleFrames = "_"
end

local layerVisibility = hideLayers(sprite)

exportLayers(sprite, sprite, path .. spriteName, multipleFrames)

restoreLayersVisibility(layerVisibility, sprite)
