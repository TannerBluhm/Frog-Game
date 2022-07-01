extends Node

func is_close_to(a: float, b: float, margin: float = 0.001) -> bool:
	return (a < b + margin and a > b - margin)
