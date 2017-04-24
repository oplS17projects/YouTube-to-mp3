#lang racket
(require racket/provide)
(require net/url)
(require net/uri-codec)

(define (port-from-url-string str)
  (get-pure-port (string->url str)))

;; goes through video results and adds them to a list
(define (search query)
  (define fixQuery (string-replace query " " "+"))
  (define searchString (string-append "https://www.youtube.com/results?search_query=" fixQuery))
  (define myport (port-from-url-string searchString))

  (define findVideo #px"data-video-ids=\"[a-zA-Z0-9\\-_]*")
  (define getTitle #px"\"  title=\"[a-zA-Z 0-9.,<>:;~|()!@#$%^&*+=\\-\\[\\]_'/]*")
  (define getUploader #px"\" >[a-zA-Z0-9!@/\\%\\^\\#\\&)(\\-_., ]*")
  (define getVerified #px"</a>[\\&\\<]")
  ;(define getVerified #px"\" >[a-zA-Z0-9!@/\\%\\^\\#\\&)(\\-_., ]*</a>[\\&\\<]")

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

;sorts through list of results and finds best video, returns list with video info and sends that list to yt-link to generate a download link
(define (bestResult lst)
  (define (iter videos first)
    (cond
      [(null? videos) (yt-link (car first))] ;final case, return first video result
      [(cadddr (car videos)) (yt-link (caar videos))] ;if video is verified
      [(string-contains? (string-downcase (caddr (car videos))) "vevo") (yt-link (caar videos))] ;if it is uploaded by VEVO
      [else (iter (cdr videos) first)])) ; recurse
  (iter lst (car lst))) ; save first video result

; derives a Download link from a youtube video ID -- will need to be parsed a little further
(define (yt-link video)
  (define videoURL (string-append "https://www.youtube.com/watch?v=" video))
  (define myport (port-from-url-string videoURL))
  (reg-match #px"url_encoded_fmt_stream_map" myport "")
  (define link 
    (car
     (string-split
      (string-replace
       (string-replace 
        (uri-decode (reg-match #px"url=[^\"]*" myport "")) "\\u0026" ",") "url=" "") ",")))
  
  (if (string-contains? link "signature=")
    (cons link videoURL)
    (cons (backup-dl video) videoURL)))

; procedure created as a back-up to generate copyright protected links
(define (backup-dl id)
  (define url (string->url (string-append "http://keepvid.com/?url=https%3A%2F%2Fwww.youtube.com%2Fwatch%3Fv%3D" id)))
  (define myport (get-pure-port url))
  (reg-match "Download music & playlists from 10,000+" myport "")
  (reg-match "youtube.com " myport "")
  
  (car (string-split (reg-match "https:[^\"]*" myport "") "&title=" )))

;; clean up the regular expression and convert to string
(define (reg-match match source cleanStr)
  (if (not (string? source))
      (bytes->string/locale (regexp-replace cleanStr (car (regexp-match match source)) ""))
      (regexp-replace cleanStr (car (regexp-match match source)) "")))

;; reverse a list
(define (reverse lst)
  (define (iter a b)
    (if (null? a) b
    (iter (cdr a) (cons (car a) b))))
  (iter lst '()))

(provide search)
(provide yt-link)
(provide port-from-url-string)
