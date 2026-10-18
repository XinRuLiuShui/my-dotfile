;;; my-files.el --- Quick access to frequently used files/directories -*- lexical-binding: t; -*-

;; ==============================
;; 常用文件
;; ==============================

(defconst my-common-files
  '(("Emacs init" . "~/.emacs.d/init.el")
    ("Log highlight" . "~/.emacs.d/lisp/log-highlight.el")
    ("My files config" . "~/.emacs.d/lisp/my-files.el"))
  "Frequently used files.")


;; ==============================
;; 常用目录
;; ==============================

(defconst my-common-directories
  '(("Emacs config" . "~/.emacs.d/")
    ("Emacs lisp" . "~/.emacs.d/lisp/")
    ("stm32-asm" . "~/Projets/stm32_asm/")
    ;; ("STM32" . "D:/Projects/STM32/")
    ;; ("RK3506" . "D:/Projects/RK3506/")
    ;; ("Linux" . "D:/Projects/Linux/")
    )
  "Frequently used directories.")


;; ==============================
;; 打开常用文件
;; ==============================

(defun my-open-common-file ()
  "Open a frequently used file."
  (interactive)
  (let* ((choice (completing-read
                  "Open file: "
                  (mapcar #'car my-common-files)
                  nil
                  t))
         (file (cdr (assoc choice my-common-files))))
    (find-file (expand-file-name file))))


;; ==============================
;; 打开常用目录
;; ==============================

(defun my-open-common-directory ()
  "Open a frequently used directory."
  (interactive)
  (let* ((choice (completing-read
                  "Open directory: "
                  (mapcar #'car my-common-directories)
                  nil
                  t))
         (directory (cdr (assoc choice my-common-directories))))
    (dired (expand-file-name directory))))


;; ==============================
;; 快捷键
;; ==============================

(global-set-key (kbd "C-c o f") #'my-open-common-file)
(global-set-key (kbd "C-c o d") #'my-open-common-directory)


(provide 'my-files)
