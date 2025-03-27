Config = {}
Config.Locale = GetConvar('esx:locale', 'en')
Config.Visible = true

Config.Items = {
	-- Food
	["bread"] = {
		type = "food",
		prop = "prop_cs_burger_01",
		status = 200000,
		remove = true,
		anim = {dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = {8.0, -8, -1, 49, 0, 0, 0, 0}}
	},

	["limonade"] = {
		type = "food",
		status = 500,
		remove = true,
		prop = "prop_cs_burger_01",
		anim = {dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = {8.0, -8, -1, 49, 0, 0, 0, 0}}
	},

	["bolcacahuetes"] = {
		type = "food",
		status = 500,
		remove = true,
		prop = "prop_cs_burger_01",
		anim = {dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = {8.0, -8, -1, 49, 0, 0, 0, 0}}
	},

	["bolnoixcajou"] = {
		type = "food",
		status = 500,
		remove = true,
		prop = "prop_cs_burger_01",
		anim = {dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = {8.0, -8, -1, 49, 0, 0, 0, 0}}
	},

	["bolpistache"] = {
		type = "food",
		status = 500,
		remove = true,
		prop = "prop_cs_burger_01",
		anim = {dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = {8.0, -8, -1, 49, 0, 0, 0, 0}}
	},

	["bolchips"] = {
		type = "food",
		status = 500,
		remove = true,
		prop = "prop_cs_burger_01",
		anim = {dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = {8.0, -8, -1, 49, 0, 0, 0, 0}}
	},

	["saucisson"] = {
		type = "food",
		status = 500,
		remove = true,
		prop = "prop_cs_burger_01",
		anim = {dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = {8.0, -8, -1, 49, 0, 0, 0, 0}}
	},

	["grapperaisin"] = {
		type = "food",
		status = 500,
		remove = true,
		prop = "prop_cs_burger_01",
		anim = {dict = 'mp_player_inteat@burger', name = 'mp_player_int_eat_burger_fp', settings = {8.0, -8, -1, 49, 0, 0, 0, 0}}
	},
	
	-- Drink
	["water"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = {dict = 'mp_player_intdrink', name = 'loop_bottle', settings = {1.0, -1.0, 2000, 0, 1, true, true, true}}
	},

	["icetea"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 50000,
		remove = true,
		anim = {dict = 'mp_player_intdrink', name = 'loop_bottle', settings = {1.0, -1.0, 2000, 0, 1, true, true, true}}
	},

	["soda"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 90000,
		remove = true,
		anim = {dict = 'mp_player_intdrink', name = 'loop_bottle', settings = {1.0, -1.0, 2000, 0, 1, true, true, true}}
	},

	["jusfruit"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = {dict = 'mp_player_intdrink', name = 'loop_bottle', settings = {1.0, -1.0, 2000, 0, 1, true, true, true}}
	},

	["energy"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = {dict = 'mp_player_intdrink', name = 'loop_bottle', settings = {1.0, -1.0, 2000, 0, 1, true, true, true}}
	},

	["drpepper"] = {
		type = "drink",
		prop = "prop_ld_flow_bottle",
		status = 100000,
		remove = true,
		anim = {dict = 'mp_player_intdrink', name = 'loop_bottle', settings = {1.0, -1.0, 2000, 0, 1, true, true, true}}
	},

	-- Alcohol
	["beer"] = {
		type = "drunk",
		prop = "prop_ld_flow_bottle",
		status = 0,
		remove = true,
		anim = {dict = 'mp_player_intdrink', name = 'loop_bottle', settings = {1.0, -1.0, 2000, 0, 1, true, true, true}}
	},

	["jager"] = {
		type = "drunk",
		prop = "prop_ld_flow_bottle",
		status = 0,
		remove = true,
		anim = {dict = 'mp_player_intdrink', name = 'loop_bottle', settings = {1.0, -1.0, 2000, 0, 1, true, true, true}}
	},

	["vodka"] = {
		type = "drunk",
		prop = "prop_ld_flow_bottle",
		status = 0,
		remove = true,
		anim = {dict = 'mp_player_intdrink', name = 'loop_bottle', settings = {1.0, -1.0, 2000, 0, 1, true, true, true}}
	},
	
	["rhum"] = {
		type = "drunk",
		prop = "prop_ld_flow_bottle",
		status = 0,
		remove = true,
		anim = {dict = 'mp_player_intdrink', name = 'loop_bottle', settings = {1.0, -1.0, 2000, 0, 1, true, true, true}}
	},

	["whisky"] = {
		type = "drunk",
		prop = "prop_ld_flow_bottle",
		status = 0,
		remove = true,
		anim = {dict = 'mp_player_intdrink', name = 'loop_bottle', settings = {1.0, -1.0, 2000, 0, 1, true, true, true}}
	},

	["tequila"] = {
		type = "drunk",
		prop = "prop_ld_flow_bottle",
		status = 0,
		remove = true,
		anim = {dict = 'mp_player_intdrink', name = 'loop_bottle', settings = {1.0, -1.0, 2000, 0, 1, true, true, true}}
	},

	["martini"] = {
		type = "drunk",
		prop = "prop_ld_flow_bottle",
		status = 0,
		remove = true,
		anim = {dict = 'mp_player_intdrink', name = 'loop_bottle', settings = {1.0, -1.0, 2000, 0, 1, true, true, true}}
	},

	-- Drinks
	["jagerbomb"] = {
		type = "drunk",
		prop = "prop_ld_flow_bottle",
		status = 0,
		remove = true,
		anim = {dict = 'mp_player_intdrink', name = 'loop_bottle', settings = {1.0, -1.0, 2000, 0, 1, true, true, true}}
	},

	["golem"] = {
		type = "drunk",
		prop = "prop_ld_flow_bottle",
		status = 0,
		remove = true,
		anim = {dict = 'mp_player_intdrink', name = 'loop_bottle', settings = {1.0, -1.0, 2000, 0, 1, true, true, true}}
	},

	["whiskycoca"] = {
		type = "drunk",
		prop = "prop_ld_flow_bottle",
		status = 0,
		remove = true,
		anim = {dict = 'mp_player_intdrink', name = 'loop_bottle', settings = {1.0, -1.0, 2000, 0, 1, true, true, true}}
	},

	["vodkaenergy"] = {
		type = "drunk",
		prop = "prop_ld_flow_bottle",
		status = 0,
		remove = true,
		anim = {dict = 'mp_player_intdrink', name = 'loop_bottle', settings = {1.0, -1.0, 2000, 0, 1, true, true, true}}
	},

	["vodkafruit"] = {
		type = "drunk",
		prop = "prop_ld_flow_bottle",
		status = 0,
		remove = true,
		anim = {dict = 'mp_player_intdrink', name = 'loop_bottle', settings = {1.0, -1.0, 2000, 0, 1, true, true, true}}
	},

	["rhumfruit"] = {
		type = "drunk",
		prop = "prop_ld_flow_bottle",
		status = 0,
		remove = true,
		anim = {dict = 'mp_player_intdrink', name = 'loop_bottle', settings = {1.0, -1.0, 2000, 0, 1, true, true, true}}
	},

	["teqpaf"] = {
		type = "drunk",
		prop = "prop_ld_flow_bottle",
		status = 0,
		remove = true,
		anim = {dict = 'mp_player_intdrink', name = 'loop_bottle', settings = {1.0, -1.0, 2000, 0, 1, true, true, true}}
	},

	["rhumcoca"] = {
		type = "drunk",
		prop = "prop_ld_flow_bottle",
		status = 0,
		remove = true,
		anim = {dict = 'mp_player_intdrink', name = 'loop_bottle', settings = {1.0, -1.0, 2000, 0, 1, true, true, true}}
	},

	["mojito"] = {
		type = "drunk",
		prop = "prop_ld_flow_bottle",
		status = 0,
		remove = true,
		anim = {dict = 'mp_player_intdrink', name = 'loop_bottle', settings = {1.0, -1.0, 2000, 0, 1, true, true, true}}
	},

	["mixapero"] = {
		type = "drunk",
		prop = "prop_ld_flow_bottle",
		status = 0,
		remove = true,
		anim = {dict = 'mp_player_intdrink', name = 'loop_bottle', settings = {1.0, -1.0, 2000, 0, 1, true, true, true}}
	},

	["metreshooter"] = {
		type = "drunk",
		prop = "prop_ld_flow_bottle",
		status = 0,
		remove = true,
		anim = {dict = 'mp_player_intdrink', name = 'loop_bottle', settings = {1.0, -1.0, 2000, 0, 1, true, true, true}}
	},

	["jagercerbere"] = {
		type = "drunk",
		prop = "prop_ld_flow_bottle",
		status = 0,
		remove = true,
		anim = {dict = 'mp_player_intdrink', name = 'loop_bottle', settings = {1.0, -1.0, 2000, 0, 1, true, true, true}}
	},
}
