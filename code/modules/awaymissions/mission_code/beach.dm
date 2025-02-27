/obj/effect/waterfall
	name = "waterfall effect"
	icon = 'icons/effects/effects.dmi'
	icon_state = "extinguish"
	opacity = 0
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	density = 0
	anchored = TRUE
	invisibility = INVISIBILITY_ABSTRACT

	var/water_frequency = 15
	var/water_timer = 0

/obj/effect/waterfall/New()
	. = ..()
	water_timer = addtimer(CALLBACK(src, PROC_REF(drip)), water_frequency, TIMER_STOPPABLE | TIMER_LOOP)

/obj/effect/waterfall/Destroy()
	if(water_timer)
		deltimer(water_timer)
	water_timer = null
	return ..()

/obj/effect/waterfall/proc/drip()
	var/obj/effect/particle_effect/water/W = new(loc)
	W.dir = dir
	spawn(1)
		W.loc = get_step(W, dir)
