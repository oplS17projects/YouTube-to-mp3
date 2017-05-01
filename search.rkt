#lang racket
(require racket/provide)
(require net/url)
(require net/uri-codec)
(require rash)

(define (search-url-string-from-query query)
  (string-append "https://www.youtube.com/results?search_query="
                 (string-replace query " " "+")))

(define (video-url-string-from-id id)
  (string-append "https://www.youtube.com/watch?v=" id))

(define (port-from-url-string str)
  (get-pure-port (string->url str)))

;; goes through video results and adds them to a list
(define (search query)
  (define myport (port-from-url-string (search-url-string-from-query query)))

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

(define (access-video-list lst field)
  (cond
    [(eqv? field 'verified) (cadddr (car lst))]
    [(eqv? field 'id) (caar lst)]
    [(eqv? field 'uploader) (caddr (car lst))]
    [(eqv? field 'title) (cadr (car lst))]
    [else #f]))

;sorts through list of results and finds best video, returns list with video info and sends that list to yt-link to generate a download link
(define (bestResult lst)
  (define (iter videos first)
    (cond
      [(null? videos) (yt-link (access-video-list first 'id))] ;final case, return first video result
      [(access-video-list videos 'verified) (yt-link (access-video-list videos 'id))] ;if video is verified
      [(string-contains? (string-downcase (access-video-list videos 'uploader)) "vevo") (yt-link (access-video-list videos 'id))] ;if it is uploaded by VEVO
      [else (iter (cdr videos) first)])) ; recurse
  (iter lst lst)) ; save first video result

; derives a Download link from a youtube video ID -- will need to be parsed a little further
(define (yt-link video)
  (define videoURL (video-url-string-from-id video))
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
  
  
  
  ; procedure to decipher a youtube video signature using the html5 player's associated javascript functions
; still has some issues.
(define (get-signature script sig)
  (define url (string->url (~ "https://www.youtube.com" script)))
  (define port (get-pure-port url))
  (define sig-func 
    (cadr
     (string-split
      (reg-match #px"signature\",[^;]*" port "") ",")))
  
  (define sig-name (car (string-split sig-func "(")))
  (define param-name (car (string-split (cadr (string-split sig-func "(")) ")")))
  (define refresh (get-pure-port url))
  (define sig-def ; function used to cipher signature
    (~ (reg-match (~ sig-name "=function\\([a-zA-Z]*\\){[^}]*") refresh "") "};"))
  (define sig-obj ; object used in signature cipher
    (car (string-split (reg-match ";[a-zA-Z0-9]*\\." sig-def ";") ".")))
  sig-def
  
  (define sub-functions
    (map (lambda (x) (car (string-split (cadr (string-split x ".")) "("))) (cdr (string-split sig-def ";"))))

  (define objp (get-pure-port url)) ; objp used to get the object definition
  (define obj-function
    (~ "var " (reg-match (~ sig-obj "={.+?(?=}};)") objp "") "}};"))

  ; created a javascript file called "script.js"
  (call-with-output-file "./script.js"
    (lambda (out)
      (display
       (~ obj-function "\n\n" sig-def "\n\nconsole.log(" sig-name "(\"" sig "\"));")
       out))
    #:exists 'replace)
  ; run script.js using rash and return the output (deciphered signature)
  (string-trim (rash/out "node ./script.js")))

(define ~ string-append)

(provide search)
(provide yt-link)
(provide port-from-url-string)
