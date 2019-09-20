; Constants
page_table_alignment = 0x1000
page_table_page_size = 0x1000
page_table_entries_count = 0x400
page_table_readable_writable_present_flags = 0x03
page_table_user_space_entries_count = config_kernel_virtual_base_address \
	/ page_table_page_size / page_table_entries_count
; Data
align page_table_alignment

directory_table:
	dd 	page_table - config_kernel_virtual_base_address \
			+ page_table_readable_writable_present_flags
	dd 	page_table_user_space_entries_count - 1 dup 0
	dd	page_table - config_kernel_virtual_base_address \
			+ page_table_readable_writable_present_flags
	dd	page_table_entries_count \
		- page_table_user_space_entries_count - 1 dup 0

align page_table_alignment

page_table:
	repeat page_table_entries_count
		dd (% - 1) * page_table_page_size \
			+ page_table_readable_writable_present_flags
	end repeat
