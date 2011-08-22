/*

	DST=~/Library/Application\ Support/TextMate/Support/bin/find_app
	g++ -arch ppc -arch i386 -isysroot /Developer/SDKs/MacOSX10.4u.sdk -Wall -Os -o "$DST" "$TM_FILEPATH" -framework ApplicationServices && strip "$DST"

*/

#include <unistd.h>
#include <cstdio>
#include <ApplicationServices/ApplicationServices.h>

char const* current_version ()
{
	char res[32];
	return sscanf("$Revision: 8040 $", "$%*[^:]: %s $", res) == 1 ? res : "???";
}

int main (int argc, char const* argv[])
{
	if(argc == 2 && strncmp("-", argv[1], 1) != 0)
	{
		CFStringRef bundleID = NULL;
		CFStringRef appName = NULL;
		if(strstr(argv[1], ".app"))
				appName = CFStringCreateWithBytes(kCFAllocatorDefault, (UInt8*)argv[1], strlen(argv[1]), kCFStringEncodingUTF8, FALSE);
		else	bundleID = CFStringCreateWithBytes(kCFAllocatorDefault, (UInt8*)argv[1], strlen(argv[1]), kCFStringEncodingUTF8, FALSE);

		CFURLRef url = NULL;
		if(noErr == LSFindApplicationForInfo(0, bundleID, appName, NULL, &url))
		{
			CFStringRef str = CFURLCopyFileSystemPath(url, kCFURLPOSIXPathStyle);

			CFIndex len = CFStringGetLength(str);
			UInt8 buf[4 * len];

			CFIndex actualLength = 0;
			if(len == CFStringGetBytes(str, (CFRange){0, len}, kCFStringEncodingUTF8, '?', FALSE, buf, sizeof(buf), &actualLength))
			{
				write(STDOUT_FILENO, buf, actualLength);
				return 0;
			}
		}
	}
	else
	{
		fprintf(stderr, "find_app r%s: print full path to application\nusage: find_app bundle_identifier\n       find_app application_name.app\n", current_version());
	}
	return 1;
}
