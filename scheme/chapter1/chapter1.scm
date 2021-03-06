;; Chapter 1 problems

;; 1.1 eval some basic expresions (trivial, skipping some)

10

(define a 3)
(define b (+ a 1))

(* (cond ((> a b) -2)
	 ((< a b) -2)
	 (else -2))
   (+ a ))

;; 1.2 translate into prefix

(/ (+ 5 4 (- 2 (- 3 (+ 6 (/ 4 5))))) (* 3 (- 6 2) (- 2 7)))

;; 1.3 define a procedure that takes there numbers as args, and returns the sum of the squares of the larger two numbers

(define (square x)
  (* x x))

(define (sum-of-squares x y)
  (+ (square x) (square y)))

(define (sum-three x y z)
  (cond ((and (< x y) (< x z)) (sum-of-squares y z)) ;; x is smallest
	((and (< z y) (< z )) (sum-of-squares x y)) ;; z is smallest
	(else (sum-of-squares x z)))) ;; y is smallest

;; 1.4 what is the behavior of the following procedure?

(define (a-plus-abs-b a b)
  ((if (> b 0) + -) a b))

;; it evaulates the if first, to return the procedure + if b is positive, or - if b is neg
;; since this operator is in the function position (first in the sexp), and it is being evaulated as
;; a procedure (because of the () ), it applys a and b to this.
;; this is then either a + b, or a - -b, so the it's a + (abs b)


;; 1.5 
;; A test for if the interpreter does applicative -order eval, or normal order -eval

(define (p) (p)) ;; does an inf loop

(define (test x y)
  (if (= x 0)
      0
      y))

;; (test 0 (p)) ;; don't eval this - it results in an infinite loop because the interpreter does applicative order evaluation!

;; if it's applicative order, it evaluates args first
;; therefore, it will infinite loop

;; if normal order, it builds up a tree and _then_ evals in a big collapse. So it will eval the test and return 0 before the infinite loop is evald


;; Sqrt example

(define (sqrt-iter guess x)
  (if (good-enough? guess x)
      guess
      (sqrt-iter (improve guess x) x)))

(define (improve guess x)
  (average guess (/ x guess)))

(define (average x y)
  (/ (+ x y) 2))

(define (good-enough? guess x)
  (< (abs (- (square guess) x)) 0.001))

(define (sqrt x)
  (sqrt-iter 1.0 x))

;; Exercise 1.6
;; Can If be defined as not a special form, just a procedure that uses cond?

(define (new-if predicate then-clause else-clause)
  (cond (predicate then-clause)
	(else else-clause)))

;; what happens if we try to use `new-if` in `sqrt-iter` above?
;; it aborts due to "maximum recursion depth exceeded", because it never stops
;; ... why?
;; becuase of eval rules for procedures! EVAL THE ARGS, then apply the operator.
;; so the else-clause ALWAYS gets evaluated, even though we only want it to be evaled when the predicate is false
;; this is why if is a special form - it only evals the else if the predicate is false

;; Exercise 1.7
;; good-enough? won't be effective for finding sqrt of very small numbers, or very large numbers (due to precision)
;; example: current version gives (sqrt 0.0001) -> 0.032308, but it should be 0.01


;; try keeping track of the old guess, and terminating when they are withing a small fraction of each other
(define (new-good-enough? guess old-guess x)
  (define percent-guess (/ (abs (- guess old-guess)) guess))
  (< percent-guess 0.01))
  
(define (new-sqrt-iter guess old-guess x)
  (if (new-good-enough? guess old-guess x)
      guess
      (new-sqrt-iter (improve guess x) guess x)))

(define (new-sqrt x)
  (new-sqrt-iter 1.0 0.0 x))

;; this works better, (new-sqrt 0.0001) -> 1e-2. The display is kinda shitty right now though, displaying fractions

;; Exercise 1.8
;; use the same above technique to approximate teh cube root
;; you can use (x/(sqare y) + 2y)/3

(define (cube-improve guess x)
  (/ (+ (/ x (square guess)) (* 2 guess)) 3))

