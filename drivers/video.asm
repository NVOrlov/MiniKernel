; Constants
driver_video_hardware_flags = 0xC0004010
driver_video_hardware_flags_video_mode_offset = 4
driver_video_hardware_flags_video_mode_mask = 0x03
driver_video_hardware_flags_video_mode_monochrome = 0x03
driver_video_text_framebuffer_pointer_monochrome = 0xC00B0000
driver_video_text_framebuffer_pointer_color = 0xC00B8000
driver_video_row_count = 25
driver_video_row_byte_size = 160

; ARGS: none
driver_video_init:
	mov	eax, [driver_video_hardware_flags]
	shr	eax, driver_video_hardware_flags_video_mode_offset
	and	eax, driver_video_hardware_flags_video_mode_mask
	cmp	eax, driver_video_hardware_flags_video_mode_monochrome
	je	.monochrome
	mov	[driver_video_text_framebuffer_pointer], \
		driver_video_text_framebuffer_pointer_color
	ret
  .monochrome:
	mov	[driver_video_text_framebuffer_pointer], \
		driver_video_text_framebuffer_pointer_monochrome
	ret

; ARGS: byte character
driver_video_print_char:
	F_ENTER
	MOV_ARG	eax, 0
	xor	ebx, ebx
	mov	bx, [driver_video_print_position]
	cmp	bx, driver_video_row_count * driver_video_row_byte_size
	jge	.new_screen
	add	ebx, [driver_video_text_framebuffer_pointer]
	mov	byte [ebx], al
	mov	byte [ebx + 1], config_video_text_color
	add	word [driver_video_print_position], 2
	jmp	.exit
  .new_screen:
	mov	word [driver_video_print_position], 0
  .exit:
	F_EXIT

; ARGS: dword buffer_address
driver_video_print_string:
	F_ENTER
	MOV_ARG	ebx, 0
  .draw_loop:
	mov	eax, [ebx]
	inc	ebx
	cmp	al, 10
	je	.new_row
	cmp	al, 0
	je	.exit
	F_CALL	driver_video_print_char, eax
	jmp	.draw_loop
  .new_row:
	xor	dx, dx
	mov	ax, [driver_video_print_position]
	mov	cx, driver_video_row_byte_size
	div	cx
	inc	ax
	cmp	ax, driver_video_row_count
	je	.last_row
	mov	cx, driver_video_row_byte_size
	mul	cx
	mov	[driver_video_print_position], ax
	jmp	.draw_loop
  .last_row:
	mov	word [driver_video_print_position], 0
	jmp	.draw_loop
  .exit:
	F_EXIT

driver_video_text_framebuffer_pointer dd ?
driver_video_print_position dw 0
