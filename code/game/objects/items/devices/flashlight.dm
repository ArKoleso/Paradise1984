/obj/item/flashlight
	name = "flashlight"
	desc = "A hand-held emergency light."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "flashlight"
	item_state = "flashlight"
	w_class = WEIGHT_CLASS_SMALL
	flags = CONDUCT
	slot_flags = SLOT_BELT
	materials = list(MAT_METAL=50, MAT_GLASS=20)
	actions_types = list(/datum/action/item_action/toggle_light)
	var/on = FALSE
	var/brightness_on = 4 //luminosity when on
	var/togglesound = 'sound/weapons/empty.ogg'


/obj/item/flashlight/Initialize()
	. = ..()
	update_brightness()


/obj/item/flashlight/update_icon_state()
	if(on)
		icon_state = "[initial(icon_state)]-on"
	else
		icon_state = "[initial(icon_state)]"


/obj/item/flashlight/proc/update_brightness()
	if(on)
		set_light(brightness_on)
	else
		set_light(0)
	update_icon()


/obj/item/flashlight/attack_self(mob/user)
	if(!isturf(user.loc))
		to_chat(user, "You cannot turn the light on while in this [user.loc].")	//To prevent some lighting anomalities.
		return FALSE
	on = !on
	playsound(user, togglesound, 100, 1)
	update_brightness()
	update_equipped_item()
	return TRUE


/obj/item/flashlight/attack(mob/living/M, mob/living/user)
	add_fingerprint(user)
	if(on && user.zone_selected == BODY_ZONE_PRECISE_EYES)

		if(((CLUMSY in user.mutations) || user.getBrainLoss() >= 60) && prob(50))	//too dumb to use flashlight properly
			return ..()	//just hit them in the head

		if(!(istype(user, /mob/living/carbon/human) || SSticker) && SSticker.mode.name != "monkey")	//don't have dexterity
			to_chat(user, "<span class='notice'>You don't have the dexterity to do this!</span>")
			return

		var/mob/living/carbon/human/H = M	//mob has protective eyewear
		if(istype(H) && ((H.head && H.head.flags_cover & HEADCOVERSEYES) || (H.wear_mask && H.wear_mask.flags_cover & MASKCOVERSEYES) || (H.glasses && H.glasses.flags_cover & GLASSESCOVERSEYES)))
			to_chat(user, "<span class='notice'>You're going to need to remove that [(H.head && H.head.flags_cover & HEADCOVERSEYES) ? "helmet" : (H.wear_mask && H.wear_mask.flags_cover & MASKCOVERSEYES) ? "mask" : "glasses"] first.</span>")
			return

		if(M == user)	//they're using it on themselves
			if(M.flash_eyes(visual = 1))
				M.visible_message("<span class='notice'>[M] directs [src] to [M.p_their()] eyes.</span>", \
									 "<span class='notice'>You wave the light in front of your eyes! Trippy!</span>")
			else
				M.visible_message("<span class='notice'>[M] directs [src] to [M.p_their()] eyes.</span>", \
									 "<span class='notice'>You wave the light in front of your eyes.</span>")
		else

			user.visible_message("<span class='notice'>[user] directs [src] to [M]'s eyes.</span>", \
								 "<span class='notice'>You direct [src] to [M]'s eyes.</span>")

			if(istype(H)) //robots and aliens are unaffected
				var/obj/item/organ/internal/eyes/eyes = H.get_int_organ(/obj/item/organ/internal/eyes)
				if(M.stat == DEAD || !eyes || (BLINDNESS in M.mutations))	//mob is dead or fully blind
					to_chat(user, "<span class='notice'>[M]'s pupils are unresponsive to the light!</span>")
				else if((XRAY in M.mutations) || eyes.see_in_dark >= 8) //The mob's either got the X-RAY vision or has a tapetum lucidum (extreme nightvision, i.e. Vulp/Tajara with COLOURBLIND & their monkey forms).
					to_chat(user, "<span class='notice'>[M]'s pupils glow eerily!</span>")
				else //they're okay!
					if(M.flash_eyes(visual = 1))
						to_chat(user, "<span class='notice'>[M]'s pupils narrow.</span>")
	else
		return ..()

/obj/item/flashlight/extinguish_light(force = FALSE)
	if(on)
		on = FALSE
		update_brightness()
		update_equipped_item()

/obj/item/flashlight/pen
	name = "penlight"
	desc = "A pen-sized light, used by medical staff."
	icon_state = "penlight"
	item_state = ""
	belt_icon = "penlight"
	w_class = WEIGHT_CLASS_TINY
	slot_flags = SLOT_BELT | SLOT_EARS
	flags = CONDUCT
	brightness_on = 2

