#!/bin/bash
patch -p1 < $TOP/how-to/patches/SimPoint.3.2/CmdLineParser.cpp.patch
patch -p1 < $TOP/how-to/patches/SimPoint.3.2/Datapoint.cpp.patch
patch -p1 < $TOP/how-to/patches/SimPoint.3.2/Datapoint.h.patch
patch -p1 < $TOP/how-to/patches/SimPoint.3.2/Dataset.h.patch
patch -p1 < $TOP/how-to/patches/SimPoint.3.2/Dataset.cpp.patch
patch -p1 < $TOP/how-to/patches/SimPoint.3.2/FVParser.cpp.patch
patch -p1 < $TOP/how-to/patches/SimPoint.3.2/KMeans.h.patch
patch -p1 < $TOP/how-to/patches/SimPoint.3.2/Simpoint.cpp.patch
patch -p1 < $TOP/how-to/patches/SimPoint.3.2/Utilities.h.patch
