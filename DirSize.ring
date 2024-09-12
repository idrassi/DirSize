###########################################################################
# File: DirSize.ring
# Description: Directory and File Size Analyzer Utility
# 
# This utility provides a comprehensive analysis of directory and file sizes.
# It offers detailed reporting options and can handle both Windows and 
# Unix-like file systems.
#
# Features:
# - Calculate the size of individual files or entire directories
# - Provide detailed listings of directory contents with sizes
# - Sort entries by size (optional)
# - Cross-platform compatibility (Windows and Unix-like systems)
# - Performance timing for size calculations
#
# Usage: 
#   DirSize Path [-details [-sort]]
#
# Arguments:
#   Path: The file or directory path to analyze
#   -details: (Optional) Provide a detailed listing of directory contents
#   -sort: (Optional) Sort the detailed listing by size (largest first)
#
# Examples:
#   DirSize C:\Users\Username\Documents
#   DirSize C:\Users\Username\Documents -details
#   DirSize C:\Users\Username\Documents -details -sort
#
# Author: Mounir IDRASSI
# Version: 1.0
# Date: 12 September 2024
# License: MIT
# Repository: https://github.com/idrassi/DirSize
#
# Requirements:
# - Ring programming language (https://ring-lang.github.io)
# - MonoRing distribtion of Ring is recommended for static build
#
###########################################################################

Load "stdlibcore.ring"

if isWindows()
	Load "winapi.ring"
	pathSeparator = "\"
else
	pathSeparator = "/"
end

TiB = 1024*1024*1024*1024
GiB = 1024*1024*1024
MiB = 1024*1024
KiB = 1024

maxEntrySize = 0 # will hold the size in bytes of the largest entry

func main

	if isWindows()
		if rwaIsWow64Process() = 1
			rWow64EnableWow64FsRedirection(False)
		end
	end

	appArgs = AppArguments()
	appArgsCount = Len(appArgs)
	
	if (appArgsCount = 1 or ((appArgsCount = 2 || appArgsCount = 3) and (appArgs[2] = "-details") and (appArgsCount < 3 or (appArgs[3] = "-sort"))))
		pathValue = appArgs[1]
		pathType = Getpathtype(pathValue)
		switch pathType
		case 0
			See "The given path doesn't exist" + nl
		case 1
			t1 = uptime()
			s = getfilesize(pathValue)
			t2 = uptime()
			diff = (t2 - t1) / 10000000
			See 'File Size = ' + GetSizeStr(s, 0, false) + nl
			See "Done in " + diff + " seconds" + nl
		case 2
			contentList = NULL
			sortEntries = false
			if (appArgsCount >= 2)
				contentList = []
				if appArgsCount >= 3
					sortEntries = true
				ok
			ok
			t1 = uptime()
			s = GetDirectorySize(pathValue, contentList)
			t2 = uptime()
			diff = (t2 - t1) / 10000000
			See "Directory Size = " + GetSizeStr(s, 0, false) + nl	
			See "Done in " + diff + " seconds" + nl
			if not isNull(contentList) DumpContent(contentList, sortEntries) ok
		else
			See "Failed to get the type of the given path" + nl
		end
	else
		PrintUsage()
	end 	
end

func PrintUsage
	if IsAppCompiled()
		See "Usage: " + sysargv[1] + " Path [-details [-sort]]" + nl
	else
		See "Usage: " + sysargv[1] + " " + sysargv[2] + " Path [-details [-sort]]" + nl
	end
end

func GetDirectorySize(entry, contentDetails)

	try
		totalSize = 0
		addDetails = IsList(contentDetails)
		contentList = dir(entry)
		for x in contentList
			childPath = AppendPath(entry,x[1])
			entrySize = 0
			if x[2]
				entrySize = GetDirectorySize(childPath, NULL)
			else
				entrySize = getfilesize(childPath)
				if entrySize = -1
					entrySize = 0
				end
			ok
			if addDetails Add(contentDetails, [x[1], x[2], entrySize]) ok
			totalSize += entrySize
			if addDetails AND (entrySize > maxEntrySize)
				maxEntrySize = entrySize
			ok
		next

		return totalSize
	catch 
		// cannot list directory: return 0 as size
		return 0
	done
end

func DumpContent (contentList, sortEntries)
	See "Content Details: " + Len(contentList) + " entries." + nl
	counter = 1
	maxSize = 0
	if sortEntries
		contentList = sort(contentList,3)
		contentList = reverse(contentList) # we reverse to have largest entries first
	ok
	bytesTextWidth = Len(string(maxEntrySize))
	# get width to use for line indexes
	counterWidth = Len(string(Len(contentList)))
	for x in contentList
		cCounterStr = HarmonizeString(string(counter), counterWidth, false)
		See cCounterStr + "- "
		if x[2] 
			entryName = x[1] + pathseparator
		else
			entryName = x[1] + " "
		ok
		See HarmonizeString(entryName, 50, true)
		See " " + GetSizeStr(x[3], bytesTextWidth, true) + nl
		counter++
	next

func AppendPath(p1, p2)
	l = len(p1)
	if l = 0
		return p2
	else
		if p1[l] = '\' || p1[l] = '/'
			return p1 + p2
		else
			return p1 + pathseparator + p2
		end
	end

func GetSizeStr(size, bytesTextWidth, nHarmonize)
	cSuffix = string(size)
	if nHarmonize
		cSuffix = " (" + HarmonizeString(cSuffix, bytesTextWidth, false) + " bytes)"
	else
		cSuffix = " (" + cSuffix + " bytes)"
	ok
	
	units = ["KiB", "MiB", "GiB", "TiB"]
	divisors = [KiB, MiB, GiB, TiB]

	for i = 4 to 1 step -1
		if (i = 1) OR (size >= divisors[i])
			size = size / divisors[i]
			cUnit = units[i]
			exit
		ok
	next

	cSizeStr = string(size)
	# ensure there '.'
	if substr(cSizeStr, ".") = 0
		cSizeStr += ".00"
	ok
	res = cSizeStr + cUnit;
	if nHarmonize
		res = HarmonizeString(res, 11, false)
	ok
	return res + cSuffix

func HarmonizeString (cStr, nBlockLen, nRight)
	nLen = Len(cStr)
	if nLen < nBlockLen
		diff = nBlockLen - nlen
		padding = space(diff)
		for i=1 to diff padding[i] = ' ' next
		if nRight
			return cStr + padding
		else
			return padding + cStr
		ok
	else
		if nRight
			return Left(cStr, nBlockLen)
		else
			return Right(cStr, nBlockLen)
		ok
	ok
