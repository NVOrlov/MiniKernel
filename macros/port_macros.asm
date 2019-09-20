DELAY_PORT equ 0x80

macro OUTB_D port_num, data
{
	push	edx
	push	eax
	mov	dx, port_num
	mov	al, data
	out	dx, al
	out	DELAY_PORT, al
	pop	eax
	pop	edx
}

macro INB_D port_num
{
	push	edx
	mov	dx, port_num
	in	al, dx
	out	DELAY_PORT, al
	pop	edx
}

macro PORT_DELAY
{
	out DELAY_PORT, al
}
