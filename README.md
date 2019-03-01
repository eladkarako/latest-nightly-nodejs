Run <code>get_latest_version.cmd</code> to get the latest, most recent version of NodeJS (both by version and date). <br/>
<code>get_latest_version.cmd</code> outputs just the version, which you can then use to "build" a complete download-URL of various NodeJS resources from https://nodejs.org/download/nightly/ .<br/>

<hr/>

See https://github.com/eladkarako/mods/tree/store/Firefox/resources/updater <br/>
and https://github.com/eladkarako/mods/blob/store/Firefox/resources/updater/updater.cmd <br/>
on how to use the STDOUT textual-output to download a URL, <br/>
which uses https://github.com/eladkarako/mods/blob/store/Aria2/aria2c.exe for a faster download.

<hr/>

A small <code>log.txt</code> is written just in-case to wish an easier copy-paste source (relative to a CMD window..).

<hr/>

dependency... 
You need nodejs on your system to run this project, you can download <code>node.exe</code> (portable-single-exe nodejs binary) from https://nodejs.org/download/nightly/v12.0.0-nightly20190301584305841d/win-x86/node.exe

I just don't want to include a 21MB file in-here (...again..).