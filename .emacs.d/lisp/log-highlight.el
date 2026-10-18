;;; log-highlight.el --- Log highlighting -*- lexical-binding: t; -*-

;; ==============================
;; 定义 face
;; ==============================

(defface my-log-sending-face
  '((t))
  "Face for sending.")

(defface my-log-receive-face
  '((t))
  "Face for receive.")

(defface my-log-error-face
  '((t))
  "Face for error.")

(defface my-log-success-face
  '((t))
  "Face for success.")

(defface my-log-item-face
  '((t))
  "Face for item.")


;; ==============================
;; 设置颜色
;; ==============================

(set-face-attribute 'my-log-sending-face nil
                    :foreground "#000000"
                    :background "#1E90FF"
                    :weight 'bold)

(set-face-attribute 'my-log-receive-face nil
                    :foreground "#000000"
                    :background "#FFC0CB"
                    :weight 'bold)

(set-face-attribute 'my-log-error-face nil
                    :foreground "#000000"
                    :background "#E53935"
                    :weight 'bold)

(set-face-attribute 'my-log-success-face nil
                    :foreground "#000000"
                    :background "#2E7D32"
                    :weight 'bold)

(set-face-attribute 'my-log-item-face nil
                    :foreground "#000000"
                    :background "#E1BEE7"
                    :weight 'bold)

;; ==============================
;; .log 文件高亮
;; ==============================

(defun my-log-highlight ()
  "Highlight keywords in log files."
  (when (and buffer-file-name
             (string-match-p "\\.log\\'" buffer-file-name))

    ;; .log 文件不自动换行
    (setq-local truncate-lines t)
    
    (font-lock-add-keywords
     nil
     '(("\\_<sending\\_>" (0 'my-log-sending-face))
       ("\\_<received\\_>" (0 'my-log-receive-face))
       ("\\_<FAIL\\_>"   (0 'my-log-error-face))
       ("\\_<PASS\\_>" (0 'my-log-success-face))
       ("\\_<item\\_>"    (0 'my-log-item-face)))
     'append)

    ;; 重新进行语法高亮
    (font-lock-flush)
    (font-lock-ensure)))


;; ==============================
;; 打开 .log 文件时执行
;; ==============================

(add-hook 'find-file-hook #'my-log-highlight)

;; ==============================
;; 横向滚动条
;; ==============================

(defun my-log-horizontal-scroll-bar ()
  "Show horizontal scrollbar only for .log files."
  (if (and buffer-file-name
           (string-match-p "\\.log\\'" buffer-file-name))
      (horizontal-scroll-bar-mode 1)
    (horizontal-scroll-bar-mode -1)))

(add-hook 'buffer-list-update-hook #'my-log-horizontal-scroll-bar)

(provide 'log-highlight)
