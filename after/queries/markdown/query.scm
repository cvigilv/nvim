;; extends
((inline) @injection.content
 (#match? @injection.content "@[A-Z][a-z]+[A-Z][a-z]")
 (#set! injection.language "contact"))
;
; ((text) @injection.content
;  (#match? @injection.content "@[A-Z][a-z]+(?:[A-Z][a-z]+)*")
;  (#set! injection.language "contact"))
