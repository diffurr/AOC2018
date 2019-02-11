#!r6rs
(import (rnrs (6)))

(define react? 
    (lambda (polymer index)
        (if (= (- (vector-length polymer) index) 1)
            #f
            (let ([a (vector-ref polymer index)][b (vector-ref polymer (+ index 1))])
                (if (= (abs (- a b)) 32)
                    #t
                    #f)))))

(define scan
    (lambda (file)
        (let pass ([polymer (map char->integer (string->list (get-string-all file)))]
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

(display (scan (open-input-file "input.txt")))
(exit)