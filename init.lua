-- Bootstrap order matters:
-- 1. core options first (vim settings before anything else)
-- 2. keymaps (leader key must be set before lazy loads plugins)
-- 3. lazy (plugin manager, loads everything else)

require("fabri.core.options")
require("fabri.core.keymaps")
require("fabri.core.lazy") 