(define (cube-iter guess old-guess x)
  (if (new-good-enough? guess old-guess x)
      guess
      (cube-iter (cube-improve guess x) guess x)))

(define (cbrt x)
  (cube-iter 1.0 0.0 x))



;; factorial example

;; linear recursize - expands out, then collapses down. O(n) space and time
(define (factorial n)
  (if (= n 1)
      1
      (* n (factorial (- n 1)))))

;; linear iterative - O(n) time, O(1) space
;; state can be summarized by a fixed number of state variables
(define (fact n)
  (define fact-iter (lambda (product count)
    (if (> count n)
	product
	(fact-iter (* product count) (+ count 1)))))
  (fact-iter 1 1))

;; Exercise 1.9

(define (inc n)
  (+ n 1))

(define (dec n)
  (- n 1))


;; is this a recursive or iterative process?
(define (plus1 a b)
  (if (= a 0)
      b
      (inc (plus1 (dec a) b))))

;; (plus1 4 5)
;; (inc (plus1 3 5))
;; (inc (inc (plus1 2 5)))
;; (inc (inc (inc (plus1 1 5))))
;; (inc (inc (inc (inc (plus1 0 5)))))
;; (inc (inc (inc (inc 5))))
;; (inc (inc (inc 6)))
;; (inc (inc 7))
;; (inc 8)
;; 9
; recursive process

;; is this a recurisve or iterative process?
(define (plus2 a b)
  (if (= a 0)
      b
      (plus2 (dec a) (inc b))))

;; (plus2 4 5)
;; (plus2 3 6)
;; (plus2 2 7)
;; (plus2 1 8)
;; (plus2 0 9)
;; 9
;; iterative process

;; Exercise 1.10
;; The following procedure computes a mathematical function called Ackermann's function

(define (A x y)
  (cond ((= y 0) 0)
	((= x 0) (* 2 y))
	((= y 1) 2)
	(else (A (- x 1)
		 (A x (- y 1))))))

;; (A 1 10)
;; 1024

;; (A 2 4)
;; 65536

;; (A 3 3)
;; 65536

;; give definitions for the following procedures

(define (exponent base n)
  (define (exponent-iter acc count)
    (if (= count n)
	acc
	(exponent-iter (* acc base) (+ count 1))))
  (exponent-iter 1 0))

(define (f n) (A 0 n)) ;;; n*2

(define (g n) (A 1 n)) ;; powers of 2, 2^n

(define (h n) (A 2 n)) ;; 2^(h(n-1))

(define (k n) (* 5 n n)) ;; 5*n^2

;; Fib!

(define (fib n)
  (if (< n 2)
	n
	(+ (fib (- n 1))
	   (fib (- n 2)))))


(define (fib-iter a b count)
  (if (= count 0)
      b
      (fib-iter (+ a b) a (- count 1))))

(define (count-change amount)
  (cc amount 5))

(define (cc amount kinds-of-coins)
  (cond ((= amount 0) 1)
	((or (< amount 0) (= kinds-of-coins 0) 0))
	(else (+ (cc amount (- kinds-of-coins 1))
		 (cc (- amount (first-denomination kinds-of-coins)) kinds-of-coins)))))

(define (first-denomination kinds-of-coins)
  (cond ((= kinds-of-coins 1) 1)
	((= kinds-of-coins 2) 5)
	((= kinds-of-coins 3) 10)
	((= kinds-of-coins 4) 25)
	((= kinds-of-coins 5) 50)))

;; Exercise 1.11
;;  A function f is defined by f(n) = n if n < 3, and f(n) = f(n-1) + 2f(n-2) + 3f(n-3) if n>=3
;; write the procedure as both an iterative process and a recursive process

;; recursive

(define (f n)
  (if (< n 3)
      n
      (+ (f (- n 1))
	 (* 2 (f (- n 2)))
	 (* 3 (f (- n 3))))))

;; iterative
;; a b c d e

(define (f2 n)
  (f-iter 2 1 0 n))

