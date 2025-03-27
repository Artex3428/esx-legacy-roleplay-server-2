Config                            = {}
Config.DrawDistance               = 100
Config.MarkerColor                = {r = 120, g = 120, b = 240}
Config.EnablePlayerManagement     = true -- enables the actual car dealer job. You'll need esx_addonaccount, esx_billing and esx_society
Config.ResellPercentage           = 50

Config.EnableESXService           = true -- Enable esx service?
Config.MaxInService               = -1 -- How many people can be in service at once? Set as -1 to have no limit

Config.Enableipl = false

Config.Locale                     = 'en'

Config.LicenseEnable = false -- require people to own drivers license when buying vehicles? Only applies if EnablePlayerManagement is disabled. Requires esx_license

-- looks like this: 'LLL NNN'
-- The maximum plate length is 8 chars (including spaces & symbols), don't go past it!
Config.PlateLetters  = 3
Config.PlateNumbers  = 3
Config.PlateUseSpace = true

Config.Zones = {

	ShopEntering = {
		Pos   = vector3(-50.14818572998047, -1089.195556640625, 26.42234802246093),
	},

	CardealerMenu = {
		Pos   = vector3(-56.93726348876953, -1098.8779296875, 26.42236518859863),
	},

	ShopInside = {
		Pos     = vector3(-47.5, -1097.2, 25.4),
		Size    = {x = 1.5, y = 1.5, z = 1.0},
		Heading = -20.0,
		Type    = -1
	},

	ShopOutside = {
		Pos     = vector3(-28.6, -1085.6, 25.5),
		Size    = {x = 1.5, y = 1.5, z = 1.0},
		Heading = 330.0,
		Type    = -1
	},

	BossActions = {
		Pos   = vector3(-31.79674339294433, -1113.7547607421875, 26.4223346710205),
	},

	GiveBackVehicle = {
		Pos   = vector3(-33.65788650512695, -1079.8399658203125, 26.68562698364257),
		Size  = {x = 3.0, y = 3.0, z = 1.0},
		Type  = (Config.EnablePlayerManagement and 1 or -1)
	},

	ResellVehicle = {
		Pos   = vector3(-46.09424209594726, -1082.3817138671875, 26.72930717468261),
		Size  = {x = 3.0, y = 3.0, z = 1.0},
		Type  = -1
	}

}
