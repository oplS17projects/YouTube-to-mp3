#lang racket
(require racket/provide)
(require "search.rkt")

(require rash)

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

(define (download url)
  (define link (target-from-url url))
  (define file (file-from-url url))
  (rash "wget -Ncq -e \"convert-links=off\" --load-cookies /dev/null --tries=50 --timeout=45 --no-check-certificate $link -O $file")
  file)

(provide title-from-url)
(provide format-from-url)
(provide download-from-search)
(provide download-from-id)
(provide download)
(provide file-from-url)
