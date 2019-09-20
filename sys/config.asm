config_bootloader_base_address = 0x7C00		; BIOS jumps here after POST
config_minimal_memory_amount = 0x400000		; From 0x400000 to 0x1000000
config_kernel_base_address = 0x00100000		; Physical address
config_kernel_virtual_base_address = 0xC0000000	; Virtual address (high-half)
config_kernel_stack_address = 0xC0400000	; Virtual address (high-half)
config_kernel_stack_size = 1			; Count of 4 kilobyte pages
config_video_text_color = 0x0A			; CGA text color byte
config_pic_master_vector_offset = 0x20		; IRQ0 - IRQ7
config_pic_slave_vector_offset = 0x28		; IRQ8 - IRQ15
config_pit_initial_time_interval = 0xFFFF	; Freq: 1.193 MHz
