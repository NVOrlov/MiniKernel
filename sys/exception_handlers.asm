exception_division_by_zero:
	F_CALL	driver_video_print_string, .text
	iret
  .text:
	db "Division by zero!", 10, 0
