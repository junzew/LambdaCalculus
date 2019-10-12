#lang racket
(require racket/match)
(require 2htdp/image)
;; Lambda Calculus

;; Alonzo Church came up with Lambda Calculus in 1936
;; Alan Turing came up with an alternative model of computation based on
;; states and tapes, known as the Turing Machine
;; The two kind of systems have been shown to be equivalent

;; Syntax

;; M  = X
;;    | λX.M
;;    | (M M)
;; X  = a variable: x, y, ...

;; Examples 
;; x                       
;; (x y)                            
;; (λx.x); Identity function
;; (λy.(λz.y)); z is a free variable
;; ((λy.(y y)) (λy.(y y)))

;; Reductions
;; α-conversion
;; β-reduction
;; η-conversion

;; Ideas:
;; (a) Do computation with ONLY single-argument functions (No nullary function)
;; (b) Functions are first class, which means that functions can be passed as values

;; Note: Multi-argument function is just a syntactic sugar
;; Currying (c.f. Haskell Curry)
((λ (x y) (+ x y)) 3 4); is equivalent to
(((λ (x) (λ (y) (+ x y))) 3) 4)

;; Encoding Booleans
(define TRUE (λ (x) (λ (y) x))); given 2 things, choose the 1st
(define FALSE (λ (x) (λ (y) y))); given 2 things, choose the 2nd

;; Encoding NOT
(define NOT (λ (b) ((b FALSE) TRUE)))
; (λ (b) ((b (λ (x) (λ (y) y))) (λ (x) (λ (y) x))))
(println 'NOT)
(NOT TRUE)
(NOT FALSE)
;; What about AND and OR?
#;
(define AND (λ (x)
              (λ (y)
                     ...)))
;; look at x, is it TRUE or FALSE?
#;
(define AND (λ (x)
              (λ (y)
                     ((x ...) ...))))
;; if x is TRUE, the truth of the AND expression is solely dependent on y
;; if x is FALSE, the truth of the AND expression is x (FALSE)
(define AND (λ (x)
              (λ (y)
                ((x y) x))))
(println 'AND)
((AND TRUE) TRUE)
((AND TRUE) FALSE)
((AND TRUE) FALSE)
((AND FALSE) FALSE)

(define OR (λ (x)
             (λ (y)
               ((x x) y))))
(println 'OR)
((OR TRUE) TRUE)
((OR TRUE) FALSE)
((OR FALSE) TRUE)
((OR FALSE) FALSE)

(define IF (λ (c)
             (λ (t)
               (λ (f)
                 ((c t) f)))))


;; Encoding Natural Numbers
;; https://en.wikipedia.org/wiki/Church_encoding
;; represent numbers with the number of times of repeatedly applying f
(define ZERO  (λ (f) (λ (x) x))) ; Note this is how we defined FALSE
(define ONE   (λ (f) (λ (x) (f x))))
(define TWO   (λ (f) (λ (x) (f (f x)))))
(define THREE (λ (f) (λ (x) (f (f (f x))))))
(define FOUR  (λ (f) (λ (x) (f (f (f (f x)))))))
(define FIVE  (λ (f) (λ (x) (f (f (f (f (f x))))))))
(define SIX   (λ (f) (λ (x) (f (f (f (f (f (f x)))))))))
(define SEVEN (λ (f) (λ (x) (f (f (f (f (f (f (f x))))))))))

;; and so on

;; we need this helper to actually see what the number is
(define _ (λ (x) (add1 x)))
((ZERO _) 0)
((ONE _) 0)
((TWO _) 0)
((THREE _) 0)

;; alternative helper for visualization
(define c (circle 5 "solid" "black"))
(define z (circle 5 "outline" "black"))
(define ~ (λ (x) (beside c x)))
((ZERO ~) z)
((ONE ~)  empty-image)
((TWO ~)  empty-image)
((THREE ~)  empty-image)

;; Another way of encoding natural numbers (Peano numbers)
;; Recursive definition
;; NATURAL is one of:
;; - ZERO
;; - SUCC(NATURAL)


;; successor
;; n is a natural number,
;; which is a function with 2 arguments
;; that applies some function n times to its argument
(define SUCC (λ (n)
               (λ (f)
                 (λ (x)
                   (f ((n f) x))))));apply f to x n times, then apply f again

(((SUCC ZERO) _) 0)
(((SUCC (SUCC ZERO)) _) 0)
(((SUCC (SUCC (SUCC ZERO))) _) 0)


;; Arithmetics
#;
(define PLUS (λ (m)
               (λ (n)
                 (λ (f)
                   (λ (x)
                     ((m f) ((n f) x))))))); apply f n times, then apply f m times
;; a simpler definition using SUCC
(define PLUS (λ (m)
               (λ (n)
                 ((m SUCC) n))))

(print "4 + 3 = ")
((((PLUS FOUR) THREE) _) 0)
(print "2 + 3 = ")
((((PLUS (SUCC (SUCC ZERO))) (SUCC (SUCC (SUCC ZERO)))) _) 0)

;; multiplication (repeated addition)
(define MULT (λ (m)
               (λ (n)
                 ((m (PLUS n)) ZERO))))

(print "2 x 2 = ")
((((MULT TWO) TWO) _) 0)
(print "3 x 4 = ")
((((MULT THREE) FOUR) _) 0)

;; exponentiation
(define EXP (λ (m)
              (λ (n)
                (n m))))
((((EXP THREE) FOUR) _) 0)
((((EXP TWO) SIX) _) 0)

;; Predicates
(define ZERO? (λ (n); if n is a natural number
                ((n (λ (x) FALSE)); apply this function to TRUE n times
                    TRUE))); if apply 0 times then it's TRUE

;; a somewhat interesting program:
; (if (zero? (+ 1 1)) (+ 1 2) (+ 3 4))
(((IF (ZERO? ((PLUS ONE) ONE)))
  ((((PLUS ONE) TWO) _) 0))
 ((((PLUS THREE) FOUR) _) 0))

;; Encoding pairs
;; TODO


;; Recursion
;; Y-combinator
;; TODO

;; References
;; Lambda Calculus: PyCon 2019 Tutorial (Screencast)
;; https://www.youtube.com/watch?v=5C6sv7-eTKg