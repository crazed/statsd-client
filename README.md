statsd-client
=============

A Ruby client for [StatsD](https://github.com/etsy/statsd), Etsy's daemon for easy stats aggregation.

Usage
-----

    client = Statsd::Client.new(host, port)
    client.timing('example.stat.1', 350)
    client.increment('example.stat.2')
    client.decrement('example.stat.2')

Documentation
-------------

[On rdoc.info](http://rdoc.info/github/tomtaylor/statsd-client/master/frames)

Copyright
---------

Copyright (c) 2011 Tom Taylor. See LICENSE.txt for
further details.

