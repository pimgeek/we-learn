; The following code comes from a Prof.'s blog article
; Title: 7 lines of code, 3 minutes: Implement a programming language from scratch
; http://matt.might.net/articles/implementing-a-programming-language/
;
; I will try to make it work under Guile 2.0.5
; And report potential bugs within inline comments
;
; ====
; eval takes an expression and an environment to a value
(define (eval e env) 
  (cond
    ((symbol? e)           (cadr (assq e env)))
    ((eq? (car e) 'lambda) (cons e env))
    (else              
                           (begin
                             (format #t "ENV:\t~a \n" env)
                             (format #t "FUN:\t~a \n" (car e))
                             (format #t "ARG:\t~a \n" (cadr e))
                             (apply (eval (car e) env) (eval (cadr e) env))))))

; apply takes a function and an argument to a value
(define (apply f x)
  (begin
    (format #t "The Original FUN:\t\t~a \n" f)
    (format #t "The Main Body of FUN:\t\t~a \n" (caddr (car f)))
    (format #t "The extented ENV of FUN:\t~a \n" (cons (list (cadr (car f)) x) (cdr f)))
    (eval (caddr (car f)) (cons (list (cadr (car f)) x) (cdr f)))))

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
;
; Since the native Guile error report looked confusing, I decided
; to embed a lot of debug output code.
; Luckily there are Guile built-in format function for this purpose.
;
; After I embeded the debug output code, I had run it again.
; Guess what did I see? 
;
;$ guile 7lines.scm
; ((lambda x x) a)
; ENV:    ((a 1))
; FUN:    (lambda x x)
; ARG:    a
; The Original FUN:               ((lambda x x) (a 1))
; The Main Body of FUN:           (x)
; The extented ENV of FUN:        ((x 1) (a 1))
; ENV:    ((x 1) (a 1))
; FUN:    x
; In /home/pimgeek/_dev/sb/we-learn/hacking-scheme/7lines.scm:
;   30: 1 [#<procedure 14d5760 ()>]
;   18: 0 [eval (x) ((x 1) (a 1))]
; 
; /home/pimgeek/_dev/sb/we-learn/hacking-scheme/7lines.scm:18:54: In procedure eval:
; /home/pimgeek/_dev/sb/we-learn/hacking-scheme/7lines.scm:18:54: In procedure car: Wrong type argument in position 1 (expecting pair): ()
;
; At first all debug output looks correct, until I notice 
; [The Main Body of FUN] is actually (x) rather than x!
; To make it even confusing, the following ouput showed
; that x had been treated like a FUN rather than VAR!!!
; 
; What in hell had been mal-function in this 7 line code?
;
; It's very tempted for me to say I quickly found the above
; mal-funtioning behaviors, but I didn't.
; It took me more than 4 hours' re-run, drafting on papers
; reogranize the concepts in my mind. 
;
; In total, I have missed 3 hours' sleeping time and my 
; breakfast before I finally got to the key point.
;
; There is one suspicious place in the original code:
;
; (format #t "The Main Body of FUN:\t\t~a \n" (cddr (car f)))
; 
; Being familiar with cdr function, I know this cddr call
; will inevitably generate a list rather than an atom.
; And reviewing the original eval definition code I can
; understand that why x was treated as a FUN rather than VAR
; It's been passed as a list look like (x) !!!
;
; So I changed the code a little, replace *cddr* with *caddr*
; Then I ran it again. This time I expect the mal-function 
; will be gone.
;
; And this is the output, seeing that, I finally felt reassured
; to have my lunch.
;
;$ guile 7lines.scm
; ((lambda x x) a)
; ENV:    ((a 1))
; FUN:    (lambda x x)
; ARG:    a
; The Original FUN:               ((lambda x x) (a 1))
; The Main Body of FUN:           x
; The extented ENV of FUN:        ((x 1) (a 1))
; 1
; 
