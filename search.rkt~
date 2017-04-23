#lang racket
(require net/url)

;; goes through video results and adds them to a list
(define (search query)
  (define fixQuery (string-replace query " " "+"))
  (define searchString (string-append "https://www.youtube.com/results?search_query=" fixQuery))
  (define searchUrl (string->url searchString))
  (define myport (get-pure-port searchUrl))

  (define findVideo #px"data-video-ids=\"[a-zA-Z0-9\\-_]*")
  (define getTitle #px"\"  title=\"[a-zA-Z 0-9.,<>:;~|()!@#$%^&*+=\\-\\[\\]_'/]*")
  (define getVerified #px"\" >[a-zA-Z0-9!@/\\%\\^\\#\\&)(\\-_., ]*</a>[\\&\\<]")

  (define (loop lst n)
    (if (= n 0) (bestResult (reverse lst))
        (loop (cons
               (list
                ;; get video ID (url)
                (cleanRegexp (regexp-match findVideo myport) #px"data-video-ids=\"")
                ;; get video Title
                (cleanRegexp (regexp-match getTitle myport) #px"\"  title=\"")
                ;; is video uploaded by Verified user? (#t or #f)
                (string=?
                     (cleanRegexp (regexp-match getVerified myport)
                                  #px"\" >[a-zA-Z0-9!@/\\%\\^\\#\\&)(\\-_., ]*</a>")
                     "&")) ;; if this string = '&' the uploader is Verified
               lst) (sub1 n))))
  (loop '() 3))

;sorts through list of results and finds best video
(define (bestResult lst)
  (define (iter videos first)
    (cond
      [(null? videos) first] ;final case, return first video result
      [(caddr (car videos)) (caar videos)] ;if video is verified
      [(string-contains? (string-downcase (cadr (car videos))) "vevo") (caar videos)] ;if it is uploaded by VEVO
      [else (iter (cdr videos) first)])) ; recurse
  (iter lst (caar lst))) ; save first video result

;; clean up the regular expression and convert to string
(define (cleanRegexp match cleanStr)
  (bytes->string/locale (regexp-replace cleanStr (car match) "")))

;; reverse a list
(define (reverse lst)
  (define (iter a b)
    (if (null? a) b
    (iter (cdr a) (cons (car a) b))))
  (iter lst '()))