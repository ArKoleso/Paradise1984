/obj/machinery/atmospherics/unary/outlet_injector
	icon = 'icons/obj/pipes_and_stuff/atmospherics/atmos/injector.dmi'
	icon_state = "map_injector"
	use_power = IDLE_POWER_USE
	layer = GAS_PIPE_VISIBLE_LAYER + GAS_SCRUBBER_OFFSET
	layer_offset = GAS_SCRUBBER_OFFSET

	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF //really helpful in building gas chambers for xenomorphs

	can_unwrench = 1

	name = "air injector"
	desc = "Has a valve and pump attached to it"

	frequency = ATMOS_TANKS_FREQ

	on = FALSE
	var/injecting = 0

	var/volume_rate = 50

	var/id

/obj/machinery/atmospherics/unary/outlet_injector/on
	on = 1

/obj/machinery/atmospherics/unary/outlet_injector/New()
	..()
	if(id && !id_tag)//I'm not dealing with any more merge conflicts
		id_tag = id

/obj/machinery/atmospherics/unary/outlet_injector/Destroy()
	if(SSradio)
		SSradio.remove_object(src, frequency)
	radio_connection = null
	return ..()

/obj/machinery/atmospherics/unary/outlet_injector/init_multitool_menu()
	multitool_menu = new /datum/multitool_menu/idtag/freq/outlet_injector(src)

/obj/machinery/atmospherics/unary/outlet_injector/update_icon_state()
	if(!powered())
		icon_state = "off"
	else
		icon_state = "[on ? "on" : "off"]"

/obj/machinery/atmospherics/unary/outlet_injector/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		add_underlay(T, node, dir)

/obj/machinery/atmospherics/unary/outlet_injector/power_change(forced = FALSE)
	if(!..())
		return
	update_icon()

/obj/machinery/atmospherics/unary/outlet_injector/process_atmos()
	..()

	injecting = 0

	if(!on || stat & NOPOWER)
		return 0

	if(air_contents.temperature > 0)
		var/transfer_moles = (air_contents.return_pressure())*volume_rate/(air_contents.temperature * R_IDEAL_GAS_EQUATION)

		var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)

		loc.assume_air(removed)
		air_update_turf()

		parent.update = 1

	return 1

/obj/machinery/atmospherics/unary/outlet_injector/proc/inject()
	if(on || injecting)
		return 0

	injecting = 1

	if(air_contents.temperature > 0)
		var/transfer_moles = (air_contents.return_pressure())*volume_rate/(air_contents.temperature * R_IDEAL_GAS_EQUATION)

		var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)

		loc.assume_air(removed)

		parent.update = 1

	flick("inject", src)

/obj/machinery/atmospherics/unary/outlet_injector/proc/broadcast_status()
	if(!radio_connection)
		return 0

	var/datum/signal/signal = new
	signal.transmission_method = 1 //radio signal
	signal.source = src

	signal.data = list(
		"tag" = id_tag,
		"device" = "AO",
		"power" = on,
		"volume_rate" = volume_rate,
		"sigtype" = "status"
	 )

	radio_connection.post_signal(src, signal, RADIO_ATMOSIA)

	return 1

/obj/machinery/atmospherics/unary/outlet_injector/atmos_init()
	..()
	set_frequency(frequency)

/obj/machinery/atmospherics/unary/outlet_injector/receive_signal(datum/signal/signal)
	if(!signal.data["tag"] || (signal.data["tag"] != id_tag) || (signal.data["sigtype"] != "command"))
		return 0

	if(signal.data["power"] != null)
		on = text2num(signal.data["power"])

	if(signal.data["power_toggle"] != null)
		on = !on

	if(signal.data["inject"] != null)
		spawn inject()
		return

	if(signal.data["set_volume_rate"] != null)
		var/number = text2num(signal.data["set_volume_rate"])
		volume_rate = between(0, number, air_contents.volume)

	if(signal.data["status"])
		spawn(2)
			broadcast_status()
		return //do not update_icon

		//log_admin("DEBUG \[[world.timeofday]\]: outlet_injector/receive_signal: unknown command \"[signal.data["command"]]\"\n[signal.debug_print()]")
		//return
	spawn(2)
		broadcast_status()
	update_icon()

	/*hide(var/i) //to make the little pipe section invisible, the icon changes.
		if(node)
			if(on)
				icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]on"
			else
				icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]off"
		else
			icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]exposed"
			on = 0
		return*/

/obj/machinery/atmospherics/unary/outlet_injector/attackby(obj/item/W, mob/user)
	if(W.tool_behaviour == TOOL_WRENCH)
		if(!(stat & NOPOWER) && on)
			to_chat(user, span_danger("You cannot unwrench this [src], turn if off first."))
			return 1
	return ..()

/obj/machinery/atmospherics/unary/outlet_injector/multitool_act(mob/user, obj/item/I)
	. = TRUE
	multitool_menu.interact(user, I)

/obj/machinery/atmospherics/unary/outlet_injector/hide(var/i)
	update_underlays()
