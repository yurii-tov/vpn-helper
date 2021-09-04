(defvar *vpn-buffer*)
(defvar *vpn-server*)
(defvar *vpn-password*)


(define-derived-mode vpn-mode nil "vpn-helper"
  (setq-local vpn-buffer *vpn-buffer*)
  (setq-local vpn-server *vpn-server*)
  (setq-local vpn-password *vpn-password*))


(progn
  (define-key vpn-mode-map (kbd "c") 'vpn-connect)
  (define-key vpn-mode-map (kbd "d") 'vpn-disconnect)
  (define-key vpn-mode-map (kbd "s") 'vpn-status))


(setq vpn-cli-exe "c:/Program Files (x86)/Cisco/Cisco AnyConnect Secure Mobility Client/vpncli.exe")


(defun run-vpn ()
  (interactive)
  (let* ((*vpn-server* (read-string "Vpn server: "))
         (*vpn-password* (read-passwd "Vpn Password: "))
         (*vpn-buffer* (format "*vpn:%s*" *vpn-server*)))
    (switch-to-buffer *vpn-buffer*)
    (vpn-mode)
    (vpn-status)))


(defun vpn-erase-buffer ()
  (with-current-buffer vpn-buffer
    (erase-buffer)))


(defmacro define-vpn-command (name command)
  `(defun ,(intern (concat "vpn-" (symbol-name name))) ()
     (interactive)
     (vpn-erase-buffer)
     (make-process :name ,(concat "vpn-" (symbol-name name))
                   :buffer vpn-buffer
                   :command ,command
                   :coding '(utf-8-dos . utf-8-dos))))


(define-vpn-command status (cons vpn-cli-exe '("status")))


(define-vpn-command connect
  (list "bash" "-c"
        (format "echo '%s' | '%s' -s connect %s && mstsc connect.rdp"
                vpn-password
                vpn-cli-exe
                vpn-server)))


(define-vpn-command disconnect (cons vpn-cli-exe '("disconnect")))
