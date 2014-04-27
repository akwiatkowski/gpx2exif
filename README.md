gpx2exif
=======

Geotagging
----------

Geotag your photos using stored GPX files. At this moment it supports only Garmin eTrex devices.


Disclaimer
----------

This gem add one executable which overwrite JPG files. BACKUP IS NEEDED!


How to use it
-------------

1. gem install gpx2exif

2. Go to path where you have JPG/JPEG photos (case insensitive) and GPX files.

3. From 0.0.1 there is 'simulation command'. Type 'geotag_simulate' and enter.

4. WARNING! it will overwrite all your photos so MAKE A BACKUP!

5. Type 'geotag_all_images' and press enter key.

6. See a nice piece of output and now you have geotagged photos :)


If something is not working send me e-mail and I'll fix it.


Create waypoint files
---------------------

You can prepare your own list of waypoints and then store into eTrex using GPX file. At this moment there is
only possible to convert data from YAML file to GPX. It is also possible to integrate with other (web)apps.

How to use it
-------------

1. Check samples/sample_yaml_pois.yml as a template.

2. Modify it, add yours POIs.

3. Run command

  generate_garmin_waypoints -y input_file.yml > output.gpx

4. You can check inter-POI distances using

  generate_garmin_waypoints -y input_file.yml -C

   Distance conflict does not mean something is wrong. POIs can be close to each other so it
   is a good idea to have your brain turned on ;)

5. You can change inter-POI distances using 'latlon something' distance for distance checking
   explained line before.

  generate_garmin_waypoints -y samples/sample_yaml_pois.yml -C -t 1

6. You can specify output file if you don't like using >> 'file.gpx'.

  generate_garmin_waypoints -y samples/sample_yaml_pois.yml -o file.gpx


Render track with OpenStreetMap
---------------------

You can "convert" your tracks to images using this command.

How to use it
-------------

1. Please check if you have installed RMagick gem.

2. Run command.

  gpx2png -g [input GPX file] -s [image size, format: WIDTHxHEIGHT] -o [output PPNG file]

  Example:

  gpx2png -g spec/fixtures/sample.gpx -s 800x600 -o map.png

3. You can specify zoom.

  gpx2png -g [input GPX file] -z [zoom, best results between 9 and 15, max 18] -o [output PPNG file]

  Example:

  gpx2png -g spec/fixtures/sample.gpx -z 11 -o map.png

4. Adding -u forces using [UMP tiles](http://ump.waw.pl/) .


Contributing to gpx2xif
-------------------------------

[![Flattr this git repo](http://api.flattr.com/button/flattr-badge-large.png)](https://flattr.com/submit/auto?user_id=bobik314&url=https://github.com/akwiatkowski/gpx2xif&title=gpx2xif&language=en_GB&tags=github&category=software)

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.


Copyright
---------

Copyright (c) 2012-2014 Aleksander Kwiatkowski, Craig Taverner. See LICENSE.txt for
further details.

