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
                                          ; instead of λor G
                                          ; Guile 2.0.5 will not recoginize
  (else                   (apply (eval (car e) env) (eval (cadr e) env)))))

; apply takes a function and an argument to a value
(define (apply f x)
  (eval (cddr (car f)) (cons (list (cadr (car f)) x) (cdr f))))

; read and parse stdin, then evaluate:
(display (eval (read) '())) (newline)

