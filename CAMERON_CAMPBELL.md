# Youtube MP3 Audio Extractor

## Cam Campbell
### April 30, 2017

# Overview
The following code allows for a user search query for a YouTube video. A list of related videos are collected through regular expression, along with important information such as the video title, uploader name, video ID, and whether or not the uploader is a verified channel.

After 3 videos are collected, a best result is determined based on whether the uploader is verified, or if the vidoe is the first result.

Finally a download link is generated through regular expression with information from the video page.


**Authorship note:** All of the code described here was written by myself.

# Libraries Used
The code uses two libraries:

```
(require net/url)
(require net/uri-codec)
```

* The ```net/url``` library provides the ability to get a pure port for use by regular expression.
* The ```net/uri-codec``` library is used to help decode the url generated from the video page.

# Key Code Excerpts


## 1. Recursively collect videos

The ``` search ``` procedure is used to run a search query and collect three vidoes. Tail-recursion is utilized here:

```
(define (loop lst n)
    (if (= n 0) (bestResult (reverse lst))
        (loop (cons
               (list
                ;; get video ID (url)
                (reg-match findVideo myport #px"data-video-ids=\"")
                ;; get video Title
                (reg-match getTitle myport #px"\"  title=\"")
                ;; get video Uploader
                (reg-match getUploader myport #px"\" >")
                ;; is video uploaded by Verified user? (#t or #f)
                (string=?
                     (reg-match getVerified myport #px"</a>")
                     "&");; if this string = '&' the uploader is Verified
                ) 
               lst) (sub1 n))))
  (loop '() 3))
 ```
 
 This recursive procedure allows regular expression to be reused to find the next video and add it to a list. The recursion continues for 3 cycles, then passes off the collected list to the ``` bestResult ``` procedure.
 
 
## 2. Functional Data Processing

All of my work involves cascading procedures. Starting from ``` search ``` a list videos (videos are treated as lists here) is past to the ``` bestResult ``` procedure:

```
(if (= n 0) (bestResult (reverse lst))
```
The list of video lists is then processed, and one video is chosen as the 'best result', where it will then be sent to the ``` yt-link ``` procedure:

```
(yt-link (access-video-list first 'id))
```
Finally the url is derived from the selected YouTube video page using regular expressions. 
 
 
## 3. Procedural Abstraction

After collecting a list of videos, certain parts of the list are checked to determine a best match. In order to completely check every video, recursion is also used here, until a match is found, or as a base case, return the first video in the list.

```
(define (bestResult lst)
  (define (iter videos first)
    (cond
      [(null? videos) (yt-link (access-video-list first 'id))] ;final case, return first video result
      [(access-video-list videos 'verified) (yt-link (access-video-list videos 'id))] ;if video is verified
      [(string-contains? (string-downcase (access-video-list videos 'uploader)) "vevo") (yt-link (access-video-list videos 'id))] ;if it is uploaded by VEVO
      [else (iter (cdr videos) first)])) ; recurse
  (iter lst lst)) ; save first video result
```
Using the format I created for checking the video list, my partner @bmourad01 created the ``` access-video-list ``` procedure:

```
(define (access-video-list lst field)
  (cond
    [(eqv? field 'verified) (cadddr (car lst))]
    [(eqv? field 'id) (caar lst)]
    [(eqv? field 'uploader) (caddr (car lst))]
    [(eqv? field 'title) (cadr (car lst))]
    [else #f]))
```
This allows symbols to be used to access the parts of the list previously mentioned. Using these symbols makes it much more clear what information is being checked when determining a match.
