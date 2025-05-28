#!/usr/bin/env sh
for f in ase/*.ase; do
	BASENAME=$(basename -s .ase $f)
	aseprite -b $f --save-as 1x/${BASENAME}.png
	aseprite -b $f --scale 2 --save-as 2x/${BASENAME}.png
done
