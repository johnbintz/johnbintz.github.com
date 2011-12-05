---
title: Migrating mail from an older Citadel server to a new one
layout: post
---
I have an old Citadel server that I want to move mail from, the destination being a new Citadel server. The old server is older than the new
over-the-wire or XML support, so I'm doing it the hard way and copying messages from one to another over the network. I found
[imapcopy.pl](http://www.athensfbc.com/imap_tools/) which is getting the job done nicely. Everything else will have to come over manually,
which will actualy be faster thatn trying to upgrade anything. :/

A few observations:

* Clean out big mailboxes. My Sent Items folder had a ton of cruft that could be removed, and it made the process go a lot faster _(no wai)_.
* Turn on IMAP protocol watching, otherwise you won't know if something's actually broke or not.

