---@class Usuario_Usuarios
---@field roles table Los cargos o roles del usuario
---@field username string El nombre de inicio de sesion
---@field name string El nombre del usuario
---@field contact string El contacto del usuario

class "Usuario_Usuarios" {
	function (this, serialized)
		local deserialized = json.decode(serialized)
		this.roles = deserialized.roles
		this.name = deserialized.name
		this.username = deserialized.username
		this.contact = deserialized.contact
	end,

	---@param this Usuario_Usuarios Un usuario
	---@return string Una cadena serializada del usuario
	serialize = function (this)
		return json.encode({
			username = this.username,
			name = this.name,
			contact = this.contact,
			roles = this.roles
		})
	end
}

class "Rol_Usuarios" {
	function (this)
		this.name = ""
		this.description = ""
		this.permissions = {}
	end,

	serialize = function (this)
		return json.encode({
			name = this.name,
			description = this.description,
			permissions = this.permissions
		})
	end
}
