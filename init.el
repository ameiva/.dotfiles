;;==============================================================================
;; Emacs initialization file
;; (Inspired by emacs-prelude)
;;==============================================================================

(require 'cl)

(unless (boundp 'user-emacs-directory)
  (defvar user-emacs-directory "~/.emacs.d/"
    "Root directory of the emacs configuration."))
(defvar user-opt-directory (concat user-emacs-directory "opt/")
  "User-installed emacs packages go here.")
(add-to-list 'load-path user-opt-directory)

;;; Package management with MELPA
(require 'package)
(require 'melpa)
(add-to-list 'package-archives
	     '("melpa" . "http://melpa.milkbox.net/packages/") t)
(package-initialize)

;; (setq url-http-attempt-keepalives nil)
;;; MORE TO BE ADDED TO PACKAGE MANAGEMENT

;;; Install the required packages
(defvar required-packages-list
  '(auctex magit markdown-mode paredit python rainbow-mode volatile-highlights zenburn-theme)
  "List of packages required to be installed at startup.")

(defun required-packages-installed-p ()
  (loop for pkg in required-packages-list
        when (not (package-installed-p pkg)) do (return nil)
        finally (return t)))

(unless (required-packages-installed-p)
  (message "%s" "Emacs Prelude is now refreshing its package database...")
  (package-refresh-contents)
  (message "%s" " done.")
  (dolist (pkg required-packages-list)
    (when (not (package-installed-p pkg))
      (package-install pkg))))

;;; Buffer customizations
(setq inhibit-startup-screen t)
(setq initial-scratch-message nil)
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))
(blink-cursor-mode -1)
(line-number-mode 1)
(column-number-mode 1)
(size-indication-mode 1)

(fset 'yes-or-no-p 'y-or-n-p)

(if (fboundp 'fringe-mode) (fringe-mode 4))
(setq scroll-margin 0
      scroll-conservatively 100000
      scroll-preserve-screen-position 1)
(setq frame-title-format
      '("" invocation-name " - " (:eval (if (buffer-file-name)
                                            (abbreviate-file-name (buffer-file-name)))
                                        "%b")))

;;; Colour themes
(load-theme 'zenburn t)

;;; Editing goodies
(show-paren-mode 1)
(setq show-paren-style 'parenthesis)
(global-hl-line-mode 1)

(electric-pair-mode 1)
(electric-indent-mode 1)
(electric-layout-mode 1)

(require 'volatile-highlights)
(volatile-highlights-mode 1)

(setq-default indent-tabs-mode nil)   ;; Don't use tabs to indent...
(setq-default tab-width 8)            ;; ...but maintain correct appearance

(setq ispell-program-name "aspell"
      ispell-extra-args '("--sug-mode=ultra"))
(autoload 'flyspell-mode "flyspell" "On-the-fly spelling checker." )

(ido-mode 1)
(setq ido-enable-prefix nil
      ido-enable-flex-matching t
      ido-create-new-buffer 'always
      ido-use-filename-at-point 'guess
      ido-max-prospects 10
      ido-default-file-method 'selected-window)

(icomplete-mode 1)
(set-default 'imenu-auto-rescan t)

;;; Global keybindings
(global-set-key [f1]          'revert-buffer)
(global-set-key [f2]          'goto-line)
(global-set-key [f5]          'query-replace)
(global-set-key [f12]         'kill-this-buffer)
(global-set-key [home]        'beginning-of-line)
(global-set-key [end]         'end-of-line)
(global-set-key [C-home]      'beginning-of-buffer)
(global-set-key [C-end]       'end-of-buffer)

;;; Backing up files
(setq backup-by-copying t
      delete-old-versions t
      kept-old-versions 2
      kept-new-versions 2
      version-control t)
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

(defun delete-old-backup-files ()
  "Delete backup files that have not been accessed in a month."
  (let ((month (* 60 60 24 7 30))
        (current (float-time (current-time))))
    (dolist (file (directory-files temporary-file-directory t))
      (when (and (backup-file-name-p file)
                 (> (- current (float-time (nth 5 (file-attributes file))))
                    month))
        (message "%s" file)
        (delete-file file)))))
(delete-old-backup-files)

;;; Programming goodies
(require 'which-func)
(which-func-mode 1)

;;; Mode-specific hooks
(add-hook 'haskell-mode-hook
          (lambda ()
            (subword-mode 1)))