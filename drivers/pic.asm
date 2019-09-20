; Ports
driver_pic_port_master_command = 0x20
driver_pic_port_master_data = 0x21
driver_pic_port_slave_command = 0xA0
driver_pic_port_slave_data = 0xA1
; Constants
driver_pic_master_irq_lines_count = 8
driver_pic_slave_irq_lines_count = 8
driver_pic_icw1_initialize = 0x10
driver_pic_icw1_icw4 = 0x01
driver_pic_icw1 = driver_pic_icw1_initialize or driver_pic_icw1_icw4
driver_pic_icw3_master_irq2 = 0x04
driver_pic_icw3_slave_cascade_num = 0x02
driver_pic_icw4_8086_mode = 0x01
driver_pic_ocw2_non_specific_eoi = 0x20
driver_pic_ocw3_read_is_reg = 0x0B
driver_pic_irq0_mask = 0x01
driver_pic_fake_irq_mask = 0x80

; ARGS: byte master_vector_offset, byte slave_vector_offset
driver_pic_init:
	F_ENTER
	; ICW1 - initialization with ICW4
	OUTB_D	driver_pic_port_master_command, driver_pic_icw1
	OUTB_D	driver_pic_port_slave_command, driver_pic_icw1
	; ICW2 - master and slave vector offsets
	MOV_ARG	eax, 0
	OUTB_D	driver_pic_port_master_data, al
	MOV_ARG	eax, 1
	OUTB_D	driver_pic_port_slave_data, al
	; ICW3
	OUTB_D	driver_pic_port_master_data, driver_pic_icw3_master_irq2
	OUTB_D	driver_pic_port_slave_data, driver_pic_icw3_slave_cascade_num
	; ICW4 - 8086/88 mode
	OUTB_D	driver_pic_port_master_data, driver_pic_icw4_8086_mode
	OUTB_D	driver_pic_port_slave_data, driver_pic_icw4_8086_mode
	; Mask all interrupts
	F_CALL	driver_pic_mask_init, 0xFF, 0xFF
	F_EXIT

; ARGS: byte master_interrupt_mask, byte slave_interrupt_mask
driver_pic_mask_init:
	F_ENTER
	; There is no need for delay after first out instruction
	; because first out doesn't affect the second
	MOV_ARG eax, 0
	out	driver_pic_port_master_data, al
	MOV_ARG eax, 1
	out	driver_pic_port_slave_data, al
	PORT_DELAY
	F_EXIT

; ARGS: byte master_interrupt_mask, byte slave_interrupt_mask
driver_pic_mask_set:
	F_ENTER
	MOV_ARG	ebx, 0
	in	al, driver_pic_port_master_data
	or	bl, al
	MOV_ARG	ecx, 1
	in	al, driver_pic_port_slave_data
	or	cl, al
	PORT_DELAY
	F_CALL	driver_pic_mask_init, ebx, ecx
	F_EXIT

; ARGS: byte master_interrupt_mask, byte slave_interrupt_mask
driver_pic_mask_unset:
	F_ENTER
	MOV_ARG	ebx, 0
	in	al, driver_pic_port_master_data
	inc	bl
	neg	bl
	and	bl, al
	MOV_ARG	ecx, 1
	in	al, driver_pic_port_slave_data
	inc	cl
	neg	cl
	and	cl, al
	PORT_DELAY
	F_CALL	driver_pic_mask_init, ebx, ecx
	F_EXIT
