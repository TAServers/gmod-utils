# TAServers GMod Utils

Initialisation scripts and other utilities for the TAServers GMod server.  

### Contributing
Create a file for your utility in the appropriate realm's folder (e.g. `sv-tas-utils`).  
*If your code is using functions etc. from other addons, or anything from `TASUtils`, you should place it in `initpostentity`*  

Any utility functions you want used globally, place in the `TASUtils` global table to keep everything together, an example being `TASUtils.Broadcast`.  
If it's not obvious what the function does, add a comment documenting it.  
