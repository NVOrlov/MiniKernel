macro F_CALL func_name, [arguments]
{
  common
	push 	ebp
	mov	ebp, esp
  reverse
	push	arguments
  common
	call	func_name
	leave
}

macro F_ENTER
{
	push	ebp
	mov	ebp, esp
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi
}

macro F_EXIT
{
	pop	edi
	pop	esi
	pop	edx
	pop	ecx
	pop	ebx
	pop	ebp
	ret
}

macro MOV_ARG reg, arg_num
{
	mov	reg, [ebp + 4 * (arg_num + 2)]
}
