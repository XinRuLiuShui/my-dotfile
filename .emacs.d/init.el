(setq custom-file (expand-file-name "~/.emacs.custom.el"))
(load custom-file 'noerror)

(setq package-archives '(("gnu"    . "https://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
                         ("nongnu" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/nongnu/")
                         ("melpa"  . "https://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)

(setq make-backup-files nil)

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(global-tab-line-mode 1)

(electric-pair-mode 1)
(electric-indent-mode -1)

(global-display-line-numbers-mode t)

(set-face-attribute 'default nil :font "JetBrains Mono-12")


(add-to-list 'load-path (expand-file-name "themes" user-emacs-directory))
(add-to-list 'custom-theme-load-path (expand-file-name "themes" user-emacs-directory))
(load-theme 'gruvbox-dark-soft t)

;; 如果写配置安装不上的话，就用package-install安装
(use-package autothemer
  :ensure t)

(use-package ace-window
  :ensure t
  :bind (("M-o" . ace-window)))


;; avy配置
(use-package avy
  :ensure t
  :defer t  ; 延迟加载，提升启动速度
  :bind (("C-:" . avy-goto-char)
         ("M-g w" . avy-goto-word-1)
         ("M-g f" . avy-goto-line))
  )

(use-package consult
  :ensure t
  :bind (("C-x b" . consult-buffer)
	 ("C-c r" . consult-ripgrep)
         )
  )


;; 把 lisp 目录加入 load-path
(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

;; 加载自定义检索
(require 'my-search)

(require 'my-files)
