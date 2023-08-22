;; export index
(find-file "index.org")
(org-html-export-to-html)
(kill-buffer (current-buffer))
 
;; org to html helpers
(defun export-file (f)
  (save-excursion
    (find-file f)
    (org-html-export-to-html)
    (kill-buffer (current-buffer))))

(defun export-dir (d)
  (mapc 'export-file
	(directory-files d t ".org")))

;; export blogs
(export-dir "./blogs")
    







