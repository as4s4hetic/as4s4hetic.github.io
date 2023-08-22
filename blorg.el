;; export index
(find-file "index.org")
(org-html-export-to-html)
(kill-buffer (current-buffer))
 
;; export blogs
(defun export-blog (f)
  (save-excursion
    (find-file f)
    (org-html-export-to-html)
    (kill-buffer (current-buffer))))

(defun export-blogs (d)
  (mapc 'export-blog
	(directory-files d t ".org")))

(export-blogs "./blogs")
    







