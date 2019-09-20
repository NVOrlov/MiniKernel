; Ports
driver_pit_port_control = 0x43
driver_pit_port_channel_0 = 0x40
driver_pit_port_channel_1 = 0x41
driver_pit_port_channel_2 = 0x42
; Constants
driver_pit_interrupt_on_terminal_count_mode = 0x00
driver_pit_rate_generator_mode = 0x02
driver_pit_square_wave_generator_mode = 0x03
driver_pit_control_two_byte_access = 0x30

; ARGS: byte mode, word count
driver_pit_init:
	F_ENTER
	MOV_ARG eax, 0
	shl	eax, 1
	or	eax, driver_pit_control_two_byte_access
	OUTB_D	driver_pit_port_control, al
	MOV_ARG	eax, 1
	OUTB_D	driver_pit_port_channel_0, al
	mov	al, ah
	OUTB_D	driver_pit_port_channel_0, al
	F_EXIT
