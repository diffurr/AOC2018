#lang racket

(struct Record (id minute elapsed))

(define writeln
    (lambda (x)
        (write x)
        (newline)))

(define show-list
    (lambda (list)
        (if (null? list)
            null
            ((lambda () (writeln (car list))
                        (show-list (cdr list)))))))

(define show-records
    (lambda (list)
        (if (null? list)
            null
            ((lambda ()
                (display (Record-id (car list)))
                (display " ")
                (display (Record-minute (car list)))
                (newline)
                (show-records (cdr list))))
                )))

(define string-strip 
    (lambda (line)
        (letrec
            ((chars-list (string->list line))
             (strip (lambda (chars)
                (if (null? chars)
                    '()
                (if (eq? #\space (car chars))
                    (strip (cdr chars))
                    (cons (car chars)(strip (cdr chars))))))))
                (list->string(strip chars-list)))))

(define epoch
    (lambda (year month day hour minute)
        (define DAYS-IN-MON '(31 28 31 30 31 30 31 31 30 31 30 31))
        (define SEC-IN-YEAR 31557600)
        (define SEC-IN-DAY 86400)
        (define SEC-IN-HOUR 3600)
        (define sum-days
            (lambda (months m)
                (if (= m 0)
                    0
                    (+ (list-ref months m)(sum-days months (- m 1))))))
        (+ 0
            (* (- year 1900) SEC-IN-YEAR)     
            (* (sum-days DAYS-IN-MON (- month 1)) SEC-IN-DAY)
            (* day SEC-IN-DAY)
            (* hour SEC-IN-HOUR)
            (* minute 60))))

(define make-Record-from-string
    (lambda (line)
        (let* 
            ((year (string->number(substring line 1 5)))
            (month (string->number(substring line 6 8)))
            (day (string->number(substring line 9 11)))
            (hour (string->number(substring line 12 14)))
            (minute (string->number(substring line 15 17)))
            (id (if (> (string-length line) 35)
                    (string->number(string-strip(substring line 26 30)))
                    #f))
            (elapsed (epoch year month day hour minute)))
            (Record id minute elapsed))))

(define parse
    (lambda (file)
        (let read-lines ((line (read-line file)) (records '()))
            (if (eof-object? line)
                records
                (read-lines (read-line file) (cons (make-Record-from-string line) records))))))

(define mark-ttable
    (lambda (table begin end)
        (let iterate ([i begin])
            (if (= i end)
                table
                ((lambda () 
                    (vector-set! table i (+ 1 (vector-ref table i)))
                    (iterate (+ i 1))))))))

(define update
    (lambda (records)
    (define new-table
        (lambda (proc table id begin record)
            (let ([ttable (mark-ttable (make-vector 60 0) begin (Record-minute(car record)))])
                (proc (cons (cons id ttable) table) id -1 (cdr record)))))
    (define up-table
        (lambda (proc table id begin record)
            (let* ([pair (assq id table)]
                    [table-new (remove pair table)]
                    [ttable (mark-ttable (cdr pair) begin (Record-minute(car record)))])
            (proc (cons (cons id ttable) table-new) id -1 (cdr record)))))

        (let iterate ([table '()][id -1][begin -1][record records])
            (if (null? record)
                table
                (cond
                    [(Record-id (car record)) 
                        (iterate table (Record-id (car record)) begin (cdr record))]
                    [(< begin 0) 
                        (iterate table id (Record-minute (car record)) (cdr record))]
                    [else 
                        (if (assq id table)
                            (up-table iterate table id begin record)            
                            (new-table iterate table id begin record))])))))

(define answer
    (lambda (tables)
        (let ([bestid -1][bestfreq -1][bestminute -1])
            (for-each (lambda (pair)
                (let ([ttable (cdr pair)][size (vector-length (cdr pair))])
                    (let iter ([i 0])
                        (if (< i size) 
                            (if (> (vector-ref ttable i) bestfreq)
                                ((lambda ()
                                    (set! bestid (car pair))
                                    (set! bestfreq (vector-ref ttable i))
                                    (set! bestminute i)
                                    (iter (+ i 1))))
                                (iter (+ i 1)))
                                0))))
            tables)
            (* bestid bestminute))))

(define start 0.0)
(set! start (current-inexact-milliseconds))
(define records (parse (open-input-file "input.txt")))
(printf "parse:    ~a\n" (* (- (current-inexact-milliseconds) start) 1000.0))

(set! start (current-inexact-milliseconds))
(define sorted (sort records 
               (lambda (a b)(< (Record-elapsed a) (Record-elapsed b)))))
(printf "sort:     ~a\n" (* (- (current-inexact-milliseconds) start) 1000.0))

(set! start (current-inexact-milliseconds))
(define tables (update sorted))
(printf "update:   ~a\n" (* (- (current-inexact-milliseconds) start) 1000.0))

(set! start (current-inexact-milliseconds))
(define result (answer tables))
(printf "answer:   ~a\n" (* (- (current-inexact-milliseconds) start) 1000.0))
(write result)
(exit)