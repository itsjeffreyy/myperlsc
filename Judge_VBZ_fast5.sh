#!/usr/bin/bash
if h5dump -pH $1 | grep -q vbz; 
	then echo File is VBZ-compressed; 
else 
	echo File is NOT VBZ-compressed; 
fi
