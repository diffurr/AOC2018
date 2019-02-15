#!r6rs
(import (rnrs (6)))

;immutable list version

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
                                (immutable id)))

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
                  (let ([cord (cons x y)][id 0])
                    (j (+ x 1) (cons (make-Loc cord id) locs)))
                  (i (+ y 1) locs)))
              (make-Grid locs xmax ymax))))))

;make points from input
(define make-points
  (lambda (data)
    (Input-coords data)))

(define sum-distances
  (lambda (points grid maxsum)
    (make-Grid (map (sum-dist points maxsum) (Grid-locs grid)) (Grid-xmax grid) (Grid-ymax grid))))

(define sum-dist
  (lambda (points maxsum)
    (lambda (loc)
      (let for-each-point ([points points][sum 0])
        (cond
          [(and (null? points) (< sum maxsum)) (make-Loc (Loc-cord loc) 1)]
          [(or (null? points) (>= sum maxsum)) (make-Loc (Loc-cord loc) 0)]
          [else (for-each-point (cdr points) (+ (manhattan (car points) (Loc-cord loc)) sum))])))))

(define manhattan
  (lambda (p1 p2)
    (let ([p1x (car p1)][p1y (cdr p1)]
          [p2x (car p2)][p2y (cdr p2)])
          (+ (abs (- p1x p2x))
             (abs (- p1y p2y))))))

(define get-region-size
  (lambda (grid)
    (fold-left (lambda (size loc) (+ size (Loc-id loc))) 0 (Grid-locs grid))))


(define data (read-input "input.txt"))
(define input-grid (make-grid data))
(define points (make-points data))
(time (get-region-size (sum-distances points input-grid 10000)))
(display (get-region-size (sum-distances points input-grid 10000)))
(exit)
