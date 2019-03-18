#!r6rs
(import (rnrs (6)))

;HELPER FUNCTIONS-----------------------------------------------------------
(define make-stack
  (lambda ()
    (let ([stack '()])
      (lambda (msg . args)
        (cond
          [(eq? msg 'push!) (set! stack (cons (car args) stack))]
          [(eq? msg 'pop!) (set! stack (cdr stack))]
          [(eq? msg 'top) (car stack)]
          [(eq? msg 'bottom) (list-ref stack (- (length stack) 1))]
          [(eq? msg 'list) stack]
          ['stack-oops-wrong-operation])))))
            
(define make-queue
  (lambda ()
    (let ([queue '()])
      (lambda (msg . args)
        (cond
          [(eq? msg 'enq!) (set! queue (append queue (cons (car args) '())))]
          [(eq? msg 'front) (car queue)]
          [(eq? msg 'deq!) (set! queue (cdr queue))]
          [(eq? msg 'empty?) (zero? (length queue))]
          [(eq? msg 'sort!) (set! queue (list-sort < queue))]
          [(eq? msg 'list) queue]
          ['queue-oops-wrong-operation])))))

(define make-pq-min
  (lambda ()
    (let ([pq '()])
      (lambda (msg . args)
        (cond
          [(eq? msg 'min) (car pq)]
          [(eq? msg 'enq!) (set! pq (list-sort < (cons (car args) pq)))]
          [(eq? msg 'remove-min!) (set! pq (cdr pq))]
          [(eq? msg 'empty?) (zero? (length pq))]
          [(eq? msg 'list) pq]
          ['pq-min-wrong-operation])))))

;-------------------------------------------------------------------------------
(define make-dag
  (lambda (n)
    (make-vector n '())))

(define add-edge
  (lambda (g v e)
    (let ([edges (vector-ref g v)])
      (vector-set! g v (cons e edges)))))

(define-record-type Input (fields (immutable nodes)
                                  (immutable num-nodes)))

(define read-input
  (lambda (filename)
    (define file (open-input-file filename))
    (let ([nodes (make-stack)])
      (let read-lines ([line (get-line file)]
                       [num-nodes 0])
        (if (eof-object? line)
            (make-Input (reverse (nodes 'list)) (+ 1 num-nodes))
            (let ([pair (parse-line line)])
              (nodes 'push! pair)
              (read-lines (get-line file)
                          (max num-nodes (car pair) (cdr pair)))))))))

(define parse-line
  (lambda (line)
    (let ([node (char->node (string-ref line 5))]
          [edge (char->node (string-ref line 36))])
      (cons node edge))))

(define char->node
  (lambda (char)
    (- (char->integer char) 65)))

(define node->char
  (lambda (node)
    (integer->char (+ node 65))))

(define nodes->string
  (lambda (nodes)
    (list->string (map node->char nodes))))

(define nodes-sort
  (lambda (g)
    (vector-map (lambda (nodes) (list-sort > nodes)) g)))

(define init-dag
  (lambda (input)
    (let ([dag (make-dag (Input-num-nodes input))])
      (let add-edges ([edges (Input-nodes input)])
        (if (null? edges)
            dag
            (let ([edge (car edges)])
              (add-edge dag (car edge) (cdr edge))
              (add-edges (cdr edges))))))))

(define add-indegree
  (lambda (indegree)
    (lambda (edge)
      (let ([count (vector-ref indegree (cdr edge))])
        (vector-set! indegree (cdr edge) (+ 1 count))))))

(define init-indegree
  (lambda (input)
    (let ([indegree (make-vector (Input-num-nodes input) 0)])
        (for-each (add-indegree indegree) (Input-nodes input))
        indegree)))

(define nodes-sort
  (lambda (g)
    (vector-map (lambda (nodes) (list-sort < nodes)) g)))

(define enq-zero-deg
  (lambda (indegree tsort)
    (let enq ([n 0])
      (if (< n (vector-length indegree))
        (begin
          (if (zero? (vector-ref indegree n))
              (tsort 'enq! n)
              #t)
          (enq (+ 1 n)))
        tsort))))
              
(define dequeue
  (lambda (queue)
    (let ([item (queue 'front)])
      (queue 'deq!)
      item)))

(define check-indeg
  (lambda (indegree tsort)
    (lambda (node)
      (let ([it (vector-ref indegree node)])
        (vector-set! indegree node (- it 1))
        (if (zero? (vector-ref indegree node))
            (tsort 'enq! node)
            #t)))))

(define topo-sort
  (lambda (g indegree)
    (let ([tsort (make-queue)]
          [sorted (make-stack)])
      (enq-zero-deg indegree tsort)
      (let tsort-loop ([tsort tsort][sorted sorted])
        (display (tsort 'list))
        (newline)
        (display (sorted 'list))
        (newline)
        (if (tsort 'empty?)
            (nodes->string (reverse (sorted 'list)))
            (begin
              (tsort 'sort!)
              (sorted 'push! (dequeue tsort))
              (for-each (check-indeg indegree tsort)  (vector-ref g (sorted 'top)))
              (tsort-loop tsort sorted)
             )
            )))))

(define schedule
  (lambda (g indegree workers)
    (let ([tsort (make-queue)]
          [sorted (make-stack)])
      (enq-zero-deg indegree tsort)
      (let tsort-loop ([tsort tsort][sorted sorted][total-time 0])
        (if (tsort 'empty?)
            total-time
            (begin
              (set! total-time (schedule-work tsort workers)) 
              (sorted 'push! (dequeue tsort))
              (for-each (check-indeg indegree tsort) (vector-ref g (sorted 'top)))
              (tsort-loop tsort sorted total-time)
             )
            )))))

(define get-answer
  (lambda (input)
    (let* ([dag (init-dag input)]
           [indegree (init-indegree input)]
           [answer (topo-sort dag indegree)])
           answer)))

(define get-answer-2
  (lambda (input workers)
    (let* ([dag (init-dag input)]
           [indegree (init-indegree input)]
           [answer (schedule dag indegree workers)])
           answer)))
