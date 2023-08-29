(defvar blogs-dir "./blogs")
(defvar index-blurb "./blurb.org")
(setq org-html-head "<link rel=\"stylesheet\" type=\"text/css\" href=\"/styles/zenburn.css\" />")

(defun directory-files-rel (dir reg)
  (mapcar (lambda (x) (concat dir "/" x))
	  (directory-files dir nil reg)))

(setq blorgs (directory-files-rel blogs-dir ".org$"))

;; export blogs

(defun export-file (f)
  (save-excursion
    (find-file f)
    (org-html-export-to-html)
    (kill-buffer (current-buffer))))

(mapc 'export-file blorgs)

;; make index

(defvar index-head "#+OPTIONS: toc:nil
#+TITLE: Blorg
")
(defvar list-format "- [[%s][%s]]
%s")

(defun org-title (f)
  (save-excursion
    (find-file f)
    (setq title (cadar (org-collect-keywords '("title"))))
    (kill-buffer (current-buffer)))
  title)

(defun make-blog-list (l)
  (if (not l)
      ""
    (let (file (car l))
      (format list-format
	      (concat (substring (car l) 0 -4) ".html")
	      (org-title (car l))
              (make-blog-list (cdr l))))))

(defun insert-file-as-string (f)
  (insert 
   (if (file-exists-p f)
       (with-temp-buffer
	 (insert-file-contents f)
	 (buffer-string))
     "")))

(defun make-index ()
  (find-file "index.org")
  (erase-buffer)
  (insert index-head)
  (insert-file-as-string index-blurb)
  (insert (make-blog-list blorgs))
  (save-buffer)
  (org-html-export-to-html)
  (kill-buffer (current-buffer)))

(make-index)
