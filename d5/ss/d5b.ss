#!r6rs
(import (rnrs (6)))

;polymer - vector of integers
;index - index into vector
;return bool
(define react? 
    (lambda (polymer index)
        (if (= (- (vector-length polymer) index) 1)
            #f
            (let ([a (vector-ref polymer index)][b (vector-ref polymer (+ index 1))])
                (if (= (abs (- a b)) 32)
                    #t
                    #f)))))

;in - list of integers
;return integer
(define scan
    (lambda (in)
        (let pass ([polymer in]
                    [reactions 1])
            (if (= reactions 0)
                (length polymer)
                (let react ([newpolymer '()][inputpolymer (list->vector polymer)][index 0][reactions 0])
                    (define nocopy
                        (lambda (newpoly inputpoly index reactions)
                            (react newpoly inputpoly (+ index 2) (+ reactions 1))))

                    (define copy
                        (lambda (newpoly inputpoly index reactions)
                            (react
                            (cons (vector-ref inputpoly index) newpoly)
                            inputpoly
                            (+ index 1)
                            reactions)))

                    (if (= index (vector-length inputpolymer))
                        (pass newpolymer reactions)
                        (if (react? inputpolymer index)
                            (nocopy newpolymer inputpolymer index reactions)
                            (copy newpolymer inputpolymer index reactions))))))))

;in - list of integers
;unit - integer
;return list of integers
(define remove
    (lambda (lst unit)
        (filter 
            (lambda (x) (not (or (= x unit) (= x (+ unit 32)) (= x (- unit 32)))))
            lst)))

(define main
    (lambda (file)
        (define input (map char->integer (string->list (get-string-all file))))
        (define units (map char->integer (string->list "ABCDEFGHIJKLMNOPQRSTUVWXYZ")))
        (let iter ([lengths '()][units units])
            (if (null? units)
                (car (sort < lengths))
                (iter 
                    (cons (scan (remove input (car units))) lengths) 
                    (cdr units))))))

(time (main (open-input-file "input.txt")))
(exit)