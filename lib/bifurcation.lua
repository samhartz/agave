-- bifurcation script
function find_local_extrema(array, start_val, end_val)
    extrema = {}
    -- array = z_a
    -- for i = 2, #array - 1 do
    for i = start_val, end_val do
      if (array[i] < array[i - 1] and array[i] < array[i + 1]) then
        table.insert(extrema, array[i])
      elseif  (array[i] > array[i - 1] and array[i] > array[i + 1]) then
        table.insert(extrema, array[i])
      end
    end
    return extrema
end

function bifurcation_diagram()
    local r_values = {}
    local z_values = {}
    local steps = 1000 --this can removed? 
    local r_min = 280
    local r_max = 301
    local r_step = 1

    local z_extrema = find_local_extrema(z_a, 10, max_extrema)

    for r = r_min * 10, r_max * 10, r_step * 10 do
      r = r / 10.0
      local phi = 250
      -- ta = r
      -- breath_of_the_plant(ta)
      -- Plot z_a here
      
      if #z_extrema == 0 then
          print("z_extrema is 0")
          table.insert(r_values, r)
          table.insert(z_values, z_a[#z_a])
      else
          for i = 1, #z_extrema do
              -- print(#z_extrema,i)
              table.insert(r_values, r)
              table.insert(z_values, z_extrema[i])
          end
      end
    end
    
    return r_values, z_values
end