/obj/item/flashlight/seclite
	name = "seclite"
	desc = "A robust flashlight used by security."
	icon_state = "seclite"
	item_state = "seclite"
	belt_icon = "seclite"
	force = 9 // Not as good as a stun baton.
	brightness_on = 5 // A little better than the standard flashlight.
	hitsound = 'sound/weapons/genhit1.ogg'

/obj/item/flashlight/drone
	name = "low-power flashlight"
	desc = "A miniature lamp, that might be used by small robots."
	icon_state = "penlight"
	item_state = ""
	flags = CONDUCT
	brightness_on = 2
	w_class = WEIGHT_CLASS_TINY

// the desk lamps are a bit special
/obj/item/flashlight/lamp
	name = "desk lamp"
	desc = "A desk lamp with an adjustable mount."
	icon_state = "lamp"
	item_state = "lamp"
	brightness_on = 5
	w_class = WEIGHT_CLASS_BULKY
	flags = CONDUCT
	materials = list()
	on = TRUE


// green-shaded desk lamp
/obj/item/flashlight/lamp/green
	desc = "A classic green-shaded desk lamp."
	icon_state = "lampgreen"
	item_state = "lampgreen"



/obj/item/flashlight/lamp/verb/toggle_light()
	set name = "Toggle light"
	set category = "Object"
	set src in oview(1)

	if(!usr.stat)
		attack_self(usr)

//Bananalamp
/obj/item/flashlight/lamp/bananalamp
	name = "banana lamp"
	desc = "Only a clown would think to make a ghetto banana-shaped lamp. Even has a goofy pullstring."
	icon_state = "bananalamp"
	item_state = "bananalamp"


// FLARES

/obj/item/flashlight/flare
	name = "flare"
	desc = "A red Nanotrasen issued flare. There are instructions on the side, it reads 'pull cord, make light'."
	brightness_on = 8
	light_color = "#ff0000"
	icon_state = "flare"
	item_state = "flare"
	togglesound = 'sound/goonstation/misc/matchstick_light.ogg'
	var/can_fire_cigs = TRUE
	var/fuel = 0
	var/on_damage = 7
	var/produce_heat = 1500
	var/fuel_lower = 800
	var/fuel_upp = 1000


/obj/item/flashlight/flare/Initialize()
	fuel = rand(fuel_lower, fuel_upp)
	. = ..()


/obj/item/flashlight/flare/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()


/obj/item/flashlight/flare/update_icon_state()
	if(on)
		item_state = "[initial(item_state)]-on"
	else
		item_state = "[initial(item_state)]"

	if(!fuel)
		icon_state = "[initial(icon_state)]-empty"
		return
	..()


/obj/item/flashlight/flare/process()
	var/turf/pos = get_turf(src)
	if(pos && produce_heat)
		pos.hotspot_expose(produce_heat, 5)
	fuel = max(fuel - 1, 0)
	if(!fuel || !on)
		turn_off()
		STOP_PROCESSING(SSobj, src)


/obj/item/flashlight/flare/proc/turn_off()
	on = FALSE
	force = initial(force)
	damtype = initial(damtype)
	update_brightness()


/obj/item/flashlight/flare/attack_self(mob/user)
	// Usual checks
	if(!fuel)
		to_chat(user, "<span class='notice'>[src] is out of fuel.</span>")
		return
	if(on)
		to_chat(user, "<span class='notice'>[src] is already on.</span>")
		return

	. = ..()
	// All good, turn it on.
	if(.)
		user.visible_message("<span class='notice'>[user] activates [src].</span>", "<span class='notice'>You activate [src].</span>")
		if(produce_heat)
			force = on_damage
			damtype = BURN
		START_PROCESSING(SSobj, src)


// GLOWSTICKS

/obj/item/flashlight/flare/glowstick
	name = "green glowstick"
	desc = "A military-grade glowstick."
	brightness_on = 4
	color = LIGHT_COLOR_GREEN
	icon_state = "glowstick"
	item_state = "glowstick"
	togglesound = 'sound/effects/bone_break_1.ogg'
	can_fire_cigs = FALSE
	produce_heat = 0
	fuel_lower = 1600
	fuel_upp = 2000
	blocks_emissive = FALSE
	var/chemglow_sprite_type = "green"


/obj/item/flashlight/flare/glowstick/Initialize()
	light_color = color
	..()


/obj/item/flashlight/flare/glowstick/update_icon_state()
	if(!fuel)
		icon_state = "glowstick-empty"


/obj/item/flashlight/flare/glowstick/update_overlays()
	. = ..()
	if(on)
		var/mutable_appearance/glowstick_overlay = mutable_appearance(icon, "glowstick-glow")
		glowstick_overlay.color = color
		. += glowstick_overlay


