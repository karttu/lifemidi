
; (define (A000523 n) (cond ((zero? n) -1) (else (floor->exact (/ (log n) (log 2))))))
;; (define floor-log-2 A000523) ;; An old alias.

;; Note for n > 0, (floor-log-2 n) = (- (binwidth n) 1)

(define (floor->exact n) (inexact->exact (floor n)))


;; Note for n > 0, (floor-log-2 n) = (- (binwidth n) 1)

(define (binwidth n) ;; = A029837(n+1)
  (let loop ((n n) (i 0))
     (if (zero? n)
         i
         (loop (floor->exact (/ n 2)) (1+ i))
     )
  )
)


(define (A000523 n) (if (zero? n) -1 (- (binwidth n) 1)))



(define (do_from_0_to_n n foo)
   (let loop ((i 0))
      (cond ((<= i n)
                (foo i)
                (loop (+ i 1))
            )
      )
   )
)

(define (do_from_1_to_n n foo)
   (let loop ((i 1))
      (cond ((<= i n)
                (foo i)
                (loop (+ i 1))
            )
      )
   )
)

(define (do_from_2_to_n n foo)
   (let loop ((i 2))
      (cond ((<= i n)
                (foo i)
                (loop (+ i 1))
            )
      )
   )
)


