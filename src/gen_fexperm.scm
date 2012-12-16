;;
;; gen_fexperm.scm -- A small Scheme-program to create a purely
;; combinational Verilog-module for converting a factorial expansion of n to
;; a corresponding permutation, in the order given by http://oeis.org/A060118
;; We can use either binary-encoded or one-hot encoded representation
;; of the digits of factorial expansion. See also: http://oeis.org/A007623
;; 

;; The original was for MIT/GNU Scheme. This one is for elk
;; if I recall right and some previous version was for Guile.
;; Still works with MIT/GNU Scheme as well,
;; if you remember to  (load-option 'format)

;; Module "fex7perm.v" was created with these top-level calls:
;;  (load "gen_fexperm.scm")
;;  (load-option 'format) ;; Needed in MIT/GNU Scheme.
;;  (create-fexperm-module 7 "fex7perm.v" #f)


;; (Note! Guile doesn't understand tail-recursive "loop"-call
;; as the else-branch of if. Use cond instead!)




(load "gen_util1.scm")

(define (output-module-headers out size use-one-hot?)
  (let ((digwidth-min-1 (A000523 size)))
    (format out "module fex~aperm(input f1" size)
    (do_from_2_to_n size
      (lambda (i)
          (format out ",\n                 input [~a:0] f~a" (if use-one-hot? i (A000523 i)) i)
      )
    )
    (do_from_0_to_n size
      (lambda (i)
          (format out ",\n                 output [~a:0] d~a"
                  digwidth-min-1 i
          )
      )
    )
    (format out ");\n\n")
    (format out "parameter w = ~a;\n\n" digwidth-min-1)
    (do_from_0_to_n size
      (lambda (i)
          (format out "parameter [w:0] lev0_~a = ~a;\n" i i) ;; Was one-based: (+ 1 i)
      )
    )
    (format out "\n\n")
  )
)



(define (output-wires-up-to-level out n output-fn-equal-m-fun)
  (let loop ((lev 1))
     (output-wires-for-level out lev output-fn-equal-m-fun)
     (format out "\n");
     (if (< lev n) (loop (+ 1 lev)))
  )
)

(define (output-wires-for-level out lev output-fn-equal-m-fun)
  (let loop ((col 0))
    (format out "wire [w:0] lev~a_~a = " lev col)
    (output-assignment-for-x-y out lev col output-fn-equal-m-fun)
    (format out ";\n");
    (if (< col lev) (loop (+ 1 col)))
  )
)

(define (output-fn-equal-m-for-binary-digits out n m)
   (format out "~a == f~a" m n)
)

(define (output-fn-equal-m out n m) ;; for shift-registers
  (if (= 1 n)
      (output-fn-equal-m-for-binary-digits out n m) ;; f1 handled differently.
      (format out "f~a[~a]" n m)
  )
)

;; lev = 1.., col = 0..lev
(define (output-assignment-for-x-y out lev col output-fn-equal-m-fun)
   (cond ((= col lev)
            (output-assignment-for-x-x out lev output-fn-equal-m-fun)
         )
         (else ;; col < lev, an easy case:
            (format out "(")
            (output-fn-equal-m-fun out lev (- lev col))
            (format out " ? lev0_~a : lev~a_~a)"
                        lev    (- lev 1) col
            )
         )
   )
)

(define (output-assignment-for-x-x out lev output-fn-equal-m-fun)
   (let loop ((i lev))
      (cond ((zero? i)
               (format out "lev0_~a" lev) ;; The last "else"-part.
               (let postloop ((i lev)) ;; Spew the ending parentheses.
                 (cond ((not (zero? i))
                    (format out ")")
                    (postloop (- i 1))
                 )
               )
             )
            )
            (else
               (format out "(")
               (output-fn-equal-m-fun out lev i)
               (format out " ? lev~a_~a : "
                            (- lev 1) (- lev i)
               )
               (loop (- i 1))
            )
      )
   )
)


(define (output-fexperm-module out size use-one-hot?)
   (output-module-headers out size use-one-hot?)
   (do_from_1_to_n size
       (lambda (lev)
         (output-wires-for-level out lev
                 (if use-one-hot? output-fn-equal-m output-fn-equal-m-for-binary-digits)
         )
         (format out "\n")
       )
   )
   (format out "\n")
   (do_from_0_to_n size
      (lambda (i)
         (format out "assign d~a = lev~a_~a;\n" i size i)
       )
   )
   (format out "\nendmodule\n")
)

;; Call with the third argument either #f or #t, depending on
;; whether you want module to use one-hot or binary encoding
;; for the factorial digits.
(define (create-fexperm-module size filename use-one-hot?)
   (with-output-to-file filename
     (lambda () (output-fexperm-module #t size use-one-hot?))
   )
)

