/*
Maybe you could combine elements from the Blob mode into a new Alien mode since Blob rarely seems to get much
play these days, is hard as fuck to actually win, and gets more use as a random event these days.

The main Alien's objective is to corrupt, infest, whatever you want to call it to a certain % of the station.
Give it an ability which, every so often allows it to drop a bunch of slime which infests floors and walls. The
main alien would be poor at actually killing anyone, but very difficult to bring down - maybe it is immune to
brute and toxic damage, and fire kills it but takes a long exposure time to do so. Suffocation/exposure would
be the only reliable way to off it.

Like the Wizard, the Alien can select from a few abilities, though they center around building things in the
slime rather than being straight up attacks or spells. For instance, it might be able to build tunnels which
take it instantly from one slime patch to another, or pods which huff poison gas at anyone that gets too close.
It can only build in areas it slimed, and the abilities have long cooldowns. The structures can also be destroyed
by anyone determined enough.

Anyone who stays in the slime for too long will end up becoming a mutant which serves the main alien. This would
give the alien an incentive to try and incapacitate or find incapacitated people to drag back into its
territory to gain more slaves. The mutants are basically just monkeys - crippled with only a few equipment
slots, but share some of the alien's durability.

To get rid of the slime, you can weld it, taze/laser it, set it on fire, blow it up or get the janitor
to clean it up, or just beat the shit out of it (which takes ages).


[11:32] <&Rick> nah dont let it wear clothing
[11:32] <&Rick> but have alien items that replace suit functions
[11:32] <&Rick> like an item that lets them walk around in space with no penalty
[11:32] <&Nannek> yeah cool
[11:33] <&Nannek> thinking making it breathe plasma or would that make the aliens life too hard
[11:33] <&Rick> hmm
[11:33] <&Rick> maybe breathing plasma benefit it
[11:33] <&Rick> but not required
[11:33] <&Nannek> yeah makes them stronger/faster or something
[11:33] <&Rick> like have stamina or something that recharges when the alien is breathing plasma
[11:33] <&Nannek> which in turn lets it uses special alien abilities
[11:34] <&Rick> if theres something the alien should be able to wear
[11:34] <&Rick> is a full human skin body suit
[11:34] <&Nannek> oh
[11:34] <&Rick> make it so you can skin dead people
[11:34] <&Nannek> that could be fun
[11:34] <&Rick> 8)
[11:34] <&Rick> but no clothing even if wearing a human suit
[11:34] <&Nannek> then they can pretend to be the human for a limited time before the suit rips apart
[11:35] <&Rick> yeah
[11:35] <&Nannek> thinking not letting aliens understand humans and vice versa
[11:35] <&Rick> that would be hilarious
[11:35] <&Rick> have a universal translator item
[11:35] <&Rick> so if the alien loses it
[11:35] <&Rick> they lose being able to communicate
[11:35] <&Nannek> kk
*/

//This is fine right now, if we're adding organ specific damage this needs to be updated
/mob/living/carbon/alien/humanoid/New()
	spawn (1)
		var/datum/reagents/R = new/datum/reagents(100)
		reagents = R
		R.my_atom = src
		if(!istype(src, /mob/living/carbon/alien/humanoid/queen))
			src.stand_icon = new /icon('alien.dmi', "alien_s")
			src.lying_icon = new /icon('alien.dmi', "alien_l")
		src.icon = src.stand_icon

		if(src.name == "alien") src.name = text("alien ([rand(1, 1000)])")
		src.real_name = src.name
		src << "\blue Your icons have been generated!"

		update_clothing()
	..()


