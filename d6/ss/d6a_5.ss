#!r6rs
(import (rnrs (6)))

;using mutable locs in vector of locs in Grid record

;HELPER FUNCTIONS
(define string-split
  (lambda (line delim)
    (define len (string-length line))
    (let split ([n (- len 1)][inword #f][word '()][words '()])
      (if (>= n 0)
        (if (eq? delim (string-ref line n))
          (if inword
            (split (- n 1) #f '() (cons (list->string word) words))
            (split (- n 1) #f word words))
         (split (- n 1) #t (cons (string-ref line n) word) words))
        (if (null? word)
          words 
          (cons (list->string word) words))))))

(define string-strip 
  (lambda (line)
    (letrec ([chars-list (string->list line)]
             [strip (lambda (chars)
              (if (null? chars)
                '()
                (if (char-whitespace? (car chars))
                  (strip (cdr chars))
                (cons (car chars)(strip (cdr chars))))))])
             (list->string(strip chars-list)))))

(define parse-line
  (lambda (line)
    (let* ([numbers (string-split line #\,)]
            [fst (string->number(string-strip(car numbers)))]
            [sec (string->number(string-strip(cadr numbers)))])
            (cons fst sec))))
;main------------------------------------------------------------------------
;
(define-record-type Input (fields (immutable coords)
                                  (immutable xdim) 
                                  (immutable ydim)))

(define-record-type Grid (fields (immutable locs)
                                  (immutable xmax)
                                  (immutable ymax)))

(define-record-type Loc (fields (immutable cord)
                                (mutable id)))

(define read-input
  (lambda (filename)
    (define file (open-input-file filename))
    (let read-lines ([line (get-line file)][coords '()][xmax 0][ymax 0])
      (if (eof-object? line)
        (make-Input coords xmax ymax)
        (let ([pair (parse-line line)])
          (read-lines (get-line file) 
            (cons pair coords)
            (max xmax (car pair))
            (max ymax (cdr pair))))))))

;make initial grid from input
(define make-grid
  (lambda (data)
    (let ([xmax (Input-xdim data)]
          [ymax (Input-ydim data)])
          (let i ([y 0][locs '()])
            (if (<= y ymax)
              (let j ([x 0][locs locs])
                (if (<= x xmax)
                  (let ([cord (cons x y)][id -1])
                    (j (+ x 1) (cons (make-Loc cord id) locs)))
                  (i (+ y 1) locs)))
              (make-Grid (list->vector locs) xmax ymax))))))

;make points from input
(define make-points
  (lambda (data)
    (Input-coords data)))

(define get-distances
  (lambda (points grid)
    (let ([locs (Grid-locs grid)])
      (vector-for-each (distance-from points) locs)
      grid)))
          
;clojure
(define distance-from 
  (lambda (points)
    (lambda (loc)
      (let for-each-point([id 1][points points][maxdist (greatest-fixnum)][maxid -1])
        (if (null? points)
            (Loc-id-set! loc maxid)
            (let ([manhattan-dist (manhattan (car points)(Loc-cord loc))])
              (cond
                [(< manhattan-dist maxdist)
                 (for-each-point (+ id 1) (cdr points) manhattan-dist id)]
                [(= manhattan-dist maxdist)
                 (for-each-point (+ id 1) (cdr points) manhattan-dist -1)]
                [else 
                  (for-each-point (+ id 1) (cdr points) maxdist maxid)])))))))

(define manhattan
  (lambda (p1 p2)
    (let ([p1x (car p1)][p1y (cdr p1)]
          [p2x (car p2)][p2y (cdr p2)])
          (+ (abs (- p1x p2x))
             (abs (- p1y p2y))))))

(define largest-area
  (lambda (grid)
    (let ([htable (make-eqv-hashtable 100)])
      (vector-for-each (count-locations htable (Grid-xmax grid) (Grid-ymax grid)) (Grid-locs grid))
      (get-max-value htable))))

(define get-max-value
  (lambda (htable)
    (let ([sorted (call-with-values (lambda () (hashtable-entries htable))
      (lambda (keys values) (vector-sort > values)))])
      (vector-ref sorted 0))))

;if loc id == -1 then skip to next loc
;if id in hashtable and id value != -1 then if loc not on border value + 1 else value = -1
;if id not in hashtable add id and value to htable
(define count-locations
  (lambda (htable xmax ymax)
    (lambda (loc)
      (define id (Loc-id loc))
      (define cord (Loc-cord loc))
      (define xymax (cons xmax ymax))
      (when (not (= -1 id))
        (if (hashtable-contains? htable id)
          (let ([val (hashtable-ref htable id 'nil)])
            (if (= val -1)
              'skip
              (hashtable-set! htable id (put-value-if cord xymax val))))
          (hashtable-set! htable id (put-value-if cord xymax 0)))))))

(define put-value-if
  (lambda (p1 p2 value)
    (let ([x (car p1)]
          [y (cdr p1)]
          [xmax (car p2)]
          [ymax (cdr p2)])
          (if (infinit? x y xmax ymax)
            -1
            (+ value 1)))))

;if cell on border then area is infinite
(define infinit?
  (lambda (c r maxc maxr)
    (or (= c 0) (= r 0) (= c maxc) (= r maxr))))


(define data (read-input "input.txt"))
(define input-grid (make-grid data))
(define points (make-points data))
(time (get-distances points input-grid))
(time (largest-area input-grid))
(display (largest-area input-grid))
(exit)
