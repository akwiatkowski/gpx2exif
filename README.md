gpx2xif
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

