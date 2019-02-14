#!r6rs
(import (rnrs (6)))

;DATA FLOW
;data-file --> (read-input) --> Info --> (make-arena) --> arena 
;                               Info --> (make-points) --> points 
;for each point in points: (we mutate arena)
;point --> (crawl) --> arena
;arena -->
;id -->
;
;arena --> (largest-area?) --> answer:)

;arena = mutable 2d array of cells
;points = vector of points
;cell = (id of point . dist to point)
;point = (x . y)

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

;array = vector of elems
;cols and rows = columns and rows of course;)
(define-record-type Array2D (fields vec
                            (immutable cols) 
                            (immutable rows)))

;c,r = columns and rows
;item = item to initialize
(define make-array-2d
  (lambda (c r item)
    (make-Array2D (make-vector (* c r) item) c r)))

;return # of columns
(define array-2d-cols
  (lambda (array)
    (Array2D-cols array)))

;return # of rows
(define array-2d-rows
  (lambda (array)
    (Array2D-rows array)))

(define array-2d-ref
  (lambda (array c r)
    (let ([index (+ (* r (Array2D-cols array)) c)])
      (vector-ref (Array2D-vec array) index))))

(define array-2d-set!
  (lambda (array c r item)
    (let ([index (+ (* r (Array2D-cols array)) c)])
      (vector-set! (Array2D-vec array) index item))))
;-------------------------------------------------------------------
;parsed information from data file
;coords - coordinates, list of pairs of numbers
;xdim - max x coordinate
;ydim - max y coordinate
(define-record-type Input (fields (immutable coords)
                                  (immutable xdim) 
                                  (immutable ydim)))

(define display-arena
  (lambda (arena)
    (define rows (array-2d-rows arena))
    (define cols (array-2d-cols arena))
    (let iterate-row ([r 0])
      (newline)
      (if (< r rows)
        (let iterate-col ([c 0])
          (if (< c cols)
            ((lambda ()
              (display (car (array-2d-ref arena c r)))
              (display " ")
              (iterate-col (+ c 1))))
            (iterate-row (+ r 1))))))))

(define crawl
  (lambda (arena point id)
    (define rows (array-2d-rows arena))
    (define cols (array-2d-cols arena))
    ;(array-2d-set! arena (car point) (cdr point) (cons id 0))
    (let iterate-row ([r 0])
      (if (< r rows)
      (let iterate-col ([c 0])
        (if (< c cols)
          ((lambda ()
            (let ([cell (array-2d-ref arena c r)])
              (when (not (eq? id (car cell)))
                (let ([dist (manhattan (cons c r) point)]
                      [cell-dist (cdr cell)])
                  (cond 
                    [(< dist cell-dist) (array-2d-set! arena c r (cons id dist))]
                    [(= dist cell-dist) (array-2d-set! arena c r (cons -1 dist))]
                    [else 'do-nothing])))
            (iterate-col (+ c 1)))))
          (iterate-row (+ r 1)))))
      arena)))

;mark distances for each point on arena
(define mark-arena 
  (lambda (arena points)
    (let ([points-len (vector-length points)])
      (let foreach ([i 0])
        (if (< i points-len)
          ((lambda ()
            (crawl arena (vector-ref points i) i)
            (foreach (+ i 1))))
          arena)))))

;calculate manhattan distance
(define manhattan
  (lambda (p1 p2)
    (let ([p1x (car p1)][p1y (cdr p1)]
          [p2x (car p2)][p2y (cdr p2)])
          (+ (abs (- p1x p2x))
             (abs (- p1y p2y))))))

(define largest-area
  (lambda (arena)
    (define rows (array-2d-rows arena))
    (define cols (array-2d-cols arena))
    (define htable (make-eqv-hashtable 100))
    (let iterate-row ([r 0])
      (if (< r rows)
        (let iterate-col ([c 0])
          (if (< c cols)
            ((lambda ()
              (let ([id (car (array-2d-ref arena c r))])
                (cond 
                  [(= id -1) (iterate-col (+ c 1))]
                  [else (add-to-table htable iterate-col c r cols rows id)]
                  ))))
            (iterate-row (+ r 1))
          )
        )
        (let ([answer (call-with-values (lambda () (hashtable-entries htable))
         (lambda (keys values) (vector-sort > values)))])
        (vector-ref answer 0))))))

(define add-to-table
  (lambda (htable proc c r cols rows id)
    (define maxc (- cols 1))
    (define maxr (- rows 1))
   (if (hashtable-contains? htable id)
    (when (not (= -1 (hashtable-ref htable id 'nil)))
    (cond 
      [(infinit? c r maxc maxr) (hashtable-set! htable id -1)]
      [else (let ([val (hashtable-ref htable id 'nil)])
              (hashtable-set! htable id (+ val 1)))]))
    (hashtable-set! htable id (if (infinit? c r maxc maxr ) -1 1)))
    (proc (+ 1 c))))

;if cell on border then area is infinite
(define infinit?
  (lambda (c r maxc maxr)
    (or (= c 0) (= r 0) (= c maxc) (= r maxr))))

;create 2d array of cells based on dimensions in info-record
(define make-arena
  (lambda (input)
    (make-array-2d (+ (Input-xdim input) 1)
                   (+ (Input-ydim input) 1)
                   (cons -1  (greatest-fixnum)))))

(define make-points
  (lambda (info)
    (list->vector (Input-coords info))))

;create pair of numbers from string
(define parse-line
  (lambda (line)
    (let* ([numbers (string-split line #\,)]
            [fst (string->number(string-strip(car numbers)))]
            [sec (string->number(string-strip(cadr numbers)))])
            (cons fst sec))))

;parse data file and create Input record
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

(define data (read-input "input.txt"))
(define arena (make-arena data))
(define points (make-points data))
(time (mark-arena arena points))
(time (largest-area arena))
(display (largest-area arena))
(exit)