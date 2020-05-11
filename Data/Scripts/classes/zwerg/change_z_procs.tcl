$start
$replace
proc beamto_world_all {} {
	foreach item [inv_list this] {
		// zusätzliches inv_find_obj, weil beamto_world u.U. mehrere Items ablegt (bei Kiepen mit Inhalt z.B.)
		if {[inv_find_obj this $item] >= 0} {
			beamto_world $item [get_roty this]
		}
	}
}
$with
proc beamto_world_all {} {
	set myTrue 1
	set myFalse 0
	
	set searchlockclasses [list]
	//add tools
	if {$my$print:TOOLS} {
		lappend searchlockclasses Kettensaege Presslufthammer Kristallstrahl
	}
	//add movement items
	if {$my$print:MOVEMENT} {
		lappend searchlockclasses Reithamster Hoverboard
	}
	//add transport items
	if {$my$print:TRANSPORT} {
		lappend searchlockclasses Holzkiepe Grosse_Holzkiepe Schubkarren
	}
	
	set lockclasses [list]
	set rememberItems [list]
	
	//search and remember items
	foreach item [inv_list this] {
		set objclass [get_objclass $item]
		
		if {[lsearch $searchlockclasses $objclass] > -1} {
			if {[lsearch $lockclasses $objclass] == -1} {
				
				set canAppend 1
				
				//find lower items
				if {$my$print:LOWER_ITEMS} {
					if {[lsearch {Reithamster} $objclass] > -1} {
						//if item is a Reithamster and in inventory is a Hoverboard
						if {[inv_find this Hoverboard]  > -1} {
							set canAppend 0
						}
					} elseif {[lsearch {Holzkiepe} $objclass] > -1} {
						//if item is a Holzkiepe and in inventory is a Grosse_Holzkiepe
						if {[inv_find this Grosse_Holzkiepe]  > -1} {
							set canAppend 0
						}
					}
				}
				
				if {$canAppend} {
					//remember item
					if {$my$print:MULTIPLE_ITEMS} {
						lappend lockclasses $objclass
					}
					lappend rememberItems $item
				}
			}
		}
	}

	//add weapons
	if {$my$print:WEAPONS} {
		set bestBallistic [get_best_weapon this 1]
		set ballistic [lindex $bestBallistic 0]
		if {$ballistic != -1} {
			lappend rememberItems $ballistic
		}
		set bestWeaponShield [get_best_weapon this 0]
		set weapon [lindex $bestWeaponShield 0]
		if {$weapon != -1} {
			lappend rememberItems $weapon
			//keep fitting amulet
			set amuletPos -1
			switch [get_objclass $weapon] {
				Axt_unq_2 { set amuletPos [inv_find this Amulett_1] }
				Axt_unq_4 { set amuletPos [inv_find this Amulett_2] }
				Schwert_2 { set amuletPos [inv_find this Amulett_3] }
				default {}
			}
			if {$amuletPos != -1} {
				lappend rememberItems [inv_get this $amuletPos]
			}
		}
		set shield [lindex $bestWeaponShield 1]
		if {$shield != -1} {
			lappend rememberItems $shield
		}
	}
	
	//drop all items
	foreach item [inv_list this] {
		if {[inv_find_obj this $item] >= 0} {
			beamto_world $item [get_roty this]
		}
	}
	
	//get all remembered items
	foreach item $rememberItems {
		take_item $item
	}
	
}
$end


$if:!mod:BugFix

$start
$replace
			set_posbottom $invitem [vector_fix $npos]
			from_wall $item
$with
			if {[get_objclass $invitem] == "Schatzbuch"} {
				call_method $invitem initiate [vector_fix $npos]
			} else {
				set_posbottom $invitem [vector_fix $npos]
			}
			from_wall $invitem
$end

$ifend
