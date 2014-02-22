--[[==========================================]]--
--[[ Example Message Module by CoffeeScripter ]]--
--[[   Displays a message using the Message   ]]--
--[[    class that lasts for five seconds.    ]]--
--[[==========================================]]--

return {
	"message",
	function(text)
		local message = Instance.new('Message', game.Workspace)
		message.Text = text
		wait(5)
		message:Destroy()
	end,
}