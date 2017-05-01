# Youtube MP3 Audio Extractor

## Benjamin Mourad
### April 30, 2017

# Overview
This set of code adds abstraction and formatting to the URL(s) produced
from a YouTube query and careful parsing of the page data.

**Authorship note:** All of the code described here was written by myself.

# Libraries Used
The code uses three libraries:

```
(require rash)
(require net/url)
(require net/uri-codec)
```

* The ```net/url``` library allows us to read the information on the page for the YouTube video in question.
* The ```rash``` library is used to execute Linux shell commands.
* The ```net/uri-codec``` library is used to decode formatting contained within the target URL of the page.

# Key Code Excerpts

Here is a discussion of the most essential procedures, including a description of how they embody ideas from 
UMass Lowell's COMP.3010 Organization of Programming languages course.

Three examples are shown and they are individually numbered. 

## 1. Wrapper procedures

For readability, these procedures allow the rest of the procedures to be
more compact while providing clear description of what is being done.

```
(define (search-url-string-from-query query)
  (string-append "https://www.youtube.com/results?search_query="
                 (string-replace query " " "+")))

(define (video-url-string-from-id id)
  (string-append "https://www.youtube.com/watch?v=" id))

(define (port-from-url-string str)
  (get-pure-port (string->url str)))
  
(define (target-from-url url)
  (car url))

(define (link-from-url url)
  (cdr url))
  
(define (title-from-url url)
  (define port (port-from-url-string (link-from-url url)))
  (string-replace (bytes->string/locale (cadr (regexp-match #px"\"title\":\"(.*?\",)" port))) #px"( |\\|\"|-|/|,|\")*?" ""))

(define (format-from-url url)
  (string-replace (cadr (regexp-match #px"video%2F(.*?&)" (target-from-url url))) "&" ""))

(define (download-from-search query)
  (download (search query)))

(define (download-from-id id)
  (download (yt-link id)))

(define (file-from-url url)
  (string-append (title-from-url url) "." (format-from-url url)))
  
```
 
The main aspect of this code is to promote good programming practices.

The ```target-from-url``` and ```link-from-url``` procedures are examples of treating the parameter as a distinct object.
The parameter in question is a pair of the target URL for downloading the video, and the original URL of the video page.
Both are needed for producing adequate output.
 
## 2. Procedural Abstraction

The result produced by the ```search``` procedure is a list of arranged data about the video.
To provide ease of access, the ```access-video-list``` procedure makes use of a literal symbol to select
certain positions of the list.


```
(define (access-video-list lst field)
  (cond
    [(eqv? field 'verified) (cadddr (car lst))]
    [(eqv? field 'id) (caar lst)]
    [(eqv? field 'uploader) (caddr (car lst))]
    [(eqv? field 'title) (cadr (car lst))]
    [else #f]))
```

Again, this list is treated as an object, since the formatting thereof does not change.

## 3. Funneling these contributions into the end result

Using ```rash``` library, external technologies such as ```wget``` and ```ffmpeg``` can be used, respectively,
for downloading the video file and converting to MP3 format.

The previous wrapper procedures are needed for the ```wget``` command to succeed. Specifically, the correct extention for
the video file must be parsed from the MIME type stored on the page source of the video.


```
(define (download url)
  (define link (target-from-url url))
  (define file (file-from-url url))
  (rash "wget -Ncq -e \"convert-links=off\" --load-cookies /dev/null --tries=50 --timeout=45 --no-check-certificate $link -O $file")
  file)
  
(define (extract-from-search query)
  (define file (download-from-search query))
  (define afile (string-append (string-replace file #px"(\\.).*" "") ".mp3"))
  (rash "ffmpeg -i $file -acodec libmp3lame -aq 4 $afile")
  (rash "rm $file"))

(define (extract-from-id id)
  (define file (download-from-id id))
  (define afile (string-append (string-replace file #px"(\\.).*" "") ".mp3"))
  (rash "ffmpeg -i $file -acodec libmp3lame -aq 4 $afile")
  (rash "rm $file"))
```

In summary, the abstraction procedures simplify and streamline the downloading and extraction process.
This sets an example of using back-end abstraction to allow a clean and readable front-end (the crux of the entire program).
