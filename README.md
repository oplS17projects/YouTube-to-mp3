# YouTube MP3 Audio Extractor

### Version: 0.1

### Statement
Let's be honest, spending our hard-earned money on music is for chumps. Those of us who are savvy on current trends know that music, in economic terms, has reached zero-scarcity status as a resource. You'll often hear musicians lamenting how difficult it is to profit from record sales.

Enter YouTube. Whenever there's a song we want to hear, we search for a video of it, even if we have a physical copy on our hard drive or another medium. Even the more rare and obscure releases can be found.

In this project, we will develop a reliable utility for the purpose of extracting audio from any given YouTube video followed by formatting it as an MP3 file with the appropriate ID3 tags. As an added bonus, the video thumbnail may be used as an 'album cover'.

### Analysis + External Technologies + Source Materials
Recursion will be the most likely technique used here. The main structure to this project will revolve around creating, filtering, and scanning lists. All of this calls for iterative procedures. We aim to avoid object-orientation for simplicity's sake.

Starting with a YouTube search query, using net/url, we will scan through videos for the most relevant result as a URL. With regular expressions, we will derive the appropriate download link from this URL to recieve the FLV file. The FLV file can then be converted to MP3 either through existing API via Racket libraries or with the help of bash and ffmpeg. The song will then be played while displaying the thumbnail image and song title.

### Deliverable and Demonstration
We will have a straightforward Racket program which takes artist name and song title as input (this conforms with video titles) and produces an MP3 file extracted from the most relevant YouTube video for said input.

For demonstration purposes, the program will be able to play the file through bash, using mpg123, following the extraction process. The ID3 tags of the file will be printed as well.

### Evaluation of Results
In the event that no relevant video is found, an error may be produced or we may simply end up with the incorrect song. Deriving the proper ID3 tags may also present itself as a challenge.

The accuracy of the program's results will serve as a measurement of success. It helps to have heard the song before, as well as knowing the metadata ahead of time.

## Architecture Diagram
Coming soon...

## Schedule

### First Milestone (Sun Apr 9)
Complete the procedures for scanning the YouTube query results for our target video URL and corresponding download URL.

### Second Milestone (Sun Apr 16)
Complete the procedures for downloading the video file and converting it to MP3 format. Finish by deriving the correct album title and year given the artist name and song title as inputs.

### Public Presentation (Mon Apr 24, Wed Apr 26, or Fri Apr 28 [your date to be determined later])
Any refinements, edge cases, and bug fixes will be addressed.

## Group Responsibilities

### Benjamin Mourad @bmourad01
Tasked primarily with completing second milestone objectives.

### Cam Campbell @ccamj
Tasked primarily with completing first milestone objectives.
