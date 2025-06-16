class Game_Map
  alias original_528_perform_load_new_map_data perform_load_new_map_data
  def perform_load_new_map_data
    original_528_perform_load_new_map_data

    base_map_data = load_data(sprintf("Data/Map%03d.rvdata2", @map_id)).data # Cf Game_Map#reload_map

    for z in 0...3
      tiles = $game_system.has_swap_tiles?(@map_id, z) ? $game_system.swapped_tiles[map_id][z] : nil
      next unless tiles

      regions = $game_system.has_swap_region?(@map_id, z) ? $game_system.swapped_region_tiles[map_id][z] : nil
      masks = $game_system.has_swap_mask?(@map_id, z) ? $game_system.swapped_mask_tiles[map_id][z] : nil
      position_tiles = $game_system.has_swap_pos?(@map_id, z) ? $game_system.swapped_pos_tiles[map_id][z] : nil

      for y in 0...height
        positions = position_tiles.nil? ? nil : position_tiles[y]
        for x in 0...width
          # Ignore if tile was replaced through anything but swap
          next if positions && positions[x]
          next if masks && masks.any? { |mask| !mask[x, y].nil? }
          next if regions && regions[(base_map_data[x, y, 3] || 0) >> 8]

          old_tid = base_map_data[x, y, z] || 0 # Cf Game_Map#tile_id
          next unless old_tid >= 2048

          autotile = (old_tid - 2048) / 48
          # Cascade or wall, cf bottom half of Game_Map#perform_load_new_map_data
          next unless (autotile == 5 or autotile == 7 or autotile == 9 or autotile == 11 or autotile == 13 or autotile == 15) or (autotile >= 48 and autotile <= 79 or autotile >= 88 and autotile <= 95 or autotile >= 104 and autotile <= 111 or autotile >= 120 and autotile <= 127)

          sub_z = (old_tid - 2048) % 48
          old_tid = old_tid - sub_z
          next unless old_tid >= 2048

          new_tile = tiles[old_tid]
          next unless new_tile && new_tile != old_tid
          next unless new_tile >= 2048

          @map.data[x, y, z] = new_tile + sub_z
        end
      end
    end
  end
end
