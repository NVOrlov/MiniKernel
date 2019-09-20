org config_kernel_virtual_base_address + config_kernel_base_address

kernel_enter:
	call	.recover_context
	call	.initialize_video
	F_CALL	driver_video_print_string, .greetings_text
	call	.initialize_interrupts
	call	create_fake_irq7
	call	.initialize_timer
  .loop:
	jmp 	.loop

  .recover_context:
	mov 	dword [directory_table], 0
	mov	eax, directory_table - config_kernel_virtual_base_address
	mov	cr3, eax
	lgdt	[.gdt_info]
	ret

  .initialize_video:
	call	driver_video_init
	ret

  .initialize_interrupts:
	F_CALL	driver_pic_init, \
		config_pic_master_vector_offset, \
		config_pic_slave_vector_offset
	F_CALL	driver_pic_mask_unset, driver_pic_irq0_mask, 0
	lidt	[.idt_info]
	sti
	ret

  .initialize_timer:
	F_CALL	driver_pit_init, \
		driver_pit_rate_generator_mode, \
		config_pit_initial_time_interval
	ret

  .greetings_text:
	db	"Hello to the MiniKernel!", 10
	db	"Just a little video and timer test...", 10, 0

  .gdt_info:
	dw	gdt_size - 1
	dd	gdt_start

  .idt_info:
	dw	idt_size - 1
	dd	idt_start
