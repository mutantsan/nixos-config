-- Extra autostart processes.
-- o.launch_on_start("my-service")

-- Clipboard manager watcher daemon (supports pinning history entries).
o.exec_on_start("/home/cherry/.cargo/bin/clipboard-manager-ms")

-- Drop-down terminal: spawn a foot window that the window rules park on the
-- special:terminal workspace. Toggle it with F1 (see hypr/bindings.lua).
o.exec_on_start("foot --app-id=special.terminal")
