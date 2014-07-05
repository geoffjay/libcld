-- sudo yum install lua-devel luarocks
-- sudo luarocks install lgi
-- sudo ln -s /usr/lib/lua/5.2/lgi/ /usr/lib64/lua/5.2/lgi

local lgi = require('lgi')
local Cld = lgi.require('Cld', '0.2')

local config = Cld.XmlConfig.with_file_name('examples/cld.xml')
local context = Cld.Context.from_config(config)

Cld.Context.print_objects(context, 0)

local chan = Cld.Context.get_object(context, 'ai0')
print("\nAIChannel ID: " .. chan.id)
