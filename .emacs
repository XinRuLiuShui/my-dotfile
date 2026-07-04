(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(setq package-archives '(("gnu"    . "https://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
                         ("nongnu" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/nongnu/")
                         ("melpa"  . "https://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")))

;(require 'package)
;(add-to-list 'package-archives
;             '("melpa" . "https://melpa.org/packages/") t)

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
 '(package-selected-packages nil))
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
  (add-hook 'python-mode-hook 'eglot-ensure)

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

(add-hook 'python-mode-hook (lambda () (electric-pair-mode 1)))
;; ============================================================
;; 6. C语言代码格式化（缩进风格）
;; ============================================================
(setq-default c-basic-offset 4)
(setq-default indent-tabs-mode nil)  ;; 使用空格代替 Tab

;; ============================================================
;; 7. Python 补全（基于已有的 Company + Eglot）
;; ============================================================

;; 7.1 打开 Python 文件时自动启动 LSP 客户端 (eglot)
;; 前提：已安装 Python 语言服务器（推荐 python3-pylsp）
(add-hook 'python-mode-hook 'eglot-ensure)

;; 7.2 设置 Python 模式下的 company 补全后端（与 C/C++ 类似）
(defun my-python-mode-company-setup ()
  "设置 Python 模式下 company 的补全后端"
  (setq-local company-backends
              '((company-capf       ; LSP 补全（eglot 提供）
                 company-dabbrev-code ; 代码中的单词补全
                 company-yasnippet)))) ; 代码片段补全（如已安装）

(add-hook 'python-mode-hook 'my-python-mode-company-setup)

;; 7.3 （可选）Python 特定的代码格式化：使用 black 或 autopep8
;; 这需要额外安装对应的格式化工具，并通过 eglot 或单独配置实现
;; 如果不想配置，Emacs 默认的 indent 也能工作


;; 设置字体
(set-face-attribute 'default nil :font "JetBrains Mono-18")
;;(set-face-attribute 'default nil :font "IBM Plex Mono-regular-italic-18")
;;(set-face-attribute 'default nil :font (font-spec :family "IBMPlexMono" :size 26 :weight 'Regular :slant 'italic))
;;(set-face-attribute 'default nil :font (font-spec :family "IBMPlexMono" :size 26 :weight 'Regular ))

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
