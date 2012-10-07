require 'base64'

$:.unshift(File.dirname(__FILE__))

# Sample marker useful for everybody :)
module Gpx2png
  class SampleMarker

    STRING = "iVBORw0KGgoAAAANSUhEUgAAACAAAAA8CAYAAAAHbrgUAAAACXBIWXMAAAsT
AAALEwEAmpwYAAAAB3RJTUUH3AoHCwYNWvFiNgAAAYxJREFUWMPtls9KAzEQ
xr9d//QkgmjxKPQBVDwJYvEPXoQWfQ7Bm48hKL6AIhT6DIp3QaGC4KEnT0q1
FxE8db2ksIRJNtlM1oPzg1A2O5v5Js23O4A/mwCuAPQB/KjRV3NNRKQOoAcg
AzBSv/kxnnsCsMidfNmS2CRklSv5gkdyXUSdQ8Ajkdz2F+Sve6HJ1w2JPgC0
AUyo0QIwMAjbCBFwqS06AvBpiR8Q8dchAl6Jig4t8W0i/i1EAHXAapb4KcMz
RlIHAToJp7+LBDwTc/uWeOreS4jAM8IBQ4PwRLlDd8JFiIAtgw2H6jBOq3Gg
3EHZcNeWIHE8iNRc4jBXmCN1ENAhRLgkygB0OQ5q0+MboI9tLrd8lUj+zWHD
vBt8Oed8X8yV2IF57qbk1qMhuYvRku14VL8Xqy98L9iFca8QjSOH6o99Fizz
Zcs410xLCDhltqs3M5btn0VFdIjer4sKWSKqb6BiblTl0V48Razkql/DH3EP
4CFkgclAAScMawiCIAiCIAiCIAj/nF9mGvLkWeHRewAAAABJRU5ErkJggg=="

    BLOB = Base64.decode64(STRING)

    URL = "http://www.iconspedia.com/icon/map-marker-icon-19842.html"
  end
end