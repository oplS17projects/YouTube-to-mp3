#lang racket
(require "pull.rkt")
(require rash)

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