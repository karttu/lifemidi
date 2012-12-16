;;
;; gen_incfex.scm -- A small Scheme-program to create a purely
;; combinational Verilog-module for increasing the factorial expansion
;; by one. This version is for binary-encoded digits of factorial expansion.
;; Coded by karttu, April 6 2010.
;; Copyright (C) 2010-2012 Antti Karttunen, subject to the terms of the GPL v2.

;; Works for example in MIT/GNU Scheme, Version 9.
;; and also in Elk, if I recall right.

;; Module inc7fex.v was created with these top-level calls:
;;  (load "gen_incfex.scm")
;;  (load-option 'format) ;; Needed in MIT/GNU Scheme.
;;  (create-incfex-module 7 "inc7fex.v")

(load "gen_util1.scm")


(define (output-module-headers out size)
   (format out "module inc~afex(input in_f1" size)
   (do_from_2_to_n size
       (lambda (i)
           (format out ",\n                input [~a:0] in_f~a" (A000523 i) i)
       )
   )
   (format out ",\n                output out_f1")
   (do_from_2_to_n size
       (lambda (i)
           (format out ",\n                output [~a:0] out_f~a" (A000523 i) i)
       )
   )
   (format out ");\n\n")
)


;; wire wrap2  =  (in_f1 && (2 == in_f2));
;; wire wrap3  =  (wrap2 && (3 == in_f3));
;; wire wrap4  =  (wrap3 && (4 == in_f4));
;; etc.

(define (output-wrap-wires out size)
   (format out "wire wrap1 = in_f1;\n") ;; Just an alias, makes these loops more streamlined.
;; If size is 3, 7, 15, 31, ... then the last wrap wire would be unnecessary.
   (do_from_2_to_n (if (= (binwidth size) (A000523 (1+ size))) (- size 1) size)
       (lambda (i)
           (format out "wire wrap~a = (wrap~a && (~a == in_f~a));\n" i (- i 1) i i)
       )
   )
   (format out "\n\n")
)

;; assign out_f2  =  (in_f1 ? (wrap2 ? 0 : in_f2+1) : in_f2);
;; assign out_f3  =  (wrap2 ? in_f3+1 : in_f3);
;; assign out_f4  =  (wrap3 ? (wrap4 ? 0 : in_f4+1) : in_f4);
;; assign out_f5  =  (wrap4 ? (wrap5 ? 0 : in_f5+1) : in_f5);
;; assign out_f6  =  (wrap5 ? (wrap6 ? 0 : in_f6+1) : in_f6);
;; assign out_f7  =  (wrap6 ? in_f7+1 : in_f7);
;; assign out_f8  =  (wrap7 ? (wrap8 ? 0 : in_f8+1) : in_f8);

(define (output-out-assignments out size)
   (format out "assign out_f1 = ~~in_f1;\n") ;; Just toggling the LSD of the factorial expansion.
   (do_from_2_to_n size
       (lambda (i)
           (cond ((= (binwidth i) (A000523 (1+ i))) ;; We can use binary autowrapping for 3, 7, 15, 31, ...
                    (format out "assign out_f~a = (wrap~a ? in_f~a+1 : in_f~a);\n" i (- i 1) i i)
                 )
                 (else
                    (format out "assign out_f~a = (wrap~a ? (wrap~a ? 0 : in_f~a+1) : in_f~a);\n" i (- i 1) i i i)
                 )
           )
       )
   )
)



(define (output-incfex-module out size)
   (output-module-headers out size)
   (output-wrap-wires out size)
   (output-out-assignments out size)
   (format out "\nendmodule\n")
)

(define (create-incfex-module size filename)
   (with-output-to-file filename
     (lambda () (output-incfex-module #t size))
   )
)

