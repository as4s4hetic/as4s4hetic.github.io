(setq blogs-dir "./blogs")
(setq index-blurb "./blurb.org")
(setq org-html-head "<link rel=\"stylesheet\" type=\"text/css\" href=\"/styles/zenburn.css\" />")

(defun directory-files-rel (dir reg)
  (mapcar (lambda (x) (concat dir "/" x))
	  (directory-files dir nil reg)))

(defun get-last-modified (f)
  (nth 5 (file-attributes f)))

(setq blorgs (directory-files-rel blogs-dir ".org$"))

(defun replace-org-html (s)
  (concat (substring s 0 -4) ".html"))

;; export blogs

(defun export-file (f)
  (save-excursion
    (find-file f)
    (org-html-export-to-html)
    (kill-buffer (current-buffer))))

(defun updated-p (f)
  (let ((html-file (replace-org-html f)))
    (if (not (file-exists-p html-file))
	t
      (let ((org-last-updated (get-last-modified f))
	    (html-last-updated (get-last-modified html-file)))
	(time-less-p html-last-updated org-last-updated )))))	

(defun export-blogs (blog-list)
  (while blog-list
    (let ((blog (car blog-list)))
      (if (updated-p blog)
	  (export-file blog)
	nil))
    (setq blog-list (cdr blog-list))))

(export-blogs blorgs)

;; index

(setq index-head "#+OPTIONS: toc:nil num:nil
#+TITLE: Blorg
")
(setq list-format "
* [[%s][%s]]
%s
%s")

(defun org-title (f)
  (save-excursion
    (find-file f)
    (setq title (cadar (org-collect-keywords '("title"))))
    (kill-buffer (current-buffer)))
  title)

(defun org-date (f)
  (save-excursion
    (find-file f)
    (setq date (substring 
		(cadar (org-collect-keywords '("date")))
		1 -5))
    (kill-buffer (current-buffer)))
  date)

;; sort blogs by date created

(setq blog-properties (mapcar (lambda (x) (list
					   (replace-org-html x)
					   (org-title x)
					   (org-date x)))
			      blorgs))

(defun blog> (x y)
  (string> (caddr x) (caddr y)))
  
(defun sort-blogs (blogs)
  (sort blogs 'blog>))

(setq blog-properties (sort-blogs blog-properties))

(defun make-blog-list (l)
  (if (not l)
      ""
    (let ((blog (car l)))
      (format list-format
	      (car blog)
	      (cadr blog)
	      (caddr blog)
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
  (insert (make-blog-list blog-properties))
  (save-buffer)
  (org-html-export-to-html)
  (kill-buffer (current-buffer)))

(make-index)
