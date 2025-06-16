class "Calendario_Eventos" {
	function (this, serialized)

end
}

class "Evento_Eventos" {
	function (this, serialized)
		local deserialized = json.decode(serialized)
		this.name = deserialized.name
		this.description = deserialized.description
		this.cron = deserialized.cron
		this.notifyRoles = deserialized.notifyRoles
		this.state = deserialized.state
	end,

	serialize = function (this)
		return json.encode({
			name = this.name,
			description = this.description,
			cron = this.cron,
			notifyRoles = this.notifyRoles,
			state = this.state
		})
	end
}
