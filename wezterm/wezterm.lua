local Config = require("config")

-- require("events.right-status").setup()
require("events.left-status").setup()
require("events.tab-title").setup()
require("events.new-tab-button").setup()

return Config:init()
  :append(require("config.appearance"))
  :append(require("colors.day-and-night"))
  :append(require("config.bindings"))
  :append(require("config.fonts"))
  :append(require("config.general"))
  :append(require("config.cursor"))
  :append(require("config.launch")).options
