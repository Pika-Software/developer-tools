# developer-tools
A powerful set of tools for debugging entities and viewing map mechanisms (kind of like Map-IO, but much faster).

## ConVars
### `developer` <0/5> - Set developer message level.

- If `developer` is greater than `1` then the entity debugging screen is activated.

![image](https://i.imgur.com/orcs6eW.png)
![image](https://i.imgur.com/VEZa9ZC.png)

- If `developer` is greater than `3` then the debugging map is activated, in which you can see all previously hidden/secret entities.

![image](https://i.imgur.com/iU0TEaG.png)
![image](https://i.imgur.com/mZVWC83.png)
![image](https://i.imgur.com/p8Wvp1o.png)

- If `developer` is greater than `4`, then the display of the center of the map and its borders is enabled.

![image](https://i.imgur.com/tzPJRgW.png)
![image](https://i.imgur.com/62ZhnIT.png)

- `developer_io_distance` <128/16384> - Maximum render distance of the map entities.
- `developer_io_ignorez` <0/1> - Enables or disables mapping entities through walls.

## Commands
- `developer_time` - Outputs all in-game clocks in a human-readable format.

![image](https://i.imgur.com/ywzCpBI.png)

- `developer_entity` - Outputs all basic information about the entity to the console.

![image](https://i.imgur.com/XHxDxtA.png)
![image](https://i.imgur.com/NCkeyly.png)

- `developer_weapon` - Same as `developer_entity`, but for active weapons, if you look at the player or npc, their weapons will be in the results.

![image](https://i.imgur.com/QotllAi.png)

- `developer_weapons` - Similar to `developer_weapon`, but prints all weapons in the player's inventory.

![image](https://i.imgur.com/kTPZeRL.png)

## Useful ConVars
- `mat_wireframe` <0/4> ( requires `sv_cheats 1` ) - Enables displaying the map rendering grid and models through textures, useful for PVS and PAS tests.
- `vcollide_wireframe` <0/1> ( requires `sv_cheats 1` ) - Render physics collision models in wireframe.
- `cl_showhitboxes` <0/1> ( requires `sv_cheats 1` ) - Turns on the display of hitboxes on the client.
- `ent_messages_draw` <0/2> ( requires `sv_cheats 1` ) - Visualizes all entity input/output activity.
- `net_graph` <0/4> - Performance Monitor.
