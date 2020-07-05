# Blobfishnet 
## A fork of Hak5Darren's caternet

## Wat?
A fork of Hak5Darren's caternet payload with a few minor improvements

## Why?
Made for a demo / walkthrough at [Kids' SecuriDay](https://securiday.com).

## What's changed?
* Tightened up the HTTP server so that only files in a payload folder can be served
* Works for most HTTP URLs instead of just folders and index.html
* Monitors the server process and indicates failure / shuts down if it crashes (in the wild you'd probably want it to keep running but disable the iptables rules)
* Pushing the button syncs the file system and shuts down
* Works in any switch folder
* I mean it's blobfish instead of Kirby the cat.