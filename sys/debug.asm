; ARGS: none
create_fake_irq7:
	; To create fake irq7 you must cut any interrupt signal from irq0-irq7
	; before INTA signal from processor will come.
	; To complete this task timer with short count is created to interrupt
	; processor. Dirung enough delay to catch interrupt request from
	; timer, interrupt controller will ask processor for INTA.
	; Meanwhile, interrupts are forbidden, so there won't be INTA signal.
	; Then timer is reloaded with big count to cut off interrupt request to
	; interrupt controller.
	; Then interrupts become enabled, processor send INTA to interrupt
	; controller and halts. But at this moment no irq0 is present, so
	; interrupt controller creates fake irq7.

	; Constants:
	.minimal_count = 0x01
	.maximal_count = 0xFFFF
	.delay_count = 0x1FFFF

	; Code
	cli
	F_CALL	driver_pit_init, \
		driver_pit_interrupt_on_terminal_count_mode, \
		.minimal_count
	mov	ecx, .delay_count
  .wait_for_tick:
	PORT_DELAY
	loop	.wait_for_tick
	F_CALL	driver_pit_init, \
		driver_pit_interrupt_on_terminal_count_mode, \
		.maximal_count
	sti
	hlt
	ret
