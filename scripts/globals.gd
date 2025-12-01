extends Node

enum COLORS {
	WHITE  # Solo usaremos un color para las reinas
}

enum PIECE_TYPES {
	QUEEN
}

const SPRITE_MAPPING = {
	COLORS.WHITE: {
		PIECE_TYPES.QUEEN: Vector2i(1, 1),  # Sprite de reina blanca
	},
}
