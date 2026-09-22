;;; emacs-programming-extra.el --- 编程常用功能 + 自定义快捷键（纯内置实现） -*- lexical-binding: t; -*-

;; ============================================================================
;; 这是什么？
;;   一份面向"用 Emacs 写代码"的自定义配置。每个按键背后都是一个 Lisp 函数，
;;   函数名都以 my- 开头，方便你读懂、修改、扩展。
;;
;; 怎么用？
;;   方式一（简单）：在 init.el 末尾追加一行：
;;     (load-file "~/.emacs.d/emacs-programming-extra.el")
;;   方式二（推荐）：放到 ~/.emacs.d/lisp/ 下，再在 init.el 里：
;;     (add-to-list 'load-path "~/.emacs.d/lisp")
;;     (require 'emacs-programming-extra)
;;   然后 M-x eval-buffer 立即生效，或重启 Emacs。
;;
;; 按键方案：
;;   所有自定义功能集中在一个前缀键表下：   C-c p <字母>
;;   p 表示 "personal / programming"。若某模式下 C-c p 与其它包冲突，
;;   把最后一行 global-set-key 的 "C-c p" 改成 "C-c x" 之类的即可。
;; ============================================================================

;; ---------------------------------------------------------------------------
;; 〇、基础开关
;; ---------------------------------------------------------------------------

;; 剪切/复制与系统剪贴板互通（GUI 下默认已通；终端下需 xclip/xsel，见文末说明）
(setq select-enable-clipboard t)
;; 所有"是否继续？"的提问只按 y/n 一次即可，不用 yes/no
(fset 'yes-or-no-p 'y-or-n-p)
;; 打开文件时自动跟随系统行尾/编码，避免跨平台切来切去
(setq-default buffer-file-coding-system 'utf-8-unix)

;; ---------------------------------------------------------------------------
;; 一、行操作
;; ---------------------------------------------------------------------------

(defun my-line-up ()
  "把当前行上移一行。"
  (interactive)
  (condition-case nil
      (transpose-lines -1)
    (error (message "已在第一行"))))

(defun my-line-down ()
  "把当前行下移一行。"
  (interactive)
  (condition-case nil
      (transpose-lines 1)
    (error (message "已在最后一行"))))

(defun my-duplicate-line-or-region ()
  "复制当前行（含换行）到其下方；若有选区则复制选区内容紧跟在选区后。"
  (interactive)
  (if (use-region-p)
      (let ((text (buffer-substring (region-beginning) (region-end))))
        (save-excursion (goto-char (region-end)) (insert text)))
    (let* ((begin (line-beginning-position))
           (end   (line-end-position))
           (text  (buffer-substring begin end)))
      (save-excursion
        (goto-char end)
        (newline)
        (insert text)))))

(defun my-open-line-below ()
  "在光标所在行的下方开一个新空行（像其它编辑器 Ctrl+Enter）。"
  (interactive)
  (end-of-line)
  (newline-and-indent))

(defun my-open-line-above ()
  "在光标所在行的上方开一个新空行，光标停在空行上。"
  (interactive)
  (beginning-of-line)
  (newline)
  (indent-according-to-mode))

(defun my-smart-beginning-of-line ()
  "智能回到行首：第一下跳到第一个非空白字符，再按一下才到真正的行首。
   习惯后比纯 C-a 好用（对应很多编辑器里的 Home 键智能模式）。"
  (interactive)
  (let ((pos (point)))
    (back-to-indentation)
    (when (= pos (point))
      (move-beginning-of-line 1))))

;; ---------------------------------------------------------------------------
;; 二、注释 / 缩进 / 空白
;; ---------------------------------------------------------------------------

(defun my-comment-line-or-region ()
  "注释或取消注释当前行；有选区时对整个选区生效。"
  (interactive)
  (if (fboundp 'comment-line)              ; Emacs 26+ 内置
      (comment-line 1)
    (if (use-region-p)
        (comment-or-uncomment-region (region-beginning) (region-end))
      (comment-dwim nil))))

(defun my-indent-buffer ()
  "按当前语言的缩进规则重排整个文件。"
  (interactive)
  (let ((beg (point-min))
        (end (point-max)))
    (save-excursion (indent-region beg end nil))
    (message "已重排整个缓冲区")))

(defun my-trim-trailing-whitespace ()
  "删除整个文件的行尾多余空格/Tab。"
  (interactive)
  (save-excursion (delete-trailing-whitespace (point-min) (point-max)))
  (message "已清理行尾空白"))

;; ---------------------------------------------------------------------------
;; 三、文件路径 / 日期
;; ---------------------------------------------------------------------------

(defun my-copy-file-path ()
  "复制当前文件的绝对路径到系统剪贴板。"
  (interactive)
  (let ((f (buffer-file-name)))
    (if f
        (let ((p (expand-file-name f)))
          (kill-new p)
          (message "已复制: %s" p))
      (message "当前 buffer 没有关联文件"))))

(defun my-copy-file-name ()
  "复制当前文件名（不带路径）。"
  (interactive)
  (let ((f (buffer-file-name)))
    (if f
        (let ((n (file-name-nondirectory f)))
          (kill-new n)
          (message "已复制: %s" n))
      (message "当前 buffer 没有关联文件"))))

(defun my-copy-file-path-line ()
  "复制 文件路径:行号，方便贴给编译器/issue。"
  (interactive)
  (let ((f (buffer-file-name)))
    (if f
        (let ((s (format "%s:%d" (expand-file-name f) (line-number-at-pos))))
          (kill-new s)
          (message "已复制: %s" s))
      (message "当前 buffer 没有关联文件"))))

(defun my-insert-date ()
  "插入今天的日期，如 2026-09-09。"
  (interactive)
  (insert (format-time-string "%Y-%m-%d")))

(defun my-insert-datetime ()
  "插入当前日期时间，如 2026-09-09 14:30:00。"
  (interactive)
  (insert (format-time-string "%Y-%m-%d %H:%M:%S")))

;; ---------------------------------------------------------------------------
;; 四、代码导航（imenu / xref / project，均为内置）
;; ---------------------------------------------------------------------------

(defun my-imenu-symbols ()
  "列出当前文件的函数/类/结构，回车跳转。"
  (interactive)
  (condition-case nil
      (imenu)
    (error (message "此模式没有可索引的结构"))))

(defun my-find-definitions ()
  "跳到光标处符号的定义处（内置 xref）。"
  (interactive)
  (if (fboundp 'xref-find-definitions)
      (xref-find-definitions)
    (message "需要 Emacs 25+ 的 xref")))

(defun my-pop-xref ()
  "从定义处跳回来。"
  (interactive)
  (if (fboundp 'xref-pop-marker-stack)
      (xref-pop-marker-stack)
    (message "需要 xref")))

(defun my-project-find-file ()
  "在项目（git 仓库等）内快速找文件。"
  (interactive)
  (if (fboundp 'project-find-file)
      (call-interactively #'project-find-file)
    (message "需要 Emacs 28+ 的 project.el")))

(defun my-project-search ()
  "在项目内搜索正则表达式。"
  (interactive)
  (if (fboundp 'project-find-regexp)
      (call-interactively #'project-find-regexp)
    (message "需要 Emacs 28+ 的 project.el")))

;; ---------------------------------------------------------------------------
;; 五、编译 / 运行（这是"像写 Python 一样"的典型例子：
;;     根据文件扩展名自动决定下一步动作）
;; ---------------------------------------------------------------------------

(defun my-smart-compile ()
  "按当前文件类型选择编译/检查命令并执行（先自动保存）。
   无 Makefile 的 C/C++ 直接编译；Python 源码检查；Elisp 批量加载检查。"
  (interactive)
  (let ((f (buffer-file-name)))
    (when f (save-buffer))
    (let* ((ext  (and f (downcase (file-name-extension f))))
           (base (and f (file-name-sans-extension f)))
           (q    (and f (shell-quote-argument f)))       ; 路径加引号，防空格
           (qb   (and base (shell-quote-argument base)))
           (cmd  (cond
                  ((string= ext "py")   (format "python3 -m py_compile %s" q))
                  ((string= ext "sh")   (format "bash -n %s" q))
                  ((string= ext "c")    (format "gcc -Wall -Wextra -g -o %s %s" qb q))
                  ((string= ext "cpp")  (format "g++ -Wall -Wextra -g -o %s %s" qb q))
                  ((string= ext "el")   (format "emacs --batch --eval \"(setq byte-compile-error-on-warn t)\" -f batch-byte-compile %s" q))
                  (t compile-command))))                  ; 其它情况交给 make
      (compile cmd))))

(defun my-run-current-file ()
  "直接运行当前文件(Python/Bash/Node 等)；GUI 下输出在 *run-output* 里。
   需要交互输入的程序请改用 M-x term。"
  (interactive)
  (let ((f (buffer-file-name)))
    (if (null f)
        (message "当前 buffer 没有文件可运行")
      (save-buffer)
      (let* ((ext (downcase (file-name-extension f)))
             (q   (shell-quote-argument f))
             (cmd (cond
                   ((string= ext "py")  (format "python3 -u %s" q))
                   ((string= ext "sh")  (format "bash %s" q))
                   ((string= ext "js")  (format "node %s" q))
                   ((string= ext "rb")  (format "ruby %s" q))
                   (t (format "bash %s" q)))))
        (async-shell-command cmd "*run-output*")
        (message "运行: %s" cmd)))))

;; ---------------------------------------------------------------------------
;; 六、代码折叠（hide-show，内置）
;; ---------------------------------------------------------------------------

(defun my-hs-toggle ()
  "折叠/展开光标处代码块。"
  (interactive)
  (if (bound-and-true-p hs-minor-mode)
      (hs-toggle-hiding)
    (message "未开启代码折叠（应已由 prog-mode 钩子自动开启）")))

(defun my-hs-hide-all ()
  "折叠整个文件的代码块，只留函数头。"
  (interactive)
  (if (bound-and-true-p hs-minor-mode)
      (hs-hide-all)
    (error "hs-minor-mode 未开启")))

(defun my-hs-show-all ()
  "展开全部代码。"
  (interactive)
  (if (bound-and-true-p hs-minor-mode)
      (hs-show-all)
    (error "hs-minor-mode 未开启")))

;; ---------------------------------------------------------------------------
;; 七、Git 快捷命令（调系统 git，结果放独立 buffer）
;; ---------------------------------------------------------------------------

(defun my-git-status () (interactive) (async-shell-command "git status"))
(defun my-git-log    () (interactive) (async-shell-command "git log --oneline -30"))
(defun my-git-diff   () (interactive) (async-shell-command "git diff"))

(defun my-git-add-commit-async ()
  "把当前文件 git add 并提交，提交信息取自光标所在行（这是个"自定义函数"示例）。"
  (interactive)
  (let ((f (buffer-file-name)))
    (if (null f)
        (message "非文件 buffer")
      (let* ((msg (string-trim (thing-at-point 'line t)))
             (msg (if (string-empty-p msg) "wip" msg))
             (cmd (format "git add %s && git commit -m %s"
                          (shell-quote-argument f)
                          (shell-quote-argument msg))))
        (async-shell-command cmd "*git-commit*")
        (message "提交: %s" msg)))))

;; ---------------------------------------------------------------------------
;; 八、配置文件入口
;; ---------------------------------------------------------------------------

(defun my-open-init-file ()
  "打开个人 init.el。"
  (interactive)
  (find-file user-init-file))

(defun my-reload-init ()
  "重新加载 init.el。"
  (interactive)
  (load-file user-init-file)
  (message "已重新加载 %s" user-init-file))

(defun my-open-recent-file ()
  "弹出最近打开过的文件列表（自动确保 recentf 追踪已开启）。"
  (interactive)
  (require 'recentf)
  (unless recentf-mode (recentf-mode 1))
  (recentf-open-files))

(defun my-insert-file-header ()
  "在当前行上方插入一段文件头（文件名 + 日期），自动采用本模式注释符号。"
  (interactive)
  (let* ((f    (buffer-file-name))
         (name (if f (file-name-nondirectory f) (buffer-name)))
         (date (format-time-string "%Y-%m-%d"))
         (txt  (concat name "\nCreated: " date "\n")))
    (save-excursion
      (beginning-of-line)
      (insert txt))
    (comment-region (line-beginning-position)
                    (save-excursion (forward-line 2) (point)))))

;; ---------------------------------------------------------------------------
;; 九、自动开启的钩子
;; ---------------------------------------------------------------------------

;; 打开代码文件时：开行号(前文已设)、开代码折叠、跟踪当前函数名
(add-hook 'prog-mode-hook
          (lambda ()
            (hs-minor-mode 1)
            (setq-local hs-hide-comments-when-hiding-all t)))
(which-function-mode 1)

;; ---------------------------------------------------------------------------
;; 十、按键绑定表（集中在此，想改哪行注释掉即可）
;; ---------------------------------------------------------------------------

(defvar my-programming-map (make-sparse-keymap)
  "个人编程功能前缀键表（入口 C-c p）。")

;; —— 行操作 ——
(define-key my-programming-map (kbd "u") #'my-line-up)                ; 行上移
(define-key my-programming-map (kbd "n") #'my-line-down)              ; 行下移
(define-key my-programming-map (kbd "d") #'my-duplicate-line-or-region) ; 复制行/选区
(define-key my-programming-map (kbd "o") #'my-open-line-below)        ; 下方开新行
(define-key my-programming-map (kbd "O") #'my-open-line-above)        ; 上方开新行

;; —— 注释 / 缩进 / 空白 ——
(define-key my-programming-map (kbd ";") #'my-comment-line-or-region) ; 整行注释/取消
(define-key my-programming-map (kbd "i") #'my-indent-buffer)          ; 重排整个文件
(define-key my-programming-map (kbd "t") #'my-trim-trailing-whitespace) ; 清理行尾空白

;; —— 路径 / 日期 ——
(define-key my-programming-map (kbd "f") #'my-copy-file-path)         ; 复制绝对路径
(define-key my-programming-map (kbd "F") #'my-copy-file-name)         ; 复制文件名
(define-key my-programming-map (kbd "l") #'my-copy-file-path-line)    ; 复制 路径:行号
(define-key my-programming-map (kbd "D") #'my-insert-date)            ; 插入日期
(define-key my-programming-map (kbd "T") #'my-insert-datetime)        ; 插入日期时间

;; —— 导航 ——
(define-key my-programming-map (kbd "a") #'my-imenu-symbols)          ; 文件内符号列表
(define-key my-programming-map (kbd "x") #'my-find-definitions)       ; 跳到定义
(define-key my-programming-map (kbd "b") #'my-pop-xref)               ; 跳回
(define-key my-programming-map (kbd "p") #'my-project-find-file)      ; 项目内找文件
(define-key my-programming-map (kbd "q") #'my-project-search)         ; 项目内搜正则

;; —— 编译 / 运行 ——
(define-key my-programming-map (kbd "c") #'my-smart-compile)          ; 智能编译
(define-key my-programming-map (kbd "r") #'my-run-current-file)       ; 运行当前文件
(define-key my-programming-map (kbd "e") #'eshell)                    ; 打开 eshell
(define-key my-programming-map (kbd "E") #'my-open-init-file)         ; 打开 init.el
(define-key my-programming-map (kbd "R") #'my-reload-init)            ; 重载 init.el

;; —— 折叠 / Git / 文件头 ——
(define-key my-programming-map (kbd "h") #'my-hs-toggle)              ; 折叠代码块
(define-key my-programming-map (kbd "H") #'my-insert-file-header)     ; 插入文件头
(define-key my-programming-map (kbd "g") #'my-git-status)             ; git status
(define-key my-programming-map (kbd "G") #'my-git-log)                ; git log

;; —— 快速打开 ——
(define-key my-programming-map (kbd "j") #'dired-jump)               ; 打开当前文件所在目录
(define-key my-programming-map (kbd "v") #'my-open-recent-file)      ; 打开最近打开的文件

;; 注册前缀：C-c p
(global-set-key (kbd "C-c p") my-programming-map)
;; —— 全局微调 ——
(global-set-key (kbd "C-a") #'my-smart-beginning-of-line) ; 智能行首（第二下到硬行首）
;; （可选）想用方向键上下移动整行，可取消下面两行注释——
;; 注意:org-mode 里 M-up/M-down 另有用途（移动子树），此处加了会覆盖它。
;; (global-set-key (kbd "M-<up>")   #'my-line-up)
;; (global-set-key (kbd "M-<down>") #'my-line-down)

;; ---------------------------------------------------------------------------
;; 十二、固定打开常用文件 / 目录   （用法：C-c p <数字> 秒开）
;; ---------------------------------------------------------------------------
;; 使用方法：把下面的 my-quick-places 表改成你自己的路径即可，每条记录 =
;;     (按键字符 . 路径)
;;   目录会自动进入 Dired 文件管理器，文件直接打开。
;;   留空(nil)时按键只会提示你还没填，不会误建文件，放心先体验。
(defvar my-quick-places
  '((?1 . "~/Projets")      ; ← 例：填一个目录  如 "~/work/projectA"
    (?2 . "~/.emacs")      ; ← 例：填一个文件  如 "~/work/projectA/src/main.c"
    (?3 . nil)      ; ← 文件或目录皆可
    (?4 . nil))
  "C-c p <数字> 要打开的路径：元素为 (按键字符 . 路径)。")

(defun my-quick-open (num)
  "打开 my-quick-places 中 NUM 对应的路径（目录进 Dired，文件直接开）。"
  (let ((path (cdr (assq num my-quick-places))))
    (cond
     ((null path)
      (message "C-c p %c 还没设置路径：编辑 my-quick-places（C-c p 0 可打开本文件）" num))
     ((not (file-exists-p path))
      (message "路径不存在，请检查 my-quick-places：%s" path))
     (t (find-file path)))))

;; 自动为每一项绑定 C-c p <数字>；以后想加第 5 个入口，
;; 只需在 my-quick-places 里补一行 (?5 . \"...\")，无需改其它代码。
(dolist (place my-quick-places)
  (let ((k (car place)))
    (define-key my-programming-map (vector k)
      (lambda () (interactive) (my-quick-open k)))))

;; C-c p 0：打开本配置文件，方便你随时来填上面的路径
(defvar my-extra-file
  (or load-file-name
      (expand-file-name "emacs-programming-extra.el" user-emacs-directory))
  "本配置文件的完整路径。")
(defun my-open-programming-extra ()
  "打开 emacs-programming-extra.el 以便编辑。"
  (interactive)
  (find-file my-extra-file))
(define-key my-programming-map (kbd "0") #'my-open-programming-extra)

;; ---------------------------------------------------------------------------
;; 附：Linux 下的两个提醒
;; ---------------------------------------------------------------------------
;; 1. 终端版 Emacs 里"复制到系统剪贴板"需要工具的桥接，装一下即可：
;;      sudo apt install xclip        ; 然后 M-x kill-ring-save 会走系统剪贴板(图形会话下)
;;    或改用 `emacs -nw` 里开 `M-x term`。最简单还是用图形版 Emacs。
;; 2. 想让"一个函数对应一个按键"的自己动手示例，去看上面 my-git-add-commit-async：
;;    它就是"快捷键 → Lisp 函数 → 调外部 git"的最短路径。
;; ============================================================================
(provide 'emacs-programming-extra)
;;; emacs-programming-extra.el ends here