//This is fine, works the same as a human
/mob/living/carbon/alien/humanoid/Bump(atom/movable/AM as mob|obj, yes)
	spawn( 0 )
		if ((!( yes ) || src.now_pushing))
			return
		src.now_pushing = 1
		if(ismob(AM))
			var/mob/tmob = AM
			if(istype(tmob, /mob/living/carbon/human) && tmob.mutations & 32)
				if(prob(20))
					for(var/mob/M in viewers(src, null))
						if(M.client)
							M << M << "\red <B>[src] fails to push [tmob]'s fat ass out of the way.</B>"
					src.now_pushing = 0
					return
		src.now_pushing = 0
		..()
		if (!istype(AM, /atom/movable))
			return
		if (!src.now_pushing)
			src.now_pushing = 1
			if (!AM.anchored)
				var/t = get_dir(src, AM)
				step(AM, t)
			src.now_pushing = null
		return
	return

//This is fine, maybe refine it a bit so they're faster than humans

/mob/living/carbon/alien/humanoid/movement_delay()
	var/tally = 0
	if (istype(src, /mob/living/carbon/alien/humanoid/queen))
		tally += 5
	return tally

//This needs to be fixed
/mob/living/carbon/alien/humanoid/Stat()
	..()

	statpanel("Status")
	if (src.client && src.client.holder)
		stat(null, "([x], [y], [z])")

	stat(null, "Intent: [src.a_intent]")
	stat(null, "Move Mode: [src.m_intent]")

	if (src.client.statpanel == "Status")
		if (src.internal)
			if (!src.internal.air_contents)
				del(src.internal)
			else
				stat("Internal Atmosphere Info", src.internal.name)
				stat("Tank Pressure", src.internal.air_contents.return_pressure())
				stat("Distribution Pressure", src.internal.distribute_pressure)

		stat(null, "Plasma Stored: [src.toxloss]")