(define (f-iter a b c count)
  (define next (+ a
		 (* 2 b)
		 (* 3 c)))

  (cond ((= count 0) c)
	((= count 1) b)
	((= count 2) a)
	(else (f-iter next
		      a
		      b
		      (- count 1)))))


;; Exercise 1.12
;; Use a recursive process to compute pascal's triangle
;; each edge is 1, each number inside the triangle is the sum of the two numbers above it
;;     1
;;    1 1
;;   1 2 1
;;  1 3 3 1
;; 1 4 6 4 1
;;1 5 t t 5 1

(define (empty? lst)
  (= (length lst) 0))

;; gets the item at the index. Indexing starts at 1
(define (get row i)
  (define loop (lambda (row count)
    (cond ((empty? row) ())
	  ((= count i) (car row))
	  (else (loop (cdr row)
		      (+ count 1))))))
  (loop row 1))

;; left parent of row n item i
(define (left-parent n i)
  (define prev-row (pascal-row (- n 1)))
  (get prev-row
       (- i 1)))

;; right parent of row i item i
(define (right-parent n i )
  (define prev-row (pascal-row (- n 1)))
  (get prev-row
       i))

 ;; note that the number of elements in each row is n
(define (pascal-row n)
  ;; recursively build n in a loop
  (define build-row (lambda (n i row)
    (cond ((= i 1) (list 1))
	  ((= i n) (append (build-row n
				      (- i 1)
				      row)
			   (list 1)))
	  (else (append (build-row n
				   (- i 1)
				   row)
			(list (+ (left-parent n i)
				 (right-parent n i))))))))
  (build-row n n ()))
	

    



;; Exercise 1.13
;;TODO

;; Exercise 1.14
;; Draw the tree illustrating the process generated by the count-change procedure of section 1.2.2
;; in making change for 11 cents. What are the orders of growth of the space and number of steps
;; used by this process as the amount to be changed increases?
;;TODO


;; Exercise 1.15

(define (cube x) (* x x x))

(define (p x) (- (* 3 x) (* 4 (cube x))))

(define (sine angle)
  (display "here")(newline)
  (if (not (> (abs angle) 0.1))
      angle
      (p (sine (/ angle 3.0)))))

;; how many times is p applied for (sine 12.15)? -> 4
;; what is the order of growth in space and number of steps (as a function of a) used
;; by the process generated by the sine procedure when (sine a) is evaluated?
;; log base3 (a), because we're cutting the search space of a in 3 each time the function is applied, and only recursing down one of those branches


;; Exercise 1.16
;; fast-exponetation iterative
;; take away technique: use an invariant of a*b^n while iterating. 
;; a starts at 1, and the final value is a

(define (fast-exp b n)
  (cond ((= n 0) 1)
	((even? n) (square (fast-exp b (/ n 2))))
	(else (* b (fast-exp b (- n 1))))))

(define (fast-exp-iter-helper b n a)
  (define (next-a)
    (if (odd? n)
	(* a b)
	(* a (fast-exp-iter b (/ n 2)))))

  (define (next-n)
    (if (odd? n)
	(- n 1)
	(/ n 2)))

  (cond ((= n 0) 1)
	((= n 1) (* a b))
	((fast-exp-iter-helper b (next-n) (next-a)))))

(define (fast-exp-iter b n )
  (fast-exp-iter-helper b n 1))

;; Exercise 1.17
;; Analogous to exponentiation by repeated multiplication, we can get multiplication by repeated addition:

(define (mult a b)
  (if (= b 0)
      0
      (+ a
	 (mult a (- b 1)))))

;; now, given double and halve, design a log multiplication algorithm

;; a * 4 = a a a a
;; so, a * (b/2) = 2 * (a a)

(define (double n)
  (+ n n))

(define (halve n)
  (/ n 2))

(define (fast-mult a b)
  (cond ((= b 0) 0)
	((= b 1) a)
	((odd? b) (+ a (fast-mult a (- b 1))))
	(else (double (fast-mult a (halve b))))))

;; now, turn this fast-mult from a recurisve process into an iterative process
;; Try to think of how to use the same invariant technique
;; let's try the invariabnt  acc + a*b
;; so each iteration we pull some b's out of a*b, and put them in acc

