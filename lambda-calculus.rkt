#lang lazy
;; Author: Junze Wu
;; Date: Nov 22, 2019
;; Description: Code to demonstrate λ-definability

;; Encoding Booleans
(define TRUE  (λ (x) (λ (y) x)))
(define FALSE (λ (x) (λ (y) y)))

;; Encoding NOT, AND, OR
(define NOT (λ (b) ((b FALSE) TRUE)))
(define AND (λ (x) (λ (y) ((x y) x))))
(define OR (λ (x) (λ (y) ((x x) y))))

;; Encoding IF
(define IF (λ (c) (λ (t) (λ (f) ((c t) f)))))

;; Encoding Natural Numbers
;; Church Numerals
;; represent numbers with the number of times of repeatedly applying f
(define ZERO  (λ (f) (λ (x) x))) ;; Note this is also FALSE
(define ONE   (λ (f) (λ (x) (f x))))
(define TWO   (λ (f) (λ (x) (f (f x)))))
(define THREE (λ (f) (λ (x) (f (f (f x))))))
(define FOUR  (λ (f) (λ (x) (f (f (f (f x)))))))
(define FIVE  (λ (f) (λ (x) (f (f (f (f (f x))))))))
(define SIX   (λ (f) (λ (x) (f (f (f (f (f (f x)))))))))
(define SEVEN (λ (f) (λ (x) (f (f (f (f (f (f (f x))))))))))
;; and so on

;; Another way of encoding natural numbers (Peano numbers)
;; Recursive definition
;; NATURAL is one of:
;; - ZERO
;; - (SUCC NATURAL)

;; Successor
(define SUCC (λ (n) (λ (f) (λ (x) (f ((n f) x))))))

;; Arithmetics
;; Addition
(define PLUS (λ (m) (λ (n) ((m SUCC) n))))

;; Multiplication (repeated addition)
#;
(define MULT (λ (m) (λ (n) ((m (PLUS n)) ZERO))))

;; Alternative definition (composition)
(define MULT (λ (m) (λ (n) (λ (f) (m (n f))))))

;; Exponentiation
(define EXP (λ (m) (λ (n) (n m))))

;; For predecessor and subtraction, we need to introduce pairs first

;; Encoding pairs and lists
;; we want the ability to 'select' from two paired items
(define CONS (λ (a) (λ (b) (λ (s) ((s a) b)))))
(define CAR (λ (p) (p TRUE)))
(define CDR (λ (p) (p FALSE)))
(define NIL FALSE) ;; denote empty list

;; Predecessor
;; the "wisdom tooth trick"
(define T (λ (p) ((CONS (SUCC (CAR p))) (CAR p))))
(define PRED (λ (n) (CDR ((n T) ((CONS ZERO) ZERO)))))

;; Subtraction
(define SUB (λ (x) (λ (y) ((y PRED) x))))

;; Predicates
(define ZERO? (λ (n) ((n (λ (x) FALSE)) TRUE)))
(define LEQ? (λ (m) (λ (n) (ZERO? ((SUB m) n)))))
(define GT? (λ (m) (λ (n) (NOT ((LEQ? m) n)))))
(define EQ? (λ (m) (λ (n) ((AND ((LEQ? m) n)) ((LEQ? n) m)))))

;; Recursion

;; In Racket, recursive procedures can be defined using self-reference
;; However, in λ-calculus, functions are anonymous
#;
(define factorial
  (λ (n)
    (if (zero? n)
        1
        (* n (factorial (sub1 n))))))
#;
(define (divide n m)
  (if (>= n m)
      (add1 (divide (- n m) m))
      0))

;; Y combinator
;; Y f = f (Y f)
(define Y (λ (f) ((λ (x) (f (x x))) (λ (x) (f (x x))))))


(define factorial (Y (λ (f)
                       (λ (n)
                         (if (zero? n)
                             1
                             (* n (f (sub1 n))))))))

(define FACTORIAL (Y (λ (f)
                       (λ (n)
                         (((ZERO? n)
                           ONE)
                          ((MULT n) (f (PRED n))))))))

(define divide
  (Y (λ (f)
       (λ (n)
         (λ (m)
           (if (>= n m)
               (add1 ((f (- n m)) m))
               0))))))

(define DIVIDE
  (Y (λ (f)
       (λ (n)
         (λ (m)
           ((((OR ((GT? n) m)) ((EQ? n) m))
             (SUCC ((f ((SUB n) m)) m)))
            ZERO))))))

;; Sample programs
(NOT TRUE)
(NOT FALSE)

((AND TRUE) TRUE)
((AND TRUE) FALSE)
((AND TRUE) FALSE)
((AND FALSE) FALSE)

((OR TRUE) TRUE)
((OR TRUE) FALSE)
((OR FALSE) TRUE)
((OR FALSE) FALSE)

;; helper function to see what the Church numeral is
(define (show n) ((n add1) 0))

(show ONE)
(show (SUCC (SUCC (SUCC ZERO))))
(show ((PLUS FOUR) THREE))
(show ((MULT THREE) FOUR))
(show ((EXP THREE) FOUR))

(CAR ((CONS ONE) TWO))
(CDR ((CONS ONE) TWO))
(CAR ((CONS ONE) ((CONS TWO) ((CONS THREE) NIL))))
(CAR (CDR ((CONS ONE) ((CONS TWO) ((CONS THREE) NIL)))))
(CAR (CDR (CDR ((CONS ONE) ((CONS TWO) ((CONS THREE) NIL))))))

(show (PRED SEVEN))
(show ((SUB SEVEN) TWO))

(ZERO? ZERO)
(ZERO? TWO)

((LEQ? ONE) TWO)
((LEQ? TWO) SIX)
((LEQ? THREE) TWO)

((EQ? ONE) ONE)
((EQ? ONE) TWO)

(show ((DIVIDE SIX) TWO))
(show ((DIVIDE SIX) THREE))
(show ((DIVIDE FOUR) TWO))

(show (FACTORIAL FIVE))

(show
 (((IF (ZERO? ((SUB ((PLUS THREE) FOUR))
               ((PLUS TWO) FIVE))))
   ((EXP THREE) TWO))
  ((MULT THREE) FOUR)))