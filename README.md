# developer-tools
A powerful set of tools for debugging entities and viewing map mechanisms (kind of like Map-IO, but much faster).

## ConVars
### `developer` <0/5> - Set developer message level.

- If `developer` is greater than `1` then the entity debugging screen is activated.

![image](https://github.com/Pika-Software/developer-tools/assets/44779902/b2a6d00c-c69b-402d-8e8b-0708c3d0414f)
![image](https://github.com/Pika-Software/developer-tools/assets/44779902/9c86a008-0080-426c-9450-cdd6ce67275c)

- If `developer` is greater than `3` then the debugging map is activated, in which you can see all previously hidden/secret entities.

![image](https://github.com/Pika-Software/developer-tools/assets/44779902/ea3de90a-1c16-462f-99fc-99434e0e0810)
![image](https://github.com/Pika-Software/developer-tools/assets/44779902/aa1679c1-1661-4426-9520-2f8763ae9684)
![image](https://github.com/Pika-Software/developer-tools/assets/44779902/f53084b1-1dd8-4e38-bdb4-e162634a813d)

- If `developer` is greater than `4`, then the display of the center of the map and its borders is enabled.

![image](https://github.com/Pika-Software/developer-tools/assets/44779902/20e7a296-323f-437a-97d3-02685fe57b71)
![image](https://github.com/Pika-Software/developer-tools/assets/44779902/3e552ce3-fb79-4c4f-8b5b-57604272707c)

- `developer_io_distance` <128/16384> - Maximum render distance of the map entities.
- `developer_io_ignorez` <0/1> - Enables or disables mapping entities through walls.

## Commands
- `developer_time` - Outputs all in-game clocks in a human-readable format.

![image](https://github.com/Pika-Software/developer-tools/assets/44779902/1e6101b7-1c97-4acb-96d5-375832799b14)

- `developer_entity` - Outputs all basic information about the entity to the console.

![image](https://github.com/Pika-Software/developer-tools/assets/44779902/4017925f-5d1a-4b70-9bc9-d481f07752f3)

- `developer_weapon` - Same as `developer_entity`, but for active weapons, if you look at the player or npc, their weapons will be in the results.

![image](https://github.com/Pika-Software/developer-tools/assets/44779902/eb2b571f-ff26-46a4-b68e-c1d7b5d2242d)

- `developer_weapons` - Similar to `developer_weapon`, but prints all weapons in the player's inventory.

![image](https://github.com/Pika-Software/developer-tools/assets/44779902/45960988-4bc6-4d27-8e73-aec57b1f0bde)

## Useful ConVars
- `mat_wireframe` <0/4> ( requires `sv_cheats 1` ) - Enables displaying the map rendering grid and models through textures, useful for PVS and PAS tests.
- `vcollide_wireframe` <0/1> ( requires `sv_cheats 1` ) - Render physics collision models in wireframe.
- `cl_showhitboxes` <0/1> ( requires `sv_cheats 1` ) - Turns on the display of hitboxes on the client.
- `ent_messages_draw` <0/2> ( requires `sv_cheats 1` ) - Visualizes all entity input/output activity.
- `net_graph` <0/4> - Performance Monitor.