//This is okay I guess unless we add alien shields or something. Should be cleaned up a bit.
/mob/living/carbon/alien/humanoid/bullet_act(flag, A as obj)
	var/shielded = 0
	for(var/obj/item/device/shield/S in src)
		if (S.active)
			if (flag == "bullet")
				return
			shielded = 1
			S.active = 0
			S.icon_state = "shield0"
	for(var/obj/item/weapon/cloaking_device/S in src)
		if (S.active)
			shielded = 1
			S.active = 0
			S.icon_state = "shield0"
	if ((shielded && flag != "bullet"))
		if (!flag)
			src << "\blue Your shield was disturbed by a laser!"
			if(src.paralysis <= 12)	src.paralysis = 12
			src.updatehealth()
	if (locate(/obj/item/weapon/grab, src))
		var/mob/safe = null
		if (istype(src.l_hand, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = src.l_hand
			if ((G.state == 3 && get_dir(src, A) == src.dir))
				safe = G.affecting
		if (istype(src.r_hand, /obj/item/weapon/grab))
			var/obj/item/weapon.grab/G = src.r_hand
			if ((G.state == 3 && get_dir(src, A) == src.dir))
				safe = G.affecting
		if (safe)
			return safe.bullet_act(flag, A)
	if (flag == PROJECTILE_BULLET)
		var/d = 51
		if (src.stat != 2)
			src.bruteloss += d
			src.updatehealth()
			if (prob(50))
				if(src.weakened <= 5)	src.weakened = 5
		return
	else if (flag == PROJECTILE_TASER)
		if (prob(75) && src.stunned <= 10)
			src.stunned = 10
		else
			src.weakened = 10
		if (src.stuttering < 10)
			src.stuttering = 10
	else if(flag == PROJECTILE_LASER)
		var/d = 20

		if (!src.eye_blurry) src.eye_blurry = 4 //This stuff makes no sense but lasers need a buff.
		if (prob(25)) src.stunned++

		if (src.stat != 2)
			src.bruteloss += d
			src.updatehealth()
			if (prob(25))
				src.stunned = 1
	else if(flag == PROJECTILE_PULSE)
		var/d = 40

		if (src.stat != 2)
			src.bruteloss += d
			src.updatehealth()
			if (prob(50))
				src.stunned = min(src.stunned, 5)
	else if(flag == PROJECTILE_BOLT)
		src.toxloss += 3
		src.radiation += 100
		src.updatehealth()
		src.stuttering += 5
		src.drowsyness += 5
	return

/mob/living/carbon/alien/humanoid/ex_act(severity)
	flick("flash", src.flash)

	if (src.stat == 2 && src.client)
		src.gib(1)
		return

	else if (src.stat == 2 && !src.client)
		var/virus = src.virus
		gibs(src.loc, virus)
		del(src)
		return

	var/shielded = 0
	for(var/obj/item/device/shield/S in src)
		if (S.active)
			shielded = 1
			break

	var/b_loss = null
	var/f_loss = null
	switch (severity)
		if (1.0)
			b_loss += 500
			src.gib(1)
			return

		if (2.0)
			if (!shielded)
				b_loss += 60

			f_loss += 60

			src.ear_damage += 30
			src.ear_deaf += 120

		if(3.0)
			b_loss += 30
			if (prob(50) && !shielded)
				src.paralysis += 1
			src.ear_damage += 15
			src.ear_deaf += 60

	src.bruteloss += b_loss
	src.fireloss += f_loss

	src.updatehealth()

/mob/living/carbon/alien/humanoid/blob_act()
	if (src.stat == 2)
		return
	var/shielded = 0
	for(var/obj/item/device/shield/S in src)
		if (S.active)
			shielded = 1
	var/damage = null
	if (src.stat != 2)
		damage = rand(1,20)

	if(shielded)
		damage /= 4


	src.show_message("\red The blob attacks you!")

	src.bruteloss += damage

	return

//unequip
/mob/living/carbon/alien/humanoid/u_equip(obj/item/W as obj)
	if (W == src.wear_suit)
		src.wear_suit = null
	else if (W == src.head)
		src.head = null
	else if (W == src.r_store)
		src.r_store = null
	else if (W == src.l_store)
		src.l_store = null
	else if (W == src.r_hand)
		src.r_hand = null
	else if (W == src.l_hand)
		src.l_hand = null

/mob/living/carbon/alien/humanoid/db_click(text, t1)
	var/obj/item/W = src.equipped()
	var/emptyHand = (W == null)
	if ((!emptyHand) && (!istype(W, /obj/item)))
		return
	if (emptyHand)
		usr.next_move = usr.prev_move
		usr:lastDblClick -= 3	//permit the double-click redirection to proceed.
	switch(text)

//if emptyhand then wear the suit, no bedsheet clothes for the alien

		if("o_clothing")
			if (src.wear_suit)
				if (emptyHand)
					src.wear_suit.DblClick()
				return
			if (( istype(W, /obj/alien/skin_suit) ))
				src.u_equip(W)
				src.head = W
				return
			return
/*			if (!( istype(W, /obj/item/clothing/suit) ))
				return
			src.u_equip(W)
			src.wear_suit = W
			W.equipped(src, text)
*/
		if("head")
			if (src.head)
				if (emptyHand)
					src.head.DblClick()
				return
			if (( istype(W, /obj/alien/head) ))
				src.u_equip(W)
				src.head = W
				return
			return
/*			if (!( istype(W, /obj/item/clothing/head) ))
				return
			src.u_equip(W)
			src.head = W
			W.equipped(src, text)
*/
		if("storage1")
			if (src.l_store)
				if (emptyHand)
					src.l_store.DblClick()
				return
			if ((!( istype(W, /obj/item) ) || W.w_class > 3))
				return
			src.u_equip(W)
			src.l_store = W
		if("storage2")
			if (src.r_store)
				if (emptyHand)
					src.r_store.DblClick()
				return
			if ((!( istype(W, /obj/item) ) || W.w_class > 3))
				return
			src.u_equip(W)
			src.r_store = W
		else
	return

/mob/living/carbon/alien/humanoid/meteorhit(O as obj)
	for(var/mob/M in viewers(src, null))
		if ((M.client && !( M.blinded )))
			M.show_message(text("\red [] has been hit by []", src, O), 1)
	if (src.health > 0)
		src.bruteloss += (istype(O, /obj/meteor/small) ? 10 : 25)
		src.fireloss += 30

		src.updatehealth()
	return

/mob/living/carbon/alien/humanoid/Move(a, b, flag)
	if (src.buckled)
		return 0

	if (src.restrained())
		src.pulling = null

	var/t7 = 1
	if (src.restrained())
		for(var/mob/M in range(src, 1))
			if ((M.pulling == src && M.stat == 0 && !( M.restrained() )))
				t7 = null
	if ((t7 && (src.pulling && ((get_dist(src, src.pulling) <= 1 || src.pulling.loc == src.loc) && (src.client && src.client.moving)))))
		var/turf/T = src.loc
		. = ..()

		if (src.pulling && src.pulling.loc)
			if(!( isturf(src.pulling.loc) ))
				src.pulling = null
				return
			else
				if(Debug)
					diary <<"src.pulling disappeared? at __LINE__ in mob.dm - src.pulling = [src.pulling]"
					diary <<"REPORT THIS"

		/////
		if(src.pulling && src.pulling.anchored)
			src.pulling = null
			return

		if (!src.restrained())
			var/diag = get_dir(src, src.pulling)
			if ((diag - 1) & diag)
			else
				diag = null
			if ((get_dist(src, src.pulling) > 1 || diag))
				if (ismob(src.pulling))
					var/mob/M = src.pulling
					var/ok = 1
					if (locate(/obj/item/weapon/grab, M.grabbed_by))
						if (prob(75))
							var/obj/item/weapon/grab/G = pick(M.grabbed_by)
							if (istype(G, /obj/item/weapon/grab))
								for(var/mob/O in viewers(M, null))
									O.show_message(text("\red [] has been pulled from []'s grip by []", G.affecting, G.assailant, src), 1)
								//G = null
								del(G)
						else
							ok = 0
						if (locate(/obj/item/weapon/grab, M.grabbed_by.len))
							ok = 0
					if (ok)
						var/t = M.pulling
						M.pulling = null

						step(src.pulling, get_dir(src.pulling.loc, T))
						M.pulling = t
				else
					if (src.pulling)
						step(src.pulling, get_dir(src.pulling.loc, T))
	else
		src.pulling = null
		. = ..()
	if ((src.s_active && !( s_active in src.contents ) ))
		src.s_active.close(src)
	return

/mob/living/carbon/alien/humanoid/update_clothing()
	..()

	if (src.monkeyizing)
		return

	src.overlays = null

	if(src.buckled)
		if(istype(src.buckled, /obj/stool/bed))
			src.lying = 1
		else
			src.lying = 0

	// Automatically drop anything in store / id / belt if you're not wearing a uniform.
	if (src.zone_sel)
		src.zone_sel.overlays = null
		src.zone_sel.overlays += src.body_standing
		src.zone_sel.overlays += image("icon" = 'zone_sel.dmi', "icon_state" = text("[]", src.zone_sel.selecting))

	if (src.lying)
		src.icon = src.lying_icon

		src.overlays += src.body_lying

		if (src.face_lying)
			src.overlays += src.face_lying
	else
		src.icon = src.stand_icon

		src.overlays += src.body_standing

		if (src.face_standing)
			src.overlays += src.face_standing

	// Uniform
	if (src.client)
		src.client.screen -= src.hud_used.other
		src.client.screen -= src.hud_used.intents
		src.client.screen -= src.hud_used.mov_int

	// ???
	if (src.client && src.other)
		src.client.screen += src.hud_used.other


	if (src.client)
		if (src.i_select)
			if (src.intent)
				src.client.screen += src.hud_used.intents

				var/list/L = dd_text2list(src.intent, ",")
				L[1] += ":-11"
				src.i_select.screen_loc = dd_list2text(L,",") //ICONS4, FUCKING SHIT
			else
				src.i_select.screen_loc = null
		if (src.m_select)
			if (src.m_int)
				src.client.screen += src.hud_used.mov_int

				var/list/L = dd_text2list(src.m_int, ",")
				L[1] += ":-11"
				src.m_select.screen_loc = dd_list2text(L,",") //ICONS4, FUCKING SHIT
			else
				src.m_select.screen_loc = null

	if (src.wear_suit)
		var/t1 = src.wear_suit.item_state
		if (!t1)
			t1 = src.wear_suit.icon_state
		src.overlays += image("icon" = 'mob.dmi', "icon_state" = text("[][]", t1, (!( src.lying ) ? null : "2")), "layer" = MOB_LAYER)
		if (src.wear_suit.blood_DNA)
			if (istype(src.wear_suit, /obj/item/clothing/suit/armor))
				src.overlays += image("icon" = 'blood.dmi', "icon_state" = "armorblood[!src.lying ? "" : "2"]", "layer" = MOB_LAYER)
			else
				src.overlays += image("icon" = 'blood.dmi', "icon_state" = "suitblood[!src.lying ? "" : "2"]", "layer" = MOB_LAYER)
		src.wear_suit.screen_loc = ui_iclothing
		if (istype(src.wear_suit, /obj/item/clothing/suit/straight_jacket))
			if (src.handcuffed)
				src.handcuffed.loc = src.loc
				src.handcuffed.layer = initial(src.handcuffed.layer)
				src.handcuffed = null
			if ((src.l_hand || src.r_hand))
				var/h = src.hand
				src.hand = 1
				drop_item()
				src.hand = 0
				drop_item()
				src.hand = h

	// Head
	if (src.head)
		var/t1 = src.head.item_state
		if (!t1)
			t1 = src.head.icon_state
		src.overlays += image("icon" = 'mob.dmi', "icon_state" = text("[][]", t1, (!( src.lying ) ? null : "2")), "layer" = MOB_LAYER)
		if (src.head.blood_DNA)
			src.overlays += image("icon" = 'blood.dmi', "icon_state" = "helmetblood[!src.lying ? "" : "2"]", "layer" = MOB_LAYER)
		src.head.screen_loc = ui_oclothing

	if (src.l_store)
		src.l_store.screen_loc = ui_storage1

	if (src.r_store)
		src.r_store.screen_loc = ui_storage2

	if (src.client)
		src.client.screen -= src.contents
		src.client.screen += src.contents

	if (src.r_hand)
		src.overlays += image("icon" = 'items_righthand.dmi', "icon_state" = src.r_hand.item_state ? src.r_hand.item_state : src.r_hand.icon_state, "layer" = MOB_LAYER+1)

		src.r_hand.screen_loc = ui_id

	if (src.l_hand)
		src.overlays += image("icon" = 'items_lefthand.dmi', "icon_state" = src.l_hand.item_state ? src.l_hand.item_state : src.l_hand.icon_state, "layer" = MOB_LAYER+1)

		src.l_hand.screen_loc = ui_belt



	var/shielded = 0
	for (var/obj/item/device/shield/S in src)
		if (S.active)
			shielded = 1
			break

	for (var/obj/item/weapon/cloaking_device/S in src)
		if (S.active)
			shielded = 2
			break

	if (shielded == 2 || src.alien_invis)
		src.invisibility = 2
	else
		src.invisibility = 0

	if (shielded || src.alien_invis)
		src.overlays += image("icon" = 'mob.dmi', "icon_state" = "shield", "layer" = MOB_LAYER)

	for (var/mob/M in viewers(1, src))
		if ((M.client && M.machine == src))
			spawn (0)
				src.show_inv(M)
				return

	src.last_b_state = src.stat

/mob/living/carbon/alien/humanoid/hand_p(mob/M as mob)
	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if (M.a_intent == "hurt")
		if (istype(M.wear_mask, /obj/item/clothing/mask/muzzle))
			return
		if (src.health > 0)
			for(var/mob/O in viewers(src, null))
				if ((O.client && !( O.blinded )))
					O.show_message(text("\red <B>[M.name] has bit []!</B>", src), 1)
			bruteloss  += rand(1, 3)

			src.updatehealth()
	return

/mob/living/carbon/alien/humanoid/attack_paw(mob/M as mob)
	if (M.a_intent == "help")
		src.sleeping = 0
		src.resting = 0
		if (src.paralysis >= 3) src.paralysis -= 3
		if (src.stunned >= 3) src.stunned -= 3
		if (src.weakened >= 3) src.weakened -= 3
		for(var/mob/O in viewers(src, null))
			O.show_message(text("\blue The monkey shakes [src] trying to wake him up!", ), 1)
	else
		if (istype(src.wear_mask, /obj/item/clothing/mask/muzzle))
			return
		if (src.health > 0)
			for(var/mob/O in viewers(src, null))
				O.show_message(text("\red <B>[M.name] has bit [src]!</B>"), 1)
			src.bruteloss  += rand(1, 3)

			src.updatehealth()
	return

/mob/living/carbon/alien/humanoid/attack_hand(mob/living/carbon/human/M as mob)
	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if (istype(src.loc, /turf) && istype(src.loc.loc, /area/start))
		M << "No attacking people at spawn, you jackass."
		return

	if ((M.gloves && M.gloves.elecgen == 1 && M.a_intent == "hurt") /*&& (!istype(src:wear_suit, /obj/item/clothing/suit/judgerobe))*/)
		if(M.gloves.uses > 0)
			M.gloves.uses--
			if (src.weakened < 5)
				src.weakened = 5
			if (src.stuttering < 5)
				src.stuttering = 5
			if (src.stunned < 5)
				src.stunned = 5
			for(var/mob/O in viewers(src, null))
				if (O.client)
					O.show_message("\red <B>[src] has been touched with the stun gloves by [M]!</B>", 1, "\red You hear someone fall", 2)
		else
			M.gloves.elecgen = 0
			M << "\red Not enough charge! "
			return

	if (M.a_intent == "help")
		if (src.health > 0)
			src.sleeping = 0
			src.resting = 0
			if (src.paralysis >= 3) src.paralysis -= 3
			if (src.stunned >= 3) src.stunned -= 3
			if (src.weakened >= 3) src.weakened -= 3
			playsound(src.loc, 'thudswoosh.ogg', 50, 1, -1)
			for(var/mob/O in viewers(src, null))
				O.show_message(text("\blue [] shakes [] trying to wake [] up!", M, src, src), 1)
		else
			if (M.health >= -75.0)
				if (((M.head && M.head.flags & 4) || ((M.wear_mask && !( M.wear_mask.flags & 32 )) || ((src.head && src.head.flags & 4) || (src.wear_mask && !( src.wear_mask.flags & 32 ))))))
					M << "\blue <B>Remove that mask!</B>"
					return
				var/obj/equip_e/human/O = new /obj/equip_e/human(  )
				O.source = M
				O.target = src
				O.s_loc = M.loc
				O.t_loc = src.loc
				O.place = "CPR"
				src.requests += O
				spawn( 0 )
					O.process()
					return
	else
		if (M.a_intent == "grab")
			if (M == src)
				return
			var/obj/item/weapon/grab/G = new /obj/item/weapon/grab( M )
			G.assailant = M
			if (M.hand)
				M.l_hand = G
			else
				M.r_hand = G
			G.layer = 20
			G.affecting = src
			src.grabbed_by += G
			G.synch()
			playsound(src.loc, 'thudswoosh.ogg', 50, 1, -1)
			for(var/mob/O in viewers(src, null))
				O.show_message(text("\red [] has grabbed [] passively!", M, src), 1)
		else
			if (M.a_intent == "hurt" && !(M.gloves && M.gloves.elecgen == 1))
				var/damage = rand(1, 9)
				if (prob(90))
					if (M.mutations & 8)
						damage += 5
						spawn(0)
							src.paralysis += 1
							step_away(src,M,15)
							sleep(3)
							step_away(src,M,15)
					playsound(src.loc, "punch", 25, 1, -1)
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[] has punched []!</B>", M, src), 1)
					if (damage > 4.9)
						if (src.weakened < 10)
							src.weakened = rand(10, 15)
						for(var/mob/O in viewers(M, null))
							O.show_message(text("\red <B>[] has weakened []!</B>", M, src), 1, "\red You hear someone fall.", 2)
					src.bruteloss += damage


					src.updatehealth()
				else
					playsound(src.loc, 'punchmiss.ogg', 25, 1, -1)
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[] has attempted to punch []!</B>", M, src), 1)
					return
			else
				if (!( src.lying ) && !(M.gloves && M.gloves.elecgen == 1))
					var/randn = rand(1, 100)
					if (randn <= 25)
						src.weakened = 2
						playsound(src.loc, 'thudswoosh.ogg', 50, 1, -1)
						for(var/mob/O in viewers(src, null))
							O.show_message(text("\red <B>[] has pushed down []!</B>", M, src), 1)
					else
						if (randn <= 60)
							src.drop_item()
							playsound(src.loc, 'thudswoosh.ogg', 50, 1, -1)
							for(var/mob/O in viewers(src, null))
								O.show_message(text("\red <B>[] has disarmed []!</B>", M, src), 1)
						else
							playsound(src.loc, 'punchmiss.ogg', 25, 1, -1)
							for(var/mob/O in viewers(src, null))
								O.show_message(text("\red <B>[] has attempted to disarm []!</B>", M, src), 1)
	return

/* aliens attacking each other!!
/mob/living/carbon/alien/humanoid/attack_alien()
//todo, put code here
	return
*/





/mob/living/carbon/alien/humanoid/restrained()
	if (src.handcuffed)
		return 1
	return 0


/mob/living/carbon/alien/humanoid/var/co2overloadtime = null
/mob/living/carbon/alien/humanoid/var/temperature_resistance = T0C+75

/mob/living/carbon/alien/humanoid/show_inv(mob/user as mob)

	user.machine = src
	var/dat = {"
	<B><HR><FONT size=3>[src.name]</FONT></B>
	<BR><HR>
	<BR><B>Left Hand:</B> <A href='?src=\ref[src];item=l_hand'>[(src.l_hand ? text("[]", src.l_hand) : "Nothing")]</A>
	<BR><B>Right Hand:</B> <A href='?src=\ref[src];item=r_hand'>[(src.r_hand ? text("[]", src.r_hand) : "Nothing")]</A>
	<BR><B>Head:</B> <A href='?src=\ref[src];item=head'>[(src.head ? text("[]", src.head) : "Nothing")]</A>
	<BR><B>(Exo)Suit:</B> <A href='?src=\ref[src];item=suit'>[(src.wear_suit ? text("[]", src.wear_suit) : "Nothing")]</A>
	<BR><A href='?src=\ref[src];item=pockets'>Empty Pockets</A>
	<BR><A href='?src=\ref[user];mach_close=mob[src.name]'>Close</A>
	<BR>"}
	user << browse(dat, text("window=mob[src.name];size=340x480"))
	onclose(user, "mob[src.name]")
	return

/mob/living/carbon/alien/humanoid/updatehealth()
	if (src.nodamage == 0)
	//oxyloss is only used for suicide
	//toxloss isn't used for aliens, its actually used as alien powers!!
		src.health = 100 - src.oxyloss - src.fireloss - src.bruteloss
	else
		src.health = 100
		src.stat = 0

