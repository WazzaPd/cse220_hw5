# contains readable and executatble data
# instructions
.section .text


.global __start

__start:
	# STDIN = 0
	# STDOUT = 1
	# STDERR = 2
	
	li $v0, 4004
	li $a0, 1
	li $t1, msg
	sw $a1, $t1
	li $a2, 13
	syscall
	

# contains readable and writeable data
# data
.section .data

msg:
.asciiz "Hello World!\n"