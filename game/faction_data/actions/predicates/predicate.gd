@abstract
class_name Predicate
extends Resource


static func fits_list(predicates: Array[Predicate], territory: Territory
		) -> bool:
	for predicate: Predicate in predicates:
		if not predicate._fits(territory):
			return false
	
	return true

@abstract func _fits(territory: Territory) -> bool
