;;
;;  facts - in-memory graph database
;;
;;  Copyright 2011-2014 Thomas de Grivel <thomas@lowh.net>
;;
;;  Permission to use, copy, modify, and distribute this software for any
;;  purpose with or without fee is hereby granted, provided that the above
;;  copyright notice and this permission notice appear in all copies.
;;
;;  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
;;  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
;;  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
;;  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
;;  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
;;  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
;;  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
;;

(in-package :facts)

(defmethod print-object ((x simple-base-string) s)
  (format s "#.(coerce ~S 'simple-base-string)" (coerce x 'simple-string)))

(defun save-db (&key into (readably t))
  (etypecase into
    ((or string pathname) (with-open-file (stream into
						  :direction :output
						  :if-exists :supersede
						  :if-does-not-exist :create
						  :element-type 'character
						  :external-format :utf-8)
			    (save-db :into stream :readably readably)))
    (null (with-output-to-string (stream) (save-db :into stream :readably readably)))
    (stream (let ((*print-readably* readably))
	      (format into "(~%")
	      (with ((?s ?p ?o))
		(let ((*print-case* :downcase)
                      (*print-pretty* nil))
		  (format into " (~S ~S ~S)~%" ?s ?p ?o))))
	    (format into ")~%")
	    (force-output into))))

(defun load-db (src)
  (etypecase src
    (string (with-input-from-string (stream src) (load-db stream)))
    (pathname (with-open-file (stream src
				      :element-type 'character
				      :external-format :utf-8)
		(load-db stream)))
    (stream (load-db (read src)))
    (list (mapcar (lambda (fact)
		    (apply #'db-insert fact))
		  src))))