/obj/item/flashlight/flare/glowstick/red
	name = "red glowstick"
	color = LIGHT_COLOR_RED
	chemglow_sprite_type = "red"

/obj/item/flashlight/flare/glowstick/green
	name = "green glowstick"

/obj/item/flashlight/flare/glowstick/blue
	name = "blue glowstick"
	color = LIGHT_COLOR_BLUE
	chemglow_sprite_type = "blue"

/obj/item/flashlight/flare/glowstick/orange
	name = "orange glowstick"
	color = LIGHT_COLOR_ORANGE
	chemglow_sprite_type = "orange"

/obj/item/flashlight/flare/glowstick/yellow
	name = "yellow glowstick"
	color = LIGHT_COLOR_YELLOW
	chemglow_sprite_type = "yellow"

/obj/item/flashlight/flare/glowstick/pink
	name = "pink glowstick"
	color = LIGHT_COLOR_PINK
	chemglow_sprite_type = "pink"

/obj/item/flashlight/flare/glowstick/emergency
	name = "emergency glowstick"
	desc = "A cheap looking, mass produced glowstick. You can practically feel it was made on a tight budget."
	color = LIGHT_COLOR_BLUE
	fuel_lower = 30
	fuel_upp = 90
	chemglow_sprite_type = "blue"

/obj/item/flashlight/flare/glowstick/random
	name = "random colored glowstick"
	icon_state = "random_glowstick"
	color = null

/obj/item/flashlight/flare/glowstick/random/Initialize()
	. = ..()
	var/T = pick(typesof(/obj/item/flashlight/flare/glowstick) - /obj/item/flashlight/flare/glowstick/random - /obj/item/flashlight/flare/glowstick/emergency)
	new T(loc)
	qdel(src) // return INITIALIZE_HINT_QDEL <-- Doesn't work


/obj/item/flashlight/flare/extinguish_light(force = FALSE)
	if(force)
		fuel = 0
		visible_message(span_danger("[src] burns up rapidly!"))
	else
		visible_message(span_danger("[src] dims slightly before scattering the shadows around it."))

/obj/item/flashlight/flare/torch
	name = "torch"
	desc = "A torch fashioned from some leaves and a log."
	w_class = WEIGHT_CLASS_BULKY
	brightness_on = 7
	icon_state = "torch"
	item_state = "torch"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	light_color = LIGHT_COLOR_ORANGE
	on_damage = 10

/obj/item/flashlight/slime
	gender = PLURAL
	name = "glowing slime extract"
	desc = "A glowing ball of what appears to be amber."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "floor1" //not a slime extract sprite but... something close enough!
	item_state = "slime"
	w_class = WEIGHT_CLASS_TINY
	brightness_on = 6
	light_color = "#FFBF00"
	materials = list()
	on = TRUE //Bio-luminesence has one setting, on.


/obj/item/flashlight/slime/update_icon_state()
	return


/obj/item/flashlight/slime/attack_self(mob/user)
	return //Bio-luminescence does not toggle.

/obj/item/flashlight/slime/extinguish_light(force = FALSE)
	if(force)
		visible_message(span_danger("[src] withers away."))
		qdel(src)
	else
		visible_message(span_danger("[src] dims slightly before scattering the shadows around it."))

/obj/item/flashlight/emp
	origin_tech = "magnets=3;syndicate=1"

	var/emp_max_charges = 4
	var/emp_cur_charges = 4
	var/charge_tick = 0


/obj/item/flashlight/emp/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)


/obj/item/flashlight/emp/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/flashlight/emp/process()
	charge_tick++
	if(charge_tick < 10)
		return FALSE
	charge_tick = 0
	emp_cur_charges = min(emp_cur_charges+1, emp_max_charges)
	return TRUE

/obj/item/flashlight/emp/attack(mob/living/M, mob/living/user)
	if(on && user.zone_selected == BODY_ZONE_PRECISE_EYES) // call original attack proc only if aiming at the eyes
		..()
	return


/obj/item/flashlight/emp/afterattack(atom/A, mob/user, proximity)
	if(!proximity)
		return
	if(emp_cur_charges > 0)
		emp_cur_charges -= 1
		if(ismob(A))
			var/mob/M = A
			add_attack_logs(user, M, "Hit with EMP-light")
		to_chat(user, "[src] now has [emp_cur_charges] charge\s.")
		A.emp_act(1)
	else
		to_chat(user, "<span class='warning'>\The [src] needs time to recharge!</span>")


/obj/item/flashlight/spotlight //invisible lighting source
	name = "disco light"
	desc = "Groovy..."
	icon_state = null
	light_color = null
	brightness_on = 0
	light_range = 0
	light_power = 10
	alpha = 0
	layer = 0
	on = TRUE
	anchored = TRUE
	var/range = null
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
