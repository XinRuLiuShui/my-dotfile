(setq custom-file (expand-file-name "~/.emacs.custom.el"))
(load custom-file 'noerror)

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(setq package-archives '(("gnu"    . "https://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
                         ("nongnu" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/nongnu/")
                         ("melpa"  . "https://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")))


(package-initialize) ;; You might already have this line
(unless package-archive-contents
  (package-refresh-contents))

;; 使用 use-package 管理插件（现代 Emacs 推荐方式）
(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)

;; 安装并加载 modus-themes
(use-package modus-themes
  :ensure t
  :config
  ;; 启用亮色主题，如果想用暗色改为 'modus-vivendi
  ;;(load-theme 'modus-operandi t))
  (load-theme 'modus-vivendi t))

;; YASnippet - 代码片段展开
;; YASnippet 默认就是用 Tab 触发的
(use-package yasnippet
  :ensure t
  :config
  (setq yas-snippet-dirs '("~/.emacs.snippets/"))  ;; 告诉 YASnippet 去哪里找代码片段
  (yas-global-mode 1))                              ;; 全局开启


;; 开启全局行号模式（在所有编程文件中显示行号）
(global-display-line-numbers-mode t)

(use-package company
  :ensure t
  :config
  (global-company-mode)
  (setq company-idle-delay 0.3)
  (setq company-minimum-prefix-length 1)
  (setq company-dabbrev-downcase nil))

;;(defun my-company-setup ()
;;  "设置 company 的补全后端，不用 LSP，纯文本匹配 + 代码片段"
;;  (setq-local company-backends
;;              '((company-dabbrev-code    ;; 代码中的单词补全
;;                 company-dabbrev         ;; 当前 buffer 中的单词补全
;;                 company-yasnippet       ;; 代码片段补全
;;                 company-files           ;; 文件路径补全
;;                 company-keywords))))    ;; 语言关键字补全
;;
;;(add-hook 'c-mode-hook 'my-company-setup)
;;(add-hook 'python-mode-hook 'my-company-setup)


(electric-pair-mode 1)

(setq-default c-basic-offset 4
              indent-tabs-mode nil)


;; 设置字体
(set-face-attribute 'default nil :font "JetBrains Mono-18")

;; avy配置
(use-package avy
  :ensure t
  :defer t  ; 延迟加载，提升启动速度
  :bind (("C-:" . avy-goto-char)
         ("M-g w" . avy-goto-word-1)
         ("M-g f" . avy-goto-line))
)

(setq inhibit-splash-screen t)
(setq make-backup-files nil)

(use-package ace-window
  :ensure t
  :bind (("M-o" . ace-window)))

(use-package consult
  :ensure t
  :bind (("C-x b" . consult-buffer)
         )
  )


;; ============================================================
;; Multiple Cursors — 多光标编辑
;; ============================================================
(use-package multiple-cursors
  :ensure t
  :bind (("C-S-c C-S-c" . mc/edit-lines)
         ("C->"         . mc/mark-next-like-this)
         ("C-<"         . mc/mark-previous-like-this)
         ("C-c C-<"     . mc/mark-all-like-this)
         ("C-}"        . mc/skip-to-next-like-this)
         ("C-{"         . mc/skip-to-previous-like-this)))

;; ============================================================
;; Move Text — 移动整行
;; ============================================================
(use-package move-text
  :ensure t
  :bind (("M-p" . move-text-up)
         ("M-n" . move-text-down)))

;; ============================================================
;; 保存时自动删除行尾空格（给常用语言加上）
;; ============================================================
(defun my/delete-trailing-whitespace-on-save ()
  (whitespace-mode 1)             ;; 高亮显示多余空格
  "保存文件时自动删除行尾多余空格"
  (add-hook 'before-save-hook 'delete-trailing-whitespace nil 'make-it-local))

(add-hook 'c-mode-hook 'my/delete-trailing-whitespace-on-save)
(add-hook 'c++-mode-hook 'my/delete-trailing-whitespace-on-save)
(add-hook 'python-mode-hook 'my/delete-trailing-whitespace-on-save)
(add-hook 'emacs-lisp-mode-hook 'my/delete-trailing-whitespace-on-save)