;; if odd, we update acc = acc + a, b--
;; if even, we update acc = acc + double


(define (fast-mult-helper a b acc)
  (define (next-acc)
    (if (odd? b)
	(+ acc a)
	(+ acc (fast-mult-iter a (halve b)))))
  (define (next-b)
    (if (odd? b)
	(- b 1)
	(/ b 2)))
  (cond ((= b 0) 0)
	((= b 1) (next-acc))
	(else (fast-mult-helper a (next-b) (next-acc)))))

(define (fast-mult-iter a b)
  (fast-mult-helper a b 0))


;; Exercise 1.19
;; Logarithmic fibonacci
;; TODO


(define (gcd a b)
  (if (= b 0)
      a
      (gcd b (remainder a b))))

;; Exercise 1.20
;; normal order application in GCD


;; 1.2.6 Testing for Primality

(define (divides? a b)
  (= (remainder b a) 0))

(define (smallest-divisor n)
  (find-divisor n 2))

;; we only need to go up to the sqrt of n, becuase a divisor d of a = d*b, so if we were past the "midpoint" of sqrt, then we should have already found the corresponding b, which is smaller than sqrt
(define (find-divisor n test-divisor)
  (cond ((> (square test-divisor) n) n)
	((divides? test-divisor n) test-divisor)
	(else (find-divisor n (+ test-divisor 1)))))

;; we can therefore test primality if n's smallest divisor is n itself
;; O(sqrt(n))

(define (prime? n)
  (= n (smallest-divisor n)))

;; we can get O(logn) using Fermat's Little Theorem

;; if n is prime, then
;; (remainder a^n n) == (remainder (remainder a n) n)
;; it's possible, but rare for a non-prime to have this property. So we can
;; use it as a basis for a past probabilistic primality test

;; Exercise 1.21
;; smallest divisor of 199 is 199
;; smallest divisor of 1999 is 1999
;; smallest divisor of 19999 is 7

;; Exercise 1.22

(define (timed-prime-test n)
  (newline)
  (display n)
  (start-prime-test n (runtime)))

(define (start-prime-test n start-time)
  (if (prime? n)
      (report-prime (- (runtime) start-time))))

(define (report-prime elapsed-time)
  (display " *** ")
  (display elapsed-time))

;;TODO

;; Exercise 1.23
;; we only need to test for primes using odd numbers


(define (next test-divisor)
  (if (= test-divsor 2)
      3
      (+ test-divisor 2)))

(define (find-divisor n test-divisor)
  (cond ((> (square test-divisor) n) n)
	((divides? test-divisor n) test-divisor)
	(else (find-divisor n (next test-divisor)))))

;; Exercise 1.24
;; TODO

;; Exercise 1.25
;; She's right, but it's inefficient for large numbers. Modding each step keeps the numbers small after each step.

;; Exercise  1.26
;; TODO

;; Exercise 1.27
;; TODO

;; Exercise 1.28
;; TODO

;; SECTION 1.3

;; Higher order functions

(define (sum term a next b)
  (if (> a b)
      0
      (+ (term a)
	 (sum term (next a) next b))))

(define (inc n) (+ n 1))

(define (kdentity x) x)

(define (sum-cubes a b)
  (sum cube a inc b))

(define (sum-integers a b)
  (sum identity a inc b))

(define (fizz-buzz n)
  (define (printit n)
    (cond ((and (= (remainder n 5) 0)
		(= (remainder n 3) 0)) (display "fizzbuzz")(newline))
	  ((= (remainder n 3) 0) (display "fizz")(newline))
	  ((= (remainder n 5) 0) (display "buzz")(newline))
	  (else (display n)(newline))))
  (define loop(lambda (n i)
		(cond ((> i n) "done")
		      (else (printit i) (loop n (+ i 1))))))
  (loop n 1))

;; Exercise 1.29
;; Integration using Simpson's rule.

