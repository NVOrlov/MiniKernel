irq0_handler:
	OUTB_D	driver_pic_port_master_command, \
		driver_pic_ocw2_non_specific_eoi
	F_CALL	driver_video_print_string, .text
	iret
  .text:
	db "Tick! ", 0

irq7_handler:
	F_CALL	check_fake_irq, driver_pic_port_master_command
	cmp	eax, 0
	je	.fake_irq
	; Real interrupt code
	OUTB_D	driver_pic_port_master_command, \
		driver_pic_ocw2_non_specific_eoi
	jmp	.exit
  .fake_irq:
	; Fake interrupt code
	F_CALL	driver_video_print_string, .text
  .exit:
	iret
  .text:
	db "Fake interrupt test: done!", 10, 10, 0

irq15_handler:
	F_CALL	check_fake_irq, driver_pic_port_slave_command
	cmp	eax, 0
	je	.fake_irq
	; Real interrupt code
	OUTB_D	driver_pic_port_slave_command, \
		driver_pic_ocw2_non_specific_eoi
	jmp	.exit
  .fake_irq:
	; Fake interrupt code
  .exit:
	OUTB_D	driver_pic_port_master_command, \
		driver_pic_ocw2_non_specific_eoi
	iret

; ARGS: word command_port_number
; RET: 0 - fake irq, 1 - true irq
check_fake_irq:
	F_ENTER
	MOV_ARG edx, 0
	OUTB_D	dx, driver_pic_ocw3_read_is_reg
	INB_D	dx
	and	al, driver_pic_fake_irq_mask
	jz	.fake_irq
	mov	eax, 1
	jmp	.exit
  .fake_irq:
	xor	eax, eax
  .exit:
	F_EXIT
