gpx2exif
=======

Geotagging
----------

Geotag your photos using stored GPX files. There are a few scripts here, the
original scripts written by akwiatkowski, and a new script called 'geotag'
by Craig Taverner, based on the older scripts.  Craig has updated the
libraries and added the new script to support geotagging both images with
timestamps, and images without.  For example, you can extract images from a
video stream, and assign timestamps based on image order or filename.  Run
the 'geotag' script for command-line options. Options like '-t #' are used for
adjusting existing timestamps, while options like '-T START -G GAP' are used to
assign completely new timestamps.

Geotagging video
----------------

At the simplest, you want something like:

    geotag -g track.gpx -o map.png -s 1500x1500 -v

To make a map of your track, from which you can work out the timestamps of
some files and therefor the starting timestamp of the entire video.

Then convert the video to jpg with:

    ffmpeg -i video.mp4 -r 1 images/video_%4d.jpg

And finally geotag the images with:

    geotag -g track.gpx -v images/video_*jpg \
      -T 2014-04-25T12:05:05+02 \
      -x "Make=GoPro,Model=Hero3+,Author=Craig Taverner"

Change the settings to suite your phone.

The rest of the original README follows. I think this is mostly out of date,
even in akwiatkowski's version of the library.

Geotagging photos
-----------------

Start by creating an image of the track:

    geotag -g track.gpx -o map.png -s 1500x1500 -v

From this work out the timestamps of some files, and therefor the offset
between the camera and the GPS equipment.

And geotag the images with:

    geotag -g track.gpx -v camera/photo_*jpg \
      -R 20140425T12:00:00+02-20140425T13:00:00+02 -t 15

Notice that you do not need the '-x EXIF' option, because the camera photos
will already have exif data.  The script will simply add the location,
orientation and direction tags to the existing EXIF.

README
------

The rest of the original README follows. I think this is mostly out of date,
even in akwiatkowski's version of the library.

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

Copyright (c) 2012 Aleksander Kwiatkowski. See LICENSE.txt for
further details.

