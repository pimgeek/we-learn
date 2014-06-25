; The following code comes from a Prof.'s blog article
; Title: 7 lines of code, 3 minutes: Implement a programming language from scratch
; http://matt.might.net/articles/implementing-a-programming-language/
;
; I will try to make it work under Guile 2.0.5
; And report potential bugs within inline comments
;
; ====
; eval takes an expression and an environment to a value
(define (eval e env) (cond
  ((symbol? e)            (cadr (assq e env)))
  ((eq? (car e) 'lambda)  (cons e env))   ; Have to use lambda 
                                          ; instead of λor 
                                          ; Guile 2.0.5 will not recoginize
  (else                   (apply (eval (car e) env) (eval (cadr e) env)))))

; apply takes a function and an argument to a value
(define (apply f x)
  (eval (cddr (car f)) (cons (list (cadr (car f)) x) (cdr f))))

; read and parse stdin, then evaluate:
(display (eval (read) '((a 1)))) (newline)

; After I created a source file for this 7-line code,
; I tried to run it under Guile, with the following input
; ((lambda x x) 1)
;
; Unfortunately, I only got the following error:
;
;$ guile 7lines.scm
; ((lambda x x) 1)
; In /home/pimgeek/_dev/sb/we-learn/hacking-scheme/7lines.scm:
;   22: 2 [#<procedure 13ce440 ()>]
;   15: 1 [eval ((lambda x x) 1) ()]
;   12: 0 [eval 1 ()]
; 
; /home/pimgeek/_dev/sb/we-learn/hacking-scheme/7lines.scm:12:8: In procedure eval:
; /home/pimgeek/_dev/sb/we-learn/hacking-scheme/7lines.scm:12:8: In procedure car: Wrong type argument in position 1 (expecting pair): 1
;
; What's been wrong with my input, or the program itself?
;
; ====
; After another thought I noticed that every value
; Has to be defined in ENV at first, so I changed the code
; a little and run again. 
; (to view the previous code, click History button on GitHub)
;
; Sadly, I only got another error
;
;$ guile 7lines.scm
;
; ((lambda x x) a)
; In /home/pimgeek/_dev/sb/we-learn/hacking-scheme/7lines.scm:
;   22: 1 [#<procedure 1c59780 ()>]
;   15: 0 [eval (x) ((x 1) (a 1))]
; 
; /home/pimgeek/_dev/sb/we-learn/hacking-scheme/7lines.scm:15:58: In procedure eval:
; /home/pimgeek/_dev/sb/we-learn/hacking-scheme/7lines.scm:15:58: In procedure car: Wrong type argument in position 1 (expecting pair): ()
; 
; I only wanted to call the id-function (lambda x x) with a = 1 predefined in ENV
; So I really had no idea what's going on behind this code. 
