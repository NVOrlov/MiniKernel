; GDT constants
gdt_present_priv_application_segment = 0x90
gdt_present_priv_system_segment = 0x80
gdt_present_user_application_segment = 0x10
gdt_present_user_system_segment = 0x00
gdt_executable_readable_segment = 0x0A
gdt_writable_readable_segment = 0x02
gdt_growing_down_writable_readable_segment = 0x06
gdt_priv_code_segment_access_byte = gdt_present_priv_application_segment \
	or gdt_executable_readable_segment
gdt_priv_data_segment_access_byte = gdt_present_priv_application_segment \
	or gdt_writable_readable_segment
gdt_priv_stack_segment_access_byte = gdt_present_priv_application_segment \
	or gdt_growing_down_writable_readable_segment
gdt_4kb_size_32bit_mode_segment_flags = 0xC0

; GDT data
gdt_start:
	; GDT entry's structure:
	; dw - Limit 0:15
	; dw - Base 0:15
	; db - Base 16:23
	; db - Access byte 0:7
	; db - Flags 0:3 (7-4 bits) and Limit 16:19 (3-0 bits)
	; db - Base 24:31

	; Empty first descriptor
	dd	0, 0
	; Ring 0 code segment
	; Base: 0x00000000
	; Limit: 0xFFFFF
gdt_priv_code_segment:
	dw	0xFFFF
	dw	0x0000
	db	0x00
	db	gdt_priv_code_segment_access_byte
	db	gdt_4kb_size_32bit_mode_segment_flags + 0x0F
	db	0x00
	; Ring 0 data segment
	; Base: 0x00000000
	; Limit: 0xFFFFF
gdt_priv_data_segment:
	dw	0xFFFF
	dw	0x0000
	db	0x00
	db	gdt_priv_data_segment_access_byte
	db	gdt_4kb_size_32bit_mode_segment_flags + 0x0F
	db	0x00
	; Ring 0 stack segment
gdt_priv_stack_segment:
  .stack_segment_limit = 0xFFFFF - config_kernel_stack_size
	dw	.stack_segment_limit and 0xFFFF
	dw	config_kernel_stack_address and 0xFFFF
	db	(config_kernel_stack_address shr 16) and 0xFF
	db	gdt_priv_stack_segment_access_byte
	db	gdt_4kb_size_32bit_mode_segment_flags \
			+ (.stack_segment_limit shr 16) and 0x0F
	db	(config_kernel_stack_address shr 24) and 0xFF

gdt_size = $ - gdt_start
gdt_priv_code_segment_index = gdt_priv_code_segment - gdt_start
gdt_priv_data_segment_index = gdt_priv_data_segment - gdt_start
gdt_priv_stack_segment_index = gdt_priv_stack_segment - gdt_start

; IDT constants
idt_interrupt_gate_present = 0x8E
idt_entries_count = 256
idt_exception_entries_count = 32
idt_pic_master_empty_entries = 6

; IDT data
idt_start:
	; IDT entry's structure:
	; dw - Offset 0:15
	; dw - Selector 0:15
	; db - Unused = 0
	; db - Flags 0:8
	; dw - Offset 16:31

	; Division by zero exception
	dw	exception_division_by_zero and 0xFFFF
	dw	gdt_priv_code_segment_index
	db	0x00
	db	idt_interrupt_gate_present
	dw	(exception_division_by_zero shr 16) and 0xFFFF
	; 0x01 - 0x19 descriptors
	dq	config_pic_master_vector_offset - 1 dup 0
	; IRQ0 descriptor
	dw	irq0_handler and 0xFFFF
	dw	gdt_priv_code_segment_index
	db	0x00
	db	idt_interrupt_gate_present
	dw	(irq0_handler shr 16) and 0xFFFF
	; 0x21 - 0x26 descriptors
	dq	idt_pic_master_empty_entries dup 0
	; IRQ7 descriptor
	dw	irq7_handler and 0xFFFF
	dw	gdt_priv_code_segment_index
	db	0x00
	db	idt_interrupt_gate_present
	dw	(irq7_handler shr 16) and 0xFFFF
	; 0x28 - 0xFF descriptors
	dq	idt_entries_count - idt_exception_entries_count \
			- driver_pic_master_irq_lines_count dup 0

idt_size = $ - idt_start
