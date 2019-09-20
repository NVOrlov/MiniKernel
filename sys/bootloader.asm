org config_bootloader_base_address

boot:
	use16
	; 16 bit code segment
	cli				; Disable interrupts

	mov	[.boot_disk_id], dl	; Save boot disk id

	mov	ax, 0x8C00		; Set SS to 0x8C00 to resolve bug of
	mov	ss, ax			; bochs stack overflow during LBA read

	; Initialize text mode
	mov	ah, 0x00		; BIOS video interrupt init function
	mov	al, 0x03		; 80x25 text mode
	int	0x10			; BIOS video interrupt call

	; Check for the CPUID instruction
	pushfd				; Save EFLAGS
	pushfd				; Store EFLAGS
	xor	dword [esp], 0x00200000	; Change ID bit in stored EFLAGS
	popfd				; Load back EFLAGS with changed ID bit
	pushfd				; Store EFLAGS again
	pop	eax			; Load EFLAGS to check ID bit
	xor	eax, [esp]		; If ID bit was changed -> eax != 0
	test	eax, eax		; Test eax
	popfd
	mov	si, .processor_error_msg
	jz	.print_error_msg	; Processor doesn't support CPUID

	; Detecting memory
	; INT 0x15 0xE801 function can detect presented amount of memory
	; AX = CX - extended memory between 1Mb and 16Mb in 1Kb blocks
	; BX = DX - extended memory above 16Mb in 64kb blocks
	; IMPORTANT:
	; if CX = 0, then AX:BX = actual memory amount
	; if AX = 0, then CX:DX = actual memory amount
	xor	cx, cx
	xor	dx, dx
	mov	ax, 0xE801
	int	0x15			; BIOS memory interrupt call
	mov	si, .bios_memory_error_msg
	jc	.print_error_msg	; Unsupported interrupt call
	cmp	ah, 0x86
	je	.print_error_msg	; Unsupported function
	cmp	ah, 0x80
	je	.print_error_msg	; Invalid command
	cmp	cx, 0
	jz	.no_ax_bx_swap		; Data is stored in AX and BX
	mov	ax, cx
	mov	bx, dx
  .no_ax_bx_swap:
	cmp	ax, (config_minimal_memory_amount - 0x100000) shr 10
	mov	si, .not_enough_memory_error_msg
	jl	.print_error_msg

	; Check for the BIOS hard drive extensions
	mov 	ah, 0x41		; BIOS hard drive interrupt
					; extension check function
	mov	dl, [.boot_disk_id]	; Extension check magic number
	mov	bx, 0x55AA		; Extension check magic number
	int	0x13			; BIOS hard drive interrupt
	mov 	si, .bios_extension_error_msg
	jc	.print_error_msg	; Check if carry flag is set

	; Load 255 sectors after the 1st megabyte
	mov	ah, 0x42		; BIOS hard drive interrupt
					; LBA read packet
	mov	si, .lba_read_packet	; LBA read packet address
	int	0x13			; BIOS hard drive interrupt
	mov	si, .lba_read_error_msg
	jc	.print_error_msg	; Check if carry flag is set

	; Delete cursor
	mov	ah, 0x02		; BIOS set cursor interrupt
	mov	bh, 0			; Set first colomn
	mov	dh, 25			; 25-th row (invisible one)
	mov	dl, 0			; 1-st colomn
	int	0x10			; Set cursor to DH:DL (row:colomn)

	; Start enabling protected mode 
	lgdt	[.gdt_info]		; Load GDTR with gdt info
	mov	eax, cr0
	or	eax, 1			; Set protected mode bit
	mov	cr0, eax		; Enable protected mode
	jmp 	gdt_priv_code_segment_index:.protected_mode_enter

	; Print debug error message
  .print_error_msg:
	mov dx, 1			; Set cursor's position counter to the
					; second colomn (first colomn = 0)
  .printing_loop:
	mov	al, [si]		; Load symbol from buffer
	cmp	al, 0			; Check symbol for 0
	je	.error_loop		; Finish printing
	mov	ah, 0x0A		; BIOS symbol printing interrupt
	mov	bh, 0			; Video page number (default = 0)
	mov	cx, 1			; Count of symbols to print
	int	0x10			; Draw symbol at cursor's position
	inc	si			; Move to the next symbol
	mov	ah, 0x02		; BIOS set cursor interrupt
	int	0x10			; Set cursor to DH:DL (row:colomn)
	inc	dx			; Change cursor's position counter
	jmp	.printing_loop		; Exit to infinite loop

	;Infinite error loop
  .error_loop:
	jmp .error_loop

	use32
	; 32 bit code segment
  .protected_mode_enter:
	; Initialize data segments
	mov	ax, gdt_priv_data_segment_index
	mov	ds, ax
	mov	es, ax
	mov	fs, ax
	mov	gs, ax

	; Initialize stack segment and pointer
	mov	ax, gdt_priv_stack_segment_index
	mov	ss, ax
	mov	sp, 0

	; Set directory page table address
	mov	eax, directory_table - config_kernel_virtual_base_address
	mov	cr3, eax

	; Enabling paging mechanism
	mov	eax, cr0
	or	eax, 0x80000000		; Set paging bit
	mov	cr0, eax		; Enable paging

	; Jump from the bootloader code to the main kernel code
	mov	dl, [.boot_disk_id]	; Save boot disk id to DL
	jmp	kernel_enter		; Jump to the main kernel code

	; Data segment
  .processor_error_msg:
	db	"i486 processor or higher is required", 0

  .bios_memory_error_msg:
	db	"BIOS INT 0x15 0xE801 is not supported", 0

  .not_enough_memory_error_msg:
	db	"Not enough memory, check configuration", 0

  .bios_extension_error_msg:
	db	"BIOS LBA extensions are missing", 0

  .lba_read_error_msg:
	db	"hard drive sector read failed", 0

  .boot_disk_id:
	db	?

  .gdt_info:
	dw gdt_size - 1
	dd gdt_start - config_kernel_virtual_base_address

  .lba_read_packet:
	db	0x10			; Size of packet
	db	0			; Always zero
	dw	0x00FF			; Number of sectors to read
	dw	0x0010			; Buffer offset address (0x100000)
	dw	0xFFFF			; Buffer segment address (0x100000)
	dd	1			; LBA address of sector (low)
	dd	0			; LBA address of sector (high)

	rb 	510 - ($ - $$)		; Empty space
	db 	0x55, 0xAA 		; Magic boot number
