# Lambda Calculus

## Syntax

```
 M  = X
    | λX.M
    | (M M)
 X  = a variable: x, y, ...
```
### Examples
```
 x                       
 (x y)                            
 (λx.x)                  
 (λy.(λz.y))            
 ((λy.(y y)) (λy.(y y)))
```

## Reductions
* α-conversion
* β-reduction
* η-conversion

## Ideas
(a) Do computation with ONLY single-argument functions (no nullary function). Other type of values can be encoded with functions.

(b) Functions are first class, which means that functions can be passed as values.

(c) Multi-argument function is just a syntactic sugar. We can convert a
multi-arg function to single arg functions. The process is known as Currying (c.f. Haskell Curry).
```
#lang racket
((λ (x y) (+ x y)) 3 4)  
;; is equivalent to
(((λ (x) (λ (y) (+ x y))) 3) 4)
```

### Encoding Booleans
```
(define TRUE (λ (x) (λ (y) x))); given 2 things, choose the 1st
(define FALSE (λ (x) (λ (y) y))); given 2 things, choose the 2nd
```

### Encoding NOT
```
(define NOT (λ (b) ((b FALSE) TRUE)))
;; fully expanded: (λ (b) ((b (λ (x) (λ (y) y))) (λ (x) (λ (y) x))))
```

### Encoding AND, OR, IF
```
(define AND (λ (x)
              (λ (y)
                ((x y) x))))

(define OR (λ (x)
             (λ (y)
               ((x x) y))))

(define IF (λ (c)
             (λ (t)
               (λ (f)
                 ((c t) f)))))
```

### Encoding Natural Numbers

#### Church Encoding
https://en.wikipedia.org/wiki/Church_encoding
```
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
```
####  Helpers for visualization
```
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
```

#### Peano numbers
https://wiki.haskell.org/Peano_numbers
```
;; Another way of encoding natural numbers
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
```

### Arithmetics
```
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
```
### Predicates
```
(define ZERO? (λ (n); if n is a natural number
                ((n (λ (x) FALSE)); apply this function to TRUE n times
                    TRUE))); if apply 0 times then it's TRUE

;; a somewhat interesting program:
; (if (zero? (+ 1 1)) (+ 1 2) (+ 3 4))
(((IF (ZERO? ((PLUS ONE) ONE)))
  ((((PLUS ONE) TWO) _) 0))
 ((((PLUS THREE) FOUR) _) 0))
```
### Encoding pairs
TODO


### Recursion
Y-combinator

TODO

### References
#### Academic
1. (Book) Church, A. (1941). The calculi of lambda-conversion. Princeton;London;: Princeton university press.
2. [(Book)]((https://www.sciencedirect.com/bookseries/studies-in-logic-and-the-foundations-of-mathematics/vol/103)) The Lambda Calculus Its Syntax and Semantics. H.P. BARENDREGT
3. [(Paper)](http://www-users.mat.umk.pl/~adwid/materialy/doc/church.pdf) The Impact of the Lambda Calculus in Logic and Computer Science. Henk Barendregt
4. [(Paper)](https://homepages.inf.ed.ac.uk/gdp/publications/cbn_cbv_lambda.pdf) Call-by-Name, Call-by-Value, and The Lambda Calculus. Gordon Plotkin
5. [(Course notes, chapter 4)](http://www.cs.utah.edu/~mflatt/past-courses/cs7520/public_html/s06/notes.pdf) Felleisen, Matthias & Flatt, Matthew. (2007). Programming Languages and Lambda Calculi.
6. [(Paper)](https://www.sciencedirect.com/science/article/pii/0304397589900698) A Syntactic Theory of Sequential State. Matthias Felleisen and Daniel Friedman
7.  [(Paper)](https://www.irif.fr/~mellies/mpri/mpri-ens/articles/moggi-computational-lambda-calculus-and-monads.pdf) Moggi, E. (1989). Computational lambda-calculus and monads. Paper presented at the 14-23. doi:10.1109/LICS.1989.39155.
8. (Book) Barendregt, H. P., Dekkers, W., Statman, R., & Cambridge Core EBA eBooks Complete Collection. (2013). Lambda calculus with types. Cambridge;New York;: Cambridge University Press. doi:10.1017/CBO9781139032636
9. (Book) Type theory and Formal Proofs. Ron Nederpelt and Herman Geuvers

#### Non-academic
10. [(Screencast)](https://www.youtube.com/watch?v=5C6sv7-eTKg) Lambda Calculus: PyCon 2019 Tutorial
11. [(Article)](http://matt.might.net/articles/compiling-up-to-lambda-calculus/) Compiling to lambda-calculus: Turtles all the way down
12. [Blog posts](http://goodmath.blogspot.com/2006/06/lamda-calculus-index.html) on lambda calculus from Good Math/Bad Math
