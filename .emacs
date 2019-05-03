(setq auto-mode-alist
      (append
       '(("\\.c" . c++-mode)  ;; bcoz of SOCET SET
         ("\\.h" . c++-mode)  ;; everybody uses .h for C++ headers
         ) auto-mode-alist))

(require 'cc-mode)  ;; causes visibility for setting indentation styles


(defun my-c-mode-common-hook ()
  (setq tab-width 3)
  (setq c-basic-offset tab-width)
  (c-set-offset 'arglist-intro c-basic-offset) ;; function parm lists
  (c-set-offset 'access-label' -2)             ;; private: public: protected:
  (c-set-offset 'func-decl-cont 0)             ;; method const
  (setq indent-tabs-mode nil)                  ;; spaces, not tabs
  (setq fill-column 80))                       ;; longer lines
(add-hook 'c-mode-common-hook 'my-c-mode-common-hook)

(define-key ctl-x-map "\C-l" 'goto-line)      ;; <CTRL>-X <CTRL>-L shortcut
(define-key ctl-x-map "\C-q" 'query-replace)  ;; <CTRL>-X <CTRL>-Q shortcut
(define-key ctl-x-map "\C-r" 'replace-string) ;; <CTRL>-X <CTRL>-R shortcut
(font-lock-fontify-buffer)                ;; syntax highlighting
(column-number-mode 1)                    ;; always show both column
(line-number-mode 1)                      ;; and line numbers
(setq-default auto-fill-mode 1)
(setq-default fill-column 80)

;; Options Menu Settings
;; =====================
(cond
 ((and (string-match "XEmacs" emacs-version)
       (boundp 'emacs-major-version)
       (or (and
            (= emacs-major-version 19)
            (>= emacs-minor-version 14))
           (= emacs-major-version 20))
       (fboundp 'load-options-file))
  (load-options-file "/home/rsetter/.xemacs-options")))
;; ============================
;; End of Options Menu Settings

(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(c-basic-offset 3)
 '(fill-column 80)
 '(global-auto-revert-mode t)
 '(indent-tabs-mode nil)
 '(inhibit-startup-screen t)
 '(initial-buffer-choice nil)
 '(initial-scratch-message nil))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 )

(autoload 'cperl-mode "CPerl-mode" "CPerl Mode." t)
(setq auto-mode-alist
      (append '(("\\.pl$" . cperl-mode)
                ("\\.pm$" . cperl-mode)
                ("\\.[ch]\\'" . c++-mode)
                ) auto-mode-alist))

(setq auto-mode-alist (cons '("\\.pl$" . cperl-mode) auto-mode-alist))

   
(define-key ctl-x-map "\C-l" 'goto-line)  ;; <CTRL>-X <CTRL>-L shortcut
(define-key ctl-x-map "\C-q" 'query-replace)  ;; <CTRL>-X <CTRL>-Q shortcut
(define-key ctl-x-map "\C-r" 'replace-string) ;; <CTRL>-X <CTRL>-R shortcut
(global-set-key [f5] 'revert-buffer)
;;(font-lock-fontify-buffer)                ;; syntax highlighting

(column-number-mode 1)                    ;; always show both column
(line-number-mode 1)                      ;; and line numbers
(c-set-offset 'arglist-intro 3)

;;;;;;;;;;;;;;;;;;Begin pretty-format-xml ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun pretty-format-xml (arg)
  "Add new-lines to xml file.
  M-x pretty-format-xml
  Add a prefix argument to also put attributes on their own lines
  C-u M-x pretty-format-xml"
  (interactive "P")

  ;; Remove all indentation
  (goto-char (point-min))
  (while (re-search-forward "^[[:space:]]+" nil t)
    (replace-match ""))

  ;; then remove all new-lines first
  (goto-char (point-min))
  (while (re-search-forward "\n" nil t)
    (replace-match " "))

  ;; add new-lines after elements
  (goto-char (point-min))
  (while (not (eq (point) (point-max)))
    (progn
      (forward-sexp)
      (insert "\n")))

  ;; Put attributes on new-lines if prefix argument is given.
  ;;(if arg ;ALWAYS
      (progn
        (goto-char (point-min))
        (while (re-search-forward "[[:word:]]+[[:space:]]*=[[:space:]]*\".*?\"" nil t)
          (goto-char (match-beginning 0))
          (insert "\n")
          (goto-char (match-end 0))));;)
  (indent-region (point-min) (point-max)))
;;;;;;;;;;;;;;;;;;end pretty-format-xml ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;; F2/F3 for 2- or 3-space indentation modes
;; http://stackoverflow.com/questions/35187584/global-set-key-settings-to-switch-indentation
(defun set-offset-2 ()
  (interactive)
  (setq-default c-basic-offset 2))
(defun set-offset-3 ()
  (interactive)
  (setq-default c-basic-offset 3))

(global-set-key [f2] 'set-offset-2)
(global-set-key [f3] 'set-offset-3)


