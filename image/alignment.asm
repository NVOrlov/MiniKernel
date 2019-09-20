image_align:
  .heads = 16
  .spt = 63
  .sector = 512
  .image_size = .heads * .spt * .sector + $$ - 512
	db 	.image_size - 1 - ($ + .image_size - 1) mod .image_size dup 0