(define (integrate f a b n)
  (define h (/ (- b a) n))

  (define loop (lambda (k acc)
		 (define yk (f (+ a (* k h))))

		 (define (multiplier)
		   (cond ((= k 0) 1)
			 ((= k n) 1)
			 ((odd? k) 4)
			 (else 2)))

		 (if (> k n)
		     acc
		     (loop (inc k) (+ acc
				      (* yk
					 (multiplier)))))))
  (* (/ h 3) (loop 0 0.0)))

;; Exercise 1.30
;; Write sum to be performed iteratively
;; TODO

;; Exercise 1.31
;; TODO

;; Exercise 1.32
;; TODO

;; Exercise 1.33
;; TODO

;; Exercise 1.34

(define (f g)
  (g 2))

(f square)
;; 4

(f (lambda (z) (* z (+ z 1))))
;; 6

;; What happens if we  evaluate (f f)? Explain
;; (f f) -> (f (f 2)) -> ERR OBJ 2 is not applicable

;; Finding roots of equations using the half-interval method

(define (search f neg-point pos-point)
  (let ((midpoint (average neg-point pos-point)))
    (if (close-enough? neg-point pos-point)
	midpoint
	(let ((test-value (f midpoint)))
	  (cond ((positive? test-value)
		 (search f neg-point midpoint))
		((negative? test-value)
		 (search f midpoint pos-point))
		(else midpoint))))))

(define (close-enough? x y)
  (< (abs (- x y)) 0.001))

(define (half-interval-method f a b)
  (let ((a-value (f a))
	(b-value (f b)))
    (cond ((and (negative? a-value) (positive? b-value))
	   (search f a b))
	  ((and (negative? b-value) (positive? a-value))
	   (search f b a))
	  (else
	   (error "Values are not of the opposite sign" a b)))))


;; Fixed point

(define (fixed-point f first-guess)
  (define tolerance 0.00001)
  (define (close-enough? v1 v2)
    (< (abs (- v1 v2)) tolerance))
  (define (try guess)
    (let ((next (f guess)))
      (if (close-enough? guess next)
	  next
	  (try next))))
  (try first-guess))

;; Exercise 1.35
;; Show that the golden ratio is a fixed poitn of the transformation x -> 1+1/x

(define (trans x)
  (+ 1 (/ 1 x)))

(fixed-point trans 1.0)
;Value: 1.6180327868852458

;; Exercise 1.36
;;TODO

;; Exercise 1.37
;; k-term finite continued fraction

(define (cont-frac n d k)
  (define loop
    (lambda (i)
      (if (= i k)
	  (/ (n i) (d i))
	  (/ (n i) (+ (d i)
		      (loop (+ i 1)))))))
  (loop 1))

;; this function approximates 1/golden ratio
(cont-frac (lambda (i) 1.0)
	   (lambda (i) 1.0)
	   100)

;; b) write cont-frac as an iterative procedure
;; TODO

;; Exercise 1.38
;; Approximate euler's expansion for e-2 using cont-frac
;; n(k) -> 1.0
;; d(k) -> 1, 2, 1, 1, 1, 4, 1, 1, 1, 6, 1, 1, 1, 8....

(define (euler k)
  (define (n k) 1.0)
  (define (d k)
    (cond ((= k 1) 1.0)
	  ((= k 2) 2.0)
	  ((= (remainder k 3) 2) (* 2
				    (+ (truncate (/ k 3))
					 1)))
	  (else 1.0)))
  (cont-frac n d k))

;; Exercise 1.39
;; Approximate tan(x) using Lambert's continued fraction approximation

(define (tan-cf x k)
  (define (n k)
    (if (= k 1)
	x
	(- (square x))))
  (define (d k)
    (- (* k 2)
       1))
  (cont-frac n d k))


(define (average-damp f)
  (lambda (x) (average x (f x))))

(define (sqrt x)
  (fixed-point (average-damp (lambda (y) (/ x y)))
	       1.0))

(define (cube-root x)
  (fixed-point (average-damp (lambda (y) (/ x (square y))))
	       1.0))
  
(define (deriv g)
  (lambda (x)
    (/ (- (g (+ x dx)) (g x))
       dx)))

;; Exercise 1.40 - 1.46
;; TODO


