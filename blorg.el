(setq blogs-dir "./blogs")
(setq styles-dir "./styles")
(setq index-blurb "./blurb.org")
(setq index-title "Blorg")
(setq curr-dir (file-name-directory buffer-file-name))
      
(defun directory-files-rel (dir reg)
  (mapcar (lambda (x) (concat dir "/" x))
	  (directory-files dir nil reg)))

(defun directory-files-abs (dir reg)
  (mapcar (lambda (x) (concat (substring dir 1) "/" x))
	  (directory-files dir nil reg)))

(defun get-last-modified (f)
  (nth 5 (file-attributes f)))

(setq blorgs (directory-files-rel blogs-dir ".org$"))

(defun replace-org-html (s)
  (concat (substring s 0 -4) ".html"))

(defun concat-list (list)
  (let ((head (car list)))
    (if (not head)
	""
      (concat head (concat-list (cdr list))))))

(defun add-org-class (string class)
  (format "#+begin_%s
%s
#+end_%s" class string class))

;; make header with all styles in styles-dir

(defun make-style-head (file)
  (format "<link rel=\"stylesheet\" type=\"text/css\" href=\"%s\" />" file))

(setq org-html-head
      (concat-list (mapcar 'make-style-head (directory-files-abs styles-dir ".css$"))))

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

;; function to re-export all blogs e.g. if styling changes

(defun export-all-blogs ()
  (interactive)
  (mapcar 'export-file blorgs))

;; index

(setq index-head (format "#+OPTIONS: toc:nil num:nil
#+TITLE: %s
" index-title))

(setq list-format "
[[%s][%s]]
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
  (insert (add-org-class (make-blog-list blog-properties) "blorg-list"))
  (save-buffer)
  (org-html-export-to-html)
  (kill-buffer (current-buffer)))

(make-index)
