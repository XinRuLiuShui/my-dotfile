;;; my-search.el --- Windows 原生检索快捷键 -*- lexical-binding: t; -*-

;;; Commentary:
;; 基于 findstr / where 的文件与关键词检索，适用于 Windows。
;; 快捷键：
;;   C-c g  当前目录搜内容
;;   C-c G  选目录搜内容
;;   C-c f  当前目录找文件
;;   C-c F  选目录找文件

;;; Code:

(defun my/findstr-current-dir (pattern)
  "在当前目录下用 findstr 递归搜索 PATTERN（忽略大小写，显示行号）。"
  (interactive "s搜索关键词: ")
  (grep (format "findstr /s /n /i /c:%s *.*"
                (shell-quote-argument pattern))))

(defun my/findstr-in-dir (dir pattern)
  "在 DIR 下用 findstr 递归搜索 PATTERN。"
  (interactive
   (list (read-directory-name "搜索目录: " nil nil t)
         (read-string "搜索关键词: ")))
  (let ((default-directory (file-name-as-directory (expand-file-name dir))))
    (grep (format "findstr /s /n /i /c:%s *.*"
                  (shell-quote-argument pattern)))))

(defun my/where-current-dir (filename)
  "在当前目录下用 where 递归查找匹配 FILENAME 的文件。
FILENAME 支持通配符，例如 main.c、*.dts、*.h。"
  (interactive "s文件名（支持通配符）: ")
  (grep (format "where /r . %s" filename)))

(defun my/where-in-dir (dir filename)
  "在 DIR 下用 where 递归查找匹配 FILENAME 的文件。"
  (interactive
   (list (read-directory-name "搜索目录: " nil nil t)
         (read-string "文件名（支持通配符）: ")))
  (let ((default-directory (file-name-as-directory (expand-file-name dir))))
    (grep (format "where /r . %s" filename))))

(global-set-key (kbd "C-c g") #'my/findstr-current-dir)
(global-set-key (kbd "C-c G") #'my/findstr-in-dir)
(global-set-key (kbd "C-c f") #'my/where-current-dir)
(global-set-key (kbd "C-c F") #'my/where-in-dir)

(provide 'my-search)
;;; my-search.el ends here
