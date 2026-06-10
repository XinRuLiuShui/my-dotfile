(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(setq package-archives '(("gnu"    . "https://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
                         ("nongnu" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/nongnu/")
                         ("melpa"  . "https://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")))

(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)

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

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages '(avy company lsp-ui magit modus-themes)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; 开启全局行号模式（在所有编程文件中显示行号）
(global-display-line-numbers-mode t)

;; 可选：设置行号显示为相对行号（当前行为0，上下递增）
(setq display-line-numbers-type 'relative) ; 'relative 为相对行号，nil 为绝对行号

;; ============================================================
;; 5. C语言补全（Company + Eglot）
;; ============================================================

;; 5.1 安装并配置 Company（补全弹出框）
(unless (package-installed-p 'company)
  (package-install 'company))
(require 'company)
(global-company-mode)                    ;; 全局启用
(setq company-idle-delay 0.2)            ;; 输入后0.2秒弹出
(setq company-minimum-prefix-length 2)   ;; 输入2个字符开始补全

;; 5.2 使用 Eglot（Emacs 29+ 内置，LSP 客户端）
;; 如果你用的是 Emacs 28 或更早，取消下面一行的注释
;; (unless (package-installed-p 'eglot) (package-install 'eglot))

(require 'eglot nil t)                   ;; 加载 eglot（如果存在）

;; 5.3 当打开 C/C++ 文件时自动启动 LSP
;; clangd 需要先安装：sudo apt install clangd (Ubuntu) / brew install llvm (macOS)
(when (fboundp 'eglot-ensure)
  (add-hook 'c-mode-hook 'eglot-ensure)
  (add-hook 'c++-mode-hook 'eglot-ensure))

;; 5.4 配置 Company 使用 Eglot 的补全源
(defun my-c-mode-company-setup ()
  "设置 C 语言模式下 company 的补全后端"
  (setq-local company-backends
              '((company-capf    ; LSP 补全（eglot 提供）
                 company-dabbrev-code  ; 代码中的单词补全
                 company-yasnippet))))  ; 代码片段补全

(add-hook 'c-mode-hook 'my-c-mode-company-setup)
(add-hook 'c++-mode-hook 'my-c-mode-company-setup)

;; 5.5 在 C 语言模式下自动插入括号/引号
(electric-pair-mode 1)

;; 5.6 保存时自动删除行尾空格
(add-hook 'c-mode-hook
          (lambda () (add-hook 'before-save-hook 'delete-trailing-whitespace nil t)))
(add-hook 'c++-mode-hook
          (lambda () (add-hook 'before-save-hook 'delete-trailing-whitespace nil t)))

;; ============================================================
;; 6. C语言代码格式化（缩进风格）
;; ============================================================
(setq-default c-basic-offset 4)
(setq-default indent-tabs-mode nil)  ;; 使用空格代替 Tab

;; 直接设置，不通过函数
(set-face-attribute 'default nil :font "JetBrains Mono-18")

;; 快速跳转到任意字符
;;(global-set-key (kbd "C-:") 'avy-goto-char);; 快速跳转到任意字符
;;
;;(global-set-key (kbd "M-g w") 'avy-goto-word-1)
;;
;;(global-set-key (kbd "M-g f") 'avy-goto-line)

;; 使用 use-package（现代 Emacs 配置标准）
(use-package avy
  :ensure t
  :defer t  ; 延迟加载，提升启动速度
  :bind (("C-:" . avy-goto-char)
         ("M-g w" . avy-goto-word-1)
         ("M-g f" . avy-goto-line))
)
