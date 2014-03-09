--[[==========================================]]--
--[[ Example Message Module by CoffeeScripter ]]--
--[[   Displays a message using the Message   ]]--
--[[    class that lasts for five seconds.    ]]--
--[[==========================================]]--

return {
	"message",
	function(...)
		local message = Instance.new('Message', game.Workspace)
		message.Text = table.concat({...}," ")
		wait(5)
		message:Destroy()
	end,
	[[==========================================
 Example Message Module by CoffeeScripter 
   Displays a message using the Message   
    class that lasts for five seconds.    
==========================================]]
}
