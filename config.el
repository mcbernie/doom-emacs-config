;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Nicolas Wilms-Brüggemann"
      user-mail-address "nicolas@wilms-brueggemann.de")

(cond ((eq system-type 'darwin)
       (setq ns-right-alternate-modifier 'none)
       )
)
;; load the Getting Things Done org-mode setup

;; don't show recent files in switch-buffer
(setq ivy-use-virtual-buffers nil)

;; change to directory with ivy even if name does not match exactly
(after! ivy
  (setq ivy-magic-slash-non-match-action 'ivy-magic-slash-non-match-cd-selected))

(setq doom-font (font-spec :family "Mononoki Nerd Font" :size 15)
      doom-variable-pitch-font (font-spec :family "Mononoki Nerd Font" :size 15))

(setq doom-theme 'doom-palenight)
;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.

;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.


(setq rustic-flycheck-clippy-params "--message-format=json")

(setq display-line-numbers-type 'relative)

(setq doom-fallback-buffer-name "► Doom"
      +doom-dashboard-name "► Doom")

(custom-set-faces! '(doom-modeline-evil-insert-state :weight bold :foreground "#339CDB"))

(setq frame-title-format
      '(""
        (:eval
         (if (s-contains-p org-roam-directory (or buffer-file-name ""))
             (replace-regexp-in-string
              ".*/[0-9]*-?" "☰ "
              (subst-char-in-string ?_ ?  buffer-file-name))
           "%b"))
        (:eval
         (let ((project-name (projectile-project-name)))
           (unless (string= "-" project-name)
             (format (if (buffer-modified-p)  " ◉ %s" "  ●  %s") project-name))))))

;; configure email
(after! mu4e
  ;; load package to be able to capture emails for GTD
  (require 'org-mu4e)
  ;; do not use rich text emails
  (remove-hook! 'mu4e-compose-mode-hook #'org-mu4e-compose-org-mode)
  ;; ensure viewing messages and queries in mu4e workspace
  (advice-add 'mu4e-view-message-with-message-id :around #'+kandread/view-in-mu4e-workspace)
  (advice-add 'mu4e-headers-search :around #'+kandread/view-in-mu4e-workspace)
  ;; instead of displaying the fallback buffer (dashboard) after quitting mu4e, switch to last active buffer in workspace
  (advice-add '+email|kill-mu4e :around #'+kandread/restore-buffer-after-mu4e)
  ;; attach files to messages by marking them in dired buffer
  (require 'gnus-dired)
  (defalias 'gnus-dired-mail-buffers '+kandread/gnus-dired-mail-buffers)
  (setq gnus-dired-mail-mode 'mu4e-user-agent)
  (add-hook! 'dired-mode-hook #'turn-on-gnus-dired-mode)
  ;; disable line wrapping when viewing headers
  (add-hook! 'mu4e-headers-mode-hook #'+kandread/turn-off-visual-line-mode)
  ;; configure mu4e options
  (setq mu4e-confirm-quit nil ; quit without asking
        mu4e-attachment-dir "~/Downloads"
        mu4e-maildir (expand-file-name "~/Mail/jpl")
        mu4e-get-mail-command "mbsync jpl"
        mu4e-user-mail-address-list '("kandread@jpl.nasa.gov" "konstantinos.m.andreadis@jpl.nasa.gov")
	    user-mail-address "kandread@jpl.nasa.gov"
	    user-full-name "Kostas Andreadis")
  (setq mu4e-bookmarks
	'(("flag:unread AND NOT flag:trashed" "Unread messages" ?u)
          ("date:today..now AND maildir:/inbox" "Today's messages" ?t)
          ("date:7d..now AND maildir:/inbox" "Last 7 days" ?w)))
  (setq message-send-mail-function 'smtpmail-send-it
	smtpmail-stream-type 'starttls
	smtpmail-default-smtp-server "smtp.jpl.nasa.gov"
	smtpmail-smtp-server "smtp.jpl.nasa.gov"
	smtpmail-smtp-service 587)
  ;; add custom actions for messages
  (add-to-list 'mu4e-view-actions
	       '("View in browser" . mu4e-action-view-in-browser) t))
