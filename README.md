Auberon
=======

*Change history imported from old defunct blog. Here be broken links aplenty.*

Version 0.3
-----------

I've updated my Connect-4 game for Mac OS X. In addition to a rename from "Puck" to
"Auberon" it has the following changes (they should now [sound](/2007/04/26/phage-02/)
[familiar](/2007/05/06/desdemona-03/)):

* Cleaned up the interface somewhat and put some of the existing clutter in a preferences pane.
* Added a progress indicator for things that go on in the background.
* Added a "Check for updates" menu item to check if new versions are available, using the wonderful [Sparkle](http://sparkle.andymatuschak.org/) framework. You also have the option to automatically check for new versions on startup.

[Download Auberon 0.3](http://code.brautaset.org/files/Auberon_0.3.dmg) (0.25 MB disk
image). [Visit the homepage](http://code.brautaset.org/Auberon/).

Version 0.1
-----------

I just uploaded [Connect4.dmg](/files/connect4/Connect4.dmg), version 0.1 of a Connect4
game for Mac OSX. It is written in Objective-C and is using the
[AlphaBeta](/software/alphabeta) framework I've written. I also reused large parts of the
[Desdemona](/software/desdemona/) game I recently wrote.

I love Cocoa and Xcode (and Interface Builder). I only started on this game yesterday but
it is already feature complete. It lacks a bit of polish, such as icons and nicer
graphics, but it is quite enjoyable already. It should maybe have an even simpler AI
though; I've not been able to beat it yet!

**Update:** Nadia, of course, beat the AI almost at once. Doing so, she also found a bug:
regardless of who wins, the message said "You lost!". Oops. I've uploaded a fix...
