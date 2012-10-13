;;
;;  lowh-facts  -  facts database
;;
;;  Copyright 2011,2012 Thomas de Grivel <billitch@gmail.com>
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

(in-package :lowh-facts)

;;  Facts ordering

(defun lessp/3 (a1 a2 a3 b1 b2 b3)
  (or (lessp a1 b1)
      (and (not (lessp b1 a1))
	   (or (lessp a2 b2)
	       (and (not (lessp b2 a2))
		    (lessp a3 b3))))))

(defun fact-spo-lessp (a b)
  (lessp/3 (fact-subject a) (fact-predicate a) (fact-object a)
           (fact-subject b) (fact-predicate b) (fact-object b)))

(defun fact-pos-lessp (a b)
  (lessp/3 (fact-predicate a) (fact-object a) (fact-subject a)
           (fact-predicate b) (fact-object b) (fact-subject b)))

(defun fact-osp-lessp (a b)
  (lessp/3 (fact-object a) (fact-subject a) (fact-predicate a)
           (fact-object b) (fact-subject b) (fact-predicate b)))

;;  Index operations

(defun index-get (index fact)
  (declare (type fact/v fact))
  (llrbtree:tree-get fact index))

(defun index-insert (index fact)
  (declare (type fact/v fact))
  (setf (llrbtree:tree-get fact index) fact)
  (define-rollback index-insert
    (index-delete index fact)))

(defun index-delete (index fact)
  (declare (type fact/v fact))
  (llrbtree:tree-delete fact index)
  (define-rollback index-delete
    (index-insert index fact)))