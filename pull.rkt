#lang racket
(require "search.rkt")

(require rash)

(define (format-from-url url)
  (string-replace (cadr (regexp-match #px"video%2F(.*?&)" url)) "&" ""))

(define (download-from-search query)
  (download (search query)))

(define (download-from-id id)
  (download (yt-link id)))

(define (file-from-url url)
  (string-append "videoplayback." (format-from-url url)))

(define (download url)
  (define fmt (file-from-url url))
  (rash "wget -Ncq -e \"convert-links=off\" --load-cookies /dev/null --tries=50 --timeout=45 --no-check-certificate $url -O $fmt"))